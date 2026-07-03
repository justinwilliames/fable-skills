#!/usr/bin/env bash

set -eo pipefail

OUTPUT_FILE=$(mktemp "${TMPDIR:-/tmp}/codex-image-output.XXXXXX")
STDERR_FILE=$(mktemp "${TMPDIR:-/tmp}/codex-image-stderr.XXXXXX")

# Pulsar drone presence — show image generation as a Nebula (visual/artist) drone
# in the swarm, so this Bash bridge (not a Claude sub-agent, so no SubagentStart
# hook fires for it) still appears. Best-effort: never affects image generation.
PULSAR_PORT="${SPEAK_PORT:-7865}"
PULSAR_DRONE_ID="imggen-$$-${RANDOM}"
pulsar_drone_start() {
    curl -sf --max-time 2 -X POST -H 'Content-Type: application/json' \
        -d "{\"agent_id\":\"${PULSAR_DRONE_ID}\",\"category\":\"nebula\"}" \
        "http://127.0.0.1:${PULSAR_PORT}/subagent/start" >/dev/null 2>&1 || true
}
pulsar_drone_stop() {
    curl -sf --max-time 2 -X POST -H 'Content-Type: application/json' \
        -d "{\"agent_id\":\"${PULSAR_DRONE_ID}\"}" \
        "http://127.0.0.1:${PULSAR_PORT}/subagent/stop" >/dev/null 2>&1 || true
}

cleanup() {
    pulsar_drone_stop
    rm -f "$OUTPUT_FILE" "$STDERR_FILE"
}
trap cleanup EXIT

usage() {
    local exit_code="${1:-1}"
    cat <<'EOF'
codex-imagegen.sh - non-interactive Codex wrapper for image generation and editing

Usage:
  codex-imagegen.sh [options] "prompt"

Options:
  --dir PATH         Working directory for Codex
  --model MODEL      Optional model override
  --effort LEVEL     Optional reasoning effort override
  --image FILE       Attach a local image (repeatable)
  --add-dir PATH     Additional writable directory for Codex (repeatable)
  --ephemeral        Do not persist the Codex session
  -h, --help         Show this help
EOF
    exit "$exit_code"
}

resolve_codex_bin() {
    if [[ -n "${CODEX_BIN:-}" && -x "${CODEX_BIN}" ]]; then
        printf '%s\n' "${CODEX_BIN}"
        return
    fi

    if command -v codex >/dev/null 2>&1; then
        command -v codex
        return
    fi

    if [[ -x "/Applications/Codex.app/Contents/Resources/codex" ]]; then
        printf '%s\n' "/Applications/Codex.app/Contents/Resources/codex"
        return
    fi

    echo "ERROR: Codex CLI not found. Install Codex or set CODEX_BIN to a valid executable." >&2
    exit 1
}

extract_session_id() {
    grep -m1 'session id:' "$1" 2>/dev/null | sed 's/.*session id: //' || echo "unknown"
}

PROMPT=""
DIR=""
MODEL="${CODEX_IMAGE_MODEL:-}"
EFFORT="${CODEX_IMAGE_EFFORT:-}"
EPHEMERAL=false
IMAGES=()
ADD_DIRS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)
            DIR="$2"
            shift 2
            ;;
        --model)
            MODEL="$2"
            shift 2
            ;;
        --effort)
            EFFORT="$2"
            shift 2
            ;;
        --image)
            IMAGES+=("$2")
            shift 2
            ;;
        --add-dir)
            ADD_DIRS+=("$2")
            shift 2
            ;;
        --ephemeral)
            EPHEMERAL=true
            shift
            ;;
        -h|--help)
            usage 0
            ;;
        --)
            shift
            PROMPT="$*"
            break
            ;;
        *)
            if [[ -z "$PROMPT" ]]; then
                PROMPT="$1"
            else
                PROMPT="$PROMPT $1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$PROMPT" ]]; then
    usage 1
fi

CODEX_BIN="$(resolve_codex_bin)"

CMD=("$CODEX_BIN" exec --skip-git-repo-check)

if [[ -n "$DIR" ]]; then
    CMD+=(-C "$DIR")
fi

if [[ -n "$MODEL" ]]; then
    CMD+=(-m "$MODEL")
fi

if [[ -n "$EFFORT" ]]; then
    CMD+=(-c "model_reasoning_effort=\"$EFFORT\"")
fi

CMD+=(
    -c 'approval_policy="never"'
    -c 'features.search_tool=true'
    -s danger-full-access
)

if $EPHEMERAL; then
    CMD+=(--ephemeral)
fi

for image in "${IMAGES[@]}"; do
    CMD+=(-i "$image")
done

for add_dir in "${ADD_DIRS[@]}"; do
    CMD+=(--add-dir "$add_dir")
done

CMD+=(-o "$OUTPUT_FILE")
CMD+=("$PROMPT")

pulsar_drone_start
"${CMD[@]}" </dev/null >/dev/null 2>"$STDERR_FILE" || true

SESSION_ID="$(extract_session_id "$STDERR_FILE")"

printf 'SESSION: %s\n' "$SESSION_ID"
printf '%s\n' '---'

if [[ -s "$OUTPUT_FILE" ]]; then
    cat "$OUTPUT_FILE"
    exit 0
fi

echo "(No final message captured from Codex.)"
grep -E '(ERROR|Error|error|Warning|warning|failed|Failed)' "$STDERR_FILE" 2>/dev/null || cat "$STDERR_FILE"
