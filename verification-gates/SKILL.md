---
name: verification-gates
description: >
  Evidence discipline for agents: a claim about the world requires an observation of the world.
  Load before claiming anything is fixed, done, working, deployed, or safe — and bake into any
  sub-agent brief whose output you will relay. Defines per-surface proof standards (code, UI,
  API, data, email, infra) and the heuristics that catch wrong-layer debugging. Do NOT use as a
  test-writing guide — it governs when you may make a claim, not how to build a test suite.
---

# Verification Gates

The most expensive agent failure is not a wrong edit — it's a wrong *claim*. A wrong edit
costs a retry; a claim of "fixed" that wasn't verified costs the user's trust plus the hour
they spend discovering it. This skill makes claims gated: no observation, no claim.

## The gate

Before emitting any of: **fixed / done / works / passing / deployed / safe / migrated / live**
— run the observation that would falsify it. If you cannot run that observation, downgrade
the claim explicitly: "edited, but unverified — I couldn't run X because Y."

A downgraded-but-honest claim is frontier behaviour. An upgraded-but-hollow claim is the
failure this skill exists to prevent.

## Proof standards by surface

| Surface | Minimum observation before claiming | Not sufficient |
|---|---|---|
| **Code change** | Run the relevant tests/build and read the output | The diff "looking correct" |
| **UI change** | Capture a screenshot AND inspect it for the expected state | The code compiling; a screenshot you didn't look at |
| **API / service** | Read the value back after writing it (GET after PUT) | A 200 response on the write |
| **Data / analytics** | Reconcile the figure against a second independent source or invariant | One query returning a plausible number |
| **Email / rendered content** | Render check in the actual client/preview pipeline | The template source reading correctly |
| **Deploy / infra** | Hit the live endpoint / check the running version | CI going green |
| **Deletion / cleanup** | List the target afterwards and confirm absence | The delete call returning success |

The last row matters more than it looks: some APIs report success on operations they silently
skip. **Write-then-readback** is the universal antidote — verify against the live system, not
against your own request.

## Heuristics that catch wrong-layer debugging

**The invariant-symptom rule.** If a symptom is unchanged under two genuinely different fixes,
the bug is not in the layer you are editing — it's upstream (the data, the payload, the
caller). Stop patching the render layer and inspect the input. This single heuristic recovers
hours: two invariant results is the signal, don't wait for four.

**Signal ≠ cause.** Before a state-changing command (restart, delete, config edit), check the
evidence supports *that specific action*. A symptom that pattern-matches a known failure may
have a different cause; the remedies are not interchangeable.

**Verify the environment, not just the artifact.** A test passing locally verifies local. If
the claim is about production, the observation must touch production (or you say "verified
locally only").

## Named failure modes

| Failure mode | What it looks like | Antidote |
|---|---|---|
| **Diff-reading confidence** | "This fixes it" from reading your own edit | Run it |
| **Testing the mock** | Green tests that never touch the real dependency | One integration-level observation per claim |
| **Unread screenshot** | Screenshot captured, attached, never inspected | State what you see in it, specifically |
| **200-means-done** | Trusting the write response | Read it back |
| **Wrong-environment proof** | Local pass presented as production truth | Name the environment in the claim |
| **Fix-loop blindness** | Third different fix, same symptom, still same layer | Invariant-symptom rule: go upstream |
| **Relayed hollow claim** | Sub-agent said "done", you repeated it | Sub-agents inherit this gate — brief them; spot-check their evidence |

## Sub-agent contract

When you delegate, the gate delegates with it. Every sub-agent brief that produces a claim
must include: the verification command/observation to run, and the instruction to report the
observation's *output*, not just a pass/fail adjective. When a sub-agent's report lacks
evidence, treat the claim as unverified and either re-check yourself or relay it downgraded.

## Related

[operator-standard](../operator-standard/SKILL.md) Rule 3 (faithful reporting) is the
communication half of this skill; this file is the epistemics half.
[challenge-before-build](../challenge-before-build/SKILL.md) applies the same discipline
*before* work starts.

## Sync home

Sync home: github.com/justinwilliames/fable-skills — canonical. Installed copies (e.g. `~/.claude/skills/verification-gates`) are distribution artifacts: edit the repo, re-copy.
