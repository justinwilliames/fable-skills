# [Outcome-phrased title, not feature-named — e.g. "Merchandisers update the seasonal catalog 50% faster — launch plan"]

<!-- Cite-provenance pattern per Mehta / Doshi / Cagan — every PRD opens by naming its evidence base. -->

> **v0.1 — [YYYY-MM-DD]**
> Launch target date: [YYYY-MM-DD]
> Data: [What this PRD is grounded in, fetched when, from where. E.g. "Warehouse views as of 2026-05-13. Customer evidence: 6 interviews across Mar–May 2026. Build status: feature-complete in staging as of 2026-05-12; QA pass 2 of 3 complete."]
> Changelog: First draft.

<!--
Launch PRD — Reforge's 10-component product spec extended with Aakash Gupta's launch-blog-post layer. 2,000–4,000 words.
Core question this doc answers: "How does this land in market?"
Reader: GTM, support, marketing, plus the engineering and design teams who built it. Decision it unblocks: launch can ship.
Aakash Gupta's frame — "the modern PRD reads like a blog post but contains all the information of the old Word document". Per-team checklists below are the GTM-facing layer that converts the spec into a launch plan.
-->

## TL;DR

[Four lines. What we're shipping / who it's for / when / how we'll know it worked. Bold the launch date. Include the launch headline — the one-sentence customer-facing pitch a marketer or salesperson would repeat verbatim.]

[Example shape:
- **What:** Inline bulk-edit for product attributes on the seasonal catalog grid.
- **Who:** Pro and Enterprise plan merchandisers at mid-market e-commerce brands managing 5,000–50,000 SKUs.
- **When:** **Launching 2026-07-15** to 100% of Pro/Enterprise, with rollback criteria defined below.
- **Launch headline:** "Update 500 SKUs in 90 seconds — bulk-edit lands in the catalog grid 15 July."
- **Success:** Time-to-update p50 under 90s by launch + 30 days; weekly catalog-update completion up 4+ points by launch + 60 days.]

## LLM Context — working memory (not part of the spec)

<!-- Pin this high (a collapsed Notion toggle is ideal) so it's recalled on every edit. The PRD's durable memory for AI-assisted editing: read before editing, append whenever a decision/convention/constraint is set. NOT product scope — never a substitute for the launch content below. -->

> Maintained for AI assistants and human editors as this launch plan's durable memory. Records the decisions, conventions, and gotchas that explain the body but don't belong in it — so future edits recall them instead of re-litigating. Keep entries dated and terse.

**Locked decisions** *(newest first; don't silently reverse — log the reversal here)*
- `[YYYY-MM-DD]` — [decision + one-line why].

**Standing conventions** *(rules every channel / variant / asset must honour)*
- [e.g. "All GTM assets use the approved launch headline verbatim — no paraphrase."]

**Known gaps & gotchas** *(traps a future editor or build will hit)*
- [e.g. "Rollback flag toggles per-region, not globally — stage the rollback by region."]

**Open threads** *(parked, not yet decided — promote into the body once resolved)*
- [ ] [question — owner].

## Problem

[2–4 paragraphs. What is broken, for whom, with evidence inline. Cite the source for every claim.]

[Example: "Merchandisers at mid-market e-commerce brands lose 6–12 minutes per session switching between the product editor and a spreadsheet to bulk-update seasonal attributes — flagged in 4 of 6 Mar–May 2026 customer interviews. Warehouse `product_attribute_updated` p50 = 4m 18s vs the 30s workflow-spec target. Support tickets tagged `bulk-edit-friction` ran 42 in Q1, up from 18 in Q4."]

> guidance: Lenny's first rule — nail the problem statement. If you wrote "by adding", "via a new", or "we will build" in this section, that's solution masquerading as problem (failure mode 1). Rewrite to "[Segment] cannot [task] because [reason], which costs [evidence]."

## Target user

[One paragraph. Specific segment, sized. Named role, named context.]

[Example: "Merchandisers at mid-market e-commerce brands with 5,000–50,000 SKUs. ~340 organisations on the Pro plan match this profile, ~62% of Pro-plan MRR."]

## Why now

[One paragraph. Strategic fit + market timing + why this quarter. Cagan's opportunity-assessment element.]

## Success metrics

[Table. Baseline + target + dashboard + owner per metric. Include launch + 7d / launch + 30d / launch + 90d columns.]

| Metric | Baseline | Launch + 7d | Launch + 30d | Launch + 90d | Dashboard | Owner |
|---|---|---|---|---|---|---|
| Median time-to-update | 4m 18s | <3m | <90s | <60s | Warehouse `merchandiser-workflow-health` | RevOps |
| Weekly catalog-update completion (Pro) | 32% | no regression | 34%+ | 38%+ | Warehouse `pro-catalog-funnel` | RevOps |
| Support tickets `bulk-edit-friction` | 42 / quarter | flat | <30 (annualised) | <20 (annualised) | CRM ticket dashboard | Support |
| Feature adoption (% of Pro orgs using ≥1x/week) | not tracked | establish | 60% | 80% | Warehouse `feature-adoption-merchandiser` | Product |
| Merchandiser NPS | not tracked | n/a | establish baseline | +10pt | Sprig `merchandiser-nps` | Product |

> guidance: Doshi — "include the dashboard view". Launch metrics need a time window per row: + 7d is the "did we break anything" check; + 30d is the early adoption read; + 90d is the real lift. Baseline can be "not tracked" — name it honestly.

## Solution overview

[2–3 paragraphs. The WHAT, not the HOW. User-facing behaviour, moments of value, what changes for the operator. Link to prototype: `[Figma — Inline bulk-edit v4](https://...)`.]

> guidance: Cagan's first rule — "the *what*, not the *how*". Mehta's preference — a working prototype linked from the doc beats prose for the visual.

## Key user flows

[Step-by-step or link to prototype. Number each step.]

1. [Step.]
2. [Step.]
3. [Step.]

## Scope + non-goals

[Two halves: in-scope items, then non-goals. Lenny + Kevin Yien: non-goals are as load-bearing as the goals.]

**In scope**
- [Item.]
- [Item.]
- [Item.]

**Non-goals** *(minimum 3)*
- [Non-goal.]
- [Non-goal.]
- [Non-goal.]

**Rabbit holes** *(Shape Up — obvious-but-wrong adjacent work the team might wander into.)*
- **[Rabbit hole 1]** — Tempting. Don't. [Reason.]
- **[Rabbit hole 2]** — Tempting. Don't. [Reason.]
- **[Rabbit hole 3]** — Tempting. Don't. [Reason.]

> guidance: fewer than three non-goals is failure mode 3. Rabbit holes concentrate editorial judgment in one place — the adjacent work that sounds good in a planning room and burns the launch.

## Dependencies + decisions

[NEED / PROCEED-WITHOUT decision table. Doshi + Cagan: force every dependency to a binary outcome — no TBDs.]

| ID | Item | Decision | Owner | Deadline | Reason / Cost |
|---|---|---|---|---|---|
| D1 | Product API supports `bulk_update` with `product_id[]` array | NEED | Lead Eng | 2026-06-15 | Without it, bulk-edit does not work — feature is non-functional. |
| D2 | Warehouse event `product_attribute_updated` includes `time_to_update` property | NEED | Data Eng | 2026-06-22 | Required to measure success metric 1. No launch-readout possible otherwise. |
| D3 | Localised copy for FR-market | PROCEED WITHOUT | — | — | French-market merchandisers see English copy on launch; ~3% of Pro audience. Add in Phase 2 if FR signups exceed 50/month. |
| D4 | Support runbook entry in help centre | NEED | Support Lead | 2026-07-08 | Without it, Tier 1 escalates everything to product. Capacity bottleneck on launch week. |
| D5 | Marketing changelog entry on example.com | NEED | Marketing Lead | launch day | Customer-facing comms requirement; ship-blocker for external announcement. |

> guidance: no "TBD" rows. If the answer isn't known, the row stays NEED with owner = "<who to ask>" and deadline = "before launch decision".

## Risks + mitigations

[Minimum 3 named risks with explicit mitigations. Cutler's "risks to mitigate"; Doshi's pre-mortem.]

- **Risk 1 — [Name].** [Why it matters.] **Mitigation:** [What we'll do.]
- **Risk 2 — [Name].** [Why it matters.] **Mitigation:** [What we'll do.]
- **Risk 3 — [Name].** [Why it matters.] **Mitigation:** [What we'll do.]

> guidance: name the tradeoff explicitly — what gets worse, who's unhappy, what we're betting against. A risks section that reads like sales material is failure mode 9.

## Launch checklist

[Per-team. Owners and dates. The checklist doubles as the launch-readiness review agenda — pass criteria is "every row is checked or has an explicit waiver".]

### Product / PM

| Item | Owner | Due | Status |
|---|---|---|---|
| Feature flag wired, default OFF | [Name] | [YYYY-MM-DD] | [ ] |
| Internal demo for leadership | [Name] | [YYYY-MM-DD] | [ ] |
| Launch readiness review held | [Name] | [YYYY-MM-DD] | [ ] |
| Rollback criteria signed off | [Name] | [YYYY-MM-DD] | [ ] |

### Engineering

| Item | Owner | Due | Status |
|---|---|---|---|
| Feature-complete in staging | [Name] | [YYYY-MM-DD] | [ ] |
| End-to-end test suite passing | [Name] | [YYYY-MM-DD] | [ ] |
| Performance test (p95 latency under target) | [Name] | [YYYY-MM-DD] | [ ] |
| Error rate < 0.5% in canary | [Name] | [YYYY-MM-DD] | [ ] |
| Observability dashboards live | [Name] | [YYYY-MM-DD] | [ ] |

### Design / UX

| Item | Owner | Due | Status |
|---|---|---|---|
| Final visual QA on production-like data | [Name] | [YYYY-MM-DD] | [ ] |
| Empty / loading / error states reviewed | [Name] | [YYYY-MM-DD] | [ ] |
| Accessibility pass (WCAG 2.1 AA) | [Name] | [YYYY-MM-DD] | [ ] |

### GTM / Marketing

| Item | Owner | Due | Status |
|---|---|---|---|
| Launch comms drafted (internal Slack + customer email) | [Name] | [YYYY-MM-DD] | [ ] |
| Customer email tested in [CRM tool], send list scoped | [Name] | [YYYY-MM-DD] | [ ] |
| Changelog entry written on example.com | [Name] | [YYYY-MM-DD] | [ ] |
| Sales enablement deck updated | [Name] | [YYYY-MM-DD] | [ ] |

### Support

| Item | Owner | Due | Status |
|---|---|---|---|
| Support runbook entry in help centre | [Name] | [YYYY-MM-DD] | [ ] |
| Tier 1 enablement session held | [Name] | [YYYY-MM-DD] | [ ] |
| Escalation path documented | [Name] | [YYYY-MM-DD] | [ ] |

## Comms plan

| Audience | Channel | Owner | Send / publish date | Status |
|---|---|---|---|---|
| Internal — all hands | Slack #announcements + Loom walkthrough | [Name] | Launch day, 09:00 local | [ ] |
| Internal — sales | Slack #sales + 15-min walkthrough | [Name] | Launch day - 2 | [ ] |
| Internal — support | Slack #support + runbook link | [Name] | Launch day - 5 | [ ] |
| External — customer | [CRM tool] email (segment: Pro + Enterprise) | [Name] | Launch day, 10:00 local | [ ] |
| External — public changelog | example.com/changelog | [Name] | Launch day | [ ] |
| External — press (if applicable) | [Outlet / blog] | [Name] | [Date] | [ ] |
| External — social | LinkedIn (founder), X (company) | [Name] | Launch day + 1 | [ ] |

> guidance: every external customer-facing row links a build-executable copy spec as a companion document — final subject, preheader, body copy, and CTAs under a dedicated build-spec contract (if the workspace has an email build-spec skill, e.g. `stripo-email-build-spec` for Stripo/Braze shops, use it). The PRD never embeds message copy and never ships a "copy TBD" row. Internal comms (Slack, enablement) can stay as checklist items.

## Support enablement

[Plain-language FAQ for the support team. What this feature is, who's it for, what to escalate, where the runbook is. Write it as if a Tier 1 agent will read it cold.]

**What is it?**
[Two sentences. E.g. "A new way for merchandisers to bulk-edit product attributes directly in the catalog grid, instead of exporting to a spreadsheet. It applies edits across selected rows in a single transaction."]

**Who has access?**
[One sentence. E.g. "All Pro and Enterprise organisations from launch day. Free and Starter plans do not see this surface."]

**Common questions to expect**

| Question | Answer |
|---|---|
| "Why doesn't bulk-edit apply to my filtered rows?" | Filter must be applied before selecting rows. Merchandiser can re-apply filter or select rows manually. Both paths work. |
| "Can I revert to the old workflow?" | Yes — `Settings > Workflow > Catalog editor > Use legacy view`. Logged in the warehouse as `revert_to_legacy_view`. |
| "Does this work for variants?" | No, parent products only for v1. Variant-level bulk-edit coming in Phase 2 (target Q4 2026). |

**What to escalate**
- [Escalation case 1 — e.g. "Any bulk-edit writing wrong data to product rows → escalate to Eng immediately, attach `org_id` and `product_ids`."]
- [Escalation case 2.]

**Runbook location:** [Link to help centre runbook]

## Rollback criteria

[What would cause us to roll back, who decides, how. The kill-criteria the launch readiness review signs off on.]

- **Rollback trigger 1 — [Threshold].** [E.g. "Error rate on `product_attribute_updated` event exceeds 2% for >30 minutes."] Decision-maker: [Name]. Action: [E.g. "Toggle feature flag OFF for all orgs; fall back to legacy view; investigate before re-enabling."]
- **Rollback trigger 2 — [Threshold].** [E.g. "More than 5 customer-reported data-corruption tickets in launch + 24h window."] Decision-maker: [Name]. Action: [What we do.]
- **Rollback trigger 3 — [Threshold].** [E.g. "p95 latency on catalog grid load exceeds 3s sustained for 1h."] Decision-maker: [Name]. Action: [What we do.]

> guidance: rollback criteria need explicit numbers, named decision-makers, and a defined action. "We'll roll back if something goes wrong" is not a rollback plan.

## Post-launch monitoring

[Which dashboards, who watches them, alert thresholds. The first 7 days are the watch window.]

| Dashboard | Watcher | Check cadence | Alert threshold |
|---|---|---|---|
| Warehouse `merchandiser-workflow-health` | [Name] | Daily for first 7d, weekly after | Time-to-update p50 > 3m for 2 consecutive days |
| Sentry — catalog-grid errors | [Name] | Real-time alert | Error rate > 1% for 15 minutes |
| Support tickets tagged `bulk-edit-friction` | [Name] | Daily for first 14d | > 5 tickets / day |
| Launch email delivery + open | [Name] | Daily for first 3d | Delivery < 95% or open < 25% |

## Phase 2 candidates

[Explicit "this is what comes next if launch succeeds". Not a commitment — a candidate list with conditional triggers. If the launch itself is phased, Phase N+1 is gated behind named numeric criteria on Phase N (e.g. "Phase 2 unlocks after: open rate > 50%, unsubscribe < 0.5%, zero deliverability incidents in 7 days") — "we'll see how it goes" is not a gate.]

- [Candidate — trigger condition. E.g. "Variant-level bulk-edit — triggered if Pro adoption hits 60%+ at launch + 30d."]
- [Candidate — trigger condition.]
- [Candidate — trigger condition.]

## Open questions

[Numbered. Owner-tagged. Recommendation where you have one.]

1. [Question — owner — recommendation.]
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
| Support lead | [Name] |
| Marketing / GTM lead | [Name] |
| Launch readiness review date | [YYYY-MM-DD] |
| Launch date | [YYYY-MM-DD] |

---

*Author: [Name]. Owner: [Name]. Last updated: [YYYY-MM-DD]. Source data: [Warehouse view / interview set / analytics query, with date].*
