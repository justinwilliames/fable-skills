---
name: infinite-working-skill
description: >-
  Set up an autonomous, self-resuming work loop for any long-running,
  decomposable task so it keeps making progress unattended — surviving usage
  limits, crashes, and closed sessions. Trigger on "work on this infinitely",
  "keep working without me", "run this unattended", "loop until done",
  "autonomous mode", "don't stop until it's finished", "resume automatically if
  usage resets", "keep going while I'm away", "infinite working", or any request
  to drive a multi-step task to completion with no human babysitting. Combines a
  self-paced in-session loop (ScheduleWakeup), ONE program-agnostic durable
  resumer that re-checks a task registry on a cadence and takes over any task
  whose live loop has stalled (heartbeat handoff), an idempotency ledger so
  nothing is ever redone on re-entry, optional periodic checkpoint/save actions,
  and hard approval gates so irreversible or external actions (posting, sending,
  deleting, pushing) halt for the user instead of firing autonomously.
---

# Infinite Working Skill

Drive a long-running, multi-step task to completion **unattended**. Keep working
turn-after-turn while the user is away, and — the load-bearing bit — **survive
usage limits**: if the model runs out of usage mid-task, a durable resumer keeps
re-attempting on a cadence and picks the work back up the moment usage resets.
Nothing is ever redone, because every completed unit is recorded in an
idempotency ledger that re-entry consults first.

**The skill is program-agnostic.** It contains nothing about any specific task.
Everything task-specific — phases, IDs, paths, idempotency rules, approval gates,
how to do each step — lives in the task's **state file** and its **playbook**.
A single generic resumer serves every registered task.

`{base}` = this skill's directory (resolved automatically when the skill loads). Throughout, `WL={base}/scripts/worklog.sh` — the `{base}` placeholder resolves to the skill's absolute path, so `WL` always points to the correct worklog.sh regardless of where the skill is installed.

## When to use it

Use it when ALL of these hold:
- The task is **decomposable** into discrete units (compose N emails, migrate N
  files, process N records, wire N steps).
- Each unit is **idempotent or can be made so** — you can tell, *on disk*,
  whether a unit is already done and skip it.
- The task will plausibly **outlast one sitting** (long, or likely to hit a usage
  limit) and the user wants progress without babysitting.

Do NOT use it for one-shot tasks, conversational replies, or work where every
step needs human judgement.

## The four pieces

| Piece | Mechanism | Role |
|-------|-----------|------|
| **State file (brain)** | JSON via `scripts/worklog.sh` | Per-task source of truth: status, phases, idempotency ledger, heartbeat, next action, `playbook_path`. Re-entry reads this first. |
| **Playbook (the how)** | A per-task markdown file the state file points at | All task-specific instructions, paths, IDs, idempotency rules, approval gates. This — not the skill — holds the program detail. |
| **In-session loop (driver)** | `ScheduleWakeup` each turn | While the session is alive and usage is available: do the next unit, stamp the heartbeat, re-arm. Fast and warm. |
| **Generic resumer (net)** | ONE `mcp__scheduled-tasks` task that reads the registry | Fires on a cadence, iterates ALL registered tasks, and via a **heartbeat handoff** takes over only those whose live loop has stalled (usage limit, crash, closed app). Contains zero task specifics. |

### How usage-limit survival actually works

Do **not** try to detect the limit or parse a reset time — that is fragile, since
the limit blocks the very turn that would do the detecting. Instead:

1. When usage is exhausted, the live loop's turn is blocked → the heartbeat goes
   **stale**.
2. The resumer keeps firing on its cadence. While usage is still exhausted its own
   attempt is *also* blocked (same account), so it makes no progress and the
   heartbeat stays stale — no harm, no duplicate work.
3. Once the rolling window **resets**, the next resumer fire succeeds, sees the
   stale heartbeat, and resumes from `next_action`, honouring the ledger.

**The attempt is the check.** A steady cadence of idempotent re-attempts beats
timing the reset. Optional fast-path: if a reset time *is* visible, additionally
schedule a one-shot `fireAt` a few minutes after it.

## Setup (once per task)

1. **State-file path** under the project, e.g. `<project>/.worklog/<task-id>.json`.
2. **Init:** `bash $WL init <file> <task-id> "<title>"`
3. **Write the playbook** — a markdown file holding everything task-specific (per
   phase: what to do, exact paths/IDs, the idempotency check, approval gates).
   Then point the state file at it: `bash $WL playbook-set <file> <playbook-path>`.
   This is what keeps the skill agnostic: a cold resumer reads the playbook, not
   the skill, to learn the task.
4. **Configure** knobs (defaults shown):
   - `heartbeat_stale_seconds=1500` — stale window before takeover. Must exceed
     your ScheduleWakeup interval + longest expected turn time; 1200 is a tight
     race against the default wakeup cadence, so default to 1500 or higher.
   - `max_iterations=1000`, `max_consecutive_failures=4` — runaway guards.
   - `checkpoint_every_seconds=0` + `checkpoint_action="..."` — periodic save.
5. **Declare phases:** `bash $WL phase-set <file> <id> <status> "[note]"`.
6. **Record approval gates** in the playbook AND as a state note: actions that
   must STOP for the user (post, send, delete prod, `git push`).
7. **Register the task:** `bash $WL register <file>` (adds it to the registry the
   generic resumer scans).
8. **Ensure the ONE generic resumer exists** — never create a per-task resumer:
   - `mcp__scheduled-tasks__list_scheduled_tasks` → if `infinite-working-skill-resumer`
     exists, reuse it (do nothing). Otherwise create it once with cron
     `17,47 * * * *` and the generic resumer prompt below.
9. **Start the loop:** do the first unit now, then follow the Turn protocol.

