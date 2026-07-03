# Voice and Clarity Rules — Deep Reference

This is the long-form reference for the "Voice rules" section of SKILL.md. Fourteen rules, each with a one-paragraph rationale and 2–3 worked before/after pairs. At the bottom: an English convention reference (AU/UK vs US) and a 100-word worked rewrite that applies all fourteen rules.

These rules are not stylistic preferences. Across the eight PM authorities surveyed for `references/pm-best-practices.md`, every one names voice and clarity as the difference between a PRD that gets read and one that does not. Apply them on every shape, every section, every draft.

---

## 1. Lead with the answer — TL;DR mandatory at the top

**The rule.** Every doc opens with a TL;DR. Always. No exceptions.

**Why.** Readers skim before they read. The doc has to survive a 30-second look. The TL;DR is the contract: if a reader stops after that paragraph, what is the one thing they should know? Doshi, Cutler, and Amazon all converge here. The TL;DR is also the test of whether the author understands their own doc — if the TL;DR cannot be written, the doc is not ready.

**Before / after.**

| Bad | Fix |
|---|---|
| Doc opens with "## Background. Over the last six months, our support team has reported friction with the ticket queue. We have been investigating the root causes and have identified several potential solutions..." | "**TL;DR.** Support agents lose 15 minutes per shift triaging the ticket queue. We will ship queue tags and tag-based filtering by 30 June 2026, targeting a drop in mean triage time from 22s to 7s per ticket. Three non-goals: bulk tag editing, admin tag UI, tag analytics." |

| Bad | Fix |
|---|---|
| (No TL;DR — doc opens straight into "## Problem") | "**TL;DR.** We are testing whether moving the trial CTA above the fold lifts signup conversion. Hypothesis: +2pp absolute lift. Sample size 8,400 per arm over 14 days. Ship rule: ship if lift ≥1pp at p<0.05; kill if guardrail (D7 retention) drops more than 1pp." |

---

## 2. Short sentences, one idea per sentence

**The rule.** One idea per sentence. One idea per paragraph. If a sentence has two clauses joined by "and", consider splitting.

**Why.** Long sentences hide weak thinking. A reader cannot tell which idea is load-bearing if three ideas are bundled. Short sentences force the author to commit to each claim individually. They also survive translation, skimming, and quotation.

**Before / after.**

| Bad | Fix |
|---|---|
| "While we acknowledge that the existing onboarding flow has historically performed reasonably well for enterprise customers, we believe that, given the recent shift in our user mix towards self-serve SMB accounts, there is now a meaningful opportunity to rethink the post-signup experience with a particular focus on time-to-first-value." | "Our user mix shifted to self-serve SMB this quarter. The current onboarding was built for enterprise. SMB customers take 9 days to first call versus a 24-hour target. We will rebuild the post-signup flow to compress that gap." |

| Bad | Fix |
|---|---|
| "The proposed solution involves the introduction of a new tagging mechanism on the ticket detail screen, alongside a filter component in the queue header that allows agents to narrow the visible queue by one or more selected tags, with the additional benefit of persisting filter state across sessions." | "Agents can apply one or more tags to a ticket. The queue header has a filter that narrows the visible queue by tag. Filter state persists across sessions." |

---

## 3. Concrete beats abstract — named numbers, not vibes

**The rule.** Replace adjectives with numbers. Replace "users" with the named segment. Replace "soon" with a date. Replace "improves" with a metric, baseline, and target.

**Why.** Abstract claims cannot be validated, falsified, or measured. Concrete claims commit the author to a position. A PRD full of vibes reads as an opinion piece; a PRD full of numbers reads as a plan.

**Before / after.**

| Bad | Fix |
|---|---|
| "Users find the dashboard hard to use." | "Support agents (n=15 interviews, Mar–May 2026) average 8m12s per dashboard session versus a 2m30s benchmark. 12 of 15 cited queue search as the top friction unprompted." |

| Bad | Fix |
|---|---|
| "We expect this to drive meaningful improvements in retention." | "We target D30 retention from 41% to 48% by 90 days post-launch (warehouse view `warehouse.events.retention_d30`)." |

| Bad | Fix |
|---|---|
| "We plan to ship this soon." | "Build complete by 18 June 2026. Internal release 25 June. GA 2 July 2026." |

---

## 4. Active voice

**The rule.** Subject performs the verb. "We will measure X" not "X will be measured." Name the actor.

**Why.** Passive voice hides ownership. "The rollout will be coordinated" — by whom? Active voice forces the author to name the owner. It also reads faster. The only legitimate use of passive voice in a PRD is when the actor is genuinely unknown or irrelevant ("the warehouse view is refreshed nightly").

