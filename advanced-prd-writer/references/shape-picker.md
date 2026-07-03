# Shape Picker — Full Decision Tree

This is the long-form reference for SKILL.md Step 1. The seven document shapes, what signals trigger each, the tiebreaker questions when two shapes are plausible, and worked examples.

The goal: never make the user pick from a menu of seven. Read their request, decide, state your pick out loud, give them one chance to redirect.

---

## The seven shapes at a glance

| Shape | Core question it answers | Reader | Decision it unblocks |
|---|---|---|---|
| Discovery brief | "Is there a real problem here worth more time?" | PM, possibly one peer | Whether to invest the next two weeks |
| Opportunity assessment | "Should we staff this?" | Product leadership | Go / no-go on resourcing |
| PR-FAQ | "What does the customer-visible win look like?" | Exec, cross-functional | Whether the idea is press-release-worthy |
| Standard PRD | "What are we building, and how do we know it works?" | Eng, design, QA | Build can start |
| Launch PRD | "How does this land in the market?" | GTM, support, marketing | Launch can ship |
| Technical RFC | "Which build path?" | Engineering | Architectural choice |
| Experiment brief | "What are we testing and what's the ship rule?" | PM, eng, data | Whether to run the test |

---

## Primary decision flow (first match wins)

Run these in order. The first rule that matches the user's input is your pick.

### Rule 1 — Exploratory language with no engineering commitment

**Signals:** "explore", "investigate", "scope this out", "figure out", "understand", "look into", "do we have a problem with", "is X worth thinking about".

**Sub-check:** is engineering capacity already committed?
- No → **Discovery brief**
- Yes → drop to Rule 2; you're past discovery

The discovery brief exists to answer a single question: *is there a real problem here worth more time?* It is cheap, narrative, and ends with the smallest next learning step.

### Rule 2 — Hypothesis testing language

**Signals:** "test", "validate", "experiment", "hypothesis", "A/B", "holdout", "ship rule", "we want to find out whether", "if we change X, will Y happen".

→ **Experiment brief**

This is the shape when the unit of work is a test, not a feature. Required: a falsifiable hypothesis, a primary metric, guardrails, sample size, duration, and a ship rule decided up front.

### Rule 3 — Architecture or build-path language

**Signals:** "architecture", "migration", "refactor", "which approach", "build vs buy", "we have three options", "system design", "data model", "API design", "infra".

→ **Technical RFC**

The RFC's job is to adjudicate between engineering options. The PM may co-author with the tech lead, but the doc's primary audience is engineering. Required: constraints, options compared with tradeoffs, a recommendation with reasoning.

### Rule 4 — Launch and rollout language

**Signals:** "launch", "ship", "GA", "rollout", "announce", "comms plan", "go to market", "release", "marketing plan", "support enablement".

→ **Launch PRD**

The Launch PRD assumes the build is underway or done. It adds: launch checklist, comms plan, support enablement, success thresholds tied to a date, rollback criteria. If the build is not yet underway, fall back to Standard PRD and add launch sections later.

### Rule 5 — Customer-story or press-release framing

**Signals:** "press release", "customer-facing story for", "Working Backwards", "what would the launch look like", "if we were to announce this", "the headline would be".

→ **PR-FAQ (Working Backwards)**

The PR-FAQ is Amazon's pattern. Useful for large new products or major features where the customer-visible win is the unknown — writing the press release first forces the team to articulate the value before building. Required: press release (6 paragraphs), external FAQ, internal FAQ.

### Rule 6 — Go/no-go or strategic-case framing without implementation commitment

**Signals:** "go/no-go", "should we", "is this worth doing", "strategic case for", "make the case", "build the business case", "is this priority", "ROI".

→ **Opportunity assessment**

The opportunity assessment is Cagan's shape. It's heavier than a discovery brief (the problem is already validated) but lighter than a Standard PRD (we have not committed to building). It exists to unblock the resourcing decision.

### Rule 7 — Default — build/spec language with a defined feature

**Signals:** "PRD for X", "spec for X", "requirements for X", "we're building X", "write a doc for the X feature", or input that names a specific feature without exploratory or experimental framing.

→ **Standard PRD**

The Standard PRD is the workhorse. Validated problem, committed scope, ready to build. Holds the eight universal must-haves plus scope, key flows, dependencies, and a rollout sketch.

---

## Tiebreakers — when two rules plausibly fire

### Discovery brief vs Opportunity assessment

Both fire on early-stage requests. The split:

- **Discovery brief** if the problem is still in question. *"Is there a real problem here?"*
- **Opportunity assessment** if the problem is established and the question is whether to invest. *"Should we staff this?"*

If unclear, ask: *"Is the question 'is there a problem here' or 'should we resource the fix'?"*

### Standard PRD vs Launch PRD

Both fire on build-stage requests. The split:

- **Standard PRD** if the audience is engineering and design, building from a clean start.
- **Launch PRD** if the audience extends to GTM, support, marketing, and the doc must coordinate the *landing*, not just the *build*.

If unclear, ask: *"Is the build underway, or are we still defining what to build?"*

### Standard PRD vs Technical RFC

Both can name engineering options. The split:

