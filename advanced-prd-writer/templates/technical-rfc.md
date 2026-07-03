# [Outcome-phrased title naming the engineering decision — e.g. "Auth migration from Cognito to Clerk — RFC"]

> **v0.1 — [YYYY-MM-DD]**
> Data: [What this RFC is grounded in, fetched when, from where. E.g. "Cognito support tickets Q1–Q2 2026 (n=18), p95 latency from Datadog `auth-service` (90d window), Clerk POC results from 2026-04-22 spike."]
> Changelog: First draft.

<!--
Technical RFC — engineering options need adjudication. 1,500–3,000 words.
Core question this doc answers: "Which build path?"
Reader: engineering. Decision it unblocks: architectural choice.

The product behaviour is assumed settled. This RFC chooses *how* we build the thing the product team already agreed we'd build. If the product question is still open, you're in the wrong shape — switch to a Standard PRD.

The PM may co-author with the tech lead. Voice is engineering-decision register: constraints, options, tradeoffs, recommendation. Less customer evidence than a PRD; more technical detail.
-->

## TL;DR

[Two lines. The recommendation, with the tradeoff named.]

[Example shape:
- **Recommendation:** Migrate authentication from Cognito to Clerk via a phased 4-week cutover, dual-running both providers during weeks 2–3.
- **Tradeoff:** Accepts ~6 weeks of engineering capacity and one breaking change for existing API clients, in exchange for ~70% reduction in auth-related support load and unblocking SOC 2 evidence collection.]

## LLM Context — working memory (not part of the spec)

<!-- Pin this high (a collapsed Notion toggle is ideal) so it's recalled on every edit. The RFC's durable memory for AI-assisted editing: read before editing, append whenever a decision/constraint is set. NOT part of the technical proposal below. -->

> Maintained for AI assistants and human editors as this RFC's durable memory. Records the decisions, conventions, and gotchas that explain the body but don't belong in it — so future edits recall them instead of re-litigating. Keep entries dated and terse.

