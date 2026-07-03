#!/usr/bin/env bash
#
# slack-status.sh — set / clear your Slack status via the Web API (users.profile.set)
#
# Headless: no browser, no logged-in Slack tab. The user token IS the auth.
#
# Auth resolution order:
#   1. $SLACK_USER_TOKEN environment variable
#   2. ~/.slack_user_token   (plaintext, xoxp-… user token — chmod 600)
#
# Required token scope: users.profile:write
#
# Usage:
#   slack-status.sh --text "In deep work" --emoji ":headphones:"
#   slack-status.sh --text "Lunch" --emoji ":sandwich:" --minutes 45
#   slack-status.sh --text "Back at 3pm" --emoji ":calendar:" --until 1751500800
#   slack-status.sh --clear
#
# Flags:
#   --text  <s>    Status text (<=100 chars, Slack truncates beyond)
#   --emoji <s>    Emoji shortcode incl. colons, e.g. :headphones:
#   --minutes <n>  Auto-expire n minutes from now
#   --until <ts>   Auto-expire at a specific Unix epoch (seconds)
#   --clear        Clear status text, emoji, and expiry
#   -h|--help      This help
#
# Exit codes: 0 ok · 2 bad args · 3 no token · 4 Slack API error · 5 no curl

set -euo pipefail

usage() { awk 'NR>1 && /^#/{sub(/^# ?/,"");print;next} NR>1{exit}' "$0"; }

command -v curl >/dev/null 2>&1 || { echo "✗ curl not found" >&2; exit 5; }

TOKEN="${SLACK_USER_TOKEN:-}"
TOKEN_FILE="${HOME}/.slack_user_token"
if [[ -z "$TOKEN" && -f "$TOKEN_FILE" ]]; then
  TOKEN="$(tr -d '[:space:]' < "$TOKEN_FILE")"
fi

# Session (xoxc-) tokens are useless without the browser's `d` cookie; xoxp- app
# tokens don't need it. Optional API base override for workspace-scoped session tokens.
DCOOKIE="${SLACK_D_COOKIE:-}"
DCOOKIE_FILE="${HOME}/.slack_d_cookie"
if [[ -z "$DCOOKIE" && -f "$DCOOKIE_FILE" ]]; then
  DCOOKIE="$(tr -d '[:space:]' < "$DCOOKIE_FILE")"
fi
API_BASE="${SLACK_API_BASE:-https://slack.com}"
API_BASE_FILE="${HOME}/.slack_api_base"
if [[ -f "$API_BASE_FILE" ]]; then
  API_BASE="$(tr -d '[:space:]' < "$API_BASE_FILE")"
fi

text=""
emoji=""
expiration=0
clear=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --text)    text="${2:-}"; shift 2 ;;
    --emoji)   emoji="${2:-}"; shift 2 ;;
    --minutes) expiration=$(( $(date +%s) + (${2:-0} * 60) )); shift 2 ;;
    --until)   expiration="${2:-0}"; shift 2 ;;
    --clear)   clear=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "✗ Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

if [[ -z "$TOKEN" ]]; then
  cat >&2 <<'EOF'
✗ No Slack user token found.
  Provide one via either:
    • export SLACK_USER_TOKEN=xoxp-…
    • echo 'xoxp-…' > ~/.slack_user_token && chmod 600 ~/.slack_user_token
  The token needs the users.profile:write scope. See the skill's SKILL.md
  "Setup (one-time)" section for how to mint it.
EOF
  exit 3
fi

if [[ "$clear" == "1" ]]; then
  text=""; emoji=""; expiration=0
fi

# JSON-escape backslash then double-quote so text/emoji are safe inside the payload.
esc() { local s="${1:-}"; s="${s//\\/\\\\}"; s="${s//\"/\\\"}"; printf '%s' "$s"; }

profile_json="{\"status_text\":\"$(esc "$text")\",\"status_emoji\":\"$(esc "$emoji")\",\"status_expiration\":${expiration}}"

curl_args=( -s -X POST "${API_BASE}/api/users.profile.set"
  --data-urlencode "token=${TOKEN}"
  --data-urlencode "profile=${profile_json}" )

if [[ "$TOKEN" == xoxc-* ]]; then
  if [[ -z "$DCOOKIE" ]]; then
    echo "✗ Session (xoxc-) token needs the 'd' cookie. Set SLACK_D_COOKIE or write ~/.slack_d_cookie." >&2
    exit 3
  fi
  curl_args+=( -H "Cookie: d=${DCOOKIE}" )
fi

resp="$(curl "${curl_args[@]}")"

if printf '%s' "$resp" | grep -q '"ok":true'; then
  if [[ "$clear" == "1" ]]; then
    echo "✓ Slack status cleared"
  else
    exp_note=""
    [[ "$expiration" != "0" ]] && exp_note=" (expires $(date -r "$expiration" '+%H:%M' 2>/dev/null || echo "@$expiration"))"
    echo "✓ Slack status set: ${emoji} ${text}${exp_note}"
  fi
  exit 0
else
  err="$(printf '%s' "$resp" | sed -n 's/.*"error":"\([^"]*\)".*/\1/p')"
  echo "✗ Slack API error: ${err:-unknown_response}" >&2
  [[ "$err" == "missing_scope" ]] && echo "  → token is missing the users.profile:write scope; reinstall the app with that scope." >&2
  [[ "$err" == "not_authed" || "$err" == "invalid_auth" ]] && echo "  → token is invalid or expired; re-mint it." >&2
  exit 4
fi
