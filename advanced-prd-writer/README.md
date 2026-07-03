# advanced-prd-writer

A Claude Code skill for writing **and critiquing** product requirements documents — grounded in published PM best practice, adaptive to the maturity of the work, opinionated about structure, and actively defensive against the ten failure modes that quietly kill most PRDs.

The skill replaces "fill in a generic template" with a behaviour: read the request, pick the right document shape, enforce the small set of sections every credible PM authority agrees on, and scan the draft for failure modes. In critique mode, the same machinery audits an existing PRD against the same canon — and pushes back when the draft drifts.

---

## Two modes

The skill operates in two modes. Both enforce the same eight universal must-haves and scan for the same ten failure modes.

### Write mode

You ask for a new PRD. The skill picks one of seven shapes, loads the matching template, drafts the doc, then runs the failure-mode scan and reports findings.

**Trigger phrases:** "write a PRD", "draft a spec", "scope this feature", "write an RFC", "press release for this idea", "I need a one-pager for X".

### Critique mode

You hand the skill an existing PRD. It runs a four-pass audit — eight must-haves, ten failure modes, voice and clarity, best-practice gap — and returns findings grouped by severity (Blockers / Majors / Minors / Nits) with the specific fix and the cited authority for each.

**Trigger phrases:** "review this PRD", "audit this draft", "critique this spec", "what's wrong with this PRD", "make this better", "tear this apart", "is this good enough to ship".

**Auto-detect:** if you paste a document of 500+ words with PRD-shaped headers (Problem / Solution / Success / Non-goals) and don't explicitly ask for something new, the skill offers critique mode before doing anything else.

> **Adversarial by default.** Critique mode does not soften. When a draft conflicts with published best practice, the skill cites the authority and recommends the change. You overrule consciously, not by default.

---

## Canon

The skill draws on eight published authorities. No single house style. No author's idiosyncrasies elevated to "load-bearing". The canon is the source of truth — if a finding is surfaced, it is because the canon supports it.

| Authority | What they contribute |
|---|---|
| **Marty Cagan** (Silicon Valley Product Group) | Opportunity assessment shape. Discovery-over-documentation thesis. "PRDs that defer decisions create silent coordination cost." |
| **Lenny Rachitsky** | The flat one-pager template. Problem-statement primacy: "nailing the problem statement is the single most important step." |
| **Shreyas Doshi** | Iterative PRDs. Dashboard-view requirement. LNO framing. "Forcing ourselves to write down our thinking enables consensus better than a meeting." |
| **Amazon Working Backwards** | The PR-FAQ structure. "Start with the customer and work backwards." Truth-seeking critique register. |
| **John Cutler** | One-pagers. Outcomes over outputs. Cost-of-delay framing. "Operating assumptions" made explicit. |
| **Ravi Mehta** | Prototype-led specs. "Vague specs produce messy codebases" — the case for inline provenance. |
| **Reforge** | The 10-component product spec. 2–3 page discipline as a quality signal. |
| **Aakash Gupta** | Modern PRD synthesis. Evidence-grounded narrative. Most-cited PRD weakness: avoided tradeoffs. |

---

## What you get

**Seven document shapes**, picked adaptively from your request:

| Shape | When to use |
|---|---|
| Discovery brief | Problem not yet validated. Thinking out loud. |
| Opportunity assessment | Problem is real. Deciding go/no-go before staffing. |
| PR-FAQ | New product or major feature. Customer-visible win is the unknown. |
| Standard PRD | Validated problem. Ready to build. Multi-week scope. |
| Launch PRD | Building underway. Doc serves cross-functional GTM. |
| Technical RFC | Build path or architecture is the unknown. |
| Experiment brief | A/B or holdout test with a ship rule. |

**Eight universal must-haves**, enforced on every shape:

1. Problem statement with evidence
2. Target user / segment
3. Why now / opportunity
4. Success metrics with baseline, target, and dashboard
5. Solution overview (the what, not the how)
6. Non-goals / out of scope
7. Risks, assumptions, open questions
8. Owner, collaborators, timeline

**Ten failure modes**, actively detected on every draft:

1. Solution masquerading as problem
2. Unmeasurable success
3. No non-goals
4. Premature solutioning
5. Feature-named initiative
6. No customer evidence
7. Tradeoffs avoided
8. Length as quality proxy
9. No pre-mortem / no risks
10. Stale assumptions left implicit

**Two cross-cutting patterns from published practice**, applied on any shape where they fit:

- **Data-freshness callout.** Every doc opens with version, date, and what data this is grounded in. Cited to Ravi Mehta (*"vague specs produce messy codebases"*) and Shreyas Doshi (*"include provenance"*). Pre-empts the "is this stale?" question and forces honesty about what the doc actually rests on.
- **NEED / PROCEED-WITHOUT.** Every dependency resolves as either a hard blocker (with owner and deadline) or a conscious cost we accept on launch. No "to be determined" rows. Cited to Doshi (*"forcing ourselves to write down our thinking enables consensus better than a meeting"*) and Cagan (*"PRDs that defer decisions create silent coordination cost"*).

---

## Install

### Claude Code CLI

Clone into your skills directory:

```bash
git clone https://github.com/justinwilliames/skills.git
cp -R skills/advanced-prd-writer ~/.claude/skills/advanced-prd-writer
```

Verify by listing skills inside any Claude Code session:

```
/skills
```

`advanced-prd-writer` should appear in the list.

### Claude Code Desktop (Mac / Windows)

Same as CLI — the Desktop app reads from `~/.claude/skills/`. Restart the app after cloning so it picks up the new skill.

### Manual install

If you'd rather not use git:

1. Download the repo as a zip.
2. Extract into `~/.claude/skills/advanced-prd-writer/`.
3. Confirm `~/.claude/skills/advanced-prd-writer/SKILL.md` exists.

---

## Usage

The skill triggers automatically whenever you ask Claude to write or critique a PRD, spec, RFC, one-pager, press release, opportunity assessment, or experiment brief. You can also invoke it directly:

```
/advanced-prd-writer
```

### Example invocations — write mode

> "Write me a PRD for our new onboarding flow"

→ Standard PRD. The skill picks this shape, loads the template, asks one clarifying question if needed, then drafts.

> "We're thinking about whether to add team workspaces — can you put something together?"

→ Discovery brief. Lighter shape. Focuses on whether the problem is real and what the next learning step is.

> "Write an RFC for migrating our auth from Cognito to Clerk"

→ Technical RFC. Adjudicates between engineering options. Recommendation with reasoning.

> "I want to test whether moving the trial CTA above the fold lifts signup"

→ Experiment brief. Falsifiable hypothesis, primary metric, ship rule decided up front.

> "If we built a feature that did X, what would the press release look like?"

→ PR-FAQ. Amazon Working Backwards shape.

The skill states its pick before drafting — *"Reading this as a Discovery brief — shout if you want a heavier shape."* You get one chance to redirect before any prose is written.

### Example invocations — critique mode

> "Review this PRD before I send it round"

→ Four-pass audit. Findings grouped Blockers / Majors / Minors / Nits, each with cited authority and specific fix.

> "Audit this draft — what's missing?"

→ Same audit. Lead with the must-haves that are missing or weak.

> "Tear this apart"

→ Adversarial pass. The skill will not soften.

> *(pasting 1,200 words of PRD-shaped markdown without a question)*

→ Skill auto-detects: *"This looks like an existing PRD. I can audit it against published best practice and surface specific edits — want me to run the scan?"* Waits for confirmation.

---

## What this skill does not do

- It does not produce marketing copy, support docs, or customer-facing prose. Different voice. Lifecycle-program PRDs hand message copy to a companion build-spec document and link it — the PRD never embeds copy.
- It does not write engineering code. Hand off after the PRD is signed.
- It does not auto-fix the failure modes it detects. It surfaces and lets you decide.
- It does not auto-apply edits in critique mode. The audit is delivered; edits land only on explicit confirmation.
- It does not pad. Length is failure mode #8. The skill cuts before it adds.
- It does not preserve any individual author's house style. The canon is published external best practice.

---

## Repo structure

```
advanced-prd-writer/
├── SKILL.md                    # entry point — Claude reads this on invocation
├── LICENSE                     # MIT
├── README.md                   # this file
├── templates/
│   ├── discovery-brief.md
│   ├── opportunity-assessment.md
│   ├── pr-faq.md
│   ├── standard-prd.md
│   ├── launch-prd.md
│   ├── technical-rfc.md
│   └── experiment-brief.md
└── references/
    ├── shape-picker.md         # full decision tree for picking the shape
    ├── failure-modes.md        # 10 failure modes, detection rules, fix patterns
    ├── pm-best-practices.md    # distilled wisdom from 8 PM authorities
    └── voice-clarity-rules.md  # writing rules with worked examples
```

`SKILL.md` is the entry point. `templates/` and `references/` are loaded on demand when the skill needs them.

---

## Voice and language

The skill writes in operator-direct, evidence-grounded prose. Short sentences. Active voice. No corporate hedging. Tables for facts. The voice rules are the same regardless of shape; the structure changes, not the register.

The skill matches the spelling convention your input uses — AU/UK or US. It does not impose one. If your input is ambiguous, it asks once before drafting and locks the choice for the document.

---

## Contributing

Issues and PRs welcome at [github.com/justinwilliames/skills](https://github.com/justinwilliames/skills).

If you have a PRD pattern that should be added, file an issue with:

- The pattern (one paragraph)
- The published PM authority or real-world doc it's grounded in
- Which shape(s) it belongs in
- Whether it's a must-have, a should-have, or shape-specific

Patterns grounded only in private experience — without a published source — will not be merged. The canon is the bar.

---

## Credits

The skill is built on the published work of eight PM authorities:

- **Marty Cagan** (Silicon Valley Product Group) — opportunity assessment, the discovery-over-documentation thesis
- **Lenny Rachitsky** — the 1-pager template, problem-statement primacy
- **Shreyas Doshi** — iterative PRDs, dashboard-view requirement, LNO framing
- **Amazon** — Working Backwards, the PR-FAQ structure
- **John Cutler** — one-pagers, outcomes over outputs, cost-of-delay
- **Ravi Mehta** — prototype-led specs, "the spec is the source code"
- **Reforge** — the 10-component product spec, 2–3 page discipline
- **Aakash Gupta** — modern PRD synthesis, evidence-grounded narrative

License: MIT.

---

## Changelog

- **v1.2** — Lifecycle/CRM program depth pack (SKILL.md Step 4.5): data points in platform attribute language, conversion-event mapping per metric, measurement/holdout design locked before build, negative scope with per-item reasons, numeric phase gates, and message copy handed off to a companion build-spec document. Critique mode stops penalising org-standard section spines that carry the must-haves, and audits depth-pack items on program PRDs. Must-haves #4 and #7 deepened (instrumentation mapping; threshold/signal/response mitigations).
- **v1.1** — Critique mode added. Three-act Program/Content/Data spine removed. Re-grounded explicitly in published authorities — every must-have, failure mode, and cross-cutting pattern now cites its source. AU-English imposition dropped — the skill now matches the user's input English convention rather than defaulting to one.
- **v1.0** — Initial release. Seven shapes, eight must-haves, ten failure modes.
