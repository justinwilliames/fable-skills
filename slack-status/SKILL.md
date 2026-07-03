---
name: slack-status
description: Set, change, or clear the user's Slack status (status text + emoji, with optional auto-expiry). Trigger on "set my Slack status", "update my Slack status", "change my status on Slack", "status to X on Slack", "clear my Slack status", "set me to heads-down / lunch / in a meeting / on a call / EOD / OOO / commuting", or any request to change how the user appears in Slack. The Chrome security filter blocks automated token extraction, so the DEFAULT working path is an in-page fetch to users.profile.set via Claude in Chrome (token stays in the browser). Headless local script (scripts/slack-status.sh) works only if the user has manually pasted their own session token + d cookie into the token files, or has an xoxp app token.
---

# Slack Status

Set / clear the user's Slack status. Read the routing below — the right path depends on what auth exists.

## Auth reality (read first — three tiers in order of preference)

**Tier 1 (default): In-page fetch via Claude in Chrome**
- Requires: Chrome connected + a logged-in Slack web session.
- The browser uses its own session token + auto-attached `d` cookie; the secret never leaves the page.
- The **Claude-in-Chrome security filter blocks reading the session token** back to Claude (returns `[BLOCKED: Sensitive key]`). Do not try to encode/obfuscate around that filter — it's a deliberate guardrail.

**Tier 2: Headless local one-liner (user self-copies the token)**
- The filter blocks *Claude* from extracting the token, but the user can copy their own.
- Values rotate on logout — re-do if the script 401s.
- Works only if the user has run the self-copy setup (see "Headless upgrade" below).

**Tier 3 (durable ideal): xoxp app token from a workspace admin**
- Requires a workspace admin to create an internal Slack app with `users.profile:write` user scope.
- The `xoxp-…` User OAuth Token never rotates and works headlessly forever.
- Most users can't self-provision this; it's the clean long-term answer if the admin ask is worth making.

## The move (Tier 1 — in-page fetch via Claude in Chrome)

1. Ensure a Slack client tab. `mcp__Claude_in_Chrome__tabs_context_mcp` to find one; if none, `navigate` to `https://app.slack.com/client`. Confirm login with a quick JS check (`location.href` should be an `app.slack.com/client/T…` URL). If a login wall shows, stop and tell the user — never touch credentials.
2. **Turn network capture on first** — call `mcp__Claude_in_Chrome__read_network_requests` once (any pattern) so tracking is live before the fetch. Map the user's ask to `status_text` + `status_emoji` + optional `status_expiration` (see mapping table). Then run this fetch via `mcp__Claude_in_Chrome__javascript_tool`:

```js
(async () => {
  const cfg = JSON.parse(localStorage.getItem('localConfig_v2'));
  const tid = Object.keys(cfg.teams).find(k => cfg.teams[k] && cfg.teams[k].token);
  const token = cfg.teams[tid].token;
  const profile = { status_text: "<TEXT>", status_emoji: "<EMOJI>", status_expiration: <EXP_OR_0> };
  await fetch('/api/users.profile.set', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'token=' + encodeURIComponent(token) + '&profile=' + encodeURIComponent(JSON.stringify(profile))
  });
  return 'fired';
})()
```

**Expect the JS result to come back as `{}`.** The Chrome security filter redacts ANY script result that touches the token (it escalates after the first token read). That is NOT a failure — the `fetch` still executes. **Never rely on the JS return value; never treat `{}` as an error.**

3. **Verify on the wire, not in the JS return.** Call `mcp__Claude_in_Chrome__read_network_requests` with `urlPattern: "users.profile.set"` → `statusCode: 200` = success. Claim success on a 200 network response for `users.profile.set`; the in-page JS result is redacted (`{}`) and unreliable — never require `ok:true`. If no request appears or it's non-200, the session is likely logged out — ask the user to reload Slack. Never thrash, never fabricate success.

To **read** current status (e.g. to restore later), same inline-token pattern against `/api/users.profile.get`. To **clear**, set all three fields empty/0.

## Natural-language → status mapping

Infer a sensible emoji + tight text from the user's phrasing; don't make them spell out the emoji. If they give explicit text/emoji, use verbatim. If they give a duration ("for an hour", "until 3pm", "back in 20"), set `status_expiration` (Unix epoch seconds; compute in the user's timezone).

| User says… | status_text | status_emoji | expiry |
|---|---|---|---|
| heads down / deep work / focus | In deep work | :headphones: | — |
| in a meeting | In a meeting | :calendar: | meeting length if stated |
| on a call | On a call | :telephone_receiver: | — |
| lunch | Lunch | :sandwich: | +45m |
| coffee / break | Back shortly | :coffee: | +15m |
| commuting / on the move | Commuting | :car: | — |
| EOD / done / logging off | Done for the day | :wave: | — |
| OOO / off / holiday | Out of office | :palm_tree: | until date if given |
| sick | Out sick | :face_with_thermometer: | — |
| clear / remove / reset | (empty) | (empty) | 0 |

Confirm the interpreted status back in one line so a bad guess is easy to catch.

## Headless upgrade (Tier 2 — user self-copies the token)

The filter blocks *Claude* from extracting the token, but the user can copy their own.
Have the user do this once (values rotate on logout — re-do if it 401s):

1. In the Slack web tab: DevTools (⌥⌘I) → **Console** →
   `JSON.parse(localStorage.localConfig_v2).teams[Object.keys(JSON.parse(localStorage.localConfig_v2).teams)[0]].token`
   → copy the `xoxc-…` string.
2. `printf '%s' 'xoxc-…' > ~/.slack_user_token && chmod 600 ~/.slack_user_token`
3. DevTools → **Application** → **Cookies** → `https://app.slack.com` → copy the **`d`** cookie value (it's httpOnly, only visible here).
4. `printf '%s' '<d-value>' > ~/.slack_d_cookie && chmod 600 ~/.slack_d_cookie`
5. `printf '%s' 'https://<your-workspace>.slack.com' > ~/.slack_api_base`  (workspace-scoped for xoxc; replace with your workspace URL)

Then: `~/.claude/skills/slack-status/scripts/slack-status.sh --text "Lunch" --emoji ":sandwich:" --minutes 45`
The script auto-detects `xoxc-` and sends the `d` cookie. See `--help` for flags.

## Durable ideal (Tier 3 — xoxp app token)

If a workspace admin creates an internal Slack app with the **`users.profile:write`** user scope:
`printf '%s' 'xoxp-…' > ~/.slack_user_token && chmod 600 ~/.slack_user_token` — no `d` cookie needed, never rotates, headless forever.

## Guardrails

- Never try to defeat the Chrome sensitive-key filter (no encoding/obfuscation tricks). If headless is wanted, route the user through the manual self-copy above.
- Report failures honestly with the Slack error code; claim success on a 200 network response for `users.profile.set` (the JS return is redacted and unreliable).
- This only ever targets the token owner's own profile.
- Session token + `d` cookie are full account auth — files stay `chmod 600`, never commit them, never echo them into chat.

## Sync home

Sync home: canonical = your live private copy; public sanitized twin: ~/code/skills/slack-status → github.com/justinwilliames/skills. Sanitization is a sync step.
