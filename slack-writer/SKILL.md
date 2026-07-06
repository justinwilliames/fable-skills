---
name: slack-writer
description: >
  Use this skill whenever the user wants to write, draft, or improve a Slack message — for internal team communications, announcements, updates, check-ins, async questions, or any message destined for Slack. Trigger on phrases like "write a Slack message", "draft a Slack post", "send this to my team on Slack", "how do I say this on Slack", or any request to communicate something internally via chat. Also trigger when a user says "post this", "announce this to the team", or "message my team about X" without specifying a channel — assume Slack. The output must always be copy-paste ready with zero edits needed.
---

# Slack Writer Skill

Produce copy-paste-ready Slack messages for internal team communications. Zero editing needed by the user.

## The send gate — Claude is never the last set of eyes (non-negotiable)

This skill produces a **draft for the operator to read, then send** — never a message to fire on autopilot. Every draft leaves assuming a human read is still owed. Before anything built here reaches a person or a channel, it clears three gates. State it in one line when handing over a substantive draft: *"Read it before you send — [N] number(s)/claim(s) to eyeball first."*

**1. Signal, not volume.** If the message can be half the length and lose nothing, halve it. One distilled update beats a slab. For status/progress updates, lead with the 1–3 things that actually matter and cut the rest — a reader who has to wade for the point stops reading, then stops trusting the sender. Verbosity is the default failure mode of AI-drafted comms; fight it on every draft. "Lots of information, all great, but no one has time to read it" is the complaint this gate exists to kill.

**2. Every number is verified or it's cut.** No stat, metric, %, count, dollar figure, or factual claim goes in a draft unless it came from a live tool result in *this* session. Never estimate, never recall a figure from memory, never carry a number forward from an earlier draft without re-checking it. If you can't stand behind it 100%, delete it — do not hedge it. One wrong number discredits every right one around it. *The signal isn't worth the confusion.*

**3. Stay in the operator's lane.** For a status/update message, default to the operator's own function. Don't fold in other people's domains (someone else's churn figures, another team's metrics) unless the operator explicitly asked. Breadth reads as overreach; depth in your own lane reads as ownership.

**Flag, don't bury.** If a draft contains any claim you could not verify this session, list it *above* the draft as `⚠️ verify before sending`, one line per claim — never slip an unverified fact into the body and hope it rides through. The operator decides what ships; the skill's job is to surface, not smuggle.

Why this is gate #1: the reader is often a busy exec who pattern-matches the sender to the quality of whatever lands in their inbox. Polished-and-short builds trust; long-and-loose burns it even when the underlying work is excellent. The slop check below guards *how it reads*; this gate guards *whether it's true, tight, and owned.*

## Recipient gate — high-stakes named readers

Some drafts go to a specific senior reader whose preferences you already know. For those, run their recipient gate on top of the send gate before handover: lead with what *they* read first, cut what they've told you they skip, match their escalation pattern, dial tone to how they receive it. If the operator keeps a persona file for the recipient, load and apply it. Never manufacture a scheduled status ritual to a manager who hasn't asked for one.

## Markup Default

This skill **always uses Slack markup** in output: `*bold*`, `_italic_`, `~strike~`, and `` `code` ``. The user has confirmed markup mode is enabled on their Slack account (Profile → Preferences → Advanced → "Format messages with markup" is ON), so typed asterisks and underscores render correctly.

Do not surface a markup-toggle tip on first invocation. Just draft with markup applied.

If the user ever explicitly asks for asterisk-free output ("plain text", "no markup", "render-safe"), drop the markup for that draft only — don't change the default.

## Core Philosophy

Slack is async, human, and skimmable. Every message should feel written by a thoughtful teammate — not a press release or a robot. Aim for:
- Brevity over completeness — if it can be cut, cut it
- Warmth over formality — contractions, first names, casual phrasing
- Clarity over cleverness — plain language wins every time

## Never invite feedback or review (operator default)

**Do NOT end a message with a feedback-soliciting closer.** Never write "Spot anything off?", "Shout before it lands", "Give me a shout if anything looks off", "Let me know what you think", "Thoughts?", "Open to feedback", "flag anything", or any variant that invites review or comment. Announcements and updates stand on their own authority by default. A feedback/review ask belongs in a draft **only** when the operator has *explicitly* asked for one in their instruction (e.g. "ask the team to review this"). Default close: a clean sign-off, a forward-looking line, a relevant CTA for the reader's own action — or no close at all. Never a request to be checked.