**Locked decisions** *(newest first; don't silently reverse — log the reversal here)*
- `[YYYY-MM-DD]` — [decision + one-line why, e.g. "Chose Option B over A — A needs a write-lock window we can't take."].

**Standing conventions** *(invariants every option / migration step must honour)*
- [e.g. "No breaking changes to the public API contract — additive only."]

**Known gaps & gotchas** *(traps a future editor or implementer will hit)*
- [e.g. "Staging mirrors prod schema but not prod data volume — load-test reads don't transfer."]

**Open threads** *(parked, not yet decided — promote into the body once resolved)*
- [ ] [question — owner].

## Problem / context

[2–3 paragraphs. What we're trying to solve at the engineering level. Where the current system falls short. Cite the evidence — incidents, latency, support tickets, scaling limits.]

[Example: "Our current auth stack on AWS Cognito has produced 18 support tickets across Q1–Q2 2026 (3.2x the next-highest service), p95 sign-in latency of 1.8s against a 600ms SLO, and no native support for SOC 2 evidence collection — which the May 2026 SOC 2 readiness review flagged as a 6-week blocker. The team has run a 2-week Clerk POC (spike doc: [link]) confirming the migration path is viable and the customer-visible surface stays largely unchanged."]

## Constraints

[Bulleted list. The boundaries any solution must respect. Performance, scale, compliance, team capability, time. Name each constraint and its source.]

- **[Constraint 1]** — [Where it comes from. E.g. "p95 sign-in latency must stay under 600ms — SLO committed in the Q1 reliability OKR."]
- **[Constraint 2]** — [Where it comes from. E.g. "Must preserve existing API token format — 12 internal services and 4 customer integrations depend on the current JWT structure."]
- **[Constraint 3]** — [Where it comes from. E.g. "Engineering capacity: 2 backend engineers, 6-week window before Q3 priorities lock."]
- **[Constraint 4]** — [Where it comes from. E.g. "SOC 2 audit evidence collection must be live by 2026-08-15."]

## Non-goals

[Minimum 3 items. What this RFC does NOT decide.]

- [Non-goal — e.g. "Not deciding whether to add SSO for enterprise customers. Separate RFC, post-migration."]
- [Non-goal — e.g. "Not rebuilding the password-reset flow. Carries over as-is on the new provider."]
- [Non-goal — e.g. "Not changing the user-data model in Postgres. Auth provider swap only; user records stay where they are."]

## Options considered

[Minimum 2 options, ideally 3. Each option gets: description, pros, cons, estimated effort, key risk. Format as parallel sub-sections — readers scan the headers to compare.]

### Option A — [Name, e.g. "Stay on Cognito, fix the latency and SOC 2 gaps in place"]

**Description:** [1–2 sentences. What this option looks like concretely.]

**Pros:**
- [Pro — e.g. "No customer-facing change. Zero migration risk."]
- [Pro — e.g. "Lower upfront engineering cost (~2 weeks vs ~6)."]

**Cons:**
- [Con — e.g. "Cognito's SOC 2 evidence tooling is third-party; adds ~$18k/year in licensing."]
- [Con — e.g. "Latency fix requires custom auth-layer caching; ~4 weeks of work, doesn't address root cause."]
- [Con — e.g. "Does not address the long-tail of Cognito-specific support tickets (auth flow brittleness)."]

**Estimated effort:** [E.g. "2 backend engineers × 3 weeks = 6 engineer-weeks."]

**Key risk:** [One sentence. E.g. "Caching layer introduces a new failure mode (cache-incoherence under password reset) — historically the source of 30% of auth-related incidents at peer companies."]

### Option B — [Name, e.g. "Migrate to Clerk with phased 4-week cutover"]

**Description:** [1–2 sentences.]

**Pros:**
- [Pro.]
- [Pro.]
- [Pro.]

**Cons:**
- [Con.]
- [Con.]

**Estimated effort:** [E.g. "2 backend engineers × 6 weeks = 12 engineer-weeks. POC already complete."]

**Key risk:** [One sentence.]

### Option C — [Name, e.g. "Build in-house auth on top of Postgres + Lucia"]

**Description:** [1–2 sentences.]

**Pros:**
- [Pro.]
- [Pro.]

**Cons:**
- [Con.]
- [Con.]
- [Con.]

**Estimated effort:** [E.g. "3 backend engineers × 10 weeks = 30 engineer-weeks. No prior spike."]

**Key risk:** [One sentence.]

## Options compared

[Summary table. Same shape per row. Locks down the comparison.]

| Dimension | Option A — In-place fix | Option B — Migrate to Clerk | Option C — In-house build |
|---|---|---|---|
| Effort (engineer-weeks) | 6 | 12 | 30 |
| Solves latency gap | partially | yes | yes |
| Solves SOC 2 evidence gap | with $18k/yr add-on | natively | requires custom tooling |
| Customer-facing impact | none | one breaking JWT change | one breaking JWT change |
| Long-term maintenance burden | high (legacy + caching layer) | low (managed) | high (owned auth stack) |
| Reversibility | n/a | dual-run window allows rollback | hard once cut over |

## Recommendation

[1–2 paragraphs. Which option, with reasoning that names the tradeoff explicitly. No hedging. Recommend or don't.]

[Example: "Recommend Option B — migrate to Clerk via phased 4-week cutover. It solves both the latency and SOC 2 gaps at the root, costs 12 engineer-weeks (2x Option A, 0.4x Option C), and preserves a reversible dual-run window during the cutover. The tradeoff is real: we accept one breaking JWT change for customer API clients, plus ~3 weeks of dual-stack operational complexity. Option A is rejected because the caching layer fix is a workaround that does not address Cognito's structural fit problems and the $18k/year SOC 2 tooling adds long-term cost. Option C is rejected because building in-house auth doubles the effort and adds permanent maintenance burden the team has no capacity to carry."]

> guidance: name the tradeoff explicitly. "What gets worse, who's unhappy, what we're betting against." Failure mode 7 is avoidable here.

## Migration plan

[Step-by-step. Each step has a checkpoint and a rollback. The plan reads as something an on-call engineer could execute from cold.]

1. **Week 1 — [Step.]** [E.g. "Provision Clerk tenant, configure user-pool import from Cognito export."]
   - **Checkpoint:** [E.g. "All 12,400 user records imported, attribute parity verified by sample (n=200)."]
   - **Rollback:** [E.g. "Drop Clerk tenant. No production impact yet."]
2. **Week 2 — [Step.]** [E.g. "Deploy auth-routing layer that accepts JWTs from both Cognito and Clerk. Default issuer = Cognito."]
   - **Checkpoint:** [E.g. "Production traffic on Cognito unaffected; Clerk path verified via canary 1% traffic for 48h with zero errors."]
   - **Rollback:** [E.g. "Disable Clerk verifier; revert to Cognito-only. No customer impact."]
3. **Week 3 — [Step.]** [E.g. "Flip default issuer to Clerk for new sign-ins; existing Cognito tokens remain valid until expiry."]
   - **Checkpoint:** [E.g. "Sign-in latency p95 < 600ms on Clerk path; error rate < 0.1%."]
   - **Rollback:** [E.g. "Flip default back to Cognito; existing Clerk tokens remain valid. No customer-visible disruption."]
4. **Week 4 — [Step.]** [E.g. "Force re-issue of remaining Cognito tokens on next request; decommission Cognito verifier."]
   - **Checkpoint:** [E.g. "Zero Cognito-issued tokens in circulation for 48h; Cognito user pool archived."]
   - **Rollback:** [E.g. "Re-enable Cognito verifier within 1h; force-reissued tokens degrade to legacy path. Reversible up to 7d after this step."]

## Risks + mitigations

[Minimum 3 named risks with explicit mitigations.]

- **Risk 1 — [Name].** [Why it matters.] **Mitigation:** [What we'll do.] [E.g. "Clerk's user-import API has a 10k/hour rate limit — could stall the week-1 import. Mitigation: run import in 5k batches with 30-min spacing, complete over a weekend low-traffic window."]
- **Risk 2 — [Name].** [Why it matters.] **Mitigation:** [What we'll do.]
- **Risk 3 — [Name].** [Why it matters.] **Mitigation:** [What we'll do.]

## Dependencies required

[NEED / PROCEED-WITHOUT decision table. Same pattern as the Standard PRD. No "TBD" rows.]

| ID | Item | Decision | Owner | Deadline | Reason / Cost |
|---|---|---|---|---|---|
| D1 | Clerk enterprise contract signed (SOC 2 BAA + SLA) | NEED | Legal | 2026-06-01 | Cannot move production traffic without contract; SOC 2 BAA required for compliance scope. |
| D2 | Customer-comms drafted re: JWT format change (API clients) | NEED | Marketing Lead | 2026-06-15 | Four integration partners affected; need 30d notice in their dev calendars. |
| D3 | Datadog auth-service dashboard rebuilt for Clerk-emitted metrics | NEED | Lead Eng | 2026-06-22 | Without it, week-2 canary is flying blind on latency + error rate. |
| D4 | Cognito user-pool MFA settings exported and replicated in Clerk | NEED | Backend Eng | 2026-06-08 | Required for parity; if missed, MFA-enrolled users (n=3,200) would re-enrol manually. |
| D5 | Custom social-login providers (Google, Microsoft) reconfigured in Clerk | PROCEED WITHOUT | — | — | <2% of users use social login. Acceptable to require these users to re-link post-migration; comms goes out in week 3. |

> guidance: this table is non-negotiable for an RFC with engineering dependencies. Every item resolves NEED or PROCEED-WITHOUT. If the answer isn't known yet, the row stays NEED with owner = "<who to ask>" and deadline = "before week 1".

## Open questions

1. [Question — owner — recommendation. E.g. "Do we issue Clerk-managed magic-link sign-in alongside password sign-in from day 1, or hold until phase 2? Owner: PM / Lead Eng. Recommendation: hold until phase 2 — adds 2 weeks scope and the migration is already at the 6-week ceiling."]
2. [Question — owner — recommendation.]
3. [Question — owner — recommendation.]

## Owner + collaborators + timeline

| Role | Name |
|---|---|
| RFC owner | [Name] |
| Engineering lead | [Name] |
| PM partner | [Name] |
| Security / compliance reviewer | [Name] |
| Migration start date | [YYYY-MM-DD] |
| Migration complete (target) | [YYYY-MM-DD] |

---

*Author: [Name]. Owner: [Name]. Last updated: [YYYY-MM-DD]. Source data: [Datadog dashboards / POC spike doc / support ticket sample, with date]. Section owner: [team].*