**Before / after.**

| Bad | Fix |
|---|---|
| "Agents will be onboarded via in-app coachmarks." | "We will onboard agents via in-app coachmarks. Owner: Lifecycle Marketing." |

| Bad | Fix |
|---|---|
| "It is recommended that the success metric be tracked weekly." | "We will track the success metric weekly. Dashboard owner: Data team. View: `warehouse.events.agent_triage_speed`." |

| Bad | Fix |
|---|---|
| "Risks have been considered and mitigations have been put in place." | "We considered three risks. Mitigations sit in the Risks section below, each with a named owner." |

---

## 5. No corporate hedging

**The rule.** Recommend or do not. Cut the weasel words. Specific phrases to ban from PRD prose:

- "We believe"
- "Could potentially"
- "May help to"
- "Should consider"
- "Might want to"
- "It seems that"
- "Perhaps"
- "We feel that"
- "It is suggested"
- "Where possible"
- "As appropriate"
- "If applicable"
- "Hopefully"
- "Largely"
- "Generally speaking"

**Why.** Hedges signal that the author has not made up their mind, or has and is hiding it. Either is bad. If the data does not support a confident recommendation, say so — "we do not have evidence to choose between X and Y; recommend running a discovery week" is a confident statement of uncertainty. Vague hedges are different — they let the author dodge accountability without admitting the dodge.

A legitimate use of hedge-shaped language: when stating a genuine probability or open question. "We assess a 60% chance the migration completes within the quarter" is fine. "We believe the migration may potentially complete soon" is not.

**Before / after.**

| Bad | Fix |
|---|---|
| "We believe this approach could potentially help to improve activation, where applicable." | "This approach lifts activation D7 from 32% to 40% in 90 days. Evidence: comparable change in a peer link-in-bio product in 2023 produced an 8pp lift in the same segment." |

| Bad | Fix |
|---|---|
| "Teams should consider tracking this metric where possible." | "The data team owns tracking this metric. Dashboard live by 1 June 2026." |

| Bad | Fix |
|---|---|
| "It may be that we want to consider whether perhaps a phased rollout might be appropriate." | "Phased rollout: 10% at week 1, 50% at week 2, 100% at week 3. Rollback criterion: D7 retention drops >1pp at any phase gate." |

---

## 6. Cite evidence inline

**The rule.** Every problem claim and every quantitative assertion has a citation next to it. Interview count plus date range. Warehouse view name. Support ticket count. NPS verbatim with date. Link if the source is link-able.

**Why.** Uncited claims age badly and travel badly. Six months later the new PM cannot tell whether a stated fact came from real research or from the author's intuition. Inline citation forces honesty about provenance — Aakash's number-one quality flag.

**Before / after.**

| Bad | Fix |
|---|---|
| "Agents say the queue is slow." | "Agents say the queue is slow (n=15 interviews, Mar–May 2026; 12/15 raised queue speed unprompted)." |

| Bad | Fix |
|---|---|
| "Activation has been declining." | "Activation D7 has declined from 41% to 32% over the past two quarters (warehouse view `warehouse.events.activation_d7`, Q4 2025 to Q1 2026)." |

| Bad | Fix |
|---|---|
| "Customers want bulk operations." | "Customers want bulk operations: 28 support tickets in March 2026 mentioned bulk edit; NPS verbatim from agent Sarah K (May 2026): *'I'd give anything for a select-all button'*." |

---

## 7. Tables for facts, prose for narrative

**The rule.** Three or more parallel items with the same shape — default to a table. Inventories, metrics, dependencies, options compared, risks with severity — all tables. Reasoning, context, story — prose.

**Why.** Tables lock down comparisons and surface gaps. A reader can scan a table for what is missing in seconds; the same content in prose hides the gap. Narrative passages do work tables cannot — they explain *why* the structure looks the way it does. Use the right tool. Strong PRDs use tables aggressively for module inventories, attribute maps, success metrics, dependency lists — the pattern is canonical.

**Before / after.**

| Bad | Fix |
|---|---|
| "The first risk is technical, and we think it's medium likelihood with high impact, mitigated by load testing. The second risk is market — adoption stalling — and is medium likelihood and high impact, mitigated by coachmarks. The third risk is operational and is low likelihood and medium impact, mitigated by an on-call rotation." | (Use a table.) |

The table form:

| ID | Risk | Type | Likelihood | Impact | Mitigation / kill criterion |
|---|---|---|---|---|---|
| R1 | Queue load >5s under p99 | Technical | Medium | High | Load test before rollout; kill at week 1 if p99 >5s |
| R2 | Agent adoption <20% at week 6 | Market | Medium | High | In-app coachmarks; pause rollout if <20% at week 6 |
| R3 | Support ticket surge >50/wk | Operational | Low | Medium | On-call rotation week 1–2 |

---

## 8. Name the tradeoff

**The rule.** Every meaningful decision in the doc has a downside. Surface it. Pattern: *"By doing X, [Y gets worse / Z segment is unhappy / we accept the cost of W]."*

**Why.** A doc that names no tradeoffs reads as a sales pitch. Stakeholders cannot calibrate confidence. The team learns about the tradeoffs post-launch, when mitigation is expensive. Amazon's truth-seeking principle and Aakash's most-cited PRD weakness both sit here.

**Before / after.**

| Bad | Fix |
|---|---|
| "We will replace the legacy queue with the new tagged queue across all tenants on day one." | "We will replace the legacy queue with the new tagged queue across all tenants on day one. **Tradeoff.** Agents with muscle memory for the old queue lose ~2 days of productivity during transition (accepted; coachmarks compress to <1 day). Opportunity cost: 6 eng-weeks not spent on the macros rewrite (accepted; queue triage moves a larger metric)." |

| Bad | Fix |
|---|---|
| "Pricing plan reshuffle ships next quarter." | "Pricing plan reshuffle ships next quarter. **Tradeoff.** ~3% of current Starter customers see a price increase at renewal. Predicted churn impact: 0.4pp MRR loss in Q3; offset by 1.8pp MRR gain from Pro plan uptake. Net +1.4pp." |

---

## 9. Write for skimmers

**The rule.** Headers. Bullets. Bolded key sentences. The doc should be parseable in 2 minutes; readable in full in 10.

**Why.** Reviewers skim. The doc that survives the skim earns the read. Long paragraphs with no headers hide the structure. Skim-friendly does not mean dumbed-down — it means the architecture is visible.

**Before / after.**

| Bad | Fix |
|---|---|
| A 600-word wall of prose under one heading "## Approach" describing problem, solution, metrics, risks, and timeline together. | Break into: ## Problem (with bolded one-line summary), ## Solution overview (with three numbered bullets), ## Success metrics (table), ## Risks (table), ## Timeline (table). Each section ≤150 words. Bold the load-bearing claim in each. |

| Bad | Fix |
|---|---|
| "There are several things we will not be doing in this release, including admin-side tag management, which we are punting to a future release because it requires changes to the settings page that are scoped separately, and bulk-edit, which is also out of scope because the underlying infrastructure does not yet support batch operations." | "**Non-goals.**<br>1. Admin-side tag management — admins edit tags via existing settings page until v2.<br>2. Bulk-edit — underlying infra does not yet support batch operations.<br>3. Tag analytics — out of scope; surfaced as filters only." |

---

## 10. No typographical shorthand

**The rule.** Do not use the section sign (§), the paragraph sign (¶), the numero sign (№), or other legal/academic marks. Write "Section 9", "Sec 9", or just "9.".

**Why.** Section sign and friends read as jargon and break tone. They are a register from legal and academic writing and signal pomposity in a PRD context. Spell it out. Standing global rule, applies on every surface.

**Before / after.**

| Bad | Fix |
|---|---|
| "See § 3.2 for the data dependencies." | "See Section 3.2 for the data dependencies." |

| Bad | Fix |
|---|---|
| "Risk R1 (¶ 4.1) is the load test." | "Risk R1 (Section 4.1) is the load test." |

| Bad | Fix |
|---|---|
| "Item № 7 in the dependency table." | "Item 7 in the dependency table." |

---

## 11. No emoji in body content

**The rule.** Body prose stays clean of emoji. Section headers (H1, occasionally H2) may take a single icon if it aids navigation — use sparingly. Bullets, paragraphs, tables, callouts stay icon-free.

**Why.** Emoji in body content cheapens the doc and ages badly. A PRD is a contract — the register is operator-direct, not group-chat-casual. Section header icons (at most one per H1, by convention) aid navigation in long docs. Inline emoji do not.

**Before / after.**

| Bad | Fix |
|---|---|
| "We're 🚀 launching this 🎉 next quarter, which is super exciting ✨." | "We launch this in Q3 2026." |

| Bad | Fix |
|---|---|
| "✅ Build complete. ⚠️ One open risk. 🔴 Two blockers." | "**Status.** Build complete. One open risk (R2). Two blockers (D1, D3)." |

(Single header icon — acceptable.)

