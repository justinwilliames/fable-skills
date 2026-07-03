# [Outcome-phrased title, not feature-named — e.g. "Sales reps triage their pipeline 50% faster"]

<!-- Cite-provenance pattern per Mehta / Doshi / Cagan — every PRD opens by naming its evidence base. -->

> **v0.1 — [YYYY-MM-DD]**
> Data: [What this PRD is grounded in, fetched when, from where. E.g. "Warehouse views `warehouse.crm.deal_stage_transitions` and `warehouse.events.rep_pipeline_actions` as of 2026-05-13. Customer evidence: 6 interviews across Mar–May 2026. Support ticket sample: 42 tickets tagged `pipeline-friction` from Q1 2026."]
> Changelog: First draft.

<!--
Standard PRD — Lenny Rachitsky's flat one-pager structure, extended with Reforge's 10-component spec for multi-week build scope. 1,500–3,000 words.
Core question this doc answers: "What are we building, and how do we know it works?"
Reader: engineering, design, QA. Decision it unblocks: build can start.
-->

## TL;DR

[Three lines. Problem / solution / success. One sentence each. Bold the lift you're claiming.]

[Example shape:
- **Problem:** Sales reps lose 6–12 minutes per shift switching between their CRM and the dialer to log deal-stage transitions.
- **Solution:** Inline deal-stage capture in the deal row, with auto-fill from the dialer webhook payload.
- **Success:** Time-to-log down from 4m 18s median to under 90s, lifting weekly deal-stage update completeness from 32% to 38% within 8 weeks of launch.]

## LLM Context — working memory (not part of the spec)

<!-- Pin this high (a collapsed Notion toggle is ideal) so it's recalled on every edit. The PRD's durable memory for AI-assisted editing: read before editing, append whenever a decision/convention/constraint is set. NOT product scope — never a substitute for the must-haves below. -->

> Maintained for AI assistants and human editors as this PRD's durable memory. Records the decisions, conventions, and gotchas that explain the body but don't belong in it — so future edits recall them instead of re-litigating. Keep entries dated and terse.

**Locked decisions** *(newest first; don't silently reverse — log the reversal here)*
- `[YYYY-MM-DD]` — [decision + one-line why].

**Standing conventions** *(rules every section / variant must honour)*
- [e.g. "Pro and Enterprise only — never a Free-plan surface."]

**Known gaps & gotchas** *(traps a future editor or build will hit)*
- [e.g. "Warehouse `deal_stage_logged` lags ~15 min — don't trust it for real-time reads."]

**Open threads** *(parked, not yet decided — promote into the body once resolved)*
- [ ] [question — owner].

## Problem

[2–4 paragraphs. What is broken, for whom, with evidence inline. Cite the source — interview, warehouse query, ticket count — for every claim. Real problems describe user pain or business gap, never the proposed fix.]

[Example: "Sales reps at mid-market SaaS teams lose 6–12 minutes per shift switching between Salesforce and their dialer to log deal-stage transitions — flagged in 4 of 6 Mar–May 2026 customer interviews as their top daily friction. Warehouse event `deal_stage_logged` (90-day window) shows a median time-to-log of 4m 18s against the 30s target in the workflow spec. Support tickets tagged `pipeline-friction` ran 42 in Q1, up from 18 in Q4 — a 2.3x increase as deal volume scaled with the Pro-plan customer base."]

> guidance: Lenny's first rule — "nailing the problem statement is the single most important step". If you wrote "by adding", "via a new", or "we will build" in this section, that's solution masquerading as problem (failure mode 1). Rewrite to "[Segment] cannot [task] because [reason], which costs [evidence]."

## Target user

[One paragraph. Lenny's "Audience" section. Specific segment, not "users". Named role, named context, named scale. Note the segment size if you know it.]

[Example: "Sales reps at mid-market SaaS teams with 5–25 reps per pod, who log 30+ deal-stage transitions per day and own the pipeline-hygiene workflow. ~340 organisations on the Pro plan match this profile (warehouse view `warehouse.crm.org_segment`, May 2026), representing ~62% of Pro-plan MRR."]

## Why now

[One paragraph. Strategic fit, market signal, evidence of demand. Why this quarter, not next. Cagan's opportunity-assessment element — the doc must justify the investment, not just describe it.]

[Example: "Pro-plan churn rose from 4.1% to 6.8% month-over-month between Feb and Apr 2026, with exit-interview notes citing 'too much manual data entry' in 7 of 12 churn calls. The Q2 OKR commits Pro-plan net retention to 95%; fixing the dominant friction point in the rep workflow is the highest-leverage move available before the July board readout."]

## Success metrics

[Table format. Baseline + target + dashboard + owner per metric. Baseline can be "not tracked" — that's honest signal that the instrumentation conversation is now part of scope.]

| Metric | Baseline | Target | Time window | Dashboard | Owner |
|---|---|---|---|---|---|
| Median time-to-log (deal-stage transition) | 4m 18s (warehouse `deal_stage_logged` p50, 90d) | <90s | 8 weeks post-launch | Warehouse dashboard `rep-workflow-health` | RevOps |
| Weekly deal-stage update completeness (Pro plan) | 32% (warehouse `warehouse.crm.update_completeness`) | 38% | 12 weeks post-launch | Warehouse `pro-pipeline-hygiene` | RevOps |
| Support tickets tagged `pipeline-friction` | 42 / quarter | <20 / quarter | Q3 2026 | CRM ticket dashboard | Support |
| Rep NPS (in-app survey) | not tracked | establish baseline + 10pt lift | 12 weeks post-launch | Sprig dashboard `rep-nps` | Product |

> guidance: Doshi specifically calls out the dashboard view — "most PRDs don't cover what the dashboard will look like". Every row needs all five columns. "Improve", "better", "increase" without a number, baseline, or dashboard is unmeasurable success (failure mode 2). If a baseline is genuinely unknown, write "not tracked" — that surfaces the instrumentation work honestly. Every metric also names the event or source that produces it; a "not tracked" baseline adds a matching NEED row to Dependencies for the instrumentation work — a metric nobody instruments is failure mode 2 wearing a table.

**Measurement design** *(decided now, not post-hoc — how the effect will be isolated)*

- [Holdout / control: e.g. "5% holdout via no-send branch; activation rate (event `X` within 14d) read at 30 days, holdout vs treated." If deliberately no holdout: name the reason and the fallback read — "pre/post on dashboard Y; seasonality caveat: Q4 uplift overlaps the read window."]

## Solution overview

[2–3 paragraphs. The WHAT, not the HOW. Describe the user-facing behaviour, the moments of value, and what changes for the operator. Avoid implementation detail — that belongs in the engineering follow-up.]

> guidance: Cagan's first rule — "the PRD's goal is to explain the *what*, not the *how*". If you find yourself writing API contracts, data models, or wireframe-level detail in this section, you're solutioning prematurely (failure mode 4). Hold the line.

## Key user flows

[Step-by-step, or link to prototype. Number each step. Note the inputs, the system response, and the visible state change.]

[Prototype link (preferred): `[Figma — Inline deal-stage capture v4](https://...)`]

1. [Step — input — system response — visible change. E.g. "Rep ends a dialer call — system auto-creates the next-action row in the CRM with deal ID, outcome, and `deal_status: unresolved` — row appears in the pipeline view within 2 seconds."]
2. [Step.]
3. [Step.]
4. [Step.]

> guidance: Mehta's preference — a working prototype linked from the doc beats prose for "what does it look like". Use the prototype as the source of truth and number the flow only to anchor reviewer comments.

## Scope

[Bulleted list. What this PRD covers. Be specific.]

- [Scope item — e.g. "Inline deal-stage capture for outbound dialer events on the deal-row pipeline view."]
- [Scope item.]
- [Scope item.]

## Non-goals

[Minimum 3 items. Lenny + Kevin Yien (Square): "as important as the goals". Pre-empts scope creep and the "why didn't you do X?" question.]

- [Non-goal — e.g. "Not redesigning the CRM deal-row layout. Surface only, no IA change."]
- [Non-goal — e.g. "Not extending to inbound calls. Outbound pipeline only for v1."]
- [Non-goal — e.g. "Not building a rep-side analytics view. Reporting stays in the warehouse."]
- [Non-goal — e.g. "Not a Free-plan feature. Pro and Enterprise only."]

**Rabbit holes** *(Shape Up — obvious-but-wrong adjacent work the team might wander into. Name each one, then say "tempting — don't" with the reason.)*

- **[Rabbit hole 1]** — Tempting. Don't. [Reason. E.g. "Building a generic 'logged events' framework instead of solving the deal-stage case. The framework adds 4–6 weeks of scope and we don't have a second use case yet."]
- **[Rabbit hole 2]** — Tempting. Don't. [Reason.]
- **[Rabbit hole 3]** — Tempting. Don't. [Reason.]

> guidance: fewer than three non-goals is failure mode 3. Lenny names this as one of the highest-leverage sections in the whole doc. Tag each exclusion: **constraint** (a gap that could unblock later — name what unlocks it) or **decision** (deliberate and stable — name the owner). Bare exclusions teach the next reader nothing.

## Dependencies + decisions required

[NEED / PROCEED-WITHOUT decision table. Force every dependency to a binary outcome — no TBDs. Doshi: "forcing ourselves to write down our thinking enables consensus better than a meeting". Cagan: deferred decisions create silent coordination cost.]

| ID | Item | Decision | Owner | Deadline | Reason / Cost |
|---|---|---|---|---|---|
| D1 | Dialer webhook payload includes `deal_id` field | NEED | Lead Eng | 2026-06-01 | Without it we cannot auto-fill the deal row — feature does not work. |
| D2 | Warehouse event `deal_stage_logged` includes `time_to_log` property | NEED | Data Eng | 2026-06-08 | Required to measure success metric 1. No baseline visibility otherwise. |
| D3 | Localised copy for FR-market reps | PROCEED WITHOUT | — | — | French speakers see English copy on launch; ~3% of Pro audience. Add in Phase 2 if Pro FR signups exceed 50/month. |

> guidance: no "TBD" rows. If the answer isn't known, the row stays NEED with owner = "<who to ask>" and deadline = "before scoping freeze". Force the decision now, not in standup later.

## Risks + mitigations

[Minimum 3 named risks with explicit mitigations, ranked by likelihood × impact — pre-mortem framing: what kills this? Cutler: "risks to mitigate". Each mitigation names a threshold, the signal you'll watch, and the response.]

- **Risk 1 — [Name].** [Why it matters.] **Mitigation:** [What we'll do to prevent or contain it.] [Example: "Dialer webhook delivery is occasionally delayed >30s under load — would break the auto-fill UX. Mitigation: add a 60s polling fallback on the deal-row view; surface a `Sync now` button if no event has landed within 90s."]
- **Risk 2 — [Name].** [Why it matters.] **Mitigation:** [What we'll do.]
- **Risk 3 — [Name].** [Why it matters.] **Mitigation:** [What we'll do.]

> guidance: name the tradeoff explicitly — what gets worse, who's unhappy, what we're betting against. A risks section that reads like sales material is failure mode 9. A mitigation without a threshold + signal + response ("monitor closely") is decoration — write "if unsubscribe > 0.8% in week 1, collapse to a single send per module".

## Open questions

[Numbered. Owner-tagged. State a recommendation where you have one. Aggregate the inline open items here; don't leave them scattered.]

1. [Question — owner — recommendation. E.g. "Should the auto-fill be reversible (i.e. rep can revert to manual entry)? Owner: PM. Recommendation: yes, with a single-click revert — protects against bad payloads without adding modal-level friction."]
2. [Question — owner — recommendation.]
3. [Question — owner — recommendation.]

## Owner + collaborators + timeline

| Role | Name |
|---|---|
| PRD owner | [Name] |
| Engineering lead | [Name] |
| Design lead | [Name] |
| Data / analytics | [Name] |
| QA | [Name] |
| Target build start | [YYYY-MM-DD] |
| Target ship | [YYYY-MM-DD] |

---

*Author: [Name]. Owner: [Name]. Last updated: [YYYY-MM-DD]. Source data: [Warehouse view / interview set / analytics query, with date].*
