# Failure Modes — Deep Reference

This is the long-form reference for SKILL.md Step 7. Ten named failure modes, with detection signals concrete enough to run mechanically against a drafted PRD, the downstream cost when they ship, the fix pattern, and a worked before/after.

Use this in two ways:

1. While drafting — keep these in peripheral vision so the draft does not produce them in the first place.
2. After drafting — run the scan section at the bottom of this file against the finished draft, surface findings to the user, never auto-fix.

The detection patterns are written so any reader (Claude, a human reviewer, a linter) can apply them without judgment calls. Where judgment is required, the rule says so explicitly.

---

## 1. Solution masquerading as problem

**What it is.** The problem statement is actually a solution description. The author has skipped past the user pain and gone straight to the fix. The reader cannot tell what is broken for whom — only what the author wants to build.

**How to detect it.** Scan the problem statement (the first paragraph or section after the TL;DR) for any of:

- Trigger phrases: "by adding", "by introducing", "via a new", "we will build", "we need a", "by implementing", "through a new", "lack of [feature name]".
- Structural absence: no named user segment, no named user task, no evidence reference. If the paragraph describes what to build without naming who is hurt and how, it fires.
- Title test: the title contains a feature name ("Add tags", "New onboarding modal") rather than an outcome. This usually co-fires with failure mode 5.

**Why it kills PRDs.** Engineering and design have no way to evaluate alternative solutions because the problem is pre-fitted to one fix. The team builds the named feature and discovers afterwards that the feature did not move the metric — because the metric was never grounded in a problem in the first place. Cagan's number-one critique of PRDs.

**The fix pattern.** Rewrite the problem statement in the form: *"[Segment] cannot [task] because [reason], which costs [evidence]."* Strip every reference to the proposed solution. Move solution language down to its own section. Confirm the rewritten problem could be solved by at least two different approaches — if it cannot, it is still a solution in disguise.

**Worked example.**

| | Bad | Fix |
|---|---|---|
| Problem statement | "We lack a tagging system on support tickets, so we will build a multi-select tag input on the ticket detail screen." | "Support agents triage 80+ tickets per shift and cannot filter by issue type, status, or assigned engineer. 60% of agent interviews (n=15, Mar 2026) cite this as the top friction. Triage time averages 22 seconds per ticket versus a 7-second target." |

---

## 2. Unmeasurable success

**What it is.** The success section uses qualitative language ("improve", "better", "increase", "reduce friction", "delight users") without a metric name, a current baseline, a target, a time window, or a dashboard reference.

**How to detect it.** Scan the success metrics section for:

- Trigger phrases: "improve X", "better Y", "increase Z", "drive more", "delight", "reduce friction", "boost", "lift", "uplift" — appearing without a number nearby.
- Structural absence: no metric name, no baseline value (or no acknowledgement that baseline is unknown), no target value, no time window ("by 30 days post-launch"), no dashboard URL or warehouse view name.
- Numeric vacuum: the section contains adjectives but no numerals.

**Why it kills PRDs.** Without a measurable success criterion the team ships the feature, declares victory, and moves on — and nobody can ever say whether it worked. Worse, the team cannot kill the feature later because there is no falsifiable claim to fail. Doshi specifically calls out the missing dashboard.

**The fix pattern.** Every success metric must resolve as: metric name + baseline (or "not yet tracked" with an instrumentation owner) + target + time window + dashboard location. If the baseline is unknown, that itself is a NEED (see failure mode 7 of skill Step 5) — name the owner and deadline for instrumentation.

**Worked example.**

| | Bad | Fix |
|---|---|---|
| Success line | "Improve onboarding so more users activate." | "Activation D7 (warehouse view `warehouse.events.activation_d7`) — baseline 32% (Q1 2026), target 40% by 60 days post-launch. Guardrail: signup-to-first-key-action time stays under 24h." |

---

## 3. No non-goals

**What it is.** The doc lists what we will do but never what we will not do. Scope is unbounded. The reader has to guess where the line is.

**How to detect it.** Check for the presence and content of a non-goals section:

- Structural absence: no section titled "Non-goals", "Out of scope", "What this PRD does not cover", "Not in scope", or equivalent.
- Quantity test: section exists but contains fewer than three items.
- Quality test: items are negations of in-scope items ("we will not fail to ship X") rather than genuine scope declines ("we will not address admin-side UI in this release").

