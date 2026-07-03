# calendar-review

A Claude skill for auditing, tidying, and rebalancing a Google Calendar — colour-coding consistency, protected rest blocks (lunch, decompress, morning, wind-down), and overlap resolution between focus time and rest.

Built for use with [Claude Code](https://docs.claude.com/en/docs/claude-code) and any client that supports the [Anthropic skills format](https://docs.claude.com/en/docs/claude-code/skills).

## What it does

Three phases, never skipped:

1. **Scan** — reads the calendar window (default: current week), classifies events by category (bookend rest / mid-day rest / micro-rest / focus / meeting), checks colour coding against the working palette.
2. **Diff** — produces a structured report:
    - **A. Colour drift** — events whose category doesn't match their colour
    - **B. Missing blocks** — protected categories absent from days they should cover
    - **C. Overlaps** — protected blocks intersecting other events, split by movability (your focus blocks → propose move; others' meetings → flag only)
3. **Apply** — only on explicit approval. Recolours, creates recurring blocks, moves focus time around rest. Never auto-moves events you don't own.

**Smart shift when conflicts can't be resolved by moving focus time:** if a protected block (e.g. lunch) clashes with a meeting you don't organise, the skill runs a slot-finder that proposes a concrete single-instance shift for the protected block — same day, same duration, no other overlaps, later beats earlier, full-hour preference for lunch. You get one proposal to approve, not a menu of options. Falls back to a three-option flag only if no valid slot fits.

## Hard rules

- **Read before write.** Always show the diff before mutating.
- **Never auto-move multi-party events.** Colleague-organised meetings are flagged, not moved.
- **Never touch today's slots after they've started.** Starts the new pattern from tomorrow.
- **Recurring scope is explicit.** Asks instance-only vs all-future vs whole-series before changing a recurring event.
- **Timezone discipline.** Always passes an explicit IANA timezone (not just offsets) on create/update.

## Default colour palette

The skill ships with this calibrated palette, but **detects an existing palette on your calendar and uses that** instead. Defaults only apply where you haven't already established a convention.

| Category | Google Calendar colour | `colorId` |
|---|---|---|
| ☀️ Morning planning | Tangerine | `6` |
| 🥪 Lunch | Banana | `5` |
| 🌿 Decompress | Sage | `2` |
| 🌙 Wrap up & shut down | Flamingo | `4` |
| Focus blocks | Graphite | `8` |
| Meetings | Blueberry (default) | `9` |

## When to use

Use this skill when you want to:
- Audit calendar colour consistency across a week
- Add or repair recurring protected blocks (lunch, decompress, focus)
- Resolve overlaps where focus time keeps eating rest time
- Enforce a consistent event taxonomy across the week

Don't use it for:
- Single one-off event creation (use `create_event` directly)
- Multi-party meeting scheduling (use a dedicated scheduler)
- Time-tracking or "where did my time go" analysis (use a self-performance review skill)

## Install

### Claude Code (CLI)

Symlink into your skills directory:

```bash
git clone https://github.com/justinwilliames/claude-skills.git ~/code/claude-skills
cp -R ~/code/claude-skills/calendar-review ~/.claude/skills/calendar-review
```

### Manual

Copy `SKILL.md` and the `references/` directory into `~/.claude/skills/calendar-review/`.

## Requirements

A Google Calendar MCP server that exposes (at minimum):

- `list_calendars`
- `list_events` (with `startTime`, `endTime`, `eventTypeFilter`, `timeZone`, `pageSize`)
- `create_event` (with `recurrenceData` support)
- `update_event` (with `colorId`, `startTime`, `endTime`, `notificationLevel`)

The skill is MCP-server-agnostic — any compliant Google Calendar MCP works.

## References

- [`SKILL.md`](SKILL.md) — main skill definition
- [`references/google-calendar-colours.md`](references/google-calendar-colours.md) — full 11-colour palette with `colorId` mapping
- [`references/event-taxonomy.md`](references/event-taxonomy.md) — category definitions and naming conventions
- [`references/overlap-resolution.md`](references/overlap-resolution.md) — decision tree for resolving overlaps

## License

MIT — see [LICENSE](LICENSE).

## Related skills

- [claude-slack-writer](https://github.com/justinwilliames/claude-slack-writer) — Slack messages, ready to paste
- [claude-self-performance-review](https://github.com/justinwilliames/claude-self-performance-review) — Weekly self-review with evidence pulled from your tools
- [advanced-prd-writer](https://github.com/justinwilliames/advanced-prd-writer) — PRDs and specs grounded in published PM best practice
