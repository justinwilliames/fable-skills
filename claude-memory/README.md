# claude-memory

A Claude Code skill that gives the file-based auto-memory system three things it doesn't have out of the box:

1. **Bidirectional GitHub sync** — your memory follows you across machines, with full diff history.
2. **Cross-project federation** — promote a memory once, see it in every project.
3. **Effectiveness measurement** — track which memories actually get read so you can prune dead weight.

This skill **does not** replace Claude's built-in auto-memory. It sits underneath it as a hygiene layer.

## What gets installed

```
~/.claude/skills/claude-memory/
├── SKILL.md                    # Claude-facing manifest + trigger phrases
├── README.md                   # this file
├── scripts/
│   ├── sync.sh                 # pull + add + commit + push
│   ├── status.sh               # drift report (read-only)
│   ├── doctor.sh               # hygiene audit (read-only)
│   ├── ledger.sh               # session reference tracker
│   ├── promote-global.sh       # per-project ↔ global mover
│   └── install-hooks.sh        # patch settings.json
└── hooks/
    ├── session-start.sh        # background pull on SessionStart
    └── session-stop.sh         # background sync on Stop
```

Plus, after install:
- `~/.claude/memory-global/` — the global tier (created on first promotion).
- `~/.claude/memory-ledger.jsonl` — session reference log (created on first SessionStop).
- `~/.claude/memory-sync.log` — background sync output (rotate if it grows).

## Setup on a fresh machine

```bash
cd ~/.claude
git pull   # ensure skill files are present
bash skills/claude-memory/scripts/install-hooks.sh
bash skills/claude-memory/scripts/install-launchd.sh   # optional: 4×/day backup
```

That's it. The hooks now run automatically — every session pulls on start, syncs + ledgers on stop. With the launchd agent installed, sync also fires at 09:00, 13:00, 17:00, 21:00 local time — useful for files edited outside Claude Code or sessions left open for days.

## Daily use

You don't really need to think about it. The hooks do the work. When you want to inspect:

```bash
# What's drifted?
bash skills/claude-memory/scripts/status.sh

# What's broken?
bash skills/claude-memory/scripts/doctor.sh

# What memories did the last session actually use?
bash skills/claude-memory/scripts/ledger.sh --show-latest 5

# What's never been referenced in 30 days?
bash skills/claude-memory/scripts/ledger.sh --dead --days 30
```

Or just ask Claude in chat:

> "memory status" / "audit my memory" / "show dead memories" / "promote caldwell tier discipline to global"

The skill is registered with trigger phrases so Claude will pick the right script.

## Federation — how the global tier works

A memory becomes global when it ends up in `~/.claude/memory-global/` with `scope: global` in its frontmatter.

`promote-global.sh feedback_caldwell_tier_discipline.md`:

1. Moves the file from its per-cwd memory dir into `memory-global/`.
2. Adds `scope: global` to the frontmatter.
3. Drops a relative symlink `_global_feedback_caldwell_tier_discipline.md` into EVERY per-cwd memory dir.
4. Appends a line to `memory-global/MEMORY-GLOBAL.md`.

Result: the memory file appears, by symlink, in every project's memory dir. Claude's auto-memory loader sees it natively — no special-case handling required.

Undo with `promote-global.sh --demote <filename>`.

### When to promote

A memory should go global when **it would still be true and useful in a project Claude has never seen before**. Examples that *should* be global:

- Voice and tone rules (apply across all your projects)
- Spelling rules (product names, brand terms)
- User identity facts (GitHub username, appearance)
- Cross-cutting domain knowledge (Stripo API quirks — applies to any project using Stripo)

A memory should stay per-project when **it only makes sense in the context of that codebase**. Examples that should stay local:

- "Orion is Orbit's dock sprite" (Orbit-specific)
- "Project-X campaign states" (only meaningful in project-x codebase)
- Per-project conventions, file paths, internal architecture notes

When in doubt, leave it per-project. The skill won't break if it's wrong — promotion and demotion are both one-line operations.

## The ledger

Every SessionStop hook appends a line like this to `~/.claude/memory-ledger.jsonl`:

```json
{"session_id":"abc-123","date":"2026-05-14","cwd":"/your/project/path","files_referenced":["feedback_voice_convention.md","reference_api_quirks.md"]}
```

Over 30 days that's enough data to know which memories pay for themselves and which are tax on every MEMORY.md load. `doctor.sh --ledger 30` and `ledger.sh --dead --days 30` use it.

The ledger is **excluded from git** by default (privacy). If you want it tracked, un-ignore `memory-ledger.jsonl` in `.gitignore`.

## Uninstall

```bash
bash ~/.claude/skills/claude-memory/scripts/install-hooks.sh --uninstall
bash ~/.claude/skills/claude-memory/scripts/install-launchd.sh --uninstall
```

The first removes the SessionStart/Stop entries from settings.json. The second unloads the launchd agent and deletes its plist. Neither touches the skill files, the ledger, or the memory-global tier.

## The two automated sync triggers

| Trigger | Fires when | What it catches |
|---|---|---|
| `SessionStop` hook | Every Claude Code session close | Memory + skill changes from active Claude sessions |
| `launchd` agent | 09:00, 13:00, 17:00, 21:00 local | Files edited outside Claude Code, sessions left open for days, plans/settings/agents dirty without memory churn |

Belt and braces. If one fails to fire, the other catches it. Both call the same `sync.sh` so behaviour is consistent.

## Why this exists

The stock auto-memory is good: file-based, lazy-loaded, indexed in MEMORY.md, scoped per-cwd. What it doesn't do:

- Sync across machines (file lives in `~/.claude` only)
- Survive a machine wipe (no backup primitive)
- Federate cross-project (cwd-scoped storage)
- Measure effectiveness (no read tracking)

This skill adds those four capabilities without replacing or restructuring what already works.

## License

Personal use. Not packaged for distribution.