**Why it kills PRDs.** Scope creep is the single most common cause of slipped PRD delivery. Engineering reads the doc, finds an unaddressed edge case, and either builds it (adding weeks) or punts it without anyone agreeing (creating a future surprise). A non-goals section pre-empts both.

**The fix pattern.** Require at least three non-goals before marking the draft ready. Good non-goals are adjacent work the team might plausibly do, named explicitly as not-this-time, with a one-line reason. Bad non-goals are trivial ("not building a rocket ship").

**Worked example.**

| | Bad | Fix |
|---|---|---|
| Non-goals section | (missing) | "**Non-goals.** (1) Admin-side tag management UI — admins edit tags via the existing settings page until v2. (2) Bulk-edit of tags across tickets — single-record edits only in this release. (3) Tag-based reporting dashboards — surfaced as filters in the existing dashboard, no new charts." |

---

## 4. Premature solutioning

**What it is.** The doc contains wireframes, API contracts, data models, or implementation detail before the problem statement, target user, and success metrics are nailed down. The reader is asked to evaluate a "how" before the "what" and "why" are settled.

**How to detect it.** Scan the section order and content:

- Position test: any of [wireframe link, Figma URL, API endpoint table, schema diagram, data model, code snippet, sequence diagram] appears before [problem section is complete, target user named, success metrics defined with numbers].
- Density test: solution section length exceeds problem + success combined by more than 2x in a non-launch PRD.
- Cagan signal: the doc reads as "here is the design — let me retrofit a problem to it".

**Why it kills PRDs.** Engineering cannot evaluate the proposed implementation because there is no problem yardstick. Design alternatives are foreclosed. The team optimises the chosen solution rather than choosing among solutions. Cagan's most-cited PRD failure mode.

**The fix pattern.** Mechanically prevent solution sections from being drafted until the problem, target user, and success metrics sections are complete. If the user provides solution detail in their initial request, accept it as input but write the problem and success sections first. Refer to solution detail only after the "why" is anchored.

**Worked example.**

| | Bad | Fix |
|---|---|---|
| Section 1 of a Standard PRD | "## Solution. The ticket detail screen will have a new TagInput component (see Figma link), backed by `POST /api/v1/tickets/:id/tags`. Tags are stored in a new `tags` table joined via `ticket_tags`. The component supports..." | "## Problem. Support agents cannot filter their ticket queue [...]. ## Success metrics. Triage time per ticket [...]. ## Solution overview. Agents can tag tickets with one or more labels and filter the queue by tag. (Detailed design: Figma link in appendix.)" |

---

## 5. Feature-named initiative

**What it is.** The doc title or stated mission names the output ("Add tags to work orders") rather than the outcome ("Coordinators triage 50% faster"). The team and the doc orient around the feature, which makes the feature impossible to kill or pivot away from.

**How to detect it.** Title and mission test:

- Title pattern: starts with "Add", "Build", "Implement", "Launch", "New", "Introduce", or names a UI element ("...modal", "...screen", "...flow", "...button").
- Mission test: the one-line description names a thing rather than a change in user or business behaviour.
- Pivot test: if the team decided to solve the same problem a different way, would the title still apply? If no, the title is feature-named.

**Why it kills PRDs.** Once an initiative is named by its feature, abandoning the feature feels like abandoning the project. Pivots become socially expensive. Cutler's primary failure mode. Outcomes-named initiatives survive pivots because the outcome is the constant.

**The fix pattern.** Rewrite the title as an outcome. Pattern: *"[Segment] [does new behaviour] [by how much] [by when]."* Or the consequence form: *"[Business metric] changes from [baseline] to [target]."* The feature name lives in the solution section, not the title.

**Worked example.**

| | Bad | Fix |
|---|---|---|
| Title | "Add tags to support tickets" | "Agents triage their queue 3x faster" |
| One-line mission | "Build a multi-select tag input on the ticket detail screen." | "Support agents clear their morning queue in under 10 minutes versus the current 30." |

---

## 6. No customer evidence

**What it is.** The problem is stated as fact with no research, no interview, no analytics, no support ticket, no anecdote. The author is asserting from their own intuition without surfacing the source.

**How to detect it.** Scan the problem section for any of:

- Citation absence: no parenthetical reference, no link, no footnote, no quoted research finding, no warehouse view name, no interview count.
- Trigger phrases: "users want", "customers struggle with", "we know that", "obviously", "everyone agrees", "it's clear that" — without a citation nearby.
- Quote absence: no direct customer language in the problem section. A real problem usually has a real quote attached.

**Why it kills PRDs.** Engineering and design build to the loudest opinion in the room. The team discovers post-launch that the "obvious" pain was felt by 5% of users, not 80%. Aakash Gupta's number-one PRD quality flag.

**The fix pattern.** Require at least one evidence reference per problem claim. Acceptable evidence: interview count + date range, warehouse view + value, support ticket count + period, NPS verbatim with date, sales call transcript reference. If no evidence exists, name that — and add it as a NEED in the dependency table with a research owner.

**Worked example.**

| | Bad | Fix |
|---|---|---|
| Problem evidence | "Buyers hate the current checkout — it's hard to find anything." | "Buyers hate the current checkout (n=15 interviews, Mar–May 2026; 12/15 raised address autocomplete as top friction unprompted). Warehouse view `warehouse.events.checkout_session_actions` shows mean session time 8m12s versus 2m30s benchmark in comparable apps." |

---

## 7. Tradeoffs avoided

**What it is.** The doc reads as if the proposed work has no cost. No mention of what gets worse, who is unhappy, what the team is betting against, what the alternative use of the engineering hours would have been.

**How to detect it.** Scan the whole doc for tradeoff language:

- Trigger phrases (presence test): "tradeoff", "cost", "we accept that", "we're betting against", "what gets worse", "the downside is", "we lose", "in exchange we accept". If none of these appear, the doc has no surfaced tradeoff.
- Risks section content: if a risks section exists but reads as a sales pitch ("low risk because we have a great team"), tradeoffs are still missing.
- Implicit-tradeoff test: any meaningful product decision has a downside. If the doc names no downside on any decision, the author has not surfaced them.

**Why it kills PRDs.** The doc presents the work as a free lunch. Stakeholders approve based on incomplete information. The tradeoff appears post-launch (the metric we did not name regressed; the user segment we did not name complained). Aakash Gupta and Amazon both flag this — Amazon's "truth-seeking, not selling".

**The fix pattern.** Require an explicit "tradeoffs" or "what gets worse" line in the doc. Pattern: *"By doing X, [Y gets worse / Z segment is unhappy / we accept the cost of W]."* Every meaningful decision in the doc should have one. Name conversion losses, user-experience regressions, technical debt, opportunity cost. The honesty makes the doc trustworthy.

**Worked example.**

| | Bad | Fix |
|---|---|---|
| Decision write-up | "We will replace the existing queue with the new tagged queue across all tenants on day one." | "We will replace the existing queue with the new tagged queue across all tenants on day one. **Tradeoffs.** (1) Agents with muscle memory for the old queue lose ~2 days of productivity during the transition (we accept; in-app coachmarks deployed to compress to <1 day). (2) Tenants on the legacy data model (~12% of accounts) see degraded filter performance for 48h while migration completes. (3) Opportunity cost: 6 eng-weeks not spent on the macros rewrite — accepted because queue triage moves a larger metric." |

---

## 8. Length as quality proxy

**What it is.** The author treats word count as evidence of seriousness. The doc balloons past 3,000 words for non-launch scope. The result is unread.

**How to detect it.** Mechanical word-count check by shape:

| Shape | Warn at | Hard limit (require justification) |
|---|---|---|
| Discovery brief | 600 | 800 |
| Opportunity assessment | 1,000 | 1,300 |
| PR-FAQ | 3,000 | 3,500 |
| Standard PRD | 3,000 | 3,500 |
| Launch PRD | 4,000 | 5,000 |
| Technical RFC | 3,000 | 3,500 |
| Experiment brief | 1,200 | 1,500 |

Secondary signal: sections that exceed 40% of total doc length almost always need to split. Repeat-content test: any paragraph that restates a point made earlier (with different words) is padding.

**Why it kills PRDs.** Long docs do not get read in full. Reviewers skim the first page, scan for headings, and approve based on partial reading. The PRD becomes a CYA artefact rather than a decision instrument. Reforge and Doshi both flag this.

