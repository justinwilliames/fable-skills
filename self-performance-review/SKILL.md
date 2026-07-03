---
name: self-performance-review
description: >
  Use this skill whenever the user wants a weekly self-performance review, dipstick check, retrospective on their own work, or "how am I going" assessment. Trigger on phrases like "self-performance-review", "weekly review", "how did I do this week", "performance check", "dipstick on my week", "what did I ship this week", "where are my blind spots", "review my week", "retro on my week", "audit my work", "honest take on how I'm performing", or any request asking for an outside view on the user's own output, communication, time allocation, or follow-through. The skill pulls evidence from Slack, Notion, Gmail, Google Calendar, Claude Code sessions, and any meeting transcripts it can find, then benchmarks against established performance and communication frameworks (Grove, Drucker, Bezos, async-comms hygiene) and produces a structured weekly review with blind-spot calls and 3 concrete improvements for next week. Defaults to the last 7 days; accepts a custom window. Reports are written to a stable local folder of your choice, e.g. ~/performance-reviews/YYYY-MM-DD.md so each week's run can compare against the prior week's improvement targets.
---

# Self Performance Review

A weekly dipstick on the user's actual work, communication, and decisions — measured against published performance and communication best practice, not vibes.

Output is a single structured report. Honest, opinionated, evidence-backed. Praise that's earned. Criticism that's specific. No hedging, no horoscope language, no "you're doing great!" filler.

## When to invoke

- The user runs `/self-performance-review` (or any of the trigger phrases in the description)
- Default lookback: **last 7 days** (Mon-Sun if today is Mon/Tue, otherwise rolling 7)
- The user can override with "last 2 weeks", "last month", "since Friday", etc.

## The frameworks the review anchors to

These are the yardsticks. Cite them by name in the report so the user can audit the logic.

### Performance

- **Grove — High Output Management.** Output = activity × leverage. Activity is busywork; output is *what shipped that affects the system*. Measure shipped artifacts, decisions made, people unblocked — not hours logged or messages sent.
- **Drucker — The Effective Executive.** Effectiveness = doing the right things, not doing things right. First things first; concentration on a few priorities; decisions over reactions.
- **Bezos — Type-1 vs Type-2 decisions.** Irreversible (Type-1) decisions deserve careful analysis; reversible (Type-2) decisions should be made fast. Spending Type-1 energy on Type-2 work is a leak. Spending Type-2 speed on Type-1 work is reckless.
- **Reforge / Lenny — leverage and compounding.** Did the week's work compound (skills, systems, brand, code, relationships) or evaporate (tickets closed but nothing accrued)?

### Communication

- **Async-first hygiene.** Decisions documented; context lives where it's needed; written clarity > meeting volume.
- **Response latency.** Are threads being left hanging? Soft commitments turning into ghosting?
- **Tone calibration.** Curt, sycophantic, clear, or evasive — sampled from actual outbound messages.
- **Ratio of asks vs answers, gives vs takes.** Is the user mostly extracting or mostly contributing in their core channels?

### Meeting hygiene (Grove + Cal Newport — deep work)

