---
name: claude-memory
description: Operate on the file-based auto-memory system at ~/.claude/memory + per-project memory dirs. Use when the user says "sync my memory", "back up memory", "what's in memory", "show memory drift", "promote this to global memory", "audit memory", "prune memory", "what memories haven't been used", "memory doctor", or any request to inspect, sync, federate, or hygiene the persistent memory layer. Read-only by default; mutating commands (sync, prune, promote) require explicit user trigger. Provides bidirectional sync with a private GitHub backup repo, cross-project federation via a memory-global tier, and a lightweight ledger of which memories actually got referenced per session.
---

# claude-memory

A skill for managing the file-based memory layer that sits underneath Claude's auto-memory system. Wraps the existing convention with **sync, federation, hygiene, and effectiveness measurement** without changing how the auto-memory itself works.

## Mental model

```
┌─────────────────────────────────────────────────────────────────┐
│  ~/.claude/  (git working tree → your private backup repo)       │
│                                                                  │
│  projects/<cwd-hash>/memory/                                     │
│      ├── MEMORY.md              ← per-cwd index (auto-loaded)    │
│      ├── feedback_*.md          ← per-cwd memory bodies          │
│      └── _global_*.md           ← symlinks to memory-global/     │
│                                                                  │
│  memory-global/                                                  │
│      ├── MEMORY-GLOBAL.md       ← cross-project index            │
│      └── *.md                   ← real files (symlink targets)   │
│                                                                  │
│  memory-ledger.jsonl            ← one line per session             │
└─────────────────────────────────────────────────────────────────┘
```

Three things this skill adds to the stock auto-memory:

1. **Sync** — bidirectional with your private backup repo on GitHub. SessionStart pulls, SessionStop commits + pushes.
2. **Federation** — `memory-global/` tier with files symlinked into every per-cwd memory dir, so cross-cutting facts follow you between projects.
3. **Ledger + doctor** — track which memories actually get referenced per session; surface dead weight + broken references.

## Triggers

Invoke the appropriate script when the user says:

| Trigger phrase | Run |
|---|---|
| "sync my memory" / "back up memory" / "push memory" | `scripts/sync.sh` |
| "memory status" / "show memory drift" / "what's pending" | `scripts/status.sh` |
| "audit memory" / "memory doctor" / "find dead memories" | `scripts/doctor.sh` |
| "promote X to global" / "make X global" | `scripts/promote-global.sh <file>` |
| "demote X from global" / "make X per-project" | `scripts/promote-global.sh --demote <file>` |
| "install memory hooks" / "wire up memory sync" | `scripts/install-hooks.sh` |
| "set up daily backup" / "install launchd agent" / "schedule the sync" | `scripts/install-launchd.sh` |
| "is the daily backup running" / "launchd status" | `scripts/install-launchd.sh --status` |
| "what memories did this session use" | `scripts/ledger.sh --show-latest` |
| "show dead memories" / "what's never referenced" | `scripts/ledger.sh --dead --days 30` |

All scripts are idempotent and safe to re-run. `sync.sh` and `promote-global.sh` are the only mutating ones.

## Operating principles

- **The auto-memory file convention is sacred.** Frontmatter format, MEMORY.md index style, naming patterns — none of this changes. The skill operates on top.
- **Federation is opt-in per file.** Memories don't auto-promote. Either the user says "promote X" or Claude offers to promote when a memory is clearly cross-cutting.
- **Read-only by default.** Status, doctor, and ledger touch nothing. Sync and promote-global mutate but always show a dry-run summary first when run interactively.
- **No silent commits.** Every sync produces a commit message describing what changed in operator terms — "add memory: stripo button-text binding", "promote to global: pulsar tier discipline".

## When NOT to use this skill

- Writing or reading individual memories during a session — the auto-memory system handles that natively. This skill is for **batch operations on the memory layer**.
- Consolidating duplicate memories — use `anthropic-skills:consolidate-memory` instead.
- General Claude Code setup backup — use your backup repo's README directly.

## Federation conventions

A file becomes global when it has `scope: global` in its frontmatter AND lives in `~/.claude/memory-global/`. The skill enforces both:

```markdown
---
name: my-convention-name
description: One-line description of what this memory encodes.
type: feedback
scope: global
---
```

`promote-global.sh feedback_my_convention_name.md` does the rest:
1. Adds `scope: global` to frontmatter
2. Moves the file from per-cwd memory dir to `memory-global/`
3. Creates a symlink back at `_global_feedback_my_convention_name.md`
4. Appends an entry to `memory-global/MEMORY-GLOBAL.md`
5. Symlinks the file into every other tracked per-cwd memory dir (so it appears in all your projects)

## Ledger format

`~/.claude/memory-ledger.jsonl` — one line per session:

```json
{"session_id":"abc-123","date":"2026-05-14","cwd":"/your/project/path","files_referenced":["feedback_voice_convention.md","reference_api_quirks.md"],"files_written":["feedback_new_thing.md"]}
```

`doctor.sh --ledger 30d` aggregates the last 30 days and surfaces:
- Memories never referenced (candidates for deletion)
- Memories referenced 10+ times (candidates for global promotion)
- Memories that grew in size but get no reads (candidates for trimming)

## Install + restore

First-time setup on a fresh machine:

```bash
cd ~/.claude
bash skills/claude-memory/scripts/install-hooks.sh
```

This patches `~/.claude/settings.json` to add the SessionStart pull + SessionStop sync hooks alongside any existing hooks. Idempotent — re-running it does nothing if already installed.

**Preflight:** run `ls {base}/scripts/*.sh` before first invocation. If scripts are missing, stop and tell the user to reinstall the skill.

To uninstall: `bash skills/claude-memory/scripts/install-hooks.sh --uninstall`.

## Sync home

Sync home: canonical = your live private copy; public sanitized twin: ~/code/skills/claude-memory → github.com/justinwilliames/skills. Sanitization is a sync step.
