# [Product or initiative name] — PR-FAQ

> **v0.1 — [YYYY-MM-DD]**
> Data: [What this PR-FAQ is grounded in. E.g. "Market sizing from internal user base + 2024 Creator Economy Report. Customer evidence: 8 discovery calls with independent creators, Feb–May 2026. Competitive scan: Patreon, Substack, Buy Me a Coffee, Aug 2025 + spot-checked Apr 2026."]
> Changelog: First draft.

<!--
PR-FAQ — Amazon Working Backwards shape. 1,500–3,000 words total. Press release ≤ 1 page.
Core question this doc answers: "What does the customer-visible win look like?"
Reader: exec, cross-functional leadership. Decision it unblocks: whether the idea is press-release-worthy.
Truth-seeking, not selling. The Internal FAQ must include the uncomfortable questions — if every internal FAQ answer reads like a sales pitch, the doc has failed.
-->

## LLM Context — working memory (not part of the spec)

<!-- Keep this as a COLLAPSED Notion toggle pinned above the Press Release so it never eats into the single-page PR. The doc's durable memory for AI-assisted editing: read before editing, append whenever a decision/convention/constraint is set. NOT customer-facing — never leaks into the Press Release or External FAQ. -->

> Maintained for AI assistants and human editors as this PR-FAQ's durable memory. Records the decisions, conventions, and gotchas that explain the body but don't belong in it — so future edits recall them instead of re-litigating. Keep entries dated and terse.

**Locked decisions** *(newest first; don't silently reverse — log the reversal here)*
- `[YYYY-MM-DD]` — [decision + one-line why].

**Standing conventions** *(rules every revision must honour)*
- [e.g. "Press release stays one page — overflow goes to the External FAQ."]

**Known gaps & gotchas** *(traps a future editor will hit)*
- [e.g. "Competitive scan is Aug 2025 — refresh before any exec review."]

**Open threads** *(parked, not yet decided — promote into the body once resolved)*
- [ ] [question — owner].

## Press Release

> guidance: this section in the final draft must fit on a single page. If it doesn't, cut. The press release is dated to a hypothetical launch — write as if the product already exists and shipped today.

### [Product name] — [one-line value claim aimed at the customer]

**[FOR IMMEDIATE RELEASE — [hypothetical launch date]]**

**[Subheading: segment + benefit, one sentence. E.g. "Built for independent creators with paid audiences, [Product] turns one-time supporters into recurring members with a single in-feed prompt."]**

[**Summary paragraph (3–5 sentences).** Launch context, what the product is, the headline advantage. Write it the way TechCrunch would: lead with the news, name the customer, name the gain. No internal jargon. No feature lists.]

[Example shape: "[Company] today launched Member Pulse, a one-tap conversion surface that turns a creator's one-time supporters into recurring monthly members. Built on the existing supporter base, Member Pulse eliminates the 3-step funnel between a tip and a membership signup that creators report as their top conversion drop-off. Creators in private beta have lifted member-conversion rate by 73%."]

[**Problem paragraph (3–4 sentences).** Customer-centric. What was the pain before this existed. Name the segment, the workflow, the cost. Optional: include rough TAM or audience size to establish market viability.]

[Example: "Independent creators with 1,000–10,000 paying supporters convert one-time tippers to recurring members at 1.2% — far below the 6% benchmark for comparable creator platforms. Most creators have to send a manual DM or post to pitch membership, losing the conversion moment. For a creator earning $50K/year from tips, that's ~$30K of unrealised recurring revenue. The category's existing tools optimise for one-time payments, not member conversion."]

[**Solution paragraph(s) (4–6 sentences).** How the product solves the problem. The "what", not the "how". One or two differentiators stated plainly. Avoid stacking feature names.]

[Example: "Member Pulse detects when a supporter has tipped twice in 30 days and surfaces a personalised membership offer inside the creator's feed, with copy generated from the creator's own past posts. Supporters convert with one tap — no checkout flow, no payment re-entry, since the payment method is already on file. Creators see member-conversion happen in real time on a dashboard, with the option to override copy before the prompt sends. Built specifically for the recurring-member motion — not retrofitted from one-time-payment infrastructure — Member Pulse understands creator-specific signals like tip cadence, content category, and audience activity windows."]

> **Internal quote (from a leader).**
>
> "[2–3 sentences in voice. Names the customer outcome, not the technology. E.g. 'Independent creators have been leaving recurring revenue on the table for years because the conversion moment is 3 taps too far away. Member Pulse closes that gap. That's what good product does — make the right thing the easy thing.'"]
>
> — [Name, Title, Company]