### Generic resumer prompt (create ONCE, serves every task — copy verbatim)

```
Generic resumer for the infinite-working-skill. COLD session — carry NO task
assumptions. You resume ANY registered task; all task detail lives in each task's
state file and the playbook it points to.

WL=/Users/<you>/.claude/skills/infinite-working-skill/scripts/worklog.sh

1. bash "$WL" list-active            # lines: <task_id>\t<state_file>\t<status>
   Empty -> nothing to do, exit.
2. For EACH line, run: bash "$WL" should-resume "<state_file>"
   - DONE    -> bash "$WL" unregister "<state_file>" ; continue.
   - BLOCKED -> continue (waiting on the user).
   - FRESH   -> continue (a live session is driving it; never double-drive).
   - RESUME  -> take over:
       a. bash "$WL" heartbeat "<state_file>"          # claim it first
       b. Read .playbook_path from the state file (bash "$WL" dump). Open that
          playbook — it holds ALL task-specific steps, paths, idempotency rules,
          and approval gates.
       c. Invoke the infinite-working-skill and follow its Turn protocol + the
          playbook, starting from .next_action.
       d. Idempotency: never redo a unit already in .ledger. NEVER perform a
          gated/irreversible action — set status blocked and stop instead.
3. If an interactive tool (e.g. a logged-in browser for computer-control) is
   unavailable in this cold run, set the affected phase blocked with a note and
   do the API-only phases.
4. If no registered task is `working`, you may disable this scheduled task.
```

## Turn protocol (every working iteration)

1. `bash $WL heartbeat <file>` — **first thing**; claims the turn. On `TRIP`, set
   status blocked ("max_iterations"), notify, stop.
2. `bash $WL status <file>` — read next_action, phases, ledger, playbook_path.
3. **Idempotency check:** for the next unit, `bash $WL ledger-has <file> "<unit>"`.
   HAS → skip. Only act on MISSING units.
4. **Approval gate:** if the next action is gated (per the playbook), set status
   blocked "needs approval: <action>", PushNotification, stop. Do not perform it.
5. Do the next unit. Success → `ledger-add` + advance phase/`next`. Failure →
   `fail`; on `TRIP` → status blocked, notify, stop.
6. **Checkpoint:** `bash $WL checkpoint-due <file>`; if DUE, perform
   `checkpoint_action`, then `checkpoint-done`.
7. **Done?** All phases done → `set-status done`, `unregister`, PushNotification,
   stop. (Leave the shared resumer in place for other tasks.)
8. Else `next <file> "<next unit>"` and, as the **last action of the turn**, call
   `ScheduleWakeup` (**60–120s while actively churning** to stay within the
   prompt-cache window; **1200–1800s when idle** or waiting on an external event).

## Safety rails (non-negotiable for "infinite")

- **Approval gates halt, never fire.** Posting, sending, publishing, deleting prod,
  `git push`, anything outward-facing or irreversible → status blocked + reason +
  notify + stop. The user resumes by setting status back to `working`.
- **Runaway guards.** `max_iterations` and `max_consecutive_failures` trip to blocked.
- **Idempotency before every mutating unit.** No ledger check → no mutation.
- **Heartbeat-first on resume** stops two drivers colliding.
- **One shared resumer, never per-task.** It serves all registered tasks; the skill
  stays agnostic of any program.
- **Notify on every stop.** Done or blocked, send a one-line PushNotification.

## worklog.sh command reference

| Command | Effect |
|---------|--------|
| `init <file> <id> [title]` | Create state file (no-op if it exists). |
| `heartbeat <file>` | Stamp heartbeat, iteration++. Run first each turn. |
| `status` / `dump <file>` | Human summary / full JSON. |
| `set-status <file> working\|blocked\|done [reason]` | Set status (+ reason). |
| `next <file> <text…>` | Set the next action. |
| `playbook-set <file> <path>` | Point the state file at its playbook. |
| `phase-set <file> <id> <status> [note]` | Upsert a phase. |
| `ledger-add <file> <unit>` / `ledger-has <file> <unit>` | Record / check a unit (0=HAS, 1=MISSING). |
| `fail <file> "<why>"` | Increment failure count; prints TRIP at the cap. |
| `note <file> <text…>` | Append a timestamped note. |
| `checkpoint-due` / `checkpoint-done <file>` | Periodic-save timer. |
| `config <file> k=v …` | Set any numeric/string knob. |
| `should-resume <file>` | DONE / BLOCKED / FRESH / RESUME. |
| `register <file>` / `unregister <file\|id>` / `list-active` | Manage the resumer's task registry. |

## Choosing the resumer mechanism

- **`mcp__scheduled-tasks` (recommended).** Persists, runs on next app launch if
  closed, fresh session each fire. One-time approval on creation. Note: the API
  has no delete — disable with `update_scheduled_task enabled:false`, or remove the
  task directory under `~/.claude/scheduled-tasks/<id>/`.
- **`CronCreate durable:true`.** No approval prompt; fires while the REPL is idle.
- **Cloud routine (`schedule` skill).** Server-side even with the app closed — best
  for *pure-API* tasks; avoid for tasks needing interactive auth (browser, local MCP).

## Teardown

On `done`: `unregister` the task. Delete the shared resumer ONLY when no tasks remain
registered (disable via `update_scheduled_task` or remove its task directory).
TaskStop any Monitor; omit ScheduleWakeup. State file + playbook remain as the record.

## Sync homes

Canonical: ~/.claude/skills/infinite-working-skill (private, live). Public sanitized twin: ~/code/claude-skills/infinite-working-skill → github.com/justinwilliames/claude-skills. Sanitization is a sync step — never push private paths/names.
