# claude-infinite-working-skill

A [Claude Code](https://claude.com/claude-code) skill that drives any long-running,
decomposable task to completion **unattended** — surviving usage limits, crashes,
and closed sessions. Nothing is ever redone on re-entry, and irreversible actions
always halt for a human.

## The idea

Long autonomous runs fail in three boring ways: the model hits a usage limit, the
session crashes, or the laptop closes. This skill makes a task resilient to all
three by separating **what to do** (a per-task state file + playbook) from **the
engine that keeps doing it** (a self-paced loop plus a durable resumer). The skill
itself is **program-agnostic** — it contains nothing about any specific task.

### Surviving usage limits, without guessing

You do not try to detect the limit or parse a reset time — that is fragile, because
the limit blocks the very turn that would do the detecting. Instead a durable
resumer re-attempts on a cadence; while usage is exhausted it makes no progress,
and the moment the window resets the next attempt succeeds and resumes. **The
attempt is the check.**

## The four pieces

| Piece | Mechanism | Role |
|-------|-----------|------|
| **State file** | JSON via `scripts/worklog.sh` | Per-task source of truth: status, phases, idempotency ledger, heartbeat, next action, playbook path. |
| **Playbook** | A per-task markdown file | All task-specific steps, paths, IDs, idempotency rules, approval gates. Keeps the skill agnostic. |
| **In-session loop** | `ScheduleWakeup` | While alive and within usage: do the next unit, stamp the heartbeat, re-arm. |
| **Generic resumer** | one `scheduled-task` reading a registry | Fires on a cadence, takes over any task whose heartbeat has gone stale (a *heartbeat handoff*). Zero task content. |

## Install

This skill follows the symlink convention:

```sh
git clone https://github.com/justinwilliames/claude-infinite-working-skill ~/code/claude-infinite-working-skill
ln -s ~/code/claude-infinite-working-skill ~/.claude/skills/infinite-working-skill
```

Then invoke it from Claude Code with `/infinite-working-skill` (or describe an
unattended, long-running task — "keep working on this without me", "loop until
done", "resume if usage resets").

## Safety rails

- **Approval gates halt, never fire.** Posting, sending, deleting production data,
  `git push` — anything irreversible — sets the task `blocked` and notifies, rather
  than acting autonomously.
- **Idempotency before every mutating unit.** No ledger check, no mutation.
- **Runaway guards.** Max-iteration and consecutive-failure caps both trip to `blocked`.
- **One shared resumer.** It serves every registered task; the skill never bakes in
  a specific program.

## Files

- `SKILL.md` — the skill definition and operating protocol.
- `scripts/worklog.sh` — the state-machine helper (init, heartbeat, ledger, phases,
  registry, resume decision). Portable bash + `jq`.

## Notes

`registry.tsv` (the list of active tasks the resumer scans) is runtime state and is
git-ignored — it holds machine-specific absolute paths, not skill code.