> **Customer quote (hypothetical, but specific).**
>
> "[2–3 sentences. Specific scenario, specific outcome. Avoid 'game-changing'. E.g. 'I was losing recurring revenue every week because asking for memberships felt awkward. With Member Pulse, the offer goes out at the right moment in the right voice. My recurring revenue tripled in two months without changing my content strategy.'"]
>
> — [Name], Independent Creator, [Audience size + niche]

[**Getting started.** Short paragraph. Where to buy, when available, who can use it. One sentence on pricing if known.]

[Example: "Member Pulse is available today for [Company] Pro and Enterprise creators. Creators on the free plan can upgrade in-product. New creators can sign up at example.com/member-pulse."]

---

## External FAQ

> guidance: questions an actual customer would ask before buying. Cover pricing, how it works, support, where to buy, and the two or three objections you know customers raise. Answer plainly — no internal jargon, no future-tense roadmap hedges.

### How much does it cost?

[Answer. Specific tier + price, or a clear "included in Pro and Enterprise" line. If pricing isn't set, name the range and the decision deadline — don't hedge.]

### How does it actually work, day-to-day?

[Answer. 3–5 sentences walking through the creator's week. Concrete steps, not capability claims.]

### What do I need to have set up first?

[Answer. Stripe account connected, audience minimum, posting cadence. Realistic time-to-value — "5 minutes if your account is connected; 30 minutes if we need to set up payments first".]

### What if my audience lives mostly on [adjacent platform — Patreon, Substack, Discord]?

[Answer. State the integration honestly. If we don't support it, say so + roadmap line.]

### What happens if the AI-generated copy gets the tone wrong?

[Answer. Preview-before-send is default, edit-before-send is one tap, no destructive auto-sending. Name the failure mode and the safety net.]

### How do I get support?

[Answer. In-app chat, email, response SLAs. If white-glove onboarding is included for a tier, name it.]

### Where can I see it in action?

[Answer. Demo link, trial path, sales contact.]

---

## Internal FAQ

> guidance: this section is the truth-seeking half. Questions an exec, eng lead, or sceptical board member would ask. Include the uncomfortable ones — kill criteria, failure scenarios, what's load-bearing. If every answer reads like a sales pitch, the doc has failed.

### How big is the addressable market for this?

[Answer. TAM, SAM, beachhead segment. Cite the source. State assumptions. "We sized this off [report / book] dated [when]. The number is X with a confidence of Y."]

### What is the build cost — money and months?

[Answer. Estimated FTE-months by discipline, third-party costs, ongoing run-rate. Be specific about whether this is order-of-magnitude or estimated post-design.]

### Who are the competitors and how do we win?

[Answer. Name the 2–3 real competitors. State where each one is stronger and where we win. Avoid the "they don't focus on independents" cop-out — articulate the actual moat.]

### What's the biggest technical risk?

[Answer. Name the risk, name the mitigation, name the kill criteria if mitigation fails.]

### What's the biggest market risk?

[Answer. The "what if customers don't actually want this enough to pay" question. Name the evidence we have and the evidence we don't.]

### What does failure look like?

[Answer. Be specific. "Failure is: 6 months post-launch, <X paying customers on the SKU, NPS for the feature below Y, creators reporting they reverted to manual outreach in support tickets." Name the kill criteria — at what point do we sunset?]

### What are we betting on that we cannot yet prove?

[Answer. 2–4 explicit assumptions. The list of things that, if wrong, sink the product. This is the pre-mortem.]

### What does success look like at month 3, 6, 12?

[Answer. Concrete numbers per milestone. Adoption, retention, revenue, NPS — pick the 3 that matter most.]

### What happens to our existing roadmap if we staff this?

[Answer. The honest tradeoff. What does NOT get built. Name the deferred initiative.]

### What is the kill criteria?

[Answer. The specific signal that would cause us to stop investment. Tied to a date and a number, not a vibe.]

---

*Author: [Name]. Owner: [Name]. Last updated: [YYYY-MM-DD]. Source data: [Market sizing source / interview set / competitive scan, with dates].*
