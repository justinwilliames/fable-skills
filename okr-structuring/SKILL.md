---
name: okr-structuring
description: Use this skill whenever the user wants to write, draft, review, audit, critique, distill, cascade, or set OKRs (Objectives and Key Results). Trigger on phrases like "write OKRs", "draft OKRs", "review my OKRs", "audit these OKRs", "are these good OKRs", "cascade these OKRs", "turn these into functional OKRs", "distill CEO OKRs into team OKRs", "set Q[N] OKRs", "team OKRs", "departmental OKRs", "functional OKRs", "OKR check-in", "what should our OKRs be", "annual OKRs", "quarterly OKRs", "stretch OKR", "committed OKR", "is this a good Key Result", or any request to write, sharpen, or critique an Objective with measurable Key Results. The skill draws on published authorities — Andy Grove, John Doerr, Christina Wodtke, Ben Lamorte, Felipe Castro, Rick Klau, the What Matters playbook — not on any single author's house style. It picks the right mode (Audit / Cascade / Create), enforces eight universal must-haves, actively detects ten named failure modes, and outputs a Notion-ready structure in one of two shapes (single-page narrative OR three-database tabular) so the user can stand the system up once and reuse it. Audit mode is adversarial — the skill names what is broken before suggesting rewrites.
---

# OKR Structuring

A skill for writing, cascading, and auditing OKRs against the published canon. Output is always ship-ready: either a copy-paste Notion block or a structured critique with rewrites.

---

## 1. When to use this skill

Fire this skill on any request that involves:

- Writing OKRs from scratch (top-down, leadership, or functional)
- Reviewing existing OKRs for quality
- Cascading CEO or leadership OKRs into team / functional OKRs
- Auditing whether a team's OKRs are actually OKRs (vs task lists in disguise)
- Designing a Notion structure to hold OKRs across cycles
- Setting up the cycle, check-in cadence, and confidence-scoring rhythm

Do NOT fire this skill for:

- General goal-setting that isn't OKR-shaped (use a planning approach, not the OKR formalism)
- Performance reviews (OKRs are explicitly decoupled from compensation — see failure mode #6)
- Personal habit/health goals (OKRs are an organisational tool, not a productivity hack)

---

## 2. The three modes

The skill operates in one of three modes. Pick the mode from the user's request before doing anything else. If unclear, ask once.

| Mode | Trigger | Input | Output |
|---|---|---|---|
| **Audit** | "review", "audit", "are these good", "rate these OKRs", user pastes existing OKRs | Existing OKRs (any format) | Per-O and per-KR scorecard + named failure-mode hits + rewrites |
| **Cascade** | "distill into functional", "cascade", "turn CEO OKRs into team OKRs", "what should my team's OKRs be given X" | Parent (CEO / leadership) OKRs + functional context (team, capabilities, headcount) | 1-3 functional Objectives, 3-5 KRs each, with explicit ladder-up to parent KRs |
| **Create** | "write OKRs for X", "draft OKRs", "what should our Q[N] OKRs be" | Function, cycle, strategic context | Full OKR set + recommended Notion shape |

After picking the mode, run the eight must-haves and ten failure modes. Never skip them.

---

## 3. The canon — who to cite when

OKRs are a 50-year-old framework with a small, stable canon. When the user pushes back or asks "says who", cite from this list. Do not invent authorities.

| Source | What they're the canon for |
|---|---|
| **Andy Grove**, *High Output Management* (1983) | The origin. OKRs invented at Intel. "iMBOs" — Intel's name. The two-question test: *Where do I want to go?* (Objective) *How will I pace myself to see if I am getting there?* (Key Results) |
| **John Doerr**, *Measure What Matters* (2018) + whatmatters.com | Brought OKRs to Google via Kleiner Perkins. Defines committed vs aspirational ("moonshot") OKRs. Author of the "CFRs" extension (Conversations, Feedback, Recognition). |
| **Christina Wodtke**, *Radical Focus* (2016, 2nd ed. 2021) | The practical operator playbook. Weekly check-in cadence, confidence scoring, the 4-square Monday/Friday format. The single best book for teams actually running OKRs. |
| **Ben Lamorte**, *The OKRs Field Book* (2022) | Coaching-led implementation. Strong on outcome-vs-output distinction and the "OKR coach" role. |
| **Felipe Castro**, felipecastro.com / *The Beginner's Guide to OKR* | Cleanest public taxonomy of OKR anti-patterns. The "OKR shift" — from output to outcome — is his framing. |
| **Rick Klau**, "How Google sets goals" (YouTube, 2013) | The definitive Google-internal account. Source of the "0.7 is a good score" stretch-goal convention. |
| **Lenny Rachitsky**, Lenny's Newsletter | Modern practitioner commentary, especially on whether OKRs are still worth it at startup stage. |

**Default position when sources conflict:** Wodtke for cadence and team mechanics, Doerr for committed vs aspirational distinction, Grove for the underlying logic, Castro for failure-mode names.

---

## 4. Eight universal must-haves

Every OKR set, regardless of mode, must pass all eight. Run this checklist explicitly in Audit mode. Pre-empt it in Cascade and Create mode.

1. **The Objective is qualitative, time-bound, and inspirational.** A sentence a team member can repeat from memory and feel pulled toward. Not a number. Not a task. *("Make [your product] the obvious choice for [your target segment]" — yes. "Hit $5M ARR" — no, that's a KR.)*

2. **3-5 Key Results per Objective.** Fewer than 3 = the Objective probably isn't ambitious enough to need triangulation. More than 5 = nothing is a priority.

3. **Every Key Result is outcome-based and independently measurable.** A KR is a number with a baseline, a target, and a deadline. Booleans count only when binary truly matches reality (e.g., "Ship feature X by Mar 31" — but see failure mode #1, this is usually a task in disguise).

4. **The KRs, if all hit, would prove the Objective is met.** The pass-the-KRs test. If you could hit every KR and still not have achieved the Objective, the KRs are wrong.

5. **Single accountable owner per Objective.** Not a team. Not a committee. One name. The team contributes; the owner is on the hook.

6. **Cycle is named and time-bound.** Quarterly is default (Doerr/Google standard). Annual is acceptable for company-level only. Anything shorter than a quarter is a project, not an OKR.

7. **Committed vs Aspirational is labelled.** Committed = must hit 1.0. Aspirational ("moonshot" in Doerr's terms) = 0.7 is success, 1.0 means you sandbagged. Mixing them without labels is the most common reason OKR programs collapse.

8. **Check-in cadence is defined.** Weekly confidence score (0-100% or 1-10) per KR is the Wodtke standard. Without it, OKRs become set-and-forget — failure mode #5.

---

## 5. Ten named failure modes

In Audit mode, scan for every one of these explicitly. Name the failure mode by number when you flag it — gives the user something to refer back to.

**1. Activity-KR (task in disguise).** "Launch X by Mar 31", "Hire 3 engineers", "Build the dashboard". These measure that work happened, not that anything changed. Test: *if we did this perfectly and the business looked identical, would we still call it a win?* If yes, it's an activity, not an outcome. Rewrite as the metric the activity is supposed to move.

**2. Vanity-metric KR.** Measures something that goes up regardless of effort or doesn't correlate with the Objective. Page views, follower counts, leads created (vs qualified). Test: *can this metric move without the business actually getting better?* If yes, it's vanity.

**3. Cascade-copy.** Functional OKR is the parent OKR re-stated with the team's name swapped in. ("Company: Increase revenue 20%." / "Sales: Increase revenue 20%.") Functional OKRs should translate, not duplicate. See Section 7 for the contribution-path test.

**4. Sandbagging.** KRs set at targets the team is already on pace to hit. Confidence at week 1 is already >90%. Doerr/Klau: aspirational OKRs should sit at ~50% confidence at start. Committed OKRs at ~70%.

**5. Set-and-forget.** OKRs published, then untouched until end-of-quarter retro. No weekly check-in, no confidence trend. Wodtke: this is the most common failure mode at companies that "tried OKRs and they didn't work".

**6. Compensation-linked.** OKR achievement tied to bonuses, performance reviews, or comp bands. Grove and Doerr are both explicit: this is fatal. Linking comp incentivises sandbagging and kills aspirational OKRs. Performance is reviewed separately.

**7. Too many OKRs.** >5 Objectives at any level, or >5 KRs per Objective. Wodtke's heuristic: a team should be able to recite all their OKRs from memory. If they can't, prune.

**8. Vague Objective.** "Improve customer experience." "Be a great place to work." Reasonable wishes; not Objectives. Test: *can two reasonable people read this and disagree about whether we hit it?* If yes, sharpen.

**9. Output-vs-outcome confusion.** Counting things shipped (features, content pieces, integrations) instead of the impact they create (activation rate, retention curve, revenue per user). This is failure mode #1's quieter cousin — looks more metric-y but still measures activity.

**10. Orphan KR.** Functional KR with no clear ladder-up to a parent KR. The team is doing work no one at the level above is counting on. Either the parent OKRs are missing something, or the team is off-strategy. Either is worth surfacing.

---

## 6. The cascade logic — top-down done right

This is the heart of the skill. Most companies cascade badly. The published canon is consistent on the right way:

### What cascading is NOT

- Copy-paste the parent OKR with the team name on it (failure mode #3)
- Take the parent's KRs and divide them up by team
- Demand every team contribute to every parent OKR

### What cascading IS

A functional OKR is a **contribution path**. The team picks 1-2 parent KRs they can credibly move, then writes Objectives and KRs that describe *how this function will move those parent KRs*.

### The four-step cascade

**Step 1 — Read the parent OKRs.** Identify each parent KR's metric, baseline, target, and timeframe. Note which ones this function can plausibly influence (some won't be — Finance can't move Engineering's deploy frequency).

**Step 2 — Pick the contribution targets.** Most functions can credibly influence 1-3 parent KRs in a cycle. Pick those. If a function can't influence any parent KR, either the parent OKRs are missing something or the function is misaligned — surface that explicitly.

**Step 3 — Translate, don't duplicate.** For each contribution target, draft 1 functional Objective that describes the function's role in moving it. Then draft 3-5 functional KRs that measure the function's specific contribution — leading indicators, conversion-rate improvements, capacity-building outputs that feed the parent metric.

**Example translation:**
- Parent KR: *"Grow paid signups from 800/mo to 1,400/mo."*
- Bad cascade (Marketing): *"Grow paid signups from 800/mo to 1,400/mo."* (copy)
- Good cascade (Marketing): *Objective: "Build a top-of-funnel that consistently delivers qualified demand at the volume product needs."* / KRs: "Increase qualified demo bookings from 120/mo to 220/mo", "Lift demo-to-paid conversion from 18% to 24%", "Reduce paid CAC from $X to $Y".

**Step 4 — Run the ladder-up test.** For each functional KR, write the one-line answer to: *"If we hit this KR, which parent KR moves, and by roughly how much?"* If you can't answer it, the KR is orphan (failure mode #10) — drop it or rewrite.

### Cascade mode escalation rule

**If the user requests Cascade mode but has not supplied parent OKRs**, ask once — a single clear question listing what is needed (parent Objectives and KRs, with their owners and cycle). Do NOT synthesise or invent parent OKRs from guesswork; fabricated parent context produces functional OKRs that are untethered from strategy and will cascade the wrong direction. Block until the parent set is provided.

### Counter-cascade: bottom-up input

Wodtke and Lamorte both flag this. Strict top-down cascading kills ownership. Best practice: leadership sets ~60% of functional OKRs via cascade; functions propose ~40% from their own ground-truth view. Surface the bottom-up portion explicitly in Cascade mode output.

---

## 7. Notion structure — two shapes

The user picks. Surface both at first encounter with the user; commit to one and use it consistently after.

### Shape A — Single-page / high-level (narrative)

**When to use:** Solo operators, small teams (<10 people), exec-summary readouts, all-hands documents, cycles where the OKR set is the whole strategy and lives in prose. Lightweight; no per-KR check-in mechanism beyond manual updates.

**Structure:**

```
# [Function or Company] OKRs — Q[N] [Year]

**Owner:** [Name]
**Cycle:** [Start date] → [End date]
**Last check-in:** [Date]

---

## Objective 1: [Inspirational sentence]
**Type:** Committed | Aspirational
**Confidence:** [0-100%]

- **KR 1.1** — [Metric]: [Baseline] → [Target] by [Date]. *Current: [X]. Confidence: [Y%].*
- **KR 1.2** — [as above]
- **KR 1.3** — [as above]

**Ladder-up:** Contributes to parent KR [X.Y] — *[one-line how]*.

---

## Objective 2: [...]
[same shape]

---

## Weekly check-in notes
- **Week of [date]:** [confidence movement + what changed]
- **Week of [date]:** [...]
```

**Trade-offs:**
- ✓ Fast to set up, easy to read end-to-end, exec-friendly
- ✓ Good for narrative and context
- ✗ No structured filtering (can't view "all KRs off-track")
- ✗ Manual to roll up across teams
- ✗ Doesn't scale past a handful of Objectives

### Shape B — Database / tabular (operational)

**When to use:** Org-wide rollouts, multiple teams/functions, cycles where you need to filter and roll up. Heavier to set up; pays back from the second cycle onward.

**Three databases, related:**

#### B1. Cycles DB
| Property | Type | Notes |
|---|---|---|
| Cycle name | Title | e.g., "Q1 2026" |
| Start date | Date | |
| End date | Date | |
| Status | Select | Planning / Active / Closed |
| Cycle narrative | Text | One-paragraph "what this quarter is about" |

#### B2. Objectives DB
| Property | Type | Notes |
|---|---|---|
| Objective | Title | The qualitative sentence |
| Owner | Person | Single accountable |
| Function | Select | Company / Product / Eng / Marketing / Sales / CS / Ops / Finance / People |
| Cycle | Relation → Cycles | |
| Parent Objective | Relation → Objectives (self) | For cascade trees |
| Type | Select | Committed / Aspirational |
| Status | Select | Not started / On track / At risk / Off track / Done |
| Confidence | Number (0-100) | Rolled up from KRs or set manually |
| Narrative | Text | Why this matters, context |

#### B3. Key Results DB
| Property | Type | Notes |
|---|---|---|
| KR | Title | The measurable statement |
| Objective | Relation → Objectives | Required |
| Parent KR | Relation → Key Results (self) | For ladder-up trace |
| Metric type | Select | Numeric / % / $ / Boolean |
| Baseline | Number | Starting value |
| Target | Number | End-of-cycle target |
| Current | Number | Updated weekly |
| Unit | Text | e.g., "MQLs/month", "%" |
| Owner | Person | KR-level owner if different from Objective owner |
| Confidence | Number (0-100) | Weekly check-in |
| Last updated | Date | Auto via formula on Confidence change |
| Check-in notes | Text | Rolling weekly notes |

#### Standard views

Build all six on day one — they are what makes this shape worth the setup cost.

1. **Current cycle, by Function** — grouped view, all Objectives + KRs for the active cycle, grouped by Function
2. **Confidence dashboard** — board view of KRs by Confidence band (>70% on track, 40-70% at risk, <40% off track)
3. **Off-track only** — filtered view of KRs with confidence <40% (the weekly intervention list)
4. **Cascade tree** — hierarchy view via Parent Objective relation; CEO → leadership → functional
5. **By Owner** — every person's OKRs in one place
6. **Historical** — all closed cycles, for retros and "where did we end up vs target"

**Trade-offs:**
- ✓ Filters, rollups, cascade traces all work
- ✓ Scales across teams and cycles
- ✓ Check-in cadence is enforced by the data shape
- ✗ Two hours to set up properly first time
- ✗ Heavier than narrative — not the right shape for a single-operator exec summary

---

## 8. Check-in cadence

Independent of Notion shape. Default to Wodtke's pattern:

- **Monday commitment** (15 min, async or live): each owner posts current confidence per KR + the 1-3 things they're doing this week to move it.
- **Friday celebration** (15 min): each owner posts what moved + what didn't + confidence delta.
- **Mid-cycle review** (45 min, week 6 of a quarter): drop or rewrite any OKR that's clearly broken. Doerr/Wodtke both endorse mid-cycle correction.
- **End-of-cycle retro** (60 min): score every KR (0.0-1.0). Discuss what was learned. Decouple completely from comp/reviews.

---

## 9. Output templates by mode

### Audit mode output

```
# OKR Audit — [Function/Company], [Cycle]

## Overall verdict
[1-paragraph headline: which of the 8 must-haves pass, which fail, which 1-3 failure modes are dominant]

## Must-haves scorecard
| # | Must-have | Pass / Fail | Notes |
| 1 | Qualitative Objective | ... | |
| ... | ... | ... | |

## Failure modes detected
| # | Mode | Where | Severity |
| 1 | Activity-KR | KR 2.3 — "Launch dashboard by Mar 31" | High |
| ... | ... | ... | ... |

## Per-Objective review

### Objective 1: [...]
**Score:** [X/10]
**What works:** [...]
**What's broken:** [name the failure modes by number]
**Proposed rewrite:**
> [rewritten Objective]
> - KR 1.1 (rewritten): [...]
> - KR 1.2 (rewritten): [...]

[repeat per Objective]

## Top 3 fixes (priority order)
1. [The single highest-leverage fix]
2. [...]
3. [...]
```

### Cascade mode output

```
# Functional OKRs — [Function], [Cycle]

## Parent OKRs this set ladders up to
[List parent OKRs being cascaded from, with which KRs this function will move]

## Functional OKRs

### Objective 1: [Inspirational sentence]
**Type:** Committed | Aspirational
**Owner:** [Name]
**Ladder-up:** Contributes to parent KR [X.Y] via [one-line mechanism]

- **KR 1.1** — [Metric]: [Baseline] → [Target] by [Date]
- **KR 1.2** — [...]
- **KR 1.3** — [...]

[repeat]

## Bottom-up additions
[Any OKRs this function is proposing that aren't direct cascades — the ~40% ground-truth additions]

## Open questions for leadership
[Anything where the parent OKRs are unclear, contradictory, or missing a function-relevant lever]
```

### Create mode output

Same shape as Cascade, minus the parent-OKR ladder section. Add a recommended Notion shape (A or B) with rationale.

---

## 10. What "good" looks like — worked examples

### Good Objective + KRs (B2B SaaS, Marketing function)

**Objective:** Make qualified pipeline the bottleneck-of-choice for the business — not a bottleneck we're stuck with.
**Type:** Committed.
**Owner:** [Head of Marketing]

- KR 1: Increase qualified demo bookings from 120/mo to 220/mo by Mar 31.
- KR 2: Lift demo-to-paid conversion from 18% to 24% by Mar 31.
- KR 3: Reduce blended CAC from $X to $Y by Mar 31 while holding pipeline volume.
- KR 4: Ship one repeatable channel test per month for the cycle (Boolean count; 3 by end of cycle).

**Why this is good:** Objective is qualitative and aspirational. KRs are outcomes (not activities). KRs prove the Objective — if all four hit, the function has demonstrably made pipeline a controllable variable. KR 4 is a defensible Boolean because it's about learning velocity, not feature shipping.

### Bad Objective + KRs (same function)

**Objective:** Improve marketing performance.
- KR 1: Launch new website by end of quarter.
- KR 2: Run 5 paid campaigns.
- KR 3: Generate 5,000 leads.

**Why this fails:**
- Objective: vague (failure mode #8) — what does "improve" mean
- KR 1: Activity-KR (failure mode #1) — shipping a website isn't a result
- KR 2: Activity-KR — running campaigns isn't a result
- KR 3: Vanity-metric KR (failure mode #2) — leads ≠ qualified leads ≠ revenue

---

## 11. Adversarial defaults

When the user pushes back on a critique:

- **Cite a specific source.** "Wodtke is explicit on this in *Radical Focus*..." not "best practice says".
- **Distinguish house preference from canon.** If the user wants something the canon allows but isn't optimal, say so plainly. Don't dress preference as principle.
- **Hold the line on the eight must-haves.** They're not stylistic. They're the load-bearing definition of an OKR.
- **Concede ground on cadence and shape.** Reasonable people disagree on weekly vs fortnightly, Shape A vs Shape B. Match the user's reality.

Never rubber-stamp. The skill exists because most OKR sets in the wild fail at least 3 of the 10 named failure modes. The default posture is: assume there's something broken, find it, name it, fix it.

---

## 12. House conventions

- **Match the user's English convention** — if they write "behaviour" / "organise", respond in AU/UK English; if "behavior" / "organize", in US English.
- **No em dashes** — use hyphens with spaces or commas.
- **No § / ¶ / № typographical shorthand** — spell it out.
- **Plain operator voice in skill output.** Skill output is a working document — keep output in plain operator voice, not the chat persona.

---

Sync home: canonical = your live private copy; public sanitized twin: ~/code/skills/okr-structuring → github.com/justinwilliames/skills. Sanitization is a sync step.

v1.1 — 2026-07-03