**The fix pattern.** Warn at the shape's threshold; require justification at the hard limit. Suggest splitting: a strategy PRD (the *why* and *what*) plus an implementation PRD (the *how* and *when*). Move detail to an appendix. Cut hedging and restatement first — that usually saves 20% before any real content is removed.

**Worked example.** A Standard PRD at 4,200 words usually splits cleanly into a Strategy PRD (1,400 words — problem, success, solution overview, non-goals) plus an Implementation PRD (2,800 words — detailed flows, data, QA, phasing). A long dunning-recovery PRD covering segment-specific copy, in-app surfaces, and webhook reliability is the canonical example of a doc that should have been split.

---

## 9. No pre-mortem / no risks

**What it is.** The risks section is missing, or present but written as sales material. The reader cannot tell what the author thinks could kill this initiative. No bets are named. No kill criteria are stated.

**How to detect it.** Scan for the risks section and its content:

- Structural absence: no section titled "Risks", "Open questions", "Things that could kill this", "Pre-mortem", "Assumptions to validate", or equivalent.
- Quantity test: section exists with fewer than three items.
- Tone test: items read as advantages disguised as risks ("risk: this might be so successful that support is overwhelmed").
- Kill-criteria test: no statement of what would cause the team to stop, pivot, or roll back.

**Why it kills PRDs.** The team learns about the risks after launch, when mitigation is expensive. Stakeholders cannot calibrate confidence. The doc cannot earn trust because it has not surfaced its own weakness. Doshi's pre-mortem call; Amazon's truth-seeking.

**The fix pattern.** Require at least three risks with named mitigations or kill criteria. Pattern per risk: *"Risk: [what could go wrong]. Likelihood: [low/medium/high]. Impact: [what it costs]. Mitigation or kill criterion: [the response]."* Genuine risks usually fall into: technical (does the build work), market (does the user care), operational (can we support it), commercial (does the business model survive contact with reality).

**Worked example.**

| | Bad | Fix |
|---|---|---|
| Risk entry | "Risk: this might be too successful and we'll have to scale." | "Risk: agent adoption stalls below 30% in week 4. Likelihood: medium — past in-app feature launches average 22% adoption in week 4. Impact: success metric (triage time) cannot move without adoption. Kill criterion: if adoption is <20% at week 6 with coachmarks deployed, pause the rollout and ship the alternative macros redesign instead." |

---

## 10. Stale assumptions left implicit

**What it is.** The author knows things that the doc does not state. The PRD is internally consistent only if you hold a mental model the author has not surfaced. New readers, future readers, and AI tools cannot reconstruct the reasoning.

**How to detect it.** Two structural and one semantic check:

- Operating assumptions section presence: a doc with no "Operating assumptions" or "What we believe" section almost certainly has implicit ones.
- Reader test: read the doc as if you joined the team today. Are there claims that cannot be evaluated without prior context? Each one is an implicit assumption.
- Date-stamping test: the doc references a market state, a team structure, a competitor's position, or a tech constraint without saying when the snapshot was taken. State changes; un-dated claims age silently.

**Why it kills PRDs.** Six months later the doc is wrong and nobody can tell. The new PM cannot pick up the thread. The team argues about decisions whose premises were never written down. Cutler explicitly flags "operating assumptions" as a load-bearing section.

**The fix pattern.** Require an "Operating assumptions" section, even if short. List the load-bearing beliefs the doc rests on, with a date stamp. Examples: "We assume Stripe webhook latency stays under 10s p95 (as of May 2026)." / "We assume support team headcount per region stays at 2–4 (no shift expected this fiscal year)." / "We assume the Pro plan remains the modal customer (currently 62% of revenue)." Date every assumption.

**Worked example.**

| | Bad | Fix |
|---|---|---|
| Doc opens with problem statement, no assumptions section | (implicit assumption that warehouse view names are stable) | "## Operating assumptions. (1) Warehouse views under `warehouse.events.*` remain canonical through end of FY26. (2) Support-agent role exists in the customer org chart at all tenants on Pro plan and above. (3) Customer.io remains the messaging surface for in-app coachmarks (no Iterable migration planned)." |

---

# How to run the scan

After producing a first complete draft, run this checklist mechanically against the doc. For each fire, surface the finding to the user with the response template. Do not auto-fix. Severity is the recommended response weight.

The scan is read-only. The user accepts or overrules with reasoning.

