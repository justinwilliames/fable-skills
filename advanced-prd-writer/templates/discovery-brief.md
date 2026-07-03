# [Outcome-phrased title, not feature-named — e.g. "Backend engineers find slow CI builds 50% faster"]

> **v0.1 — [YYYY-MM-DD]**
> Data: [What this brief is grounded in, fetched when, from where. E.g. "Warehouse view `warehouse.events.ci_builds_daily` as of 2026-05-13. Customer evidence: 3 interviews with backend engineers between Apr–May 2026."]
> Changelog: First draft.

<!--
Discovery brief — lightest shape. 300–600 words.
Core question this doc answers: "Is there a real problem here worth more time?"
Reader: PM, possibly one peer. Decision it unblocks: whether to invest the next two weeks.
Do NOT write solution detail here. If you're tempted, the shape is wrong — switch to a Standard PRD or Opportunity assessment.
-->

## TL;DR

[One sentence. Problem + smallest next step. E.g. "Three of five backend engineers cannot identify the slowest step in a failed CI pipeline within 30 seconds; next step is a 5-user moderated test of three alternative log-surfacing patterns."]

## Problem

[2–4 sentences. What is broken, for whom, with evidence inline. Concrete user pain or business gap, never the proposed fix. Cite the source — interview, warehouse query, support ticket count.]

[Example shape: "Backend engineers at mid-size SaaS teams lose 6–12 minutes per failed build hunting through stacked CI logs to find the failing step. Three of five engineer interviews (Apr 2026) flagged this as their top friction. Warehouse event `ci_build_failed_investigated` shows median time-to-root-cause of 4m 18s vs the 30s target in the workflow spec."]

> guidance: if you wrote "by adding", "via a new", or "we will build" in this section, that's solution masquerading as problem. Rewrite.

## Why now — hypothesis

[One paragraph. What we think is driving the problem and why it's worth attention this quarter rather than next. The hypothesis is falsifiable — if X, then Y, because Z.]

[Example: "We think engineer friction is dragging on the team's iteration speed because failed-build investigation is now ~9% of weekly engineering time at our target accounts. If we cut time-to-root-cause by 50%, we expect weekly merge throughput to lift 4–6%. The bet is that investigation speed, not raw build speed, is the throughput lever this quarter."]

## Target user

[One or two sentences. Specific segment, not "users". Named role, named context, named scale.]

[Example: "Backend engineers on teams of 8–40 developers, who own at least one production service and run 30+ CI pipelines per day."]

## Smallest next learning step

[The most important section in this doc. What would we do next, this fortnight, if this brief justified more time? Name the activity, the owner, the timebox, and what we'd know at the end.]

[Example shape:
- **Activity:** Moderated test of 3 log-surfacing patterns with 5 backend engineers on Calendly slots.
- **Owner:** PM.
- **Timebox:** 10 working days.
- **What we'd know:** Which pattern cuts time-to-root-cause most, and whether the lift is large enough to justify a build.]

> guidance: this is where most discovery briefs go vague. Force a concrete next move with an owner and a timebox. If you can't, the brief isn't ready to circulate.

## Non-goals

[At least three. The things this brief is NOT trying to do. As load-bearing as the goals — they bound scope before anyone asks.]

- [Non-goal 1 — e.g. "Not redesigning the CI dashboard. Scope is failure-investigation surface only."]
- [Non-goal 2 — e.g. "Not a pricing question. Plan mix stays as-is."]
- [Non-goal 3 — e.g. "Not building anything yet. This is to decide whether to build."]

## Open questions

[Numbered. Owner-tagged where known. State a recommendation where you have one.]

1. [Question — owner — recommendation if you have one. E.g. "Do we have enough engineer interviews to call the pattern? Owner: PM. Recommendation: 2 more interviews before staffing."]
2. [Question — owner — recommendation.]
3. [Question — owner — recommendation.]

---

*Author: [Name]. Owner: [Name]. Last updated: [YYYY-MM-DD]. Source data: [Warehouse view / interview set / analytics query, with date].*