## Message Structure

For short messages (1–3 lines): just write it. No headers, no structure. Conversational.

For longer messages (announcements, updates, FYIs), use this loose structure:
1. Hook line — one sentence that tells people what this is about (don't bury the lede)
2. Body — context, details, or ask — broken into short paragraphs or bullets
3. CTA or close — what (if anything) do you need from them? A clean sign-off or a reader-action CTA is fine; do NOT invite feedback/review on the message unless explicitly asked (see "Never invite feedback or review")

For long, multi-section posts (roundups, release notes, weekly digests, planning docs, anything with 3+ distinct sections): reach for **headers and section structure** — see the next section. The test is *number of sections*, not length: a 200-word message with one idea stays conversational; a message with three or more genuinely separate groups earns headers.

## Headers & Section Dividers (long posts only)

Slack supports two real structural devices in typed messages — use both on long posts:

- **Headers** — start a line with `# ` (one hash is enough; Slack renders a single header size regardless of how many you use). The line becomes a large bold header block. This is what breaks a long post into scannable sections.
- **Horizontal dividers** — a line containing only `---` renders as a genuine full-width horizontal rule. Use it to separate *top-level groups* from each other (e.g. "Major features" vs "Supporting improvements"), not between every item.

Both come back from the Slack API as structural blocks with the markup stripped, which is why a read-back of the message shows the header text plain and shows no sign of the rule at all — they're there, they just don't survive as inline `*mrkdwn*`.

**How to combine them.** Header on each section; a `---` rule between the major top-level groups. Don't put a rule between every header — one or two rules in a whole post is plenty, marking the big boundaries. Reserve headers for the sections and the rule for the seam between blocks of sections. Over-ruling chops the post into confetti.

Don't fake rules with runs of `─`, `—`, or `=` — you have the real thing, use it. A single emoji anchor on a header line is fine for extra weight, used once per section at most, never a decorative row.

**The long-form pattern** (mirrors a well-structured roundup):

```
*Punchy title line in inline bold*

One framing sentence — who this is for, what it covers.

# First section header
*1. Lead-in bold* _(metadata in italics)_
The detail, in one or two short sentences.

*2. Next item* _(metadata)_
Detail.

---

# Second section header
*Group label*
• Tight bullet with a *bold lead-in* — then the point _(date)_
• Next bullet, one line each
```

Rules for the pattern:
- **Title line stays inline bold** (`*...*`), not a `#` header — it reads as the headline above the first section, and a header there competes with the section headers below it. One `#` header for the whole post's title is fine *only* if there are no other sections.
- **Never wrap a `#` header in asterisks** — `# *Section*` double-bolds and looks broken. The header style already bolds it.
- **Header text is a plain label**, sentence case, no trailing punctuation. "Major features", "Supporting improvements", "What's shipping this week" — not "MAJOR FEATURES:" or "*Major Features*".
- **One blank line above every header**; reserve the breathing room for section boundaries rather than double-spacing everywhere.
- **A `---` rule marks the big seams, not every header.** Drop one between top-level groups (the "headliners → supporting detail" kind of boundary). A post with five headers might have one or two rules, total. Wrap the `---` in a blank line above and below.
- **Keep the bullet/sub-item shape consistent** across sections: same bold-lead-in-then-detail rhythm, same `_(italic metadata)_` placement. Inconsistency is what makes long posts feel sloppy.
- **Don't over-section.** Two sections rarely need headers — a blank line and a bold label will do. Headers earn their place at 3+ sections.

Gate this hard: headers on a short message read as corporate over-structuring. Most messages never need them. This is for the genuinely long, genuinely multi-part post.

## Tables — use native pipe tables, never monospace blocks

Slack renders **GitHub-style pipe tables natively** in typed messages when markup mode is on — real cell borders, a bold header row, proper columns. This is **verified** (a benchmark-comparison post rendered with bordered cells and an emoji verdict column). Any time the content is genuinely tabular — performance numbers vs benchmarks, a comparison grid, a metric/result/verdict matrix — **build a native pipe table.**

**Never fake a table with a monospace/triple-backtick code block.** Hand-aligned columns inside a ```` ``` ```` fence render as flat grey fixed-width text with no borders, they collapse on mobile, and they look amateur next to a real table. The pipe table is the only acceptable style for tabular data.

**Syntax** (header row, separator row, data rows — one row per line, no blank lines inside the table):

```
| Metric | Your product | SaaS avg | Trades avg | vs benchmark |
| --- | --- | --- | --- | --- |
| Open rate | 36.5% | 39.3% | 40.0% | ✅ on par |
| Click rate | 7.0% | 1.2% | 3.5% | 🔥 ~2-6x above |
| Unsub rate | 0.2% | 0.2% | 0.3% | ✅ on par, clean |
```

Rules for tables:
- **Header row is the column labels; the second row must be the `| --- | --- |` separator** (one `---` cell per column). Without it Slack won't render the table.
- **Keep cells short** — a few words max. Long sentences belong in prose above or below the table, not in a cell.
- **A final verdict column reads beautifully.** Label it "vs benchmark", "Read", or similar, and lead each cell with a single status emoji: ✅ on par / good, 🔥 well above, ⚠️ above-norm-but-expected, 🔻 below. One emoji per cell, at the front.
- **Cite the benchmark source once**, in italics on the framing line above the table — e.g. _(MailerLite 2025 - SaaS + trades verticals)_ — so the numbers are defensible. Reuse the operator's established house source across messages rather than swapping benchmark sets between drafts.
- **Frame the table, then let it breathe.** One short sentence above ("How we stack up vs benchmarks:"), the table, then the narrative read ("the real story is the click rate"). Don't bury the headline number inside the grid only.
- **The table still lives inside the copy-paste code block** we wrap every draft in (see Output Format) — the raw pipe syntax survives the copy and renders on paste. Do not double-fence the table in its own nested code block.

## Formatting Rules

Emphasis: **always use Slack markup** in output. Apply `*bold*` for load-bearing words and headers, `_italic_` for soft emphasis or quoted phrases, `~strike~` for retractions, and `` `code` `` for filenames, commands, IDs, and technical references. The user has markup mode ON in their Slack preferences, so these render correctly.

Use markup with restraint — bold the 2-3 most important phrases in a longer post, not every sentence. Over-bolding flattens hierarchy. Pair markup with the other emphasis tools below for layered structure:
- Word choice and sentence structure (still the strongest tool)
- Leading emoji to anchor the eye on a key moment
- Line breaks between thoughts
- Bullet structure for parallel items
- Putting the load-bearing phrase at the start of a sentence

If a user explicitly asks for plain-text or asterisk-free output ("no markup", "render-safe", "for a recipient who hasn't enabled markup"), drop markup for that draft only.

Bullets: use for 3+ items that would be awkward in a sentence. Keep each bullet to 1 line. No nested bullets unless absolutely necessary.

Line breaks: one blank line between paragraphs/sections. Break at ~3 sentences. No walls of text.

Emoji usage: 1–3 emojis max for standard messages; up to 5 for celebratory announcements. Lead with an emoji on announcement-style messages. Use emojis inline or at end of line, not mid-sentence.
- Avoid: 🙏 💯 🚀 (overused/cliché)
- Prefer: ✅ 📢 👀 🎉 ⚠️ 📅 🔗 💬 🙌 ⏰ 🛠️ 📌

Code/technical references: use backticks for filenames, commands, variables, endpoints.

Typographical shorthand: never use `§` (section sign), `¶` (paragraph sign), `№` (numero sign), `††`, or other legal/academic symbols. Most readers don't recognise them — they read as jargon and break the conversational tone. Write "Section 9", "Sec 9", or just "9." instead. Same rule for any obscure mark a normal person wouldn't read fluently.

Mentions: include @here, @channel, or @Name where appropriate. @channel = everyone including offline (use sparingly). @here = active members only (time-sensitive). Named mentions for direct asks.

## Grammar Baseline (non-negotiable)

Slack is casual but it isn't sloppy. Every draft must clear a basic grammar bar before voice-matching kicks in:

- **Apostrophes are mandatory.** Write "can't", "won't", "that's", "I'd", "you've" — never "cant", "wont", "thats", "Id", "youve". Dropped apostrophes look lazy on substantive messages, especially anything sent to a colleague.
- **Sentence starts are capitalised.** "Hey Alex", not "hey alex". First word of every sentence gets a capital. Proper nouns always.
- **Sentences end with punctuation.** Full stop, question mark, or exclamation — pick one. Trailing fragments are fine if rhythmic, but don't string two clauses together with a comma where a full stop belongs.
- **Spell out abbreviations on first use** where ambiguity is possible. After that, casual forms are fine.
- **Hyphens with spaces around them (`- like this`) substitute for em dashes.** Em dashes (`—`) are still off-limits — they read as AI.
- **No typo-style shortcuts.** "u" for "you", "ur" for "your", "thx" for "thanks" — out. Even in DMs.
- **Spelling is always correct.** No misspellings, doubled words, dropped words, or wrong-word swaps — "its"/"it's", "your"/"you're", "their"/"there"/"they're", "then"/"than", "loose"/"lose". No dictation or autocorrect wreckage (the "try lending" → "trial ending" kind). Every draft is spell-clean, first pass.
- **Never fake a typo to sound human.** Do not add, keep, or replicate a mistake to make a message look more authentically "them". Clean writing never reads as robotic; a typo reads as careless. Authenticity comes from vocabulary, rhythm, and warmth — never from errors.

These rules apply to **every** draft, including casual DMs, and they are absolute: **grammatical and spelling correctness always wins over voice-mirroring.** Even when the operator's own past messages are riddled with typos, dropped apostrophes, missing capitals, or autocorrect debris, the draft comes out clean. Mirror their vocabulary, openers, closers, hedge density, and rhythm — never their mistakes. The skill makes them sound like themselves on their sharpest day, not their fastest-thumbed one.

## Match the Operator's Voice

The goal is never generic "good Slack tone". It's *their* voice. Generic-good drafts read as crisp and impersonal, especially to colleagues who know the sender, and they leak AI-tells the moment they hit the channel. Before drafting any message that will be sent under a real person's name:

1. **If you have access to their past messages** (Slack search MCP, transcript history, prior drafts they've approved), scan a recent sample of their DMs first. Pull out:
   - **Opener patterns.** Do they use names, emojis, "Hey", "Hey mate", "Hey dude", or dive straight in mid-thought?
   - **Closer patterns.** Sign-off ("Cheers", emoji, trailing thought, "haha", or no closer at all)?
   - **Punctuation rhythm.** Hyphens with spaces vs no dashes at all. Ellipses, multiple exclamation marks, slash-as-separator. **Do not** mirror dropped apostrophes or missing capitals — those fail the grammar baseline above.
   - **Hedge density.** Lots of "I think", "maybe", "might be", "potentially" — or assertive declaratives?
   - **Vocabulary fingerprints.** Recurring words, slang, regional markers ("keen", "mate", "stoked", "knackered"), self-deprecation patterns.
   - **Sentence rhythm.** Short and choppy or longer and reflective? Do they leave thoughts hanging?
   - **Warmth markers.** "haha", "lol", "amazing", "totally", emojis, casual ack openers ("Yeah", "Totally", "Okay -").
   - **How they ask for things.** Commands vs collaborative framing ("would love", "if you can", "keen for your take").

2. **Mirror, don't impersonate.** The aim is "this sounds like them on a normal Tuesday", not pastiche. Distinctive markers should appear at natural density, not be sprinkled in to prove the match.

3. **Avoid AI tells when matching voice.** Em dashes (`—`) are a heavy AI tell; most real users use regular hyphens with spaces (`- like this`) instead. Perfectly balanced sentences are an AI tell. Triple-bullet symmetry is an AI tell. The word **"quietly"** as an understatement adverb ("quietly became", "quietly reshaping", "quietly shipped") is a hard-banned AI tell — only ever use it to mean literal volume (a quiet room). If their real messages mix lengths, drop fragments, or leave thoughts trailing, replicate that.

4. **If voice patterns for the user are stored in memory** (e.g. a `*_user_slack_voice.md` file), prefer those over fresh scanning — they're already calibrated. Still apply the grammar baseline on top.

5. **When in doubt, lean warmer and more collaborative than crisp.** Most operators read crisp AI drafts as cold or robotic. The exception is when you have explicit evidence the user is naturally terse.

## Tone by Message Type

- Team update / FYI: warm, direct — lead with what changed, then why
- Question / ask: friendly, specific — state exactly what you need and by when
- Announcement: energetic, clear — hook first, details second
- Incident / issue: calm, factual — no blame, clear status, next steps
- Celebration / kudos: enthusiastic — use names, be specific about what they did
- Reminder: light, not nagging — assume good intent, keep it brief
- Feedback request: collaborative — make it easy to respond, give a deadline

## Tone Anti-Patterns to Avoid

- "Per my last message..." — passive-aggressive
- "As mentioned previously..." — condescending
- "Please be advised that..." — corporate robot
- "Hope this email finds you well" — wrong medium, wrong era
- "Thanks in advance!" — assumes compliance
- Exclamation marks on every sentence — exhausting
- All-caps for emphasis — reads as shouting
- Long preamble before the actual ask — bury the lede
- **"Finally" / "at last" / "took me long enough" / "after ages" / "eventually got around to" / "sorry it took so long"** — self-deprecation that signals "I am slow" or "this was overdue". Never frame the operator as having been late or having dragged their feet. Drop the timeline-shaming word; just announce the thing. *"Finally got the doc done"* → *"Got the doc done"*. *"At last we have the data"* → *"The data's in"*. Same applies to "managed to" when it implies struggle (*"managed to ship the fix"* → *"shipped the fix"*).

## Slop check (run before you finalise)

This skill shares its anti-AI-slop standard with the Orbit slop detector — the same heuristic engine that gates Orbit's published content. Before you hand over any Slack draft longer than a throwaway one-liner, lint it through the detector so AI tells (including "quietly", "seamlessly", "leverage", not-just-X-but-Y, empty openers/closers, anaphora, engagement-bait) get caught the same way they would in Orbit content.

Run the helper (reads the draft from a file or stdin):

```
echo "<draft text>" | ~/.claude/skills/slack-writer/scripts/slop-check.sh
# or
~/.claude/skills/slack-writer/scripts/slop-check.sh /path/to/draft.txt
```

It prints `{ score, tier, findings[] }` where `tier` is `sharp` (≥85), `decent` (≥70), `generic` (≥50), or `slop`. Each finding names the AI tell, what it matched, and the fix.

How to act on it (Slack is conversational, so use judgment — the detector is calibrated for marketing/blog prose):
- **Any `high`-severity finding, or the "Quietly (AI understatement tell)" finding, must be fixed** unless it is a genuine literal-volume use.
- `medium` findings — reconsider each; fix unless the phrasing is genuinely how this operator talks (a real voice match beats a clean lint score).
- Ignore `low`-severity length/adverb nits when they reflect the operator's natural voice.
- Aim for `decent` or better. A casual message need not hit `sharp`, but it should never trip a `high` tell.
- If the detector or Node is unavailable the helper exits cleanly — fall back to the inline AI-tell rules above (item 3 of "Match the Operator's Voice").

## Output Format

Always output the message inside a code block so it's easy to copy. Then optionally add 1–2 lines of brief notes below the block if relevant (e.g. suggest adding @channel if urgent, or flag a placeholder to adjust). Keep notes minimal — the message should speak for itself.

## Examples

Request: Announce that standup is moving from 9am to 9:30am starting Monday.
Output:
```
📅 *Heads up - standup is moving to 9:30am starting Monday.*

Same format, same link, just 30 minutes later. Update your calendars and let me know if that causes any conflicts 🙌
```

---

Request: Ask the team if anyone can cover a client call on Friday afternoon.
Output:
```
Hey team 👀 anyone available to cover a client call this Friday afternoon (~2-3pm)?

I've got a conflict and need someone to step in. Drop a reply or DM me if you can help out - really appreciate it!
```

---

Request: Write a kudos message for Sarah who just shipped a big feature.
Output:
```
🎉 *Huge shoutout to Sarah for shipping the new dashboard feature today!*

This one's been a long time coming and she navigated some seriously gnarly data pipeline issues to get it over the line. The team's already loving it. Well done! 🙌
```

---

Request: Write the monthly product roundup for the team — QuickBooks integration, a new Companies record, and a batch of smaller scheduling fixes.
Output:
```
*June Product Roundup*

What shipped this month, written so it makes sense whether or not you've seen the feature yet.

# The headliners
*1. QuickBooks Online integration* _(16 Jun)_
Businesses can now connect QuickBooks alongside Xero — invoices and quotes sync both directions automatically. Live in AU and the UK.

*2. Companies* _(16 Jun)_
A new account record that groups multiple contacts and addresses under one parent. Built for property managers, strata, and commercial clients sending work across many sites.

---

# Smaller wins
*Scheduling*
• *Team Unavailability* now shows on the appointments calendar — block time off and your product won't book over it _(15 May)_
• Scheduler now offers the *next available day* rather than slots minutes after a call _(16 Jun)_
```
Note: two `#` headers because there are two genuinely separate groups with items underneath, and one `---` rule marking the seam between the headliners and the smaller wins — a flat bullet list would lose the hierarchy.

---

Sync home: canonical = your live private copy; public sanitized twin: ~/code/skills/slack-writer → github.com/justinwilliames/skills. Sanitization is a sync step.
