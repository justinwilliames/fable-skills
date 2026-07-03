# [Outcome-phrased title — e.g. "Above-the-fold trial CTA lifts signup conversion"]

> **v0.1 — [YYYY-MM-DD]**
> Data: [What this brief is grounded in. E.g. "PostHog signup funnel insight `signup_d1_conversion`, 90-day window ending 2026-05-13. Baseline: 8.4% control. Prior qual: 4 user-test sessions Apr 2026."]
> Changelog: First draft.

<!--
Experiment brief — test-shaped, not feature-shaped. 500–1,200 words.
Core question this doc answers: "What are we testing and what's the ship rule?"
Reader: PM, eng, data. Decision it unblocks: whether to run the test.
The ship rule is decided BEFORE the test runs. If you write the ship rule after seeing results, you've HARKed the experiment.
-->

## TL;DR

- **Hypothesis:** [One sentence. "If we move the trial CTA above the fold on the homepage, then D1 signup conversion will lift, because the current placement is below the average scroll depth of mobile visitors."]
- **Primary metric:** [Name + baseline + minimum detectable effect. "D1 signup conversion, baseline 8.4%, MDE +0.8pp at 95% confidence."]
- **Ship rule:** [Decided up front. "Ship treatment if primary metric is +0.8pp or greater with p<0.05 AND no guardrail moves more than -2%."]

## Hypothesis

[Falsifiable. Format: "If we change X, then Y will happen, because Z." If you can't write it in that shape, the test isn't ready.]

[Example: "If we move the trial CTA above the fold on the homepage hero, then D1 signup conversion will lift from 8.4% to 9.2%+, because mobile session recordings show 62% of visitors scroll past the current CTA position without seeing it."]

> guidance: hypotheses that begin "we believe" or "we want to see if" are not hypotheses — they're hopes. Rewrite in the if/then/because shape.

## Predicted user behaviour change

[2–3 sentences. What will the user actually do differently. Not "engagement goes up" — name the click, the dwell, the conversion step. Tie back to the qualitative or analytics evidence that informed the prediction.]

[Example: "Mobile visitors will see the CTA without scrolling. Click-through on the CTA is expected to lift from 3.1% to ~4.0% of sessions. Downstream, signup completion rate from CTA click should hold steady (~28%), so the lift will compound through the funnel."]

## Primary metric

| Field | Value |
|---|---|
| Metric name | [e.g. D1 signup conversion] |
| Baseline | [e.g. 8.4%, 90-day rolling average ending 2026-05-13] |
| Target lift (MDE) | [e.g. +0.8pp absolute, +9.5% relative] |
| Direction | [e.g. Higher is better] |
| Dashboard | [PostHog insight URL or name, e.g. `signup_d1_conversion`] |
| Owner | [Name] |

> guidance: one primary metric. Not three. If you have three "primary" metrics, you have one primary and two guardrails — sort them out below.

## Guardrail metrics

[Metrics that must NOT move adversely. The ship rule includes guardrail thresholds. Minimum three guardrails — common ones: downstream activation, support tickets, paid-conversion rate, page load time.]

| Guardrail | Baseline | Acceptable bound | Dashboard |
|---|---|---|---|
| [e.g. Activation D7 from signup] | [42%] | [No drop greater than -2pp absolute] | [`activation_d7`] |
| [e.g. Paid conversion D30] | [3.2%] | [No drop greater than -0.3pp absolute] | [`paid_conv_d30`] |
| [e.g. Homepage LCP (page load)] | [1.8s] | [No regression past 2.1s] | [Vercel analytics] |

## Sample size and duration

[State the calculated sample size needed for the MDE at the target power, the daily traffic volume, and therefore the expected runtime. If not yet calculated, name the owner and the deadline — do not handwave.]

[Example: "At baseline 8.4% and MDE +0.8pp, 80% power, 95% confidence, two-sided test: 11,800 sessions per variant. Homepage averages 1,200 mobile sessions/day in the test segment, so ~10 days per variant. Plan to run 14 days to cover a full weekly cycle."]

[If not yet calculated: "Sample size calculation pending — Owner: [data lead]. Deadline: before test launch. Brief will not be marked ready until this row is filled."]

## Variants

| Variant | Description | Traffic allocation |
|---|---|---|
| Control | [Current homepage hero. CTA at position Y=920px, below the fold on iPhone 13.] | 50% |
| Treatment | [CTA repositioned to Y=420px, above the fold on iPhone 13. Hero illustration shifted right.] | 50% |

[Optional 1–2 sentences below the table on anything non-obvious about the implementation — feature-flag mechanism, audience exclusions, holdout cohorts.]

## Ship rule

[Decided BEFORE the test runs. Quote it verbatim from the TL;DR. State exactly which outcomes ship treatment, which ship control, and which sit in the ambiguous middle — and what we do in the ambiguous case.]

**Ship treatment if:**
- Primary metric ([D1 signup conversion]) is +0.8pp or greater absolute lift
- AND p-value < 0.05 two-sided
- AND no guardrail moves outside its acceptable bound

**Ship control if:**
- Primary metric is flat or negative
- OR any guardrail breaches its bound

**Inconclusive (lift positive but not significant, or significant but below MDE):**
- Do not ship. Do not extend the test. Bank the qualitative learning and move on. State why up front: extending a test to chase significance inflates false-positive rate.

> guidance: the ship rule is the single most important thing in this doc. Write it before you launch the test. If reviewers push back to "let's see how it goes", that's the failure mode this section exists to prevent.

## What we do regardless of the result

[The learning that's banked either way — wins or losses. Even a failed test produces signal. Name what we'll know on day 15 that we didn't on day 0.]

[Example: "Regardless of outcome, we learn whether above-the-fold CTA placement materially affects mobile signup behaviour at our current traffic mix. If treatment loses, we stop investing in CTA-placement experiments on the homepage and shift the next test to copy variation. If treatment wins but small, we know the lever exists but is small; ship it and move on rather than building a placement-optimisation system."]

## Risks

[Named, with mitigation. Minimum three. Common risks: novelty effect, traffic mix shift mid-test, instrumentation lag, segment cannibalisation.]

| Risk | Mitigation |
|---|---|
| [Novelty effect inflates early signal] | [Plan to read final result at day 14, not day 3. Pre-commit to the full run.] |
| [Traffic mix shifts during test (paid campaign starts)] | [Confirm with growth team — no new paid campaigns during the 14-day window.] |
| [Instrumentation lag on the new CTA event] | [Eng to verify event fires correctly in staging before traffic allocation. Owner: eng lead.] |

---

*Author: [Name]. Owner: [Name]. Last updated: [YYYY-MM-DD]. Source data: [PostHog insight / session-recording set / analytics query, with dates].*
