# Event Taxonomy

A consistent calendar needs a small, defensible set of categories. Each category has:

1. **A clear purpose** — what kind of time this is
2. **A naming convention** — emoji prefix + short title pattern
3. **A colour** — drawn from the palette
4. **A movability rule** — who can move it, under what conditions

This file defines the default taxonomy. The skill detects existing taxonomy from a calendar and adapts; the defaults here are starting points, not impositions.

---

## Category 1 — Bookend rest (morning + evening)

**Purpose:** Anchor the working day with protected planning + shutdown time. Prevents work bleeding into the entire day; gives a deliberate handoff between "off" and "on".

| Element | Default |
|---|---|
| Morning name | `☀️ Morning planning` |
| Morning slot | 09:00–09:30 weekday |
| Morning colour | **Tangerine (6)** |
| Evening name | `🌙 Wrap up & shut down` |
| Evening slot | 16:30–17:00 weekday |
| Evening colour | **Flamingo (4)** |
| Movable? | **No** — protected. Skill flags overlaps but never moves them. |

**Why two bookends, not one:** the morning slot sets intent; the evening slot enforces a hard stop. A single "planning" slot doesn't give you the shutdown discipline.

---

## Category 2 — Mid-day rest (lunch)

**Purpose:** A protected hour mid-day to eat, step away from the desk, and reset cognitive load. The cost of skipping is paid in the afternoon.

| Element | Default |
|---|---|
| Name | `🥪 Lunch` |
| Slot | 12:00–13:00 weekday |
| Colour | **Banana (5)** |
| Recurrence | `RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR` |
| Movable? | **No** — protected. Flag overlaps. |

**Why Banana:** completes the warm "daily arc" — morning Tangerine → noon Banana → evening Flamingo. Reads as a coherent rhythm on the week view.

---

## Category 3 — Micro-rest (decompress)

**Purpose:** Short (10–15 min) deliberate pauses between cognitively heavy blocks. Different from lunch — these are between-meeting recovery, not a full break.

| Element | Default |
|---|---|
| Name | `🌿 Decompress` |
| Slot | Ad-hoc, 10–15 min, after intense meetings or long focus blocks |
| Colour | **Sage (2)** |
| Recurrence | Usually one-off, occasionally daily |
| Movable? | **No** — protected. Skill colour-codes but does not unilaterally reschedule. |

**Why Sage:** distinct from the warm bookend / lunch palette; visually quiet so it doesn't compete with the warm anchors; thematically fits the 🌿 emoji.

---

## Category 4 — Focus blocks

**Purpose:** Protected deep-work time on a specific objective. Visually receding so meetings and rest blocks stand out.

| Element | Default |
|---|---|
| Name pattern | `Focus: <project or topic>` (e.g., `Focus: Activation PRD`) |
| Slot | Variable, 60–180 min typical |
| Colour | **Graphite (8)** |
| Movable? | **YES** — user-owned, no attendees. Skill proposes moves when they overlap protected rest. |

**Rule:** focus blocks yield to rest blocks. If a focus block overlaps lunch, the focus block moves — not the lunch. Rest blocks are non-negotiable; focus blocks flex around them.

---

## Category 5 — User-organised meetings

**Purpose:** Meetings the user owns (organised, set the agenda).

| Element | Default |
|---|---|
| Name | Free-form |
| Colour | Default (Blueberry 9) — no override |
| Movable? | **Conditionally** — yes, but moving sends attendee notifications. Skill flags rather than moves unless explicitly asked. |

---

## Category 6 — External meetings

**Purpose:** Meetings someone else organised; user is an invitee.

| Element | Default |
|---|---|
| Colour | Default (Blueberry 9) |
| Movable? | **NO** — not the user's to move. Skill flags overlaps and offers user-side workarounds (skip the protected block that day, shift the protected block just for that instance, or ask the organiser manually). |

---

## Detecting an existing taxonomy

When the skill scans a calendar, it does NOT assume the defaults above. It:

1. Identifies recurring events first — those usually encode the user's existing pattern.
2. Reads the `colorId` field on those recurring events.
3. Builds a working taxonomy from what's there: e.g., "the user's morning event is `☕ Coffee` in Lavender — use that as the morning bookend definition for this session."
4. Only falls back to the defaults above for categories the user hasn't yet established.

**Never override an existing established colour without explicit instruction.** If the user's `Focus:` events are all Peacock, do not "fix" them to Graphite. Detect, respect, ask before changing.

---

## Naming convention rationale

The emoji-prefix pattern (`☀️`, `🥪`, `🌿`, `🌙`) is not aesthetic — it's functional:

1. **Scannable on the week view.** Emoji are the first character; you can identify category at a glance without reading the title.
2. **Searchable.** `fullText` search on `☀️` returns all morning blocks. `Lunch` returns lunch. The emoji acts as a stable category tag.
3. **Survives renames.** If you rename `Morning planning` to `AM kickoff`, the ☀️ stays — category identity is preserved.

If the user already uses a different convention (text prefixes like `[FOCUS]`, no emoji at all, etc.), follow theirs. The pattern is a default, not a rule.
