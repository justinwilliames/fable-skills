---
name: codex
description: Delegate tasks to OpenAI Codex (GPT-5.5) as background tasks for precision coding, code review, deliberation, and complex implementation. Always launch in background (run_in_background=true), continue working, then collect results with TaskOutput when needed.
allowed-tools: Bash, Read, Grep, Glob, TaskOutput, Edit, Write
---

# Codex

> Paths below use `{base}` as shorthand for this skill's base directory, provided automatically at the top of the prompt when the skill loads.

Codex is GPT-5.5 — a different model with a different reasoning manifold than Claude. It catches things you miss, thinks about problems differently, and arrives at solutions from a different angle. Use it as a genuine second brain, not just a subprocess. Its opinions, reviews, and implementations carry independent signal — when Codex disagrees with your approach, that disagreement is valuable.

Two modes of operation:

| Mode | Command | Sandbox | Web | Sessions | Purpose |
|------|---------|---------|-----|----------|---------|
| **think** | `think` | read-only | yes | ephemeral | Analysis, deliberation, research, review, second opinions |
| **run** | `run` | full-access | yes | persisted | Implementation, coding, refactoring, bug fixes |

**Choose think** when the user wants opinions, analysis, or research — no files will be modified.
**Choose run** when the user wants code changes.
When unclear, default to **run**.

## Usage

```bash
# Think (read-only + web search)
{base}/scripts/codex.sh think "prompt" --dir /path/to/project
{base}/scripts/codex.sh think "prompt" --image screenshot.png --dir /project

# Run (full-access + web search)
{base}/scripts/codex.sh run "prompt" --dir /path/to/project
{base}/scripts/codex.sh run "prompt" --image mockup.png --dir /project
{base}/scripts/codex.sh run "prompt" --schema schema.json --dir /project
{base}/scripts/codex.sh run "prompt" --add-dir /other/path --dir /project

# Review (read-only, specialized)
{base}/scripts/codex.sh review --base main "Focus on security"
{base}/scripts/codex.sh review --commit abc123
{base}/scripts/codex.sh review --uncommitted

# Resume a previous run session
{base}/scripts/codex.sh resume --last "follow-up instruction"
{base}/scripts/codex.sh resume --session <SESSION_ID> "follow-up"
```

**Flags:** `--dir`, `--model`, `--effort`, `--sandbox`, `--image`, `--ephemeral`, `--schema`, `--add-dir`

## How to Invoke

1. **Always run in background.** Continue working or block on `TaskOutput`.
2. **Pass the user's intent as-is.** Don't over-engineer the prompt — Codex reads files and figures things out.
3. **Add context Codex can't see** — working directory, file paths, framework info, constraints from earlier in conversation.
4. **Collect results** with `TaskOutput(task_id=..., block=True, timeout=300000)`.
5. **After run mode**, check `git status` — Codex may have modified files.

```python
Bash(command='{base}/scripts/codex.sh think "Is this auth design scalable?" --dir /project',
     run_in_background=True)
# → task_id

TaskOutput(task_id="...", block=True, timeout=300000)
# → SESSION: <uuid>\n---\n<response>
```

For complex tasks, add structure (see `references/prompt-engineering.md` for templates). For simple asks, just describe what you need.

## When Codex Shines

- **Second opinion** — its different training means it spots different bugs, suggests different patterns, and flags things you'd overlook
- **Adversarial review** — use `think` to challenge your own implementation. A different model questioning your code is more valuable than self-review
- **Parallel expertise** — while you work on feature A, Codex implements feature B or researches approach C
- **Deep reasoning tasks** — xhigh effort on complex algorithms, security analysis, architecture decisions

## When NOT to Use Codex

- Simple edits, typos, trivial changes — do them yourself
- Multi-file orchestration — you coordinate better across many files
- Conversational responses or explanations
- Tasks requiring mid-execution user interaction

## Parallelism

Launch multiple Codex tasks at once. Peek without blocking: `TaskOutput(task_id=..., block=False, timeout=0)`.

## Self-Healing

If anything breaks, fix the skill files directly — you have authorization to edit anything under `{base}/`:
- `scripts/codex.sh` — wrapper script
- `SKILL.md` — this file
- `references/cli-reference.md` — CLI flags
- `references/prompt-engineering.md` — prompt templates

**Preflight:** before invoking `{base}/scripts/codex.sh`, verify `codex` is available — `which codex` or check `/Applications/Codex.app/Contents/Resources/codex`. If neither is found, stop and tell the user to install Codex CLI before continuing.

**TaskOutput timeout escalation:** the default collect call uses `timeout=300000` (300s). If TaskOutput returns a timeout error, check `{base}/scripts/codex.sh`'s last output file or session log for partial output and surface what's there. If no partial output is available, retry once with `timeout=600000` (600s). If that also times out, report the failure and let the user decide whether to resume via `codex.sh resume --last`.

## Companion skills — route here instead when the task fits

This skill delegates **single-focus** work to Codex (one coding task, one review, one deliberation). Three shapes of work are better served by a purpose-built sibling skill — hand off rather than driving raw Codex yourself:

| If the task is… | Route to skill | Why |
|---|---|---|
| Generating or editing raster images | **`codex-imagegen`** | Purpose-built Codex image wrapper — prompt skeletons, attachment flow, clean capture |
| Driving the screen — web automation, browser control, or a native macOS app | **`computer-control`** | Picks the right engine between Claude-in-Chrome and Codex Computer Use |
| A large multi-part build needing decomposition, parallel fan-out, QA, and a unified diff | **`intelligent-delegation`** | Orchestrator that fans work across Sonnet/Haiku/Codex and runs the QA gate (it calls *this* skill as one of its runners) |

Keep handling **directly here**: a single Codex `think` / `run` / `review` — one focused task, no decomposition, no screen, no image work.

These siblings are separate skills and must be installed to be available — see [README → Companion skills](README.md#companion-skills) for the one-line install of each.

## Sync homes

Canonical: ~/.claude/skills/codex (private, live). Public sanitized twin: ~/code/claude-skills/codex → github.com/justinwilliames/claude-skills. Sanitization is a sync step — never push private paths/names.
