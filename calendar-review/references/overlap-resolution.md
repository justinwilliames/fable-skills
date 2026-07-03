# Overlap Resolution Playbook

When a protected block (lunch, decompress, morning, wind-down) clashes with another event, the resolution depends on two questions:

1. **Who owns the overlapping event?** (User vs someone else)
2. **Is the overlapping event movable without side effects?** (Focus block vs attendee meeting)

This file is the decision tree.

---

## The decision tree

```
Overlapping event detected with a protected block.
│
├── Is the overlapping event user-owned AND has no other attendees?
│   └── YES → Propose a MOVE of the OVERLAPPING event (the focus block).
│             Protected block stays put.
│             (e.g., focus block 12:30→13:30 becomes 13:00→14:00)
│             Apply on user approval.
│
├── Is the overlapping event user-owned BUT has attendees?
│   └── YES → Run the SLOT-FINDER (below) on the protected block.
│             • If a valid same-day slot exists: auto-propose shifting
│               the protected block (this instance only). Single concrete
│               proposal, not a menu.
│             • If no slot fits: FLAG with three options
│               (move meeting with notification / skip protected block /
│               manually ask attendees).
│             NEVER silently move a meeting with attendees.
│
└── Is the overlapping event organised by someone else?
    └── YES → Run the SLOT-FINDER (below) on the protected block.
              • If a valid same-day slot exists: auto-propose shifting
                the protected block (this instance only).
              • If no slot fits: FLAG with three options
                (skip the block / shift across days / ask organiser to move).
              NEVER move someone else's event.
```

## The slot-finder algorithm

When a protected block must move around a non-movable conflict, find the best alternative slot **on the same day** using these rules in order:

1. **Preserve duration.** A 60-min lunch stays 60 min. A 15-min decompress stays 15 min.
2. **Stay inside working hours.** Default 09:00–17:00 local time. Respect the morning/wind-down bookends as outer bounds — don't push lunch before morning planning or after wind-down.
3. **No other overlaps.** The candidate slot must be free against every other event on that day (meetings, focus blocks, other protected blocks).
4. **Adjacent first, then widen.** Search ±2 hours from the original start time first. Only widen to ±4 hours if nothing fits in the narrow window.
5. **Same-shape preference.** Lunch prefers full-hour starts (12:00 / 13:00 / 14:00) over odd starts (12:15 / 13:45). Decompress is flexible.
6. **Later beats earlier.** Given two equally-valid slots, push **later** in the day. A lunch at 13:00 beats a lunch at 11:00 — preserves the rhythm of "rest in the middle of the day, not before it really started."
7. **Don't collapse protected blocks together.** If shifting lunch to 13:00 would butt against a 13:00 decompress with no gap, find the next valid slot. Rest blocks need air around them.
8. **Don't shift across days.** If no same-day slot works, fall back to flagging — never silently relocate Tuesday lunch to Wednesday.

### Output format when slot-finder succeeds

Single concrete proposal, not a buffet:

> **Tuesday lunch shifts 12:00→13:00 → 13:00→14:00 (avoids HOD Weekly 12:30–13:00). OK?**

Not:

> ~~Tuesday lunch could be at 11:00, 13:00, or 14:30. Which would you prefer?~~

The user should be able to approve with one word ("yes" / "go" / "apply") or counter-propose if the auto-pick is wrong ("no, make it 13:30"). The skill does the thinking; the user confirms.

### Output format when slot-finder fails

Fall back to the three-option flag:

> **Tuesday lunch can't shift cleanly** — every slot 10:00–16:00 already has something. Options:
>
> 1. Skip Tuesday lunch (add EXDATE to the series)
> 2. Take a short break instead (e.g., 15-min decompress at 15:00)
> 3. Ask the meeting organiser to move
>
> Which?

---

## Worked examples

### Example 1 — Focus block overrunning lunch

- **Protected:** 🥪 Lunch Mon 12:00–13:00 (Banana)
- **Overlapping:** `Focus: Activation PRD` Mon 11:00–13:30 (Graphite, user-owned, no attendees)

**Resolution:** Propose moving the focus block to 11:00–12:00 + 13:00–14:00 (split) OR 13:00–15:30 (push) — whichever the user prefers. Apply on approval.

### Example 2 — Colleague's recurring meeting overlapping lunch

- **Protected:** 🥪 Lunch Tue 12:00–13:00 (Banana)
- **Overlapping:** `HOD Weekly meeting` Tue 12:30–13:00 (Blueberry, organised by Jacob, 8 attendees)