| # | Failure mode | Trigger pattern | Response template | Severity |
|---|---|---|---|---|
| 1 | Solution masquerading as problem | Problem section contains: "by adding" / "by introducing" / "via a new" / "we will build" / "we need a" / "by implementing" / "lack of [feature name]" — OR no named user segment + task + evidence in the first paragraph. | "Problem statement reads as a solution. Suggest rewriting as: '[Segment] cannot [task] because [reason], which costs [evidence].' Strip [trigger phrase]." | High |
| 2 | Unmeasurable success | Success section contains "improve" / "better" / "increase" / "delight" / "reduce friction" / "lift" without an adjacent number — OR no metric name + baseline + target + time window + dashboard reference. | "Success criterion not measurable. Suggest the form: metric + baseline + target + time window + dashboard location. If baseline unknown, raise as a NEED." | High |
| 3 | No non-goals | No section titled "Non-goals" / "Out of scope" / "Not in scope" / "What this PRD does not cover" — OR section present with fewer than 3 items. | "Non-goals section [missing / has only N items]. Require at least 3. What is the team explicitly choosing not to do in this scope?" | High |
| 4 | Premature solutioning | Any wireframe / Figma URL / API endpoint table / schema / code snippet appears before the problem section is complete and success metrics are defined with numbers — OR solution section is >2x the combined length of problem + success in a non-launch PRD. | "Solution detail precedes a complete problem and success section. Suggest moving [solution content] below the problem / success / non-goals sections." | High |
| 5 | Feature-named initiative | Title starts with "Add" / "Build" / "Implement" / "Launch" / "New" / "Introduce" — OR title names a UI element ("modal", "screen", "flow", "button") — OR mission line names a thing rather than a behaviour change. | "Title names the output, not the outcome. Suggest the form: '[Segment] [does new behaviour] [by how much] [by when].' Feature name lives in the solution section." | Medium |
| 6 | No customer evidence | Problem section has zero parenthetical references / links / footnotes / interview counts / warehouse view names — OR contains "users want" / "customers struggle with" / "we know that" / "obviously" / "everyone agrees" without an adjacent citation. | "Problem stated without customer evidence. Require at least one citation per problem claim (interview count + date, warehouse view, support ticket count, NPS verbatim). If no evidence exists, raise as a NEED with a research owner." | High |
| 7 | Tradeoffs avoided | Doc contains zero instances of "tradeoff" / "cost" / "we accept that" / "we're betting against" / "what gets worse" / "the downside is" / "we lose" — OR risks section reads as advantages. | "No tradeoffs surfaced. Suggest naming the downside on the top 2–3 decisions in the doc: '[By doing X, Y gets worse / Z segment is unhappy / we accept the cost of W].'" | Medium |
| 8 | Length as quality proxy | Word count exceeds the shape's warn threshold (Discovery 600 / Opportunity 1,000 / PR-FAQ 3,000 / Standard 3,000 / Launch 4,000 / RFC 3,000 / Experiment 1,200) — OR any single section is >40% of doc length. | "Draft is [N] words versus the [shape] warn threshold of [M]. Suggest: (a) cut hedging and restatement first; (b) move detail to appendix; (c) consider splitting into Strategy PRD + Implementation PRD." | Medium (High past hard limit) |
| 9 | No pre-mortem / no risks | No section titled "Risks" / "Open questions" / "Pre-mortem" / "Assumptions to validate" — OR section present with fewer than 3 items — OR no kill criteria stated anywhere. | "Risks section [missing / has only N items / lacks kill criteria]. Require at least 3 risks with named mitigations or kill criteria. Cover technical, market, operational, commercial axes." | High |
| 10 | Stale assumptions left implicit | No section titled "Operating assumptions" / "What we believe" — OR claims about market / team / competitor / tech reference an undated snapshot. | "Operating assumptions not surfaced. Suggest a short section listing the load-bearing beliefs with date stamps. Date every assumption." | Medium |

Severity guide for the response:

- **High** — the PRD should not ship without resolving. Flag prominently. The user can overrule with reasoning, but the default is fix.
- **Medium** — the PRD is functional without resolving, but quality drops. Flag clearly. The user is more likely to accept the tradeoff.

After running the scan, present the findings as a single bulleted list under a heading like "Issues to address before ship". Each finding names the failure mode, the location in the draft, and the response template. Then offer the three Step 8 next moves: Sharpen, Split, Ship.