- **Standard PRD** if the product question is open ("what should this do for users?").
- **Technical RFC** if the product question is settled and the engineering question is open ("which way do we build the thing we already agreed on?").

If unclear, ask: *"Is the product behaviour decided, and you're choosing the build path? Or is the product still being defined?"*

### Opportunity assessment vs PR-FAQ

Both fire on "should we do this" framing. The split:

- **Opportunity assessment** if the question is internal — staff vs not staff, priority order, strategic fit.
- **PR-FAQ** if the question is customer-facing — would this excite a customer, would we be proud to launch this.

If unclear, ask: *"Is the doc trying to convince the leadership team to staff this, or trying to articulate what the customer-visible win would look like?"*

### Experiment brief vs Standard PRD

Both can describe a feature change. The split:

- **Experiment brief** if the unit of work is a test with a primary metric and a ship rule.
- **Standard PRD** if the unit of work is "we're shipping this regardless; how should it work".

If unclear, ask: *"Is this an A/B test with a ship rule, or are we committed to shipping it either way?"*

---

## Worked examples

### Example 1
**User input:** "Can you help me write a PRD for our new onboarding flow?"

**Signals:** "PRD", "new onboarding flow" — named feature, build implied, no exploratory or experimental language.

**Decision:** Standard PRD.

**State out loud:** *"Reading this as a Standard PRD — sounds like the build is committed. If you need launch-side content (comms, support enablement), say the word and I'll switch to a Launch PRD."*

### Example 2
**User input:** "We're thinking about whether to add team workspaces. Can you put something together?"

**Signals:** "thinking about whether" — exploratory, no commitment. "Add team workspaces" — named direction.

**Decision:** Discovery brief (problem isn't validated; we're in "should we do this" territory).

**State out loud:** *"Reading this as a Discovery brief — sounds like you're scoping rather than building. Light on detail, heavy on whether the problem's real and what we'd need to believe to invest more. Shout if you want a heavier shape."*

### Example 3
**User input:** "Write me an RFC for migrating our auth from Cognito to Clerk."

**Signals:** "RFC", "migrating", "from Cognito to Clerk" — explicit RFC, architectural choice.

**Decision:** Technical RFC.

**State out loud:** *"Reading this as a Technical RFC — adjudicating between engineering options. I'll structure as constraints, options compared, recommendation, migration plan, risks."*

### Example 4
**User input:** "I want to test whether moving the trial CTA above the fold lifts signup."

**Signals:** "test whether" — hypothesis testing. "Lifts signup" — primary metric implied.

**Decision:** Experiment brief.

**State out loud:** *"Reading this as an Experiment brief — testable hypothesis, single primary metric, ship rule. I'll ask one question about sample size and duration once we have the hypothesis nailed."*

### Example 5
**User input:** "We're launching the new pricing model next month. Can you write the PRD?"

**Signals:** "launching", "next month" — launch timing. Build implied done or nearly done.

**Decision:** Launch PRD.

**State out loud:** *"Reading this as a Launch PRD — build is presumably underway and the doc needs to coordinate launch across GTM and support. I'll include the comms plan, support enablement, and success thresholds tied to launch + 30 days."*

### Example 6
**User input:** "If we built a feature that did X, what would the press release look like?"

**Signals:** "press release", "if we built" — customer-facing story framing, pre-build.

**Decision:** PR-FAQ.

**State out loud:** *"Reading this as a PR-FAQ — Amazon Working Backwards shape. Press release first, then customer-facing FAQ, then internal FAQ that covers the hard questions about market size, build cost, and what could fail."*

### Example 7
**User input:** "Make the case for prioritising the dashboard rebuild this quarter."

**Signals:** "make the case for prioritising" — strategic / resourcing framing, no commitment yet.

**Decision:** Opportunity assessment.

**State out loud:** *"Reading this as an Opportunity assessment — making the resourcing case. I'll lead with the problem, evidence, what we'd need to believe to invest, and the cost of not doing it."*

---

## When the signal is genuinely ambiguous

If after running the decision flow plus tiebreakers the shape still is not clear, ask **one** clarifying question. Not five. The question should be the single one that resolves the shape, framed as a binary or a short list.

Good clarifying questions:

- *"Is the build underway, or are we still defining what to build?"* (Standard vs Discovery)
- *"Is the product behaviour decided?"* (Standard vs RFC)
- *"Is this an A/B test or a committed ship?"* (Experiment vs Standard)
- *"Is the doc for internal resourcing or for customer-facing alignment?"* (Opportunity vs PR-FAQ)

Bad clarifying questions:

- *"Which of these seven shapes would you like?"* — defeats the purpose of the skill.
- *"Can you tell me more about your situation?"* — too open, costs the user time.
- A multi-part question with three sub-questions. Pick one.

---

## Shape-switching mid-draft

If during drafting it becomes obvious the original pick is wrong, say so. Do not silently switch.

Pattern: *"[Name], looking at what you've described, this is bigger than a Discovery brief — there's real customer evidence and a clear direction. Switching to an Opportunity assessment. We'll keep what we have and add the staffing case."*

Two reasons it is worth interrupting:

1. The user gets to override (sometimes Discovery is the right choice even with evidence — they may not be ready to commit).
2. The shape change usually means the section list changes; better to surface than to silently reshape the doc.