- Total meeting hours / week — **only events with ≥ 2 attendees count.** Solo calendar entries (lunch, focus blocks, gym, OOO, personal blocks) are not meetings, full stop.
- Back-to-back density (any 3-hour-plus blocks of solid meetings?)
- Recurring vs ad-hoc split
- No-shows and reschedules (theirs and others')
- Deep-work blocks preserved (any 2+ hour uninterrupted blocks?)

## The data pull — sources and tools

Run all of these **in parallel** at the start of the review. Note any source that errors or returns empty so the report can flag the gap.

### Required pulls

| Source | Tool | What to extract |
|---|---|---|
| **Calendar** | `mcp__3dd3d3ce-a539-4928-bc84-51b139526c42__list_events` | Every event in the window. **A "meeting" requires ≥ 2 attendees** (the user + at least one other person). Solo events — lunch, focus blocks, "Focus: X", working-location events, OOO, gym, personal blocks — are NOT meetings and must be excluded from the meeting count. They count as deep-work or personal time instead. Inspect descriptions for Read.ai/Fathom/Granola transcript links. |
| **Gmail** | `mcp__68f17ef3-ef45-45c7-94ec-dc28b9908980__search_threads` | The user's outbound threads in window (`from:me after:YYYY/MM/DD`). Count, top recipients, threads where the user hasn't replied (`is:unread to:me`). Also look for unreplied threads from key people. |
| **Slack** | `mcp__55031377-b138-41eb-bb4a-2b0e7730a3ec__slack_search_public_and_private` | The user's posts in window. DMs sent, channels active in, threads where they were @-mentioned but didn't reply. |
| **Notion** | `mcp__b8c48844-29ce-4b13-9e29-e12205bf18c1__notion-search` + `notion-query-meeting-notes` | Pages created/edited in window. Meeting notes with action items assigned to the user. |
| **Claude Code sessions** | `mcp__ccd_session_mgmt__list_sessions` + `mcp__ccd_session_mgmt__search_session_transcripts` | Sessions in window. Topic clusters, what shipped, recurring problems (same issue across multiple sessions = signal). |
| **Git / shipped work** | Bash | For your active repos — fill in: `gh pr list --author @me --state merged --search "merged:>YYYY-MM-DD"` across your key repos. Plus any release tags pushed. |

### Optional / nice-to-have

- **Transcripts** — if any Calendar events contain Read.ai/Fathom/Granola/Otter links, note them in the report but don't try to fetch the content (most live behind auth). Just count: "8 meetings, 5 had transcripts attached."
- **Call recordings** — if transcripts surface via Notion or Slack, include. Skip otherwise.

### Hat-tagging

Every piece of work gets tagged with its context area (e.g. **[Work]**, **[Side Project]**, **[Personal]**) in the report. Different contexts have different success criteria — don't conflate them.

Define your context tags at the top of your first run. For example:
- **[Work]** = your primary employer/client domain
- **[Project]** = active side projects or open-source
- **[Personal]** = personal tooling, learning, family

## The report structure

Write to a stable local folder of your choice, e.g. `~/performance-reviews/YYYY-MM-DD.md`, and also print to chat. Use today's date as the filename.

If a prior report exists in that directory, **read the most recent one first** and explicitly check: did the user hit the 3 improvement targets from last week? Call it out in section 7.

### Report template

```markdown
# Weekly Self-Review — {window-start} to {window-end}

**Hats this week:** Work {X%} · Project {Y%} · Personal {Z%}  *(rough split by hours/output)*

---

## 1. Headline verdict — one paragraph

Two to four sentences. Honest. What kind of week was it: shipping, planning, scattered, deep, reactive, strategic? Lead with the verdict, not the qualifiers.

## 2. What shipped — the output ledger

Grove's test: *did the system change?*

- **[Hat]** Concrete shipped artifact — PR merged, tag cut, doc published, decision made, person unblocked. One line each. Link where possible.
- Aim for 5-15 items. If under 5, that's a signal — flag it.
- Separate **shipped** (in the wild) from **in-flight** (started, not landed).

## 3. Time allocation — where the week went

| Bucket | Hours | % of working hours | Verdict |
|---|---|---|---|
| Meetings (synchronous, ≥ 2 attendees) | | | |
| Deep work (Claude sessions, coding, writing, focus blocks) | | | |
| Async comms (Slack, email) | | | |
| Unaccounted | | | |

**Meeting density:** {X} meetings, longest back-to-back stretch {Y} hours, {Z} meeting-free 2hr+ blocks. **Solo calendar events (lunch, focus blocks, OOO) excluded — they're not meetings.**

**Verdict:** ratio of meetings to ship — healthy / heavy / starved.

## 4. Communication audit

### Outbound volume + cadence
- Slack messages sent: {N}. Top 3 channels.
- Email threads initiated: {N}. Top 3 recipients.
- Average response latency to people who messaged first: {best estimate}.

### Tone sample
Pull 2-3 actual sentences the user wrote this week. Don't anonymise — name the channel/recipient. Audit for voice consistency: hyphens, dropped apostrophes, soft hedges as collaboration signals vs unnecessary hedging when commitment was needed. Note where the actual voice matched the user's standard, and where it drifted (too curt, too formal, sycophantic).

### Asks vs answers
Rough ratio of "user asked someone for something" vs "user answered someone's ask". Heavy extraction = warning sign.

## 5. Decisions made — Type-1 vs Type-2

- **Type-1 (irreversible)** decisions this week: list them. Each with a one-line "was this analysed with appropriate care?" verdict.
- **Type-2 (reversible)** decisions this week: list them. Each with a one-line "was this made fast enough?" verdict.
- **Decisions deferred:** anything punted on that's costing optionality. Name them.

## 6. Blind spots — the uncomfortable section

This is the section worth running the skill for. Be specific. Cite evidence.

- **Unanswered threads.** People waiting. Name them, name the channel, name how long.
- **Dropped commitments.** "I'll get back to you on X" said and not delivered. Cross-reference Slack/email/Notion action items.
- **Repeated patterns.** Same problem surfacing across multiple Claude sessions, multiple Slack threads, multiple meetings. Likely a structural issue, not a one-off.
- **Topic avoidance.** Anything deflected three+ times. Name it.
- **Energy leaks.** Where Type-1 care was spent on Type-2 work, or vice versa.
- **Compounding gaps.** Things that didn't compound — pure ticket-closing, redo work, busywork that didn't build the system, the brand, or skills.

## 7. Last week's improvement targets — did the user hit them?

If a prior report exists, list the 3 targets verbatim and grade each:
- ✅ Hit — with evidence
- ⚠️ Partial — what was done, what wasn't
- ❌ Missed — why, and is it still worth pursuing

If no prior report, skip this section and write: *(First review — no prior targets to grade.)*

**Grade outcomes, not forms.** When checking whether a target was hit, look for the *intent being satisfied*, not the literal noun used in the wording. The user works across many surfaces — Notion, Linear, Slack, GitHub, scheduled tasks, Mac scripts, Google Drive, their own skills repo. A target phrased as "build a request board" can be hit by a Notion DB, a Linear project, a Slack channel, a shared sheet, a GitHub issue queue, or any system that triages the incoming asks. If the underlying *outcome* exists in any medium the user works in, grade it ✅ Hit — not ⚠️ Partial because the form differed from the template's implied shape.

Concrete examples of outcome equivalents:
- "Build a board" → Notion DB / Linear project / Slack channel / GitHub Projects / scheduled-task pipeline
- "Document X" → memory file / repo README / Notion page / inline code comment / Slack canvas
- "Schedule recurring Y" → cron / launchd / Claude Code scheduled-task / Slack reminder / calendar event
- "Communicate Z to the team" → Slack post / email / 1:1 / standup mention / Notion update / verbal in a meeting

Before grading ⚠️ Partial or ❌ Missed, **actively check every plausible medium** the user might have used. Search Slack channels, list Notion pages, check Linear projects, grep recent git commits, look at scheduled-tasks. Form-blind grading (assuming the target meant literally the medium implied) is a documented failure mode of this skill.

## 8. Three improvements for next week

Three. Not five. Not ten. Three.

Each one must be:
- **Specific** — "respond to X's thread in #channel by Tuesday" not "communicate better"
- **Measurable** — the user or the next review can verify it
- **Leverage-bearing** — fixes something that compounds, not a one-off

Format:
1. **{Target}** — Why: {one-line}. How to verify: {one-line}.
2. **{Target}** — Why: {one-line}. How to verify: {one-line}.
3. **{Target}** — Why: {one-line}. How to verify: {one-line}.

## 9. Earned praise (only when earned)

One short paragraph. The genuinely strong piece of the week — the thing that, if repeated, would make next quarter materially better. If nothing earns praise this week, write *(Nothing landed cleanly enough to call out. Next week.)* and move on. Do NOT manufacture praise.

## 10. Scorecard

Ten categories, scored 1–10, with a colour-coded bar and two deltas: vs. the most recent prior report, and vs. the all-time average across all prior reports. Self-calibrating: the all-time average is recomputed every run from the embedded JSON in each prior report.

| # | Category | Score | Bar | Δ Last | Δ Avg | Why |
|---|---|---|---|---|---|---|
| 1 | Shipping output | X/10 | {bar} | {±N or baseline} | {±N.N or baseline} | {one short sentence with concrete evidence} |
| 2 | Strategic impact | X/10 | {bar} | {±N or baseline} | {±N.N or baseline} | {one short sentence with concrete evidence} |
| 3 | Decision quality | X/10 | {bar} | {±N or baseline} | {±N.N or baseline} | {one short sentence with concrete evidence} |
| 4 | Communication clarity | X/10 | {bar} | {±N or baseline} | {±N.N or baseline} | {one short sentence with concrete evidence} |
| 5 | Follow-through | X/10 | {bar} | {±N or baseline} | {±N.N or baseline} | {one short sentence with concrete evidence} |
| 6 | Focus discipline | X/10 | {bar} | {±N or baseline} | {±N.N or baseline} | {one short sentence with concrete evidence} |
| 7 | Leverage thinking | X/10 | {bar} | {±N or baseline} | {±N.N or baseline} | {one short sentence with concrete evidence} |
| 8 | Stakeholder alignment | X/10 | {bar} | {±N or baseline} | {±N.N or baseline} | {one short sentence with concrete evidence} |
| 9 | Energy management | X/10 | {bar} | {±N or baseline} | {±N.N or baseline} | {one short sentence with concrete evidence} |
| 10 | Personal compounding | X/10 | {bar} | {±N or baseline} | {±N.N or baseline} | {one short sentence with concrete evidence} |
| | **Overall** | **X.X/10** | {bar} | {±N.N or baseline} | {±N.N or baseline} | {one-sentence shape-of-the-week summary} |

**Movers this week:** {one-line callout of the 2-3 biggest +/- movers vs last week — e.g. "Focus discipline -3 (Wednesday's 8-block disaster); Leverage thinking +2 (key system unblock)"}.

{If drift detected, add:} **⚠ Anchor drift detected:** {category} all-time avg is {value} over {N} reports — rubric anchors may have inflated. Recalibrate before next run.

<!--
scores_v1:
  shipping_output: X
  strategic_impact: X
  decision_quality: X
  communication_clarity: X
  follow_through: X
  focus_discipline: X
  leverage_thinking: X
  stakeholder_alignment: X
  energy_management: X
  personal_compounding: X
  overall: X.X
-->

---

*Frameworks referenced: Grove (High Output Management), Drucker (The Effective Executive), Bezos (Type-1/Type-2 decisions), async-first communication hygiene.*
```

## Scorecard rubric — anchor definitions

The ten categories below are the **fixed yardsticks**. Score against the anchors, not against last week's number. Last week's number is a *delta* to report, never a target to drift toward. If you anchor on prior scores you get grade inflation; if you anchor on the rubric you get honest signal.

For each category: **1** = critical / red-alert, **5** = normal exec week, **10** = once-a-quarter exceptional. Use the full 1–10 range. A 7 is a "good week" not a "default."

| # | Category | What 1 looks like | What 5 looks like | What 10 looks like |
|---|---|---|---|---|
| 1 | **Shipping output** | Nothing landed in the wild | 4–6 discrete artefacts (PRs, decisions, docs, tags) shipped | 15+ artefacts including a major release or program lock-in |
| 2 | **Strategic impact** | Pure busywork; no decision moved | One meaningful decision or program advanced | Multiple Type-1s locked AND a major program unblocked |
| 3 | **Decision quality** | Reckless on Type-1 or paralysed on Type-2 | Mixed — most calls correct, some under-deliberated | Consistently sharp; Type-1s analysed, Type-2s fast |
| 4 | **Communication clarity** | Same point re-stated 3+ times; recipients confused | Most messages landed first time | Every message landed; pushback was clean and earned |
| 5 | **Follow-through** | Most soft commitments dropped or invisible | ~60-70% closed or explicitly deferred | All commitments closed or formally deferred with a "why" |
| 6 | **Focus discipline** | Fragmented all week; no 2hr+ deep blocks | ~3 focus titles per day; some deep blocks | Clean 2-3 deep blocks per day; no evening/dawn bleed |
| 7 | **Leverage thinking** | Pure ticket-closing; nothing compounded | Some system work alongside artefact work | A major compounding investment shipped (skill, tool, system) |
| 8 | **Stakeholder alignment** | Visible friction, repeat escalations, unresolved | Normal collaboration with occasional friction | Clean handoffs, all stakeholders on the same page |
| 9 | **Energy management** | Visible burnout signals (evening work, frustration vents, missed meals) | Normal load with one or two long days | Sharp, sustainable, no over-extension signals |
| 10 | **Personal compounding** | Nothing built that pays forward | Some learning or tool maintenance | Major skill / brand / relationship investment shipped |

**Overall** = arithmetic mean of the 10 category scores, to one decimal place. Do not separately "judge" the overall — it falls out of the categories.

### Colour-bar encoding

The bar is 10 squares wide. Filled squares = score; empty squares = remainder. Fill colour is determined by the score band:

| Score band | Fill | Empty |
|---|---|---|
| 1–2 | 🟥 | ⬜ |
| 3–4 | 🟧 | ⬜ |
| 5–6 | 🟨 | ⬜ |
| 7–8 | 🟩 | ⬜ |
| 9–10 | 🟦 | ⬜ |

Examples: 7/10 → `🟩🟩🟩🟩🟩🟩🟩⬜⬜⬜`. 4/10 → `🟧🟧🟧🟧⬜⬜⬜⬜⬜⬜`. 10/10 → `🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦`.

### Self-calibration logic

Before drafting section 10:

1. **List all prior reports** — `ls ~/performance-reviews/*.md` (sorted by filename, which equals date). Adjust the path to wherever you chose to store reports.
2. **Extract scores** from each file's `<!-- scores_v1: ... -->` block via `grep -A 12 'scores_v1:' {file}`. Older reports without the block contribute nothing (skip silently).
3. **Compute per-category all-time averages** across every prior report. Round to one decimal.
4. **Compute deltas:**
   - **Δ Last** = `this_week_score - most_recent_prior_score`. Whole number. Sign required: `+2`, `-1`, `0`.
   - **Δ Avg** = `this_week_score - all_time_avg`. One decimal. Sign required: `+1.4`, `-0.6`, `+0.0`.
5. **First report:** both deltas display `baseline` (literal word). Do not show `0` — it implies a comparison was made.
6. **Anchor drift detection:** if a category's all-time average is ≥ 8.5 OR ≤ 3.5 over ≥ 4 reports, the rubric has drifted. Flag it under the table with the `⚠ Anchor drift detected:` line. The fix is *not* to suppress the drift — it's to recalibrate the anchor descriptions in the next session.
7. **Movers callout:** identify the 2–3 categories with the largest `|Δ Last|`. Name them with the one-line cause. This is the most actionable single line in the whole report.

### Scoring discipline

- **Anchor first, calibrate second.** Look at the rubric anchors before looking at last week's scores.
- **Use the full range.** If every category is 7 or 8, the rubric isn't doing its job. A week with a clear 9 should also have a clear 4 or 5 somewhere.
- **Evidence each score.** Behind every 1–4 or 9–10 there must be a specific incident in sections 2–6 of the report. No mystery scores.
- **Don't smooth.** If energy management was a 4 (evening work + frustration vent), score it a 4. Smoothing to 6 to be kind defeats the skill.
- **Overall is a sanity check, not a vibe.** If the overall feels wrong, a category is wrong. Find which one.

### The "Why" column

Every row in the scorecard table includes a free-text "Why" cell — one short sentence (≤ ~120 chars) that names the specific evidence behind the score. Rules:

- **Cite a concrete thing.** A repo, a thread, a meeting, a person, a count — never a vibe word.
- **Match the score's polarity.** A 9 cites the win; a 4 cites the cost. Don't soften a 4's "Why" with a positive framing.
- **No headers or bullets inside the cell** — it's a table cell, plain prose.
- **For the Overall row,** the "Why" is the one-sentence shape-of-the-week summary (e.g. "Heavy shipping + leverage week; energy + focus collapsed by Wednesday").

This column is the reader's at-a-glance audit trail. Scan the scorecard alone and immediately know what drove each rating without reading sections 2–6.

## Behaviour rules

1. **Be specific. Always cite evidence.** "You ghosted X on Monday" not "communication could improve". Pull the actual thread, the actual date.
2. **Never hedge to spare feelings.** The user asked for blind spots. Surface them. Direct, occasionally blunt.
3. **No fake praise.** If section 9 has nothing real, leave it empty with the placeholder. Manufactured praise debases real praise.
4. **No generic advice.** "Improve focus" / "be more proactive" / "communicate clearly" are banned. Every recommendation names a person, a thread, a repo, or a decision.
5. **Hat-tag everything.** Different context areas have different success criteria. Conflating them is the most common review-tool failure.
6. **One report per run.** Write the markdown file, print the report. Don't ask follow-up questions mid-report — make the calls and let the user push back after.
7. **If data is missing, say so.** "No call transcripts accessible this run" is fine. Hallucinating data is not.
8. **Compare to last week if a prior report exists.** Section 7 is load-bearing. Without it, weekly reviews become disconnected snapshots.
9. **Look beyond the obvious medium.** The user may solve problems by inventing a tool, repurposing an existing channel, or writing a skill rather than using the medium the template expects. When checking whether a target was hit, actively search across Slack, Notion, Linear, GitHub, scheduled-tasks, and the skills directory before assuming it wasn't done. Grade the outcome, not the form.

## Failure modes to actively avoid

- **The horoscope.** Vague, applies to anyone, no specific evidence. → Banned.
- **The participation trophy.** "Great week overall!" with no shipped output to back it. → Banned.
- **The pile-on.** Twelve criticisms with no ranking. → Cap blind spots at 6 named items, ranked by impact.
- **The framework parade.** Listing five frameworks for every observation. → Cite the framework once when it materially explains the verdict, then move on.
- **The recommendation tax.** Three improvements only. Not "and here are five more for good measure".
- **Source soup.** Don't dump raw Slack/email content. Summarise, cite, link.
- **The all-greens trap.** Every category scored 7+ with no reds or yellows. → If the rubric never produces a low score, the rubric isn't working. Use the full 1–10 range.
- **Anchor sliding.** Scoring against last week's number instead of the rubric anchors. → Drift detection exists for a reason; respect the anchors.
- **The smoothed score.** Energy management was a 4 but you scored it a 6 to be kind. → Honest signal beats kind signal. Score the evidence.
- **Form-blind grading.** Assuming a target meant literally the medium named ("a Notion board" when the wording said "a board"), and missing creative implementations that satisfy the spirit. → Always grade outcomes, not forms. Search every plausible surface — Slack channels, Notion, Linear, GitHub, scheduled-tasks, Mac scripts — before declaring a target missed.

## Operational notes

- **Date math.** Today is provided in the system prompt (`currentDate`). Compute window as `today - 7 days` unless the user specified otherwise. Always print the explicit window in the headline ("4 May → 11 May 2026") so the user can sanity-check.
- **Working hours assumption.** ~40 hours/week unless evidence says otherwise. State the assumption when computing the time-allocation table.
- **Parallel pulls.** Calendar, Gmail, Slack, Notion, Claude sessions, GitHub all run as parallel tool calls in a single message. Don't serialise.
- **Report file naming.** `~/performance-reviews/{YYYY-MM-DD}.md` (or your chosen folder) using today's ISO date. If a file with today's date already exists, suffix `-2`, `-3` etc. — don't overwrite.
- **Prior report read.** `ls -t ~/performance-reviews/*.md | head -1` then read it before drafting section 7. Adjust path as needed.
- **All-prior-scores read.** Before drafting section 10, run `grep -l 'scores_v1:' ~/performance-reviews/*.md | xargs -I{} sh -c 'echo "=== {} ==="; grep -A 12 "scores_v1:" {}'` to pull every prior scorecard. Compute the per-category all-time average from this output. If no prior scores exist, use `baseline` in both delta columns.
- **Scores block is load-bearing.** The `<!-- scores_v1: ... -->` block at the end of every report is the input to next week's deltas. Format must be exact (2-space indent, snake_case keys, integer scores, one-decimal overall). A malformed block means the next report can't self-calibrate.
- **Drift floor/ceiling.** Per-category all-time average should sit between 4.0 and 8.0 over the long run. If a category drifts above 8.5 or below 3.5 across ≥ 4 reports, flag it and recalibrate the rubric anchor for that category. Drift is a sign the rubric has lost its grip, not a sign the user is exceptional or struggling.

## What this skill is NOT

- Not a productivity coach. No advice on tools, calendars, or time-blocking strategies.
- Not a therapist. Doesn't psychoanalyse. Reports observable patterns, not motivations.
- Not a daily check. Weekly cadence. The compounding signal only shows up at 7-day grain.
- Not a public artifact. Reports are local. Never paste a report into Slack/Notion/email without the user's explicit instruction.

## Fallback — when data sources are unavailable

If Slack, Gmail, and Calendar pulls ALL fail (auth errors, no MCP connection, tool unavailable), do not abort the review. Produce a minimum-viable review using:

1. **Claude Code sessions** — `mcp__ccd_session_mgmt__list_sessions` + `search_session_transcripts` for the window. This is always available.
2. **Git history** — `gh pr list` and `git log` across active repos. Also always available locally.

Produce sections 2, 5, 6 (partial), 7, and 8 from these sources alone. Sections 3 (time allocation) and 4 (communication audit) will be incomplete — say so explicitly at the top of each section: "Calendar unavailable — meeting count omitted" / "Slack unavailable — communication audit from session context only." Name every unavailable source clearly in the report header. Do not silently skip sections or hallucinate data.

## Sync homes

Canonical: ~/.claude/skills/self-performance-review (private, live). Public sanitized twin: ~/code/claude-skills/self-performance-review → github.com/justinwilliames/claude-skills. Sanitization is a sync step — never push private names/paths.
