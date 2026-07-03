# [Outcome-phrased title — e.g. "Dunning recovery lifts net retention 1.5–2.0 points"]

> **v0.1 — [YYYY-MM-DD]**
> Data: [What this assessment is grounded in. E.g. "Stripe billing events Jan–Apr 2026; warehouse view `warehouse.billing.subscription_states` as of 2026-05-13; 6 customer-success interviews Mar–May 2026."]
> Changelog: First draft.

<!--
Opportunity assessment — Cagan's shape. 600–1,000 words.
Core question this doc answers: "Should we staff this?"
Reader: product leadership. Decision it unblocks: go / no-go on resourcing.
Heavier than a Discovery brief (problem is established) but lighter than a Standard PRD (no commitment to build).
The heart of this doc is the "What we'd need to believe to invest" section. Do not skip it.
-->

## TL;DR

[One sentence + recommendation. E.g. "Failed-payment recovery is currently 14% vs a benchmark 35%; staffing a 6-week dunning rebuild would recover ~$180K ARR annually. Recommendation: staff in Q3."]

## LLM Context — working memory (not part of the spec)

<!-- Pin this high (a collapsed Notion toggle is ideal) so it's recalled on every edit. The assessment's durable memory for AI-assisted editing: read before editing, append whenever a decision/constraint is set. NOT part of the assessment content below. Carries forward if this becomes a Standard PRD. -->

> Maintained for AI assistants and human editors as this assessment's durable memory. Records the decisions, conventions, and gotchas that explain the body but don't belong in it — so future edits recall them instead of re-litigating. Keep entries dated and terse.

**Locked decisions** *(newest first; don't silently reverse — log the reversal here)*
- `[YYYY-MM-DD]` — [decision + one-line why].

**Standing conventions** *(rules every later iteration must honour)*
- [e.g. "Scope is recovery only — acquisition lift is explicitly out, see Non-goals."]

**Known gaps & gotchas** *(traps a future editor or build will hit)*
- [e.g. "Stripe benchmark is 2025 — refresh before quoting in the go/no-go review."]

**Open threads** *(parked, not yet decided — promote into the body once resolved)*
- [ ] [question — owner].

## Problem statement

[2–4 sentences. What is broken, for whom, with evidence. The problem is real — that's why we're past discovery. State it as a fact with the source named.]

[Example: "Customers on lapsed-payment status currently recover at 14% over 30 days, against a SaaS benchmark of 35% (Stripe Billing benchmarks, 2025). The gap costs the business an estimated $180K ARR per year at current MRR base. Six CS interviews (Mar–May 2026) confirm the recovery flow is generic Stripe emails with no segment-specific copy, no dunning tier escalation, and no in-app surface."]

## Customer evidence

[Required. Without this, this section is a hypothesis, not an assessment. Cite interviews, support tickets, analytics, NPS verbatims — linked or referenced.]

| Source | Date | Signal |
|---|---|---|
| [Interview set name] | [date range] | [What we heard, in one line] |
| [PostHog query / dashboard] | [date] | [The number, with baseline] |
| [Support ticket cluster] | [date range] | [Volume + theme] |

[Optional 2–3 sentences of synthesis below the table. What pattern emerged.]

## Strategic fit — why now

[One paragraph. How this aligns to the current company priorities, market signal, or competitive context. If it doesn't align, say so — and explain why we'd staff it anyway, or recommend defer.]

[Example: "Net retention is the board's #1 priority for FY26. Recovery uplift maps directly. Dunning also unblocks the planned annual-billing motion, which depends on a credible failed-payment recovery flow. No competitive pressure — this is internal capability, not market-driven."]

## Definition of done

[What does success look like, concretely. Metric + baseline + target + time window + dashboard.]

| Metric | Baseline | Target | Window | Dashboard |
|---|---|---|---|---|
| [e.g. Failed-payment recovery rate] | [14% — Stripe Billing, 30d window] | [25% by month 3; 30% by month 6] | [Rolling 30d] | [Warehouse insight `dunning_recovery_rate`] |

> guidance: if you wrote "improve recovery" without a number, that's failure mode #2 — unmeasurable success. Force the metric.

## What we'd need to believe to invest

[The heart of this shape. List 3–5 beliefs that would make this a yes. Each one falsifiable, with the test that would confirm or kill it.]

1. **[Belief — e.g. "Segment-specific copy lifts recovery by 5+ points over generic copy."]** — Test: [the smallest experiment that would confirm. E.g. "2-week A/B on lapsed-payment cohort: generic vs segment-specific copy. n=400, primary metric recovery rate at 14d."]
2. **[Belief 2.]** — Test: [the test].
3. **[Belief 3.]** — Test: [the test].

> guidance: if you can't articulate what would change your mind, this isn't an assessment — it's advocacy. Rewrite.

## Cost of not doing it

[One paragraph. The dollar / strategic / morale cost of leaving the gap open for another quarter or year. Make it concrete.]

[Example: "Leaving recovery at 14% costs ~$45K ARR per quarter at current MRR. Compounds with growth — at 2x MRR the gap is $90K/quarter. Also blocks the annual-billing motion: CFO has flagged she will not sign off on annual offers until dunning is credible."]

## Estimated investment

[Rough sizing. Months, FTEs, dependencies. Order-of-magnitude is fine at this stage — precision belongs in the Standard PRD.]

| Resource | Estimate |
|---|---|
| Engineering | [e.g. 1 backend + 0.5 frontend, 6 weeks] |
| Product | [e.g. 0.3 PM, 6 weeks] |
| Design | [e.g. 0.5 designer, 2 weeks front-loaded] |
| External | [e.g. Stripe Billing add-on, ~$400/mo] |

## Risks and assumptions

[Named. Owner-tagged. Mitigation or kill-criteria where applicable. Minimum three.]

| Risk | Owner | Mitigation / kill criteria |
|---|---|---|
| [e.g. Stripe webhook reliability degrades recovery flow] | [Eng lead] | [Add idempotency guard; kill if webhook loss >2%/week] |
| [Risk 2] | [Owner] | [Mitigation] |
| [Risk 3] | [Owner] | [Mitigation] |

## Recommendation

[One paragraph. Staff / defer / kill, with reasoning. Take a position — this is the whole point of the doc.]

[Example: "Staff in Q3. The recovery gap is large, the evidence is direct, and the dependency chain to annual billing makes deferring a compound cost. Single biggest risk is webhook reliability; address with idempotency before launch. If activation work in Q3 is over-subscribed, defer to Q4 — do not split staffing across both."]

---

*Author: [Name]. Owner: [Name]. Last updated: [YYYY-MM-DD]. Source data: [Stripe billing export / PostHog dashboard / interview set, with dates].*