| Acceptable | Notes |
|---|---|
| `# 💰 Pricing & Packaging PRD` | Single icon on an H1, no others in the body. |

---

## 12. Match the user's English convention

**The rule.** Match whatever English convention the user's input is already in — AU/UK or US. Mirror; do not impose. Neither convention is the skill's "default". If the input is genuinely mixed or too short to detect from, ask once before drafting and lock the choice for the document.

**Why.** Spelling inconsistency reads as carelessness. A PRD with both "behaviour" and "behavior" in the same doc looks like it was written by two people. Imposing a convention the user doesn't write in is the same kind of carelessness, one step earlier — the doc reads as foreign before the reader hits the first claim. The "English convention reference — AU/UK vs US" section below names the swap pairs, and the detection signal below it names how the skill picks.

**Detection signal.** Scan the first 2–3 distinctive words in the user's input. Distinctive = words that differ between conventions (the "-ise/-ize", "-our/-or", "-re/-er", "-ce/-se" families).

- "behaviour" + "organisation" → AU/UK.
- "behavior" + "organization" → US.
- "centre" + "colour" → AU/UK.
- "center" + "color" → US.
- "optimise" + "analyse" → AU/UK.
- "optimize" + "analyze" → US.

If the input is too short to contain a distinctive word, or it mixes both conventions, ask one question before drafting: *"Quick check before I draft — AU/UK spelling (behaviour, organisation, centre) or US (behavior, organization, center)?"* Lock the answer.

**Before / after.**

| Bad | Fix (AU) | Fix (US) |
|---|---|---|
| "We will optimize the user behavior to maximize engagement and recognize the customer's preferences." | "We will optimise the user behaviour to maximise engagement and recognise the customer's preferences." | "We will optimize the user behavior to maximize engagement and recognize the customer's preferences." |

(A mixed-spelling doc is the actual failure — pick one and stick to it.)

---

## 13. Honour the data-freshness callout

**The rule.** Every doc opens with a version, date, and data-provenance callout. Pattern in SKILL.md Step 4.

**Why.** Stale data is the silent killer of PRDs. Six months later a reader picks up the doc and cannot tell whether the numbers are current. The callout pre-empts the "is this stale?" question and forces the author to surface the source. Strong onboarding and dunning PRDs in the wild carry this pattern.

**Before / after.**

| Bad | Fix |
|---|---|
| Doc opens with "## Problem" (no version, no date, no data source). | Doc opens with a blockquote callout: "**v0.1 — 2026-05-14.** Data: warehouse views as of 2026-05-13. Customer evidence: 4 interviews across Mar–May 2026. Changelog: First draft." |

| Bad | Fix |
|---|---|
| "v0.2 — small edits since last time." | "**v0.2 — 2026-05-18.** Data: refreshed against the warehouse as of 2026-05-17. Changelog: (1) Updated success metric baseline from 32% to 35% after Q2 data landed. (2) Added R4 risk on Stripe webhook latency. (3) Cut non-goal #4 (now in scope per Eng review)." |

---

## 14. Force a decision — no TBD

**The rule.** Every item in a dependency, requirement, or open-question list resolves as either **NEED** (hard blocker, named owner, named deadline) or **PROCEED WITHOUT** (we ship without this; the cost we accept is named).

**Why.** "To be determined" is where PRDs go to die. It is the most common source of slipped delivery because the team treats TBD as "someone else's problem". The NEED / PROCEED-WITHOUT pattern forces the author to either escalate the blocker or accept the cost — both of which surface the decision to the team. Strong onboarding-and-activation PRDs in the wild use this pattern as a signature.

**Before / after.**

| Bad | Fix |
|---|---|
| Dependency list: <br>- Activation event in the warehouse — TBD<br>- French localisation — TBD<br>- Stripe webhook reliability — open | Use a NEED / PROCEED table. |

The table form:

| ID | Item | Decision | Owner | Reason / cost |
|---|---|---|---|---|
| D1 | Activation event in the warehouse | NEED | Lead Eng — before launch | Without it we cannot measure success metric A. |
| D2 | French localisation | PROCEED WITHOUT | — | French speakers see English copy on launch; ~3% of audience. Localisation backlogged for v2. |
| D3 | Stripe webhook reliability | NEED | Backend Eng — before week 1 of rollout | Dunning state machine depends on webhook delivery <60s p99. |

---

# English convention reference — AU/UK vs US

A swap table the skill uses to **stay consistent** with whatever convention the user's input is already in. AU/UK is the left column; US is the right column. Neither is the skill's default — the detection signal in Rule 12 picks. Once a convention is locked for a document, every word in this table follows it.

