# Google Calendar Colour Palette

Google Calendar exposes 11 event colours via the `colorId` field (string, `"1"` through `"11"`). These map to fixed names in the Google Calendar UI — the names cannot be customised, but you can override the display swatch globally in account settings.

## Full palette

| `colorId` | Name | Hex (approximate) | Hue family | Typical use |
|---|---|---|---|---|
| `1` | Lavender | `#7986cb` | Cool / soft blue-purple | Personal, soft-touch events |
| `2` | Sage | `#33b679` | Green / nature | Decompress, rest, outdoors |
| `3` | Grape | `#8e24aa` | Deep purple | Strategic, high-stakes |
| `4` | Flamingo | `#e67c73` | Warm pink-coral | Day-end, soft wind-down |
| `5` | Banana | `#f6c026` | Warm yellow | Midday, lunch, energy |
| `6` | Tangerine | `#f5511d` | Warm orange | Day-start, morning |
| `7` | Peacock | `#039be5` | Cool teal-blue | Default-ish, collaborative |
| `8` | Graphite | `#616161` | Neutral grey | Focus blocks, low-emphasis |
| `9` | Blueberry | `#3f51b5` | Cool blue (calendar default) | Standard meetings, default |
| `10` | Basil | `#0b8043` | Deep green | Long-form work, projects |
| `11` | Tomato | `#d50000` | Red | Urgent, blockers, do-not-disturb |

Source: Google Calendar API `colors().get()` reference + UI inspection.

## Recommended pairings

### Warm "daily arc" palette
Use this when you want morning → noon → evening to read as a temperature gradient.

- Morning: **Tangerine (6)** — bright orange day-start
- Midday: **Banana (5)** — warm yellow lunch
- Evening: **Flamingo (4)** — soft coral wind-down

### Cool "work blocks" palette
Use this to distinguish work types without competing with the warm rest palette.

- Deep focus: **Graphite (8)** — neutral, recedes visually
- Long-form project: **Basil (10)** — deeper, more weight
- Strategic / high-stakes: **Grape (3)** — visual emphasis without being alarming

### Rest / break palette
- Decompress / micro-break: **Sage (2)** — green, distinct from warm bookends
- Personal / soft: **Lavender (1)** — cool, low-key

### Alert palette
- Urgent: **Tomato (11)** — use sparingly; loses meaning if overused
- Default meetings: **Blueberry (9)** — leave as-is for most events

## Anti-patterns

- **Don't paint everything.** Overcoloured calendars become visual noise. Default Blueberry is fine for the bulk of meetings — colour is for categories that benefit from being scannable.
- **Don't reuse warm colours for unrelated categories.** If Tangerine is "morning", don't also use it for "urgent". Pick one meaning per colour.
- **Don't use Tomato (11) for routine events.** It anchors your attention and dilutes when something is genuinely urgent.
- **Don't use Graphite (8) for events you want to attend.** It's designed to recede — works for focus blocks (you respect them, but they don't grab the eye); does not work for important meetings.

## Setting colours via the API

When calling `update_event` or `create_event`, pass `colorId` as a **string**, not an integer:

```json
{ "colorId": "5" }   // ✓ correct
{ "colorId": 5 }     // ✗ rejected
```

To remove a custom colour and revert to the calendar default (Blueberry), omit `colorId` on create, or set it to an empty string on update (behaviour varies by client — test before relying on it).
