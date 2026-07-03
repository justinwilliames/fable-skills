# claude-okr-structuring

A Claude skill for writing, cascading, and auditing OKRs (Objectives and Key Results) against the published canon — Grove, Doerr, Wodtke, Lamorte, Castro, Klau. Outputs ship-ready Notion-shaped structure in one of two house shapes.

Built for use with [Claude Code](https://docs.claude.com/en/docs/claude-code) and any client that supports the [Anthropic skills format](https://docs.claude.com/en/docs/claude-code/skills).

## What it does

Three modes, picked from the request:

1. **Audit** — paste existing OKRs, get a per-Objective and per-KR scorecard, named failure-mode hits, and concrete rewrites. The skill is adversarial by default: it assumes something is broken and names what.
2. **Cascade** — paste parent CEO or leadership OKRs plus functional context (team, capabilities), get 1-3 functional Objectives with 3-5 KRs each, every KR with an explicit ladder-up trace to a parent KR.
3. **Create** — describe the function and cycle, get a full OKR set plus a recommended Notion shape.

## The opinion baked in

OKRs are a 50-year-old framework with a small stable canon. Most OKR sets in the wild fail at least 3 of the 10 named failure modes. The skill exists to call those out without flinching.

**Eight universal must-haves** — every OKR set is checked against these:

1. Qualitative, time-bound, inspirational Objective
2. 3-5 Key Results per Objective
3. Every KR is outcome-based and independently measurable
4. KRs prove the Objective (the pass-the-KRs test)
5. Single accountable owner per Objective
6. Cycle is named and time-bound
7. Committed vs Aspirational labelled
8. Check-in cadence defined

**Ten named failure modes** — flagged by number in Audit mode:

1. Activity-KR (task in disguise)
2. Vanity-metric KR
3. Cascade-copy (child = parent restated)
4. Sandbagging
5. Set-and-forget
6. Compensation-linked
7. Too many OKRs
8. Vague Objective
9. Output-vs-outcome confusion
10. Orphan KR (no ladder-up to parent)

## The cascade logic

Most companies cascade badly: they copy-paste the parent OKR with the team name swapped in. The skill rejects that and enforces the contribution-path model — a functional OKR translates a parent KR into the metric *this function* can move, then runs a ladder-up test on every KR to prove it.

Default split per Wodtke/Lamorte: ~60% top-down cascade, ~40% bottom-up function-proposed. The skill surfaces the bottom-up portion explicitly.

## Notion structure — two shapes

The user picks per cycle:

**Shape A — Single-page narrative.** One Notion page per cycle. Objectives as H2, KRs as bullets with baseline/target/current/confidence inline. Light. Good for solo operators, small teams, exec readouts.

**Shape B — Three databases (operational).** `Cycles` + `Objectives` + `Key Results`, fully related, with six standard views (current cycle, confidence dashboard, off-track only, cascade tree, by owner, historical). Heavier to set up; pays back from cycle 2.

Both shapes are documented end-to-end in `SKILL.md` with every property typed.

## Check-in cadence

Wodtke's pattern, baked in as the default:

- **Monday commitment** (15 min) — current confidence + 1-3 things to move it this week
- **Friday celebration** (15 min) — what moved, confidence delta
- **Mid-cycle review** (week 6 of a quarter) — drop or rewrite anything broken
- **End-of-cycle retro** — score every KR 0.0-1.0, decoupled from comp

## The canon

Cited by source when the user pushes back. No invented authorities.

| Source | Canon for |
|---|---|
| Andy Grove, *High Output Management* (1983) | Origin. The two-question test. |
| John Doerr, *Measure What Matters* (2018) + whatmatters.com | Committed vs Aspirational. CFRs. |
| Christina Wodtke, *Radical Focus* (2016, 2nd ed. 2021) | Weekly cadence, confidence scoring, team mechanics. |
| Ben Lamorte, *The OKRs Field Book* (2022) | Coaching-led implementation, outcome-vs-output. |
| Felipe Castro, felipecastro.com | Failure-mode taxonomy. |
| Rick Klau, "How Google sets goals" (YouTube, 2013) | 0.7 = good score, Google-internal mechanics. |
| Lenny Rachitsky, Lenny's Newsletter | Modern practitioner commentary. |

When sources conflict: Wodtke for cadence, Doerr for committed/aspirational, Grove for underlying logic, Castro for failure-mode names.

## Install

Clone the repo into `~/code/` and symlink into your Claude skills directory:

```bash
git clone https://github.com/justinwilliames/skills.git
cp -R skills/okr-structuring ~/.claude/skills/okr-structuring
```

The skill is then available in any Claude Code session — trigger by asking Claude to write, draft, audit, review, or cascade OKRs.

## Triggers

Fires on phrases like:

- "write OKRs for [function]"
- "draft Q[N] OKRs"
- "review my OKRs" / "audit these OKRs" / "are these good OKRs"
- "cascade these CEO OKRs into [function] OKRs"
- "distill these into functional OKRs"
- "is this a good Key Result"
- "what should our [function] OKRs be"

Does NOT fire on personal goal-setting, performance reviews (OKRs are explicitly decoupled from comp), or general planning that isn't OKR-shaped.

## License

MIT.
