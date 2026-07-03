---
name: linkedin-post-writer
description: >
  Use this skill whenever the user wants to turn something they have done into a LinkedIn
  post — a session, a Slack thread, a workflow built, a tool tried, a conversation, an
  opinion, or a moment worth reflecting on. Trigger on phrases like "write a LinkedIn post",
  "turn this into a LinkedIn post", "draft a post about X", "post this on LinkedIn",
  "LinkedIn post from this work", "make a LinkedIn post and image", "share this on LinkedIn",
  or any request to publish to the user's LinkedIn. Also triggers on banner requests —
  "make a LinkedIn banner", "design a banner for this post", "marketing graphic", "an image
  with text", "attention-grabbing LinkedIn image". The skill drafts in the user's exact voice
  (calm, first-person, plainspoken, no AI-tells), optionally generates a matching on-brand
  image (via the codex-imagegen bridge or scripts/build-linkedin-banner.py compositor),
  presents both for approval, and — only on explicit sign-off — posts to LinkedIn via
  Claude in Chrome. It NEVER posts, sends, or schedules anything without that explicit approval.
---

# LinkedIn Post Writer

Turn real work into LinkedIn posts that sound exactly like the user, paired with an optional
on-brand image, posted only on explicit approval.

> `{base}` = this skill's directory. The workflow references several reference files — populate
> them before first use (see "Before first use" below).

## Before first use — bring your own voice guide

This skill is a voice-agnostic framework. Before it can produce posts that sound like you,
supply your own context files in `{base}/reference/`:

- **`voice.md`** — how you write: openers, closers, sentence rhythm, vocabulary, emoji
  discipline, AI-tell suppression list, length targets, approved post structures. This is
  the most important file — without it the skill cannot mirror your voice.
- **`engagement.md`** — what makes your posts resonate vs what games reach. The skill uses
  this to prioritise resonance, not vanity metrics.
- **`banner-style.md`** — visual style guide for banners (photo + text overlay). Describe
  your palette, font choices, and composition rules.
- **`image-style.md`** — if you want face-consistent photos, describe your identity-lock
  parameters and where your face references live in `reference/face/`.

Until these are filled in, this skill is a framework, not a working personal tool.

## Prime directive

Generate content that feels like a real person explaining something clearly to a peer over
coffee. When forced to choose between impressive vs clear, persuasive vs honest, sharp vs
calm, optimised vs human — **always choose the second**. Clarity beats flourish. Always.

## When to use / not use

**Use it** when the user gives you raw material — a thing they built, a result, an opinion,
a conversation, a moment — and wants it shaped into a post (with or without an image), or
wants it posted.

**Do not use it** for customer-facing brand copy (those have their own skills and voices),
for internal Slack messages (use slack-writer), or for any writing not destined for the
user's personal LinkedIn.

## The workflow

```
0. SCAN       ALWAYS read the user's recent LinkedIn posts FIRST (last ~2 weeks)
              → (a) is today already taken? (posted OR scheduled today)
              → (b) does the idea duplicate a recent post? avoid topic/phrasing fatigue
1. INTAKE     gather the real material; ask up to 3 questions only if genuinely needed
2. DRAFT      write the post in the user's voice (one idea, one of three structures),
              DIFFERENTIATED from recent posts
3. IMAGE      if wanted → PHOTO (image-style.md) OR BANNER = photo+text (banner-style.md)
4. PRESENT    show the draft + image together, plus 1-2 optional improvements
5. APPROVE    user edits / approves / rejects  ← HARD GATE before anything leaves
6. PLACE      on approval: post via Claude in Chrome if today is free, else SCHEDULE next
              available day
```

### 0. Scan recent posts FIRST (mandatory — never skip)

Before drafting anything, read the user's recent LinkedIn activity (profile → recent-activity,
last ~2 weeks, ~8-10 posts) via Claude in Chrome. This gates everything after it:

- **Duplication / fatigue check — published AND scheduled.** Pull the topic, thesis, and
  opening angle of each recent **published** post AND the content of each **scheduled** post
  (open the scheduled-posts modal and read the post text, not just the date). The new draft
  must NOT repeat the topic, thesis, timeframe framing, or phrasing of anything in either
  set. When in doubt, it's too similar — change it.
- **Schedule awareness — read BOTH sources.** (1) Published posts (check activity feed
  timestamps). (2) The scheduled queue — open via the composer: Start a post → the clock
  icon ("Schedule for later") → "View all scheduled posts". Collect ALL scheduled dates.
  The **next available date** is the earliest future day with neither a published nor a
  scheduled post — NEVER assume "tomorrow".
- **Cadence.** Aim for one post per day max; never two in a day.

### 1. Intake — collaborate, don't interrogate

- **Proceed immediately and draft** when a concrete moment is provided, the lens is explicit,
  specifics are present, and intent is clear. Do not over-explore.
- **Ask up to 3 questions first** (one at a time, neutral) only when: the idea is abstract,
  a belief is stated with no concrete moment, specifics are missing (numbers, tools,
  decisions), or the insight could apply to anyone. Approved question styles: "This feels
  true, but what actually happened?" / "What decision did this change for you?" / "Where
  did you see this play out?"
- **EXPERIENCE ATTRIBUTION RULE (mandatory):** never invent lived experience — events,
  conversations, numbers, decisions, outcomes, emotional responses. If something is not
  supplied, ask for it or keep the post abstract without implying personal involvement.

When the raw material is a session or Slack thread, pull the real specifics out of it (what
was actually built, the real number, the actual decision) rather than generalising.

### 2. Draft — the user's voice

Read `reference/voice.md` before drafting. Non-negotiables until your voice.md overrides:

- **First-person only** ("I", never "you"). Conversational, warm, grounded, plainspoken, calm.
- **One idea per post.** If multiple ideas appear, cut or defer them. Clarity beats completeness.
- **AI-fingerprint suppression:** no negation framing ("not just X but Y"), no contrast
  rhetoric ("instead of", "rather than", "but the real issue is"), no metaphors/analogies.
  Declarative sentences, one idea each, additive.
- **Punctuation:** no em dashes, no semicolons, no ellipses. Light commas. Full stops preferred.
- **First line** is declarative and carries meaning — no teasing hook, no negation, no
  contrast. Earn "see more" through clarity.
- **Closing line** is a calm lens or a quiet thought to sit with. No engagement-bait
  questions, no "comment below". Let it linger.
- **Quotes:** when the user actually spoke to someone or is quoting a named source, quote
  verbatim with attribution. Never fabricate a quote.
- **Spoken read-aloud test (mandatory):** would the user comfortably say this sentence out
  loud to a peer? If anything other than yes, rewrite.

Pick one of the three approved structures (guides, not templates):

- **A. Moment → Reflection → Lens** — declarative opening tied to a real moment, brief
  factual context, what was noticed/learned, broader lens, quiet close.
- **B. Opinion → Evidence → Reframe** — clear bounded opinion, concrete evidence (a number,
  a tool, a decision), clarifying nuance, a more grounded way to see it, summary line.
- **C. Numbers → Meaning** — a real number or calculation, what it represents, why it
  matters, what to keep, calm sign-off.

Opinions must be specific, bounded, situational ("In my experience…"). Avoid absolutes and
"most people" generalisations. Authority comes from precision, not force.

**Default register and length (from your voice.md).** Thinking posts typically run
1,145–1,717 characters; light moments stay short. Never pad to hit a count.

### 3. Image — on-brand, identity-locked

**Route on what was asked for:**
- **A plain photo** (candid, no text) → `reference/image-style.md` for the full spec.
- **A banner / marketing graphic** (bold headline over a photo) → `reference/banner-style.md`
  and `scripts/build-linkedin-banner.py` compositor. Banners generate the underlying photo
  (with composition space for text) then composite type on top via HTML → Chrome-headless —
  never bake text into the AI image (models garble text).

