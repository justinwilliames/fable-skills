---
name: posthog-design-customization
description: >
  Use this skill whenever the user wants to customize the VISUAL properties of a PostHog insight — series colors, currency prefixes, percent suffixes, decimal places, display type, axis labels, trend lines, custom labels, anything inside `chartSettings.yAxis[].settings.display.*` or `chartSettings.yAxis[].settings.formatting.*` or the matching `tableSettings.columns[].settings.*`. Trigger on phrases like "color X red/green/blue", "make the churned bar red", "format X as currency", "add $ prefix", "add % suffix", "set decimal places", "change the chart colors", "match the brand palette", "the colors are wrong", "fix the formatting", "set display.color", "format this insight", "the % suffix is missing", "this should be styled as currency", "customize the visualization", "MCP stripped my formatting", "PATCH PostHog directly". ALSO trigger any time a user asks to mutate one of these fields via PostHog MCP — the MCP `insight-update` tool silently strips them, so even a request that LOOKS like it should go via MCP must use the browser-fetch path documented here. The skill is read+write capable via the authenticated browser session and produces verified, immediately-rendered visual changes.
---

# PostHog Design Customization Skill

> Apply visual customizations to PostHog insights — colors, formatting, prefixes, suffixes, decimal places, display types — by driving raw PATCH from inside an authenticated PostHog browser tab. Bypasses the MCP gateway's silent strip of these fields. Verified working pattern, May 2026. Re-verify if PostHog MCP has updated since — check that a round-trip PATCH to display.color still returns `"display": {}` before assuming the strip is still active.

## The problem this solves

PostHog MCP's `insight-update` tool **silently strips** the following fields on the way in (empirically verified — request sent, response returns `display: {}` and `formatting` gone):

- `chartSettings.yAxis[].settings.display.color`
- `chartSettings.yAxis[].settings.display.label`
- `chartSettings.yAxis[].settings.display.trendLine`
- `chartSettings.yAxis[].settings.display.displayType`
- `chartSettings.yAxis[].settings.formatting.style`
- `chartSettings.yAxis[].settings.formatting.prefix`
- `chartSettings.yAxis[].settings.formatting.suffix`
- `chartSettings.yAxis[].settings.formatting.decimalPlaces`
- All equivalents on `tableSettings.columns[].settings.*`

The MCP tool's JSON schema explicitly only exposes `yAxisPosition` under `display`. Everything else gets dropped at the gateway. Confirmed by the PostHog router rule "Use raw PATCH API for `display`, `chartSettings`, `tableSettings` — MCP `insight-update` tool cannot set these fields."

**This skill is the raw PATCH path.** It uses the user's existing PostHog browser session (cookies + CSRF) to hit the REST API directly, which accepts the full payload.

## When to fire

Fire automatically whenever the user wants any of:

| User says | What they mean | Tool field |
|---|---|---|
| "color the churned bar red" | series color | `display.color` |
| "make new signups green" | series color | `display.color` |
| "match the brand palette" | series colors | `display.color` |
| "format MRR as currency" | `$` prefix on a number | `formatting.prefix` + `formatting.style` |
| "add a percent suffix" | `%` suffix | `formatting.suffix` |
| "no decimal places on count columns" | rounding | `formatting.decimalPlaces: 0` |
| "two decimals on the rate" | precision | `formatting.decimalPlaces: 2` |
| "change the y-axis label" | series label override | `display.label` |
| "show a trend line" | trend overlay | `display.trendLine` |
| "make this a bar chart instead of line" | per-series viz override | `display.displayType` |
| "put this on the right y-axis" | dual-axis | `display.yAxisPosition` (this one DOES work via MCP) |
| "the colors are wrong" | fix needed | inspect + repaint |
| "MCP stripped my formatting" | known cause | apply via this skill |

Do NOT fire for:
- SQL/HogQL query changes (use PostHog MCP `insight-update` for those — query body is NOT stripped)
- Tags, descriptions, names (MCP handles those fine)
- Creating new insights (use MCP `insight-create`)
- Anything outside the visual customization surface

## Prerequisites

Before driving any PATCH:

1. **Browser MCP available** — Claude in Chrome tools surfaced (`mcp__Claude_in_Chrome__*`).
2. **User has an authenticated PostHog tab** OR willing to let the skill open one and rely on saved session cookies.
3. **User can confirm they're logged in** — the skill verifies `/api/users/@me/` returns 200 before any writes.

If browser MCP is NOT available, fall back to the proposal-only workflow: produce a per-insight hex/format table and tell the user it's UI work or have them set `POSTHOG_API_KEY` for a Bash-driven raw PATCH.

## The verified working pattern

### Step 1 — Get a Chrome tab on PostHog

```
mcp__Claude_in_Chrome__tabs_context_mcp(createIfEmpty: true)
mcp__Claude_in_Chrome__navigate(tabId, url: "https://us.posthog.com/project/<your-project-id>")
```

