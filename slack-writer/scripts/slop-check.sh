#!/usr/bin/env bash
# Slack-writer slop lint.
#
# Runs a draft through the Orbit AI-slop detector
# (orbit-for-claude/server/slop-detector.js -> analyseSlop) and prints
# { score, tier, findings[] } as JSON. Keeps the Slack writer's anti-AI-slop
# standard identical to Orbit's published-content gate.
#
# Usage:
#   echo "draft text" | slop-check.sh
#   slop-check.sh /path/to/draft.txt
#
# Reads the draft from $1 (a file path) or from stdin.
# Degrades gracefully (exit 0, message on stderr) if Node or the detector
# is unavailable — the caller then falls back to the inline rules in SKILL.md.
set -euo pipefail

# Override the detector path by setting ORBIT_SLOP_DETECTOR in your environment:
#   export ORBIT_SLOP_DETECTOR=/path/to/your/orbit-for-claude/server/slop-detector.js
# Default assumes the orbit-for-claude repo is at ~/code/orbit-for-claude/.
DETECTOR="${ORBIT_SLOP_DETECTOR:-$HOME/code/orbit-for-claude/server/slop-detector.js}"

if ! command -v node >/dev/null 2>&1; then
  echo "SLOP_CHECK_SKIPPED: node not found — fall back to the inline AI-tell rules in SKILL.md" >&2
  exit 0
fi
if [ ! -f "$DETECTOR" ]; then
  echo "SLOP_CHECK_SKIPPED: detector not found at $DETECTOR — fall back to the inline AI-tell rules in SKILL.md" >&2
  exit 0
fi

if [ "${1:-}" != "" ] && [ -f "${1:-}" ]; then
  DRAFT="$(cat "$1")"
else
  DRAFT="$(cat)"
fi

DETECTOR_URL="file://$DETECTOR" DRAFT_TEXT="$DRAFT" node --input-type=module -e '
const { analyseSlop } = await import(process.env.DETECTOR_URL);
const a = analyseSlop(process.env.DRAFT_TEXT || "");
const out = {
  score: a.score,
  tier: a.tier,
  findings: (a.findings || []).map((f) => ({
    severity: f.severity,
    label: f.label,
    matches: f.matches,
    fix: f.fix,
  })),
};
console.log(JSON.stringify(out, null, 2));
'