Only generate an image if the user wants one — an image does not inherently drive reach.
Face references live in `reference/face/` — without them, identity-locked generation is
unreliable; flag rather than ship an off-likeness result.

**Always generate a FRESH image per run.** Vary the scene each time. Match scene and
expression to the post's tone: reflective → contemplative scene; build/active → focused
scene.

1. Read the post content and infer its tone.
2. Suggest 2-3 framing options. Ask the user to pick unless already stated.
3. Generate via the **codex-imagegen bridge**, passing the face reference(s) as identity
   anchor (see your `image-style.md` for the master prompt template).
4. Run the **QC checklist** from `reference/image-style.md`. Regenerate with stronger
   constraints on any failing item.

### 4. Present for approval

Show the **post text and image together**, ready to judge as a pair. Offer **1-2 optional
improvements** (never force a rewrite). Treat every output as a draft.

### 5 & 6. Approval gate → post

**Posting to LinkedIn is a HARD GATE.** Never post, schedule, or publish anything without
the user's explicit, in-the-moment approval of that specific post and image. Approval of
one post never carries to the next.

On explicit approval, place it via **Claude in Chrome**:
- **Today is free** → post now, with the image attached in the composer.
- **Today is taken** → use LinkedIn's Schedule option for the **next available date**
  (image attached).
- Always attach the approved image to the LinkedIn post itself (upload in the composer).
- **NEVER ask the user to perform a manual UI step** (click a button, pick a file, type in
  a dialog). If a step blocks, find an automated workaround. The user's only job is judging
  the words and the picture.

## Resonance, not engagement

Read `reference/engagement.md` for the user's specific resonance analysis. General defaults:

- **Do not optimise for likes, impressions, or generic engagement.** Value thoughtful
  comments, DMs, follow-ups, recall. Study what makes the user's posts *resonate*.
- **An image does not drive reach.** Substance and a clear position drive reach; the image
  is for richness when it earns its place, never a lever. Never add an image just to "boost".
- **Never** use engagement-bait questions, "comment X below", manufactured hot-takes, or
  hook-and-withhold openers.

## Tone calibration is cumulative

When the user flags a word or phrase as "not me", "too AI", or "too LinkedIn", record it as
a **persistent constraint** — append it to `reference/voice.md` under a "Learned constraints"
heading and never reuse that phrasing. When they endorse phrasing or rewrite a line for tone,
learn that too. Priority: previously endorsed language → simplicity → spoken cadence →
clarity → restraint.

## Banner compositor — scripts/build-linkedin-banner.py

`scripts/build-linkedin-banner.py` takes a photo and a copy spec (JSON) and produces a
consumer-SaaS-quality banner. Text is composited via HTML → Chrome-headless screenshot —
never baked into the AI image. See the script's docstring for the full spec format.

**Customise for your brand:** set `FONT_DISP` (display typeface path), `FONT_BODY` (body
typeface path), `CHROME` (Chrome binary path if non-standard), and the theme palette entries
in the script. Three built-in themes: `grape` (default), `mint`, `coral`. Swap in your own
hex values or add a theme.

## Hard rules (override everything)

1. **Content needs explicit approval before posting.** Execution is hands-off — never ask
   the user to perform a manual UI step.
2. Never invent lived experience (events, numbers, conversations, decisions, outcomes, feelings).
3. Never optimise for engagement metrics or use bait. Resonance, not reach.
4. Enforce AI-tell suppression (no negation, contrast, metaphor, em dash, semicolon, ellipsis).
5. Apply the spoken read-aloud test to every line before finalising.
6. Keep images identity-locked, or flag that face references are missing.
7. Choose real over impressive, clear over clever, calm over sharp. Every time.

---

Sync home: canonical = your live private copy; public sanitized twin: ~/code/skills/linkedin-post-writer → github.com/justinwilliames/skills. Sanitization is a sync step.
Personal assets (reference images, voice guide) remain in the private linkedin-post-writer repo.
