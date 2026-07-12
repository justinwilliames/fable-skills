---
name: session-recall
description: Proactively find and reference the user's OTHER Claude sessions — past conversations, decisions, prior work — WITHOUT asking permission first. Fire whenever the user references work not visible in the current context ("like we did the other day", "the session where we fixed X", "we discussed this before", "didn't we already solve this?", "check my other sessions", "what was that finding from last week"), whenever a task smells like a re-run of prior work, or whenever knowing what a parallel/previous session did would change the plan. Searching is ALWAYS in-bounds — never ask "want me to check your other sessions?"; just check and cite. Do NOT use for memory-layer batch ops, naming sessions, or messaging/archiving other sessions — those writes still require explicit confirmation.
---

# session-recall

Standing rule: **past sessions are context you already have permission to read.** When a
question touches prior work, search first, answer second — asking "should I look?" is the
failure mode this skill exists to kill.

## The recall ladder — run top-down, stop when answered

| Step | Surface | When | How |
|---|---|---|---|
| 1 | Memory index | Already in context every session | Check the auto-memory index before any search — the fact may already be loaded |
| 2 | Desktop session search | `mcp__ccd_session_mgmt__*` tools present (Claude Desktop app) | `search_session_transcripts {query}` → one hit per session + snippet; `list_sessions` to browse by title/recency |
| 3 | Session ledgers/summaries | Your setup maintains per-session summary files (e.g. a hook writing to a ledgers dir) | `rg -il "<term>" <ledgers-dir>/` then read the hits — small files, safe to read whole |
| 4 | Raw transcripts | A prior step gave a session id, or steps 2–3 missed | See "Raw transcript protocol" below — NEVER read a .jsonl whole |

If the later steps all come up dry, say so **naming the surfaces searched** — "no prior
session covered X" is only claimable after ledgers AND transcripts were swept, not after
one search.

## Raw transcript protocol

Transcripts live at `~/.claude/projects/<cwd-slug>/<session-id>.jsonl` — one dir per working
directory, so a fact from another project lives in another slug dir. Files run to 40MB+;
reading one whole poisons the seat.

```bash
# find which sessions mention a term (swap slug for other projects)
rg -l -i "<term>" --glob "*.jsonl" ~/.claude/projects/<cwd-slug>/

# extract just the human-readable conversation from a hit
jq -r 'select(.type=="user" or .type=="assistant") | .message.content
       | if type=="array" then .[] | select(.type=="text") | .text else . end' <file>.jsonl

# context around a specific match without extracting everything
rg -i -C2 "<term>" <file>.jsonl | head -50
```

Bulk sweeps (3+ transcripts, or any file >5MB) → delegate to a read-only search sub-agent;
it returns findings + session ids, not dumps.

## Output contract

Every recalled claim carries its provenance: **session id (short) + date + what surface it
came from**, e.g. "In the 05ae159 session (8 Jul, ledger), we established X." A recalled fact
with no session pointer is an unverifiable vibe — don't ship it.

## Recalled ≠ still true

A past session's facts were true *then*. Before acting on a recalled decision, config value,
or "already fixed" claim, verify it against the live system this session — sessions go stale
the same way reports do. Recall answers *what happened*; it never substitutes for
re-verifying *what is*.

## Named failure modes

| Failure mode | Signal | Antidote |
|---|---|---|
| Permission theatre | "Want me to check your other sessions?" | Just search — reads are pre-authorized by this skill |
| Transcript dump | A .jsonl read whole into context | jq/rg extraction, or a sub-agent for bulk |
| Stub trust | Citing an empty/stub ledger as evidence | A stub proves the session existed, nothing more — drop to the transcript |
| Single-surface "not found" | "No session covered X" after only one search | Sweep ledgers + transcripts before claiming absence |
| Slug blindness | Searching only the current project's transcript dir | Other projects = other slug dirs under ~/.claude/projects/ |
| Recall-as-truth | Acting on a recalled fact without re-verifying | "Recalled ≠ still true" gate above |

## Autonomy calibration

- **Always without asking:** list_sessions, search_session_transcripts, ledger greps,
  transcript rg/jq extraction, sub-agent sweeps. All read-only.
- **Always confirm first:** `send_message` to another session, `archive_session`, or editing
  any ledger/transcript file. Referencing sessions is free; touching them is not.

## Setup — kill the permission prompts too

"Without asking" has two halves: the behavioural rule above, and the harness allowlist. Add
the read-only tools to `permissions.allow` in `~/.claude/settings.json` so the ladder runs
prompt-free:

```json
"mcp__ccd_session_mgmt__list_sessions",
"mcp__ccd_session_mgmt__search_session_transcripts",
"Bash(jq:*)", "Bash(rg:*)", "Bash(grep:*)", "Bash(ls:*)"
```

The desktop search tools only exist in the Claude Desktop app — in plain CLI sessions the
ladder falls through to ledgers + transcripts, which cover everything.

## Sync home

Sync home: canonical = your live private copy; public sanitized twin: ~/code/skills/session-recall → github.com/justinwilliames/skills. Sanitization is a sync step.