Replace `<your-project-id>` with your numeric PostHog project ID (visible in the URL when logged in, e.g. `us.posthog.com/project/12345`).

### Step 2 — Verify session + capture CSRF

```javascript
mcp__Claude_in_Chrome__javascript_tool(action: "javascript_exec", tabId, text: `(async () => {
  const csrf = document.cookie.split(';').map(c => c.trim()).find(c => c.startsWith('posthog_csrftoken='))?.split('=')[1];
  const res = await fetch('/api/users/@me/', {credentials: 'include'});
  const me = res.ok ? await res.json() : {error: res.status};
  return JSON.stringify({csrfPresent: !!csrf, loginStatus: res.status, user: me.email, org: me.organization?.name});
})()`)
```

Expect: `loginStatus: 200`, `csrfPresent: true`, `user: <user email>`. If 401/403 → user not logged in, surface the issue and stop.

### Step 3 — Drive PATCH from the authenticated context

The pattern for **any** stripped field is identical — only the `colorMaps` / `formattingMaps` payload changes.

**For COLORS:**

```javascript
(async () => {
  const csrf = document.cookie.split(';').map(c => c.trim()).find(c => c.startsWith('posthog_csrftoken='))?.split('=')[1];
  const PROJECT = <your-project-id>; // Replace with your PostHog project ID (numeric)

  const colorMaps = {
    'shortId1': { column_a: '#DC2626', column_b: '#16A34A' },
    'shortId2': { column_x: '#3B82F6' }
  };

  const results = [];
  for (const [shortId, colors] of Object.entries(colorMaps)) {
    const list = await (await fetch(`/api/projects/${PROJECT}/insights/?short_id=${shortId}`, {credentials: 'include'})).json();
    const insight = list.results?.[0];
    if (!insight) { results.push({shortId, error: 'not found'}); continue; }

    const query = JSON.parse(JSON.stringify(insight.query)); // deep clone — never mutate the original
    if (!query.chartSettings) query.chartSettings = {};
    if (!Array.isArray(query.chartSettings.yAxis)) query.chartSettings.yAxis = [];

    const applied = {};
    for (const y of query.chartSettings.yAxis) {
      if (!(y.column in colors)) continue;
      y.settings ??= {};
      y.settings.display ??= {};
      y.settings.display.color = colors[y.column];
      applied[y.column] = colors[y.column];
    }

    const patch = await fetch(`/api/projects/${PROJECT}/insights/${insight.id}/`, {
      method: 'PATCH',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json', 'X-CSRFToken': csrf },
      body: JSON.stringify({query})
    });

    // Verify by reading back from the PATCH response
    const verify = {};
    if (patch.ok) {
      const body = await patch.json();
      for (const y of (body.query?.chartSettings?.yAxis || [])) {
        if (y.column in colors) verify[y.column] = y.settings?.display?.color || 'MISSING';
      }
    }

    results.push({shortId, insightId: insight.id, patchStatus: patch.status, applied, verify});
  }
  return JSON.stringify(results, null, 2);
})()
```

**For FORMATTING (currency / percent / decimals):**

Same shape, different payload key. Replace `y.settings.display.color = ...` with:

```javascript
y.settings.formatting ??= {};
y.settings.formatting.style = 'number';          // or 'percent'
y.settings.formatting.prefix = '$';              // for currency
y.settings.formatting.suffix = '%';              // for percent
y.settings.formatting.decimalPlaces = 0;         // count cols: 0, rate cols: 1-2
```

**For TABLE columns (tableSettings.columns instead of chartSettings.yAxis):**

Mirror the same write to `query.tableSettings.columns[].settings.{display|formatting}.*`. Always patch BOTH `chartSettings` and `tableSettings` for the same column when both exist on an insight — otherwise the table view shows different formatting than the chart view.

### Step 4 — Verify with a fresh fetch

After the PATCH loop completes, run a separate fetch that re-reads the insight and confirms the field landed:

```javascript
(async () => {
  const PROJECT = <your-project-id>; // Replace with your PostHog project ID
  const results = [];
  for (const sid of ['shortId1', 'shortId2']) {
    const data = await (await fetch(`/api/projects/${PROJECT}/insights/?short_id=${sid}`, {credentials: 'include'})).json();
    const insight = data.results?.[0];
    const live = {};
    for (const y of (insight.query?.chartSettings?.yAxis || [])) {
      live[y.column] = {
        color: y.settings?.display?.color || 'NONE',
        prefix: y.settings?.formatting?.prefix || 'NONE',
        suffix: y.settings?.formatting?.suffix || 'NONE'
      };
    }
    results.push({sid, live});
  }
  return JSON.stringify(results, null, 2);
})()
```

A patched-but-not-verified result is incomplete. Always run the readback before reporting "done".

