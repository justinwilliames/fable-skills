---
name: context-discipline
description: >
  Context-window economics for long-running agent sessions: keep the orchestrating seat lean,
  push bulk reads into sub-agents, re-triage when scope changes, and hand off cleanly when a
  session degrades. Load at the start of any session likely to exceed a few tool calls, and
  whenever you notice re-reading, re-deriving, or exploration creep. Do NOT use for one-shot
  lookups or single-file edits — the overhead is the anti-pattern there.
---

# Context Discipline

A context window is a workspace, not a warehouse. Sessions degrade not because the model gets
worse but because the seat fills with raw material that should have stayed in a delegate:
whole-file dumps, dead exploration, restated conclusions. The discipline: **conclusions live
in the seat; raw reads live in sub-agents.**

## The seat rules

1. **Delegate reads, keep findings.** When answering requires sweeping many files or sources,
   send a sub-agent and take back its conclusion — not the file contents. A search you've
   delegated, you don't also run yourself.
2. **Never re-derive.** Facts established earlier in the session are settled. Don't re-open
   decisions the user already made; don't re-read files you just edited to "verify" an edit
   the tool already confirmed.
3. **Read the part, not the file.** When you know which section you need from a large file,
   read that range. Whole-file reads of known files are warehouse behaviour.
4. **Act when you can act.** When you have enough to proceed, proceed. Narrating options you
   won't pursue, or summarising what you're "about to do" at length, burns the same tokens as
   doing it.

## Re-triage triggers

The delegation decision is not a one-shot at session start. Re-ask "should this fan out?"
whenever:

- A follow-up adds scope ("also do X", "apply the same to Y" — replication *is* parallelism).
- A tool result reveals the surface is bigger than assumed.
- You're about to read a third file in one turn just to orient (hand the exploration to a
  search agent).
- You catch the thought "this is bigger than I thought" — that thought *is* the trigger.

## Cache-window awareness

Prompt caches have short TTLs (typically ~5 minutes). When waiting on external state, either
poll inside the cache window or commit to a long sleep — a wait just past the TTL pays the
full re-read for no benefit. Never poll for work the harness will notify you about; polling
tracked work is pure waste.

## Handoff — when and how

Hand off to a fresh session when the seat is genuinely polluted or the topic pivots — not as
a reflex. A handoff must be a **self-contained transfer prompt in the chat** (no "go read the
handoff file"), containing:

```
## What was done        — shipped work, confirmed facts, dead ends proven
## Current state        — what exists now, what's live
## Next action          — the single concrete first step
## Open unknowns        — what's unverified, what could break
## Key files            — path + why it matters
## Dead ends            — approach + why it fails (so the next session doesn't retry them)
```

The "Dead ends" section is the most commonly omitted and the most valuable: a fresh session
re-attempting a proven failure is the costliest handoff defect.

## Named failure modes

| Failure mode | What it looks like | Antidote |
|---|---|---|
| **Exploration creep** | Fifth file read "to understand the codebase" before any decision | Delegate the sweep; you need the map, not the terrain |
| **Context hoarding** | Whole files read into the seat "in case" | Read ranges; take conclusions from delegates |
| **Re-derivation** | Recomputing/reconfirming a settled fact | Trust the session record |
| **Double work** | Delegating a search, then also doing it yourself | One owner per question |
| **Poll spinning** | Short sleeps polling harness-tracked work | Wait for the notification |
| **Warehouse handoff** | Handoff prompt is a transcript, not a distillation | The six-section format, tight |
| **Premature handoff** | Suggesting a fresh session at the first sign of length | Handoff on pollution or pivot, not on turn count |

## Related

[operator-standard](../operator-standard/SKILL.md) — the communication discipline the lean
seat exists to serve. [skill-hardening](../skill-hardening/SKILL.md) — applies this economy
rule to skill files themselves (R10).

## Sync home

Sync home: github.com/justinwilliames/skills — canonical. Installed copies (e.g. `~/.claude/skills/context-discipline`) are distribution artifacts: edit the repo, re-copy.
