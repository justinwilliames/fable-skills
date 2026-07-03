# PM Best Practices — Distilled

This reference distils the eight PM authorities whose work underwrites this skill. Each section is short on purpose — the goal is to keep the load-bearing thesis and the one or two patterns the skill bakes in, not to reproduce the original essays.

A note on research provenance, kept honest at the top: not every source was reachable in full primary text. Cagan's SVPG essays, Doshi's personal site, and Reforge's articles returned 403s or paywalls in the research run that built this skill. Where that is the case, the quotes below are drawn from search-engine extracts and secondary references (Lenny's podcast notes, Amplitude interviews, free Confluence templates). Treat them as faithful paraphrases rather than direct primary quotes. Marked inline where it matters.

---

## Marty Cagan (SVPG)

**Core thesis.** The traditional PRD is an artefact of the waterfall era. A high-fidelity prototype produced through product discovery beats a written spec almost every time. Where a written doc is still needed, it must follow discovery, not replace it.

**What only Cagan adds.** The structural separation of the *what* from the *how*. Cagan's 2006 PRD guide was 37 pages; his post-2007 view is that 80% of that should be replaced by prototypes. The point that survived: the PRD's job is to articulate the problem and the desired user outcome — never the implementation. Engineering chooses the how. Design chooses the form. PM owns the why and the success criteria, full stop. This sharper boundary is more disciplined than any other authority in this set.

