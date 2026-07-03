---
name: calendar-review
description: >
  Use this skill whenever the user wants to audit, tidy, colour-code, or rebalance their Google Calendar — including weekly calendar reviews, enforcing consistent colour-coding across event categories (bookend / rest / focus / meeting), creating or repairing recurring protected blocks (morning planning, lunch, decompress, wind-down), and resolving overlaps between focus time and protected rest blocks. Trigger on phrases like "review my calendar", "tidy my calendar", "audit my calendar", "calendar review", "fix my calendar colours", "make sure my decompression events are colour coded", "add a lunch hour every weekday", "move my focus times around X", "weekly calendar tidy", "stop my focus blocks eating my lunch", "fix overlaps". The skill is read-first, write-on-approval — it produces a structured diff (what's wrong, what to change, what's flagged for the user to decide) BEFORE mutating any event. It NEVER unilaterally moves or cancels events the user does not own (meetings organised by colleagues). Output must be ready to apply with a single "go" from the user.
---

# Calendar Review Skill

Audit and tidy a Google Calendar so that **rest blocks are protected**, **colour coding is consistent**, and **focus time doesn't silently overrun lunch, decompression, or end-of-day wind-down**.

The skill operates in three phases — **Scan**, **Diff**, **Apply** — and never skips straight to mutating events. Calendar changes are high-blast-radius: a deleted recurring event, a moved meeting that pinged colleagues, a colour overwrite on something the user actually liked — all painful to reverse. So: produce the plan, get approval, then act.

---

## Behaviour — what to do on invocation

### Step 0 — Confirm scope

If the user has not said which window to review, ask:

- **This week** (default) — Monday → Friday of the current ISO week
- **Next week**
- **A custom range** (e.g., "next two weeks", "May 18 → May 31")

Default to **this week** if the user is impatient or the request is ambient ("tidy my calendar"). Confirm timezone — almost always the user's primary calendar timezone, but ask if events span travel.

### Step 1 — Scan

Use the Google Calendar MCP `list_events` tool (or equivalent) with:

- `startTime` / `endTime` covering the chosen window
- `eventTypeFilter: ["default", "focusTime", "outOfOffice"]`
- `timeZone` matching the user's primary timezone
- `pageSize: 250` (raise pagination if needed)

For each event captured, record:

| Field | Why it matters |
|---|---|
| `summary` | Identifies category (bookend / rest / focus / meeting) |
| `start` / `end` | Drives overlap detection |
| `colorId` | Drives colour-coding audit |
| `recurringEventId` | Distinguishes single-instance edits from series edits |
| `organizer.email` vs user's email | Distinguishes **user-owned** (movable) from **other-owned** (flag-only) |
| `attendees` | Confirms multi-party events (don't move unilaterally) |

### Step 2 — Classify

Match each event to one of these categories using `summary` keywords + emoji prefixes:

| Category | Default identifiers | Default colour | Movable? |
|---|---|---|---|
| **Morning bookend** | `☀️ Morning planning`, "morning catch up", "AM standup-self" | **Tangerine (6)** | No — protected |
| **Evening bookend** | `🌙 Wrap up & shut down`, "wind down", "EOD shutdown" | **Flamingo (4)** | No — protected |
| **Mid-day rest** | `🥪 Lunch`, "lunch", "midday break" | **Banana (5)** | No — protected |
| **Micro-rest** | `🌿 Decompress`, "breather", "reset" | **Sage (2)** | No — protected |
| **Focus block** | `Focus:`, "deep work", "focus time" | **Graphite (8)** | **Yes** — owner is user |
| **User-organised meeting** | Has attendees, user is organizer | Default (Blueberry 9) | Conditionally — needs notice to attendees |
| **External meeting** | User is invitee, organizer is someone else | Default (Blueberry 9) | **No** — flag only |

These are **defaults**. The user can override category-to-colour mapping in the conversation; carry overrides for the session.

### Step 3 — Diff

Build a structured diff with three sections:

**A. Colour drift** — events whose category doesn't match their assigned colour. Example: a 🌿 Decompress event with no colour set, or a `Focus: …` block in Banana.

**B. Missing protected blocks** — categories the user has indicated should exist that are absent on one or more days. Example: lunch is set Mon/Tue/Wed but missing Thu/Fri.

**C. Overlap conflicts** — protected blocks (lunch, decompress, morning, wind-down) that intersect with another event. Split into:

- **User-owned movable** — Focus blocks owned by the user that eat into a protected block. **Propose a move** of the focus block. Protected block stays put.
- **Other-owned / multi-party** — meetings organised by colleagues that clash. The meeting is non-movable, so the skill **auto-proposes a shifted slot for the protected block** (just that instance) using the slot-finder algorithm below. Present one concrete proposal, not a buffet. The user approves, rejects, or asks for a different time.

Present the diff as a markdown table per section. Do not bundle them — the user needs to see each class separately.

#### Slot-finder algorithm (for shifting a protected block this-instance-only)

When a protected block needs to move around a non-movable event, find the best alternative slot the **same day** using these rules, in order:

1. **Same duration** — preserve the block's original length (60 min lunch stays 60 min, 15 min decompress stays 15 min).
2. **Within working hours** — default 09:00–17:00 local time; respect any morning/wind-down bookends as outer bounds.
3. **No other overlaps** — the proposed slot must be free against every other event on that day.
4. **Adjacent to the original window** — search ±2 hours from the original start time first; widen to ±4 only if nothing fits.
5. **Same-shape preference for lunch** — lunch prefers landing on a full hour (12:00, 13:00, 14:00) over odd starts (12:15, 13:45).
6. **Later beats earlier** — given two equally-valid slots, push later. A lunch at 13:00 beats a lunch at 11:00; a decompress after the meeting beats a decompress before it.
7. **Never collapse two protected blocks together** — if shifting lunch to 13:00 would butt against a 13:00 decompress, find the next valid slot.

If the algorithm finds **no valid slot**, fall back to flagging — present the four manual options:
1. **Skip the block for this day** — acknowledge the gap and move on.
2. **Shift the block to another day this week** — propose the specific day and slot where the block does fit, and document the exception (e.g. "Tuesday lunch moved to Thursday 12:00–13:00 — HOD Weekly conflict"). If taken, add a note to the apply-pass output so there's a record.
3. **Ask the organiser to move the meeting** — only viable for user-organised or flexible external meetings.
4. **Accept the day without this block** — no rescheduling, just note the calendar gap in the summary.

When a valid slot is found, present as: **"Tuesday lunch shifts 12:00→13:00 → 13:00→14:00 (avoids HOD Weekly 12:30–13:00). OK?"** — one concrete shift, not a menu.

### Step 4 — Apply (only on explicit approval)

After presenting the diff, ask: **"Apply all? Or pick which to apply?"**

When applying:

- **Colour fixes**: `update_event` with `colorId`. Run in parallel where possible (independent events).
- **New recurring blocks**: `create_event` with `recurrenceData: ["RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"]` (adjust BYDAY as needed). Set the timezone explicitly — do not rely on offset suffixes alone for recurring events.
- **Moves of user-owned focus blocks**: `update_event` with new `startTime` / `endTime`.
- **NEVER**: `update_event` or `delete_event` on a multi-party event the user does not organise.

After the apply pass, summarise:

- What was changed (count by category)
- What was **not** changed and why (the flagged-only items, with a clear next-step prompt for the user)

---

## Hard rules — non-negotiable

1. **Read before write.** Always run Scan + Diff before any mutation. No exceptions, even for "just fix the colours" — colour fixes still need a confirm pass because the wrong category mapping is a real failure mode.
2. **Never auto-move multi-party events.** If a colleague organised it or attendees exist beyond the user, flag it and let the user decide.
3. **Never touch today's slots after they've started.** If the user runs the skill at 14:00 and lunch would have been 12:00–13:00, do NOT retroactively create or move today's lunch. Start the new pattern from tomorrow (or the next valid weekday).
4. **Recurring events: clarify scope.** When moving or recolouring a recurring event, ask whether the change applies to (a) just this instance, (b) this and all future, or (c) the whole series. Default to (a) if the user is silent — it's the least destructive.
5. **No silent series replacement.** If a lunch series already exists and the user asks for lunch, surface the existing one. Do not create a duplicate.
6. **Timezone discipline.** Always pass an explicit IANA timezone (e.g., `Australia/Brisbane`) on create/update. Offset suffixes alone (`+10:00`) drift around DST.
7. **One-off "skip today" allowance.** If a recurring protected block clashes with a meeting the user can't move and the user says "skip this Tuesday", create an EXDATE on the series rather than deleting the instance.

---

## Failure modes — actively scan for these

| Mode | What it looks like | Fix |
|---|---|---|
| **Silent colour overwrite** | Skill recolours something the user had deliberately styled differently. | Always show the colour diff before applying. List each event by name with old → new colour. |
| **Recurring-series accident** | User asks for a single colour change; skill recolours the whole series. | Default to instance-only; confirm before touching the series. |
| **Doubled lunch** | Skill creates a new lunch series without checking for an existing one. | Run a `summary` search for "lunch" in the window before creating. |
| **Phantom block** | Skill creates lunch on a public holiday or vacation day. | Cross-check against `outOfOffice` events; skip those days. |
| **Eating an external meeting** | Skill moves a user-owned focus block into a slot already booked by an external meeting. | Re-check the destination slot is empty before issuing the move. |
| **Recurrence + DST drift** | RRULE created with offset-only times shifts an hour when DST flips. | Always set `timeZone` field, not just the offset in the timestamp. |
| **Surprise notification storm** | Skill updates an event with attendees, triggers email notifications. | Pass `notificationLevel: "NONE"` when mutating user-organised events that don't need to ping attendees. |
| **Colour mismatch with established taxonomy** | Skill applies a new colour to one event in a series, leaving the rest of the series another colour. | When recolouring, recolour the whole series if all instances drift the same way. |

---

## Default colour palette — user-overridable

The skill ships with these defaults (calibrated against the original user's working pattern):

| Event category | Google Calendar `colorId` | Colour name | Rationale |
|---|---|---|---|
| Morning bookend | `6` | Tangerine | Warm, energetic, day-start |
| Lunch | `5` | Banana | Warm midday — completes morning → noon → evening arc |
| Wind-down | `4` | Flamingo | Warm soft pink — day-end calm |
| Decompress | `2` | Sage | Green / nature — distinct from warm bookends |
| Focus block | `8` | Graphite | Visually receding — lets meetings stand out |
| User-organised meeting | (no colour) | Blueberry (default) | Standard calendar colour |
| External meeting | (no colour) | Blueberry (default) | Same |

If the user has a different palette already in use, **detect it from the existing recurring events** during Scan and use that as the working palette for the session. Do not impose the defaults on a calendar that already has its own consistent coding.

See [`references/google-calendar-colours.md`](references/google-calendar-colours.md) for the full 11-colour palette and ID mapping.

---

## Output format — what the user sees

### Scan summary (one paragraph)

> Reviewed your calendar Mon 18 May → Fri 22 May. Found 24 events: 5 morning bookends ✓, 5 wind-downs ✓, 4 decompress (drift), 0 lunch (missing), 6 focus blocks (2 overlap protected slots), 5 external meetings (1 overlap).

### Diff table (per section)

#### A. Colour drift

| Event | When | Current colour | Should be | Why |
|---|---|---|---|---|
| 🌿 Decompress | Mon 12:30 | (default Blueberry) | Sage (2) | Matches decompress taxonomy |
| 🌿 Decompress | Mon 16:00 | (default Blueberry) | Sage (2) | Matches decompress taxonomy |

#### B. Missing blocks

| Block | Days missing | Proposed slot | Colour |
|---|---|---|---|
| 🥪 Lunch | Mon–Fri (entire week) | 12:00–13:00 | Banana (5) |

#### C. Overlaps

| Protected block | Overlapping event | Owner | Action |
|---|---|---|---|
| 🥪 Lunch Mon 12:00–13:00 | Focus: Activation PRD 12:30–14:00 | You | **Propose move:** Focus → 13:00–14:30 (lunch stays) |
| 🥪 Lunch Tue 12:00–13:00 | HOD Weekly 12:30–13:00 | Jacob | **Auto-shift lunch (Tue only):** 13:00–14:00 (slot is free; preserves 60 min; pushes later not earlier) |

### Closing prompt

> Apply all? Or which sections (A / B / C)?

---

## What this skill is NOT

- **Not a scheduling assistant.** It does not find optimal meeting slots, propose times across multiple calendars, or handle invitations. Use the native calendar UI or a dedicated tool for that.
- **Not a time-tracker.** It audits structure, not time allocation. For "where did my time go this week" analysis, use a self-performance review skill.
- **Not a personality.** It does not editorialise on the user's calendar habits ("you're working too much" / "you have no rest"). It surfaces structural inconsistencies and lets the user decide.
- **Not a CRM integration.** It does not push events from external systems (HubSpot, Salesforce) into the calendar. That's a different problem.

---

## When to invoke vs not

**Invoke when:**
- User asks for a calendar review, audit, tidy, or weekly check
- User wants to add or repair recurring protected blocks (lunch, decompress, focus time)
- User wants colour-coding enforced or repaired
- User flags overlaps ("my focus blocks keep eating my lunch")
- User wants to apply a new event category convention across the week

**Do NOT invoke for:**
- Single one-off event creation ("schedule a meeting with Jane tomorrow at 2pm") — use `create_event` directly
- Calendar exports / reports — use a reporting tool
- Meeting scheduling across multiple parties — use a dedicated scheduler

---

## Companion references

- [`references/google-calendar-colours.md`](references/google-calendar-colours.md) — Full 11-colour palette with `colorId` mapping
- [`references/event-taxonomy.md`](references/event-taxonomy.md) — Default category definitions (bookend / rest / focus / meeting) and recommended naming conventions
- [`references/overlap-resolution.md`](references/overlap-resolution.md) — Decision tree for resolving overlaps based on event ownership and movability

## Sync homes

Canonical: ~/.claude/skills/calendar-review (private, live). Public sanitized twin: ~/code/claude-skills/calendar-review → github.com/justinwilliames/claude-skills. Sanitization is a sync step — never push private names/paths.