| AU | US |
|---|---|
| behaviour | behavior |
| organisation | organization |
| optimise | optimize |
| prioritise | prioritize |
| recognise | recognize |
| customise | customize |
| analyse | analyze |
| categorise | categorize |
| centralise | centralize |
| utilise | utilize |
| realise | realize |
| colour | color |
| favourite | favorite |
| flavour | flavor |
| labour | labor |
| neighbour | neighbor |
| centre | center |
| metre | meter |
| theatre | theater |
| litre | liter |
| catalogue | catalog |
| dialogue | dialog |
| programme (as in a TV programme / training programme) | program |
| program (as in software program) | program |
| licence (noun) / license (verb) | license (both) |
| practice (noun) / practise (verb) | practice (both) |
| defence | defense |
| offence | offense |
| pretence | pretense |
| travelled / travelling | traveled / traveling |
| cancelled / cancelling | canceled / canceling |
| modelled / modelling | modeled / modeling |
| towards | toward |
| amongst | among |
| whilst | while |

Note on "program" — AU/UK keeps "programme" for TV shows, training schemes, and broadcast contexts, but uses "program" for software. When the locked convention is AU/UK and the PRD is discussing software, use "program". Use "programme" only if the doc is genuinely about a training programme, broadcast programme, or similar non-software sense.

---

# Worked example — bad PRD paragraph rewritten

Take a 100-word paragraph that violates almost every rule above. Then rewrite it applying all fourteen. The user's input in this example is in AU/UK convention — the skill detects that from "optimise" and "behaviour" elsewhere in the brief, locks AU/UK, and the "optimize" appearing in the bad draft is therefore a Rule 12 violation. The same example in a US-locked doc would flip the spelling decisions; everything else is convention-agnostic.

**Before — 102 words. Locked convention: AU/UK. Every rule violated.**

> It seems that, generally speaking, the new onboarding flow could potentially help to improve activation rates among users, where applicable, and the team should consider whether perhaps it might be appropriate to optimize the experience by adding a new modal that highlights key features. Users have indicated through various channels that they find onboarding to be confusing 😕, and we believe that addressing this issue, possibly through a series of UX changes, may help to drive better outcomes overall. We will look into the data and report back on findings 📊 in due course, hopefully sometime in the near future.

Violations counted:

1. No TL;DR (rule 1).
2. Long bundled sentences (rule 2).
3. Vague — "users", "improve", "better outcomes", "near future" (rule 3).
4. Passive — "users have indicated", "the experience be optimized" (rule 4).
5. Hedges everywhere — "it seems", "generally speaking", "could potentially", "where applicable", "should consider", "perhaps", "might be appropriate", "we believe", "possibly", "may help to", "hopefully", "in due course" (rule 5).
6. No evidence cited (rule 6).
7. Prose where structure would help (rule 7).
8. No tradeoff named (rule 8).
9. No headers, no skim path (rule 9).
10. No typographical shorthand here, but emoji used in body (rule 11).
11. Wrong convention — "optimize" in an AU/UK-locked doc (rule 12).
12. No version / date / data callout (rule 13).
13. No NEED / PROCEED decision on the "data and report back" (rule 14).

**After — same content, rules applied. ~145 words including the callout and table, but readable in under a minute.**

> **v0.1 — 2026-05-14.** Data: warehouse view `warehouse.events.activation_d7` as of 2026-05-13. Customer evidence: 9 onboarding-session recordings (Apr 2026), 14 support tickets tagged `onboarding-confusion` (Mar–Apr 2026).
>
> **TL;DR.** Self-serve SMB signups activate at 32% on D7 versus a 40% target. We will ship a feature-spotlight modal in the post-signup flow by 18 June 2026, targeting +5pp activation by 30 July. Tradeoff: adds one screen to the onboarding path, lengthening time-to-first-value by ~12s.
>
> **Problem.** SMB signups (n=14 support tickets, Mar–Apr 2026; 9/14 cite "didn't know where to start") cannot identify the three load-bearing features in the first session. Activation D7 has dropped from 41% to 32% over the past two quarters.
>
> **Open dependency.**
>
> | ID | Item | Decision | Owner | Cost |
> |---|---|---|---|---|
> | D1 | Activation event firing on first-key-action | NEED | Lead Eng — before 1 June | Without it the success metric cannot move from "not tracked" to measurable. |

Every rule applied. Every claim cited. Every hedge cut. Tradeoff named. Spelling consistent. Skim-readable. Owner and deadline on the open dependency. This is the target voice for every PRD this skill produces.