## Semantic color palette for lifecycle/retention dashboards

When the user says "match the brand palette" or doesn't specify hex codes for a lifecycle/retention insight, this semantic palette maps action meanings to colors so any bar/line chart reads positive-to-negative at a glance. Adapt the column names to your own schema.

| Semantic | Hex | Example columns |
|---|---|---|
| **Positive — new growth** | `#16A34A` | `new_subscriptions`, `mrr_gained`, `orgs_gained`, `entered_flow` |
| **Positive — retained / saved** | `#4ADE80` | `retained`, `resubscriptions`, `resumptions` |
| **Positive — accumulator / stock** | `#3B82F6` | `total_mrr`, `paying_logos`, `active_logos`, `total_entered` |
| **Warning — at risk** | `#EAB308` | `pauses`, `paused`, `past_due` |
| **Warning — cancel pipeline** | `#F97316` | `churn_requested`, `cancel_requested` |
| **Warning — scheduled cancel** | `#FB923C` | `cancel_scheduled` |
| **Negative — lost** | `#DC2626` | `churned`, `churn_pct`, `churned_mrr`, `churned_orgs` |
| **Calculated metric** | `#8B5CF6` | `net_mrr`, `save_rate`, `flow_coverage_pct` |
| **Neutral — unknown / data quality** | `#9CA3AF` | `Unknown`, `uncategorized`, `Other` |

Categorical reason palette (adapt reason labels to your own taxonomy):

| Reason type | Hex |
|---|---|
| Product not a fit | `#DC2626` |
| Quality issues | `#F97316` |
| Too expensive | `#EAB308` |
| Non-payment | `#F59E0B` |
| Integration / technical | `#06B6D4` |
| Support issues | `#A855F7` |
| End customer sentiment | `#EC4899` |
| Competitor / Switched | `#EF4444` |
| Oversold | `#F87171` |
| Business closed | `#6B7280` |
| Other | `#9CA3AF` |
| Uncategorized | `#D1D5DB` |

## Formatting defaults

Sensible numerical display conventions:

| Column type | `style` | `prefix` | `suffix` | `decimalPlaces` |
|---|---|---|---|---|
| Currency (mrr, arr, revenue, amount, price) | `"number"` | `"$"` | — | `0` |
| Counts (logos, orgs, customers, subscriptions, count) | `"number"` | — | — | `0` |
| Percentages (rate, pct, percent, percentage) | `"number"` | — | `"%"` | `1` or `2` |
| Plain numbers | `"number"` | — | — | `0` |

**Mirror both `chartSettings.yAxis[]` AND `tableSettings.columns[]`** for the same column. PostHog renders the chart and the table view independently — if you only patch one, the other looks unstyled.

## Anti-patterns

- **Do not** attempt to set colors via PostHog MCP `insight-update`. It accepts the payload and returns 200 OK, but `display.color` is silently dropped. The empirical test result was `"display": {}` in the response body even though valid hex was sent. Same for formatting fields.
- **Do not** skip the verification readback. The PATCH response shows the field landed in the database; a separate fetch confirms it survived round-trip. They're not the same check.
- **Do not** mutate `insight.query` directly — deep-clone first via `JSON.parse(JSON.stringify(...))`. Bugs from shared object references in this kind of script are nasty to debug.
- **Do not** drive this against insights the user doesn't own. Check `tags` and `last_modified_by` first. Tag-managed insights may belong to your data owner — coordinate with them rather than patching unilaterally.
- **Do not** patch ALL yAxis items if the colorMap only covers some. The script above correctly skips columns not in the map; preserve this behavior.
- **Do not** assume the project ID — pull it from the URL or `me.team.id` if uncertain.
- **Do not** try this from a fresh anonymous browser tab — it'll 403. The tab must be on a domain where the user's PostHog session cookies live (e.g. `us.posthog.com` or `eu.posthog.com`).

## Closeout

After applying customizations:

1. **Show verified state** — list the affected insights, each patched field, and the live readback value. Don't claim "done" without the readback.
2. **Flag missed columns** — if a column existed in the user's palette but wasn't found in the insight's yAxis, surface it. Could be a column name typo, or a column that lives in `tableSettings` only.
3. **Note data-owner-managed siblings** — if the user is restyling an insight that has a sibling managed by your data owner (identifiable by tag conventions), mention that the sibling won't match unless they apply the same palette.

## Origin

This pattern was discovered empirically: the MCP `insight-update` color-strip was confirmed by sending a valid hex value and receiving `"display": {}` in the response body. The browser-fetch workaround was developed and verified by patching 6 insights with 45 total color assignments. Verified working pattern as of 2026-05-15.

## Sync home

Sync home: canonical = your live private copy; public sanitized twin: ~/code/skills/posthog-design-customization → github.com/justinwilliames/skills. Sanitization is a sync step.