**Resolution:** Run the slot-finder on lunch (HOD meeting is untouchable). Tuesday afternoon is free from 13:00–15:00, so the auto-pick is **13:00–14:00** — preserves 60 min, full-hour start, later not earlier, no other overlap.

Present:

> **Tuesday lunch shifts 12:00→13:00 → 13:00→14:00 (avoids HOD Weekly 12:30–13:00). OK?**

Single instance-only change (Tuesday only — Wed/Thu/Fri lunch stays at 12:00). Apply on user approval. If the user counter-proposes ("make it 13:30"), accept and apply.

If Tuesday afternoon were ALSO booked solid, slot-finder fails and the skill falls back to the three-option flag (skip Tue lunch / micro-break instead / ask Jacob to move).

### Example 3 — Focus block overlapping decompress

- **Protected:** 🌿 Decompress Wed 15:30–15:45 (Sage)
- **Overlapping:** `Focus: PRD review` Wed 14:00–16:00 (Graphite, user-owned)

**Resolution:** Propose shortening the focus block to 14:00–15:30 OR splitting to 14:00–15:30 + 15:45–16:00. Note that decompress is short enough that a split is usually preferable to shortening — the user wanted 2 hours of focus, not 90 minutes.

### Example 4 — Wind-down overlapping an external meeting

- **Protected:** 🌙 Wrap up & shut down Thu 16:30–17:00 (Flamingo)
- **Overlapping:** `Vendor demo` Thu 16:00–17:30 (Blueberry, external organiser)

**Resolution:** Run slot-finder. Wind-down is the day's last protected block, so the only valid "later" slot is **17:30–18:00** — that exits the default 09:00–17:00 working window. Two outcomes:

- If the user has allowed slot-finder to push outside working hours (config flag), auto-propose **17:30–18:00**.
- If working hours are strict, slot-finder fails. Fall back to the three-option flag (skip Thursday wind-down / push to 17:30–18:00 / skip the vendor demo).

The wind-down is the protected block that most commonly gets sacrificed for late-day externals — that's expected and not a structural failure. Persistent overlaps with the wind-down slot are a signal to renegotiate the slot itself (move it earlier permanently).

---

## When to apply EXDATEs vs single-instance overrides

If the user wants to skip a protected block on **one specific day**:

- **One-off, recent, won't repeat:** delete the single instance (Google Calendar handles this as an automatic EXDATE)
- **Recurring pattern they want to formalise** (e.g., "I never have lunch on Wednesdays"): add a permanent EXDATE or change the BYDAY rule on the series

**Default behaviour:** instance-only override. Do not change the master series unless the user explicitly says "always" or "never on X days".

---

## Edge cases

### Back-to-back events vs true overlap

- **Back-to-back** (e.g., lunch ends 13:00, meeting starts 13:00 exactly): not an overlap. Do NOT flag.
- **One-minute touch** (e.g., lunch ends 13:00, decompress starts 12:55): treat as overlap. Surface to user.

### Recurring overlaps

If the same recurring meeting overlaps a recurring protected block **every week**:

- Surface this as a structural issue, not a per-instance one.
- Recommend: rename the protected block's slot for that weekday, or accept a recurring EXDATE.

Don't generate five identical "flag this week's Tuesday lunch" alerts. Surface the pattern once.

### Multi-day events overlapping protected blocks

- All-day events (e.g., conferences, OOO): the protected blocks should automatically be skipped for those days. Add EXDATEs automatically when an all-day event is detected.
- Multi-hour events that span lunch (e.g., a 3-hour workshop 11:00–14:00): treat as a single overlap — flag, don't propose splitting the workshop.

### User's own back-to-back blocks

If the user has a focus block 09:30–11:30 and another focus block 11:30–13:00, treat them as one logical block for overlap purposes — moving one in isolation breaks the flow. Surface both together.

---

## What NOT to do

- **Don't propose moving a meeting "by 30 minutes" without saying where it goes.** Always propose specific new times.
- **Don't move events into slots that have other meetings.** Re-check the destination slot before proposing.
- **Don't move events across days** unless the user explicitly asks. "Move my Monday focus block to Tuesday" is a different operation from "resolve this overlap".
- **Don't apply more than one move in a single approval without listing every move first.** If three focus blocks overlap protected slots, show all three proposed moves before mutating any.
- **Don't silently send attendee notifications.** When mutating user-organised events with attendees, pass `notificationLevel: "NONE"` or warn the user that an attendee notification will fire.
