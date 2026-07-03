#!/usr/bin/env bash
# ledger.sh — records which memory files were referenced in the most recent
# Claude session, by scanning the session transcript (jsonl) for memory paths.
#
# Run at SessionStop. Appends one JSON line to ~/.claude/memory-ledger.jsonl.
#
# Read-back commands:
#   ledger.sh --show-latest        most recent N session records
#   ledger.sh --dead --days 30     memories never referenced in last 30 days
set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
PROJECTS_ROOT="$CLAUDE_DIR/projects"
LEDGER_FILE="$CLAUDE_DIR/memory-ledger.jsonl"

MODE="record"
SHOW_N=10
DAYS=30

while [ $# -gt 0 ]; do
  case "$1" in
    --show-latest) MODE="show"; SHOW_N="${2:-10}"; shift ;;
    --dead) MODE="dead" ;;
    --days) DAYS="${2:-30}"; shift ;;
    -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "unknown flag: $1" >&2; exit 2 ;;
  esac
  shift
done

if [ "$MODE" = "record" ]; then
  # Find the most recent jsonl session transcript for the current cwd
  # SessionStop hook passes session_id via $CLAUDE_SESSION_ID if available,
  # otherwise we pick the most-recently-modified transcript.
  cwd_encoded=$(echo "$PWD" | sed 's|/|-|g')
  proj_dir="$PROJECTS_ROOT/$cwd_encoded"
  if [ ! -d "$proj_dir" ]; then
    # Fall back to scanning all project dirs for the most recent transcript
    proj_dir=$(find "$PROJECTS_ROOT" -maxdepth 1 -type d -name "-Users-*" | head -1)
  fi

  if [ -z "${CLAUDE_SESSION_ID:-}" ]; then
    transcript=$(find "$proj_dir" -maxdepth 1 -name "*.jsonl" -type f 2>/dev/null \
      | xargs ls -t 2>/dev/null | head -1 || true)
  else
    transcript="$proj_dir/$CLAUDE_SESSION_ID.jsonl"
  fi

  if [ -z "$transcript" ] || [ ! -f "$transcript" ]; then
    exit 0
  fi

  # Extract memory file references from tool_use Read paths and content
  files_referenced=$(grep -oE 'memory/[^"]+\.md' "$transcript" 2>/dev/null \
    | sed 's|.*memory/||' | sort -u | python3 -c 'import sys,json; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))')
  [ -z "$files_referenced" ] && files_referenced="[]"

  session_id=$(basename "$transcript" .jsonl)
  date=$(date -u +%Y-%m-%d)

  python3 -c "
import json
line = {
    'session_id': '$session_id',
    'date': '$date',
    'cwd': '$PWD',
    'files_referenced': $files_referenced,
}
print(json.dumps(line))
" >> "$LEDGER_FILE"

elif [ "$MODE" = "show" ]; then
  [ ! -f "$LEDGER_FILE" ] && { echo "No ledger yet at $LEDGER_FILE"; exit 0; }
  echo "═══ Last $SHOW_N session memory ledger entries ═══"
  tail -n "$SHOW_N" "$LEDGER_FILE" | python3 -c "
import json, sys
for line in sys.stdin:
    r = json.loads(line)
    refs = r.get('files_referenced', [])
    print(f\"{r['date']}  {r['session_id'][:8]}  {len(refs):>2} files  {', '.join(refs[:3])}{'...' if len(refs)>3 else ''}\")
"

elif [ "$MODE" = "dead" ]; then
  [ ! -f "$LEDGER_FILE" ] && { echo "No ledger yet — run a few sessions first."; exit 0; }
  cutoff=$(python3 -c "import datetime; print((datetime.date.today() - datetime.timedelta(days=$DAYS)).isoformat())")
  echo "═══ Memory files never referenced since $cutoff ═══"

  referenced=$(python3 <<PY
import json
seen = set()
with open("$LEDGER_FILE") as fh:
    for line in fh:
        try:
            r = json.loads(line)
            if r.get('date','') >= "$cutoff":
                for f in r.get('files_referenced', []):
                    seen.add(f)
        except Exception:
            pass
for s in sorted(seen):
    print(s)
PY
)
  dead_count=0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    base=$(basename "$f")
    [ "$base" = "MEMORY.md" ] && continue
    [ "$base" = "MEMORY-GLOBAL.md" ] && continue
    if ! grep -qxF "$base" <<< "$referenced"; then
      echo "  💀 $f"
      dead_count=$((dead_count + 1))
    fi
  done < <(find "$PROJECTS_ROOT" "$CLAUDE_DIR/memory-global" -maxdepth 3 -name "*.md" -not -type l 2>/dev/null)
  echo ""
  echo "$dead_count dead memory candidates."
fi
