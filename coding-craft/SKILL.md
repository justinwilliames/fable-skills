---
name: coding-craft
description: >
  Frontier-quality code changes: read before writing, match the codebase's idiom, keep diffs
  minimal, comment only constraints, and debug by evidence rather than pattern-matching. Load
  for any non-trivial code change, review, or debugging session. Do NOT use for greenfield
  architecture design (it governs changes within a codebase, not system design) — though its
  debugging and verification rules apply everywhere.
---

# Coding Craft

Code quality for an agent is mostly restraint: the best change is the smallest one that
fully solves the problem, written so the next reader can't tell an agent wrote it.

## Before writing

- **Read the neighbourhood first.** The surrounding file defines naming, error handling,
  test style, and idiom. Your change should be indistinguishable from the incumbent author's
  work — matching conventions beats imposing better ones, unless you're asked to refactor.
- **Find the existing helper before writing a new one.** Most codebases already contain the
  function you're about to write. Search before you add.
- **Check the premise** ([challenge-before-build](../challenge-before-build/SKILL.md)): if
  the request describes code you can read, read it — the described bug and the actual bug
  are frequently different.

## The diff discipline

- **Minimal surface.** Touch the lines the task requires. Drive-by reformatting, renames,
  and "while I'm here" cleanups contaminate review and hide the real change. If you spot
  unrelated debt, report it — don't fix it inside this diff.
- **No speculative abstraction.** Don't build the general mechanism for the single case in
  front of you. Two concrete call sites justify a helper; one does not.
- **Comments state constraints, not narration.** Write a comment only for what the code
  cannot say: an invariant, a non-obvious *why*, an external contract. Never "// increment
  the counter", and never comments that talk to the reviewer about your change — those are
  noise the moment the change merges.
- **Delete what you obsolete.** A change that leaves the old path dangling isn't finished.
  But before deleting anything you didn't create: inspect it — if what you find contradicts
  the request's description of it, surface that instead of proceeding.

## Debugging by evidence

1. **Reproduce before fixing.** A fix for an unreproduced bug is a guess with a commit message.
2. **One variable at a time.** Change one thing, observe, then the next. Shotgun edits
   destroy the information each attempt would have produced.
3. **The invariant-symptom rule.** If the symptom is unchanged under two genuinely different
   fixes, the bug is upstream of the layer you're editing — go inspect the input/data/caller
   instead of writing fix number three ([verification-gates](../verification-gates/SKILL.md)).
4. **Read the error.** The message usually names the file, line, and cause. Pattern-matching
   a symptom to a familiar failure without reading the evidence is how you fix the wrong thing.
5. **Instrument, don't speculate.** When stuck, add the log line / breakpoint / minimal repro
   that would decide between your top two hypotheses.

## The verification gate

No claim of "fixed/working" without running the relevant tests or the app itself, and
reading the output — the full standard lives in
[verification-gates](../verification-gates/SKILL.md). A compiling diff proves compilation,
nothing else. If the environment prevents running anything, say so and mark the change
unverified.

## Hygiene non-negotiables

- No secrets, tokens, or credentials in code, commits, or logs — ever, including "temporary" ones.
- New code paths get the same error handling the codebase already uses — not less, not a new scheme.
- Failing tests you didn't cause are reported, not silently "fixed" by weakening assertions.

## Named failure modes

| Failure mode | Detection signal |
|---|---|
| **Idiom import** | Your diff introduces a style the file didn't have |
| **Drive-by bloat** | Diff touches files the task didn't require |
| **Speculative framework** | New abstraction with one caller |
| **Reviewer comments** | Comment explains the change instead of the code |
| **Shotgun debugging** | Second simultaneous edit before observing the first |
| **Assertion weakening** | A test "fixed" by loosening what it checks |
| **Confident guess** | "This should fix it" on an unreproduced bug |

## Sync home

Sync home: github.com/justinwilliames/fable-skills — canonical. Installed copies (e.g. `~/.claude/skills/coding-craft`) are distribution artifacts: edit the repo, re-copy.