**Representative quotes** *(paraphrased from search-engine extracts of SVPG primary sources; full essay text was 403'd on direct fetch — treat as faithful summaries rather than verbatim):*

- "High-fidelity prototypes of a product are the best replacement for PRDs." (Revisiting the Product Spec, 2007)
- "The PRD's goal is to explain the *what*, not the *how*. In each section, be clear on the problem being solved versus the solution."
- "Teams are reverting back to heavy use of artefacts. The problem is, in nearly every case, the PRD is written instead of the discovery work."

**Pattern baked into the skill.** Mechanical separation of problem from solution. The draft cannot contain wireframes, API contracts, or implementation detail before the problem statement, target user, and success metrics are complete. This is failure mode 4 in `references/failure-modes.md`.

---

## Lenny Rachitsky

**Core thesis.** Nailing the problem statement is the single highest-leverage step. The doc itself should be a one-pager by default. Non-goals are as load-bearing as goals.

**What only Lenny adds.** The Non-Goals section as a first-class element. Lenny borrowed the pattern from Kevin Yien at Square. It is the most under-used structural section in PRDs and the highest-leverage anti-scope-creep mechanism in the literature. Lenny also champions the iterative review pattern — share, integrate feedback, re-share, iterate — over the "PM emerges with a finished doc" anti-pattern.

**Lenny's one-pager structure** (Atlassian Confluence template, fetched directly):

1. Description — What is it?
2. Problem — What problem is this solving?
3. Why — How do we know this is a real problem worth solving?
4. Success — How do we know if we've solved this problem?
5. Audience — Who are we building for?
6. What — What does this look like in the product?

Plus appendix, timeline, and Non-Goals.

**Representative quotes** *(from Lenny's free Confluence template and the public "favorite templates" newsletter issue; the side-by-side PRD examples article is paywalled and unread):*

- "Nailing the problem statement is the single most important step in solving any problem. It's deceptively easy to get wrong. It's a superpower of the best leaders."
- "Share the draft with the entire team, ask for feedback, integrate, re-share — iterate."
- On Kevin Yien's Square template: praises specifically the Non-Goals section and the step-by-step flow structure.

**Pattern baked into the skill.** The non-goals section is mandatory with at least three items before the draft is marked ready. Failure mode 3 in `references/failure-modes.md`.

---

## Shreyas Doshi

**Core thesis.** A great PM writes the PRD iteratively and collaboratively so engineering and design are never blocked waiting on it. Quality is clarity plus judgment, not length.

**What only Doshi adds.** Two things. First, the explicit call-out that success metrics need a *dashboard view*, not just a numeric target — most PRDs name the metric but never specify where the team will look at it on launch day. Second, the LNO framework applied to PRD writing itself: most PRD time is Overhead disguised as Leverage. The PM who spends two months perfecting a PRD has often spent eight weeks on what should have been two days.

**Representative quotes** *(from Lenny's podcast notes, Amplitude interview, and search extracts; Doshi's personal site returned encoded content in the research run and was not directly readable):*

- "Good PMs write detailed and lucid PRDs that their teams become highly reliant on. Great PMs iteratively write their PRDs so engineering and design tasks are rarely blocked on them."
- "By forcing ourselves to write down our thinking, it enables the reaching of consensus or a decision better than if we were trying to do it all just in a meeting."
- LNO framework: "Leverage tasks return 10x to 100x. Neutral tasks return 1.1x. Overhead tasks are necessary but return little. Most PRD time is Overhead disguised as Leverage."

**Pattern baked into the skill.** The success metrics format requires a dashboard reference, not just a number — failure mode 2 in `references/failure-modes.md`. The skill defaults to the shortest viable shape (discovery brief, opportunity assessment) before reaching for Standard PRD — direct application of Doshi's LNO logic to doc choice.

---

## Amazon (Working Backwards / PR-FAQ)

**Core thesis.** Write the press release before any code. Force the team to articulate the customer-visible win first. If you cannot write a press release that excites a customer, the idea is not ready.

**What only Amazon adds.** The PR-FAQ shape itself, and the principle of "truth-seeking, not selling". The internal FAQ section is the most under-rated discipline in product writing — it forces the team to name competitive position, market size, technical risk, profitability timeline, and failure conditions before any commitment is made. A PR-FAQ that reads as a sales pitch has failed at its purpose.

**Required sections** (fetched directly from workingbackwards.com/resources):

Press release (6 paragraphs):

1. Heading — one-sentence product name plus customer
2. Subheading — segment plus benefit
3. Summary — launch context, product, advantage
4. Problem — customer-centric, with TAM and viability
5. Solution — how the product solves the problem
6. Quotes — internal plus hypothetical customer, then getting-started CTA

External FAQ: price, how it works, support, where to buy.

Internal FAQ: competitive landscape, market size, technical and operational challenges, upfront investment, profitability timeline, success assumptions, failure risks.

**Representative quotes** (fetched directly):

- "Start with the customer and work backwards. Easy, right? In practice, much harder than it sounds."
- "Velocity, not raw speed." (Velocity is directional — the right direction at speed beats motion in the wrong direction.)
- "First drafts should take only a few hours, not a few days. Then iterate over weeks or months."

**Pattern baked into the skill.** The PR-FAQ is one of the seven document shapes. The internal FAQ requirement — surface what could fail, not what could go right — feeds failure mode 7 (tradeoffs avoided) and failure mode 9 (no pre-mortem) in `references/failure-modes.md`.

---

## John Cutler

**Core thesis.** A one-pager is for shared understanding, not specification. Outcomes over outputs. Reduce uncertainty, do not manufacture certainty.

**What only Cutler adds.** Three patterns the other authorities do not name explicitly. First, "definition of awesome / celebration quotes" — what would the team say at the retro if this worked. Second, "pivot and proceed points" — the criteria under which the team would change direction or push through. Third, "operating assumptions" as a first-class section — the load-bearing beliefs the work rests on, surfaced rather than left implicit.

**Cutler's one-pager structure** (Medium essay, fetched directly):

- Title and tweet-length mission (not feature-named)
- Definition of awesome / celebration quotes
- Cost of delay estimate
- Pivot and proceed points
- Key data points and insights
- Operating assumptions
- Open questions / assumptions to validate
- Risks to mitigate
- Baseline behaviour and target condition
- Possible interventions

**Representative quotes** (fetched directly):

- "One-pagers are not meant to communicate detailed specifications, requirements, and plans."
- "Outcome oriented — start with the desired outcome, not the output."
- "It is dangerous to go more than three months without showing a meaningful outcome." (Cutler recommends a one-week to three-month scope per one-pager.)

**Pattern baked into the skill.** The feature-named initiative check (failure mode 5) is Cutler's. The operating assumptions section requirement (failure mode 10) is Cutler's. The skill's discovery brief and opportunity assessment templates borrow Cutler's "definition of awesome" framing for the success section.

---

## Ravi Mehta

**Core thesis.** In the AI-first era, the spec *is* the source code — but only if it is written with enough specificity that humans and AI can both execute against it. The traditional product lifecycle was built to manage the cost of building wrong things; that cost has collapsed, so prototypes and tight specs replace heavy upstream documents.

**What only Mehta adds.** The argument that a sufficiently precise spec generates working code through AI tooling, and the corollary that vague specs now actively hurt the team — they produce messy AI-generated codebases. Mehta is also the strongest voice for prototype-led PRDs: a working prototype linked from the doc beats prose for the "what does this look like" section.

**Representative quotes** (fetched directly from blog.ravi-mehta.com):

- "A sufficiently robust spec can generate good TypeScript, good Rust, servers, clients, documentation, tutorials, blog posts, and even podcasts."
- "Working software is no longer just what you deliver at the end of the process. It's integral to how we communicate, decide, and validate along the way."
- "The traditional product lifecycle was not designed to help you build great products. It was designed to manage the cost of building the wrong ones."
- "Vague specs produce messy codebases."

**Pattern baked into the skill.** The Standard PRD and Launch PRD templates name a "Prototype" field as first-class — a Figma URL or working-software link sits adjacent to the solution overview, not buried in an appendix. The behavioural-specification rigor in the solution section is sharper than older PRD shapes called for.

---

## Reforge

**Core thesis.** PRDs are not dead but must evolve to match modern agile reality. A product spec or "Lean PRD" is two to three pages, intended to inspire and enable conversation across cross-functional leaders. Frameworks over templates.

**What only Reforge adds.** The "10 components of a great product spec" framework, which is the closest thing in the literature to a structural checklist for the Standard PRD shape: problem; user; opportunity; goals plus non-goals; success metrics; solution overview (not detailed design); scope; key flows; risks and dependencies; rollout plan. Reforge is also the most explicit voice on length-as-quality being a failure mode rather than a virtue.

**Representative quotes** *(from search-engine extracts and Reforge's public blog index; the full "How to Write a PRD" and "10 Components" articles are paywalled and not directly readable):*

- "Product specs, also called Lean PRDs, are typically 2-3 pages in length and are intended to inspire and enable conversation with cross-functional leaders around the solution space."
- On framework versus template: Reforge consistently argues for adaptive frameworks over rigid templates, with the structure adjusting to the maturity of the work.

**Pattern baked into the skill.** The 10-component structure shapes the Standard PRD template directly. The length-as-quality failure mode (failure mode 8 in `references/failure-modes.md`) is Reforge's call. The "frameworks over templates" stance underwrites the skill's seven-shape adaptive picker rather than a one-template-fits-all approach.

---

## Aakash Gupta

**Core thesis.** The modern PRD is shorter than the 2006 version but more insightful. It reads like a blog post but contains all the information of the old Word document. Data-driven narrative beats requirements list.

**What only Aakash adds.** A clean named list of modern PRD failure modes — the most explicit failure-mode taxonomy in any of the eight sources. Aakash also stresses analytics gaps and the avoidance of tradeoffs more sharply than other authorities.

**Aakash's named failure modes** (from news.aakashg.com, fetched directly):

- Weak content quality (filling sections with vacuous statements)
- Missing customer validation
- Over-delegation (pushing design decisions to designers instead of establishing PM thinking upfront)
- Analytics gaps (failing to specify concrete metrics with measurable controls)
- Avoiding tradeoffs (ignoring downside risks like potential conversion losses)

**Representative quotes** (fetched directly from news.aakashg.com):

- "The modern PRD reads like a blog post but contains all the information of the old Word document."
- "Avoiding tradeoffs is the most common quality failure in PRDs I review."
- "Analytics gaps — failing to specify concrete metrics with measurable controls — is the single most-cited weakness in retrospective PRD reviews."

**Pattern baked into the skill.** Three of the ten failure modes in `references/failure-modes.md` map directly to Aakash's taxonomy — failure mode 6 (no customer evidence), failure mode 7 (tradeoffs avoided), failure mode 2 (unmeasurable success). The narrative-not-list voice rule in `references/voice-clarity-rules.md` is Aakash's framing.

---

# What every authority agrees on

The bedrock. These points appear, with consistent emphasis, across all eight sources. They are the skill's non-negotiables.

1. **The problem statement is the highest-leverage section.** Cagan, Lenny, Cutler, Amazon, Aakash, Mehta — every one of them puts the problem first and warns against solutions in disguise. Nailing the problem changes the trajectory of the work more than any other single decision.

2. **Outcomes beat outputs.** Cutler is loudest on this, but Cagan, Doshi, Aakash, and Amazon all reinforce it. Titles, missions, and success criteria orient around what changes for the user or business, never the feature that ships.

3. **Measurable success or no ship.** Doshi names the dashboard. Aakash names the analytics gap. Lenny names the "Success" section as a required heading. Without a measurable criterion the team cannot tell whether the work succeeded — and cannot kill it when it did not.

4. **Non-goals are as load-bearing as goals.** Lenny is the loudest voice here; Reforge codifies it in their 10-component framework; Cutler implies it in "pivot and proceed points". The most common cause of slipped delivery is unbounded scope.

5. **Tradeoffs surfaced, not hidden.** Amazon's "truth-seeking, not selling". Aakash's number-one named failure mode. Every meaningful decision has a downside; a doc that names none cannot be trusted.

6. **Customer evidence behind every problem claim.** Aakash's number-one quality flag, Lenny's "Why" section, Amazon's "Problem paragraph", Mehta's "concrete behavioural specification". Assertions without citations are intuitions in disguise.

7. **Length is not quality.** Reforge and Doshi name this explicitly. Cagan's modern revisit cut his own 37-page PRD guide to a recommendation that 80% of it be replaced with prototypes. Short, sharp, and read beats long, padded, and skimmed.

8. **Risks surfaced, not assumed away.** Amazon's internal FAQ, Cutler's "risks to mitigate", Doshi's pre-mortem, Mehta's "assumptions to validate". The doc earns trust by surfacing its own weakness, not by hiding it.

These eight points are the skill's bedrock. Every other decision — shape, template, voice rule, failure-mode check — sits on top of them.
