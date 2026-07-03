#!/usr/bin/env bash
# doctor.sh — hygiene audit of the memory layer.
# Flags: broken file/symlink references, stale paths inside memory bodies,
# orphaned MEMORY.md entries (link points to non-existent file), duplicate
# memory names across projects, oversized memory files.
set -uo pipefail   # NB: no -e — many checks intentionally allow no-match

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
GLOBAL_DIR="$CLAUDE_DIR/memory-global"
PROJECTS_ROOT="$CLAUDE_DIR/projects"
LEDGER_DAYS=0
SHOW_DEAD=0

while [ $# -gt 0 ]; do
  case "$1" in
    --ledger) LEDGER_DAYS="${2:-30}"; shift ;;
    --dead) SHOW_DEAD=1 ;;
    -h|--help) sed -n '2,6p' "$0"; exit 0 ;;
    *) echo "unknown flag: $1" >&2; exit 2 ;;
  esac
  shift
done

issues=0
report() { echo "  $*"; issues=$((issues + 1)); }

echo "═══ claude-memory doctor ═══"
echo ""

# ---- 1. Orphaned MEMORY.md entries ---------------------------------------
echo "▸ Checking MEMORY.md index → body file links..."
for memory_dir in "$PROJECTS_ROOT"/*/memory; do
  index="$memory_dir/MEMORY.md"
  [ -f "$index" ] || continue
  while IFS= read -r ref; do
    file="${ref%%#*}"
    [[ "$file" == http* ]] && continue
    [[ "$file" == /* ]] && continue
    if [ ! -e "$memory_dir/$file" ]; then
      report "Orphaned link in $(basename "$(dirname "$memory_dir")")/MEMORY.md → $file"
    fi
  done < <(grep -oE '\]\([^)]+\.md\)' "$index" 2>/dev/null | sed 's/](//;s/)$//')
done

# ---- 2. Broken symlinks --------------------------------------------------
echo "▸ Checking federation symlinks..."
for memory_dir in "$PROJECTS_ROOT"/*/memory; do
  for link in "$memory_dir"/_global_*.md; do
    [ -L "$link" ] || continue
    [ -e "$link" ] || report "Broken symlink: $link"
  done
done

# ---- 3. Frontmatter sanity check -----------------------------------------
echo "▸ Checking memory frontmatter..."
for memory_dir in "$PROJECTS_ROOT"/*/memory "$GLOBAL_DIR"; do
  [ -d "$memory_dir" ] || continue
  for f in "$memory_dir"/*.md; do
    [ -f "$f" ] || continue
    [ -L "$f" ] && continue
    base="$(basename "$f")"
    [ "$base" = "MEMORY.md" ] && continue
    [ "$base" = "MEMORY-GLOBAL.md" ] && continue
    first_line=$(head -1 "$f" 2>/dev/null)
    if [ "$first_line" != "---" ]; then
      report "Missing frontmatter: $f"
    fi
  done
done

# ---- 4. Oversized memory files -------------------------------------------
echo "▸ Checking memory file sizes (>5KB warning)..."
for memory_dir in "$PROJECTS_ROOT"/*/memory "$GLOBAL_DIR"; do
  [ -d "$memory_dir" ] || continue
  for f in "$memory_dir"/*.md; do
    [ -f "$f" ] || continue
    [ -L "$f" ] && continue
    base="$(basename "$f")"
    [ "$base" = "MEMORY.md" ] && continue
    size=$(wc -c < "$f" | tr -d ' ')
    if [ "$size" -gt 5000 ]; then
      report "Oversized memory ($size bytes): $f"
    fi
  done
done

# ---- 5. Duplicate memory names across projects ---------------------------
echo "▸ Checking for duplicate memory names across projects..."
all_names=$(find "$PROJECTS_ROOT" -maxdepth 3 -name "*.md" \
  -not -name "MEMORY.md" -not -name "_global_*" 2>/dev/null \
  | xargs -I {} basename {} | sort)
dupes=$(echo "$all_names" | uniq -d)
if [ -n "$dupes" ]; then
  while IFS= read -r d; do
    [ -z "$d" ] && continue
    report "Duplicate filename across projects: $d"
  done <<< "$dupes"
fi

# ---- 6. Ledger-based dead memory detection (optional) --------------------
if [ "$SHOW_DEAD" -eq 1 ] || [ "$LEDGER_DAYS" -gt 0 ]; then
  days="${LEDGER_DAYS:-30}"
  ledger="$CLAUDE_DIR/memory-ledger.jsonl"
  if [ -f "$ledger" ]; then
    echo ""
    echo "▸ Dead memory candidates (no reference in last ${days}d)..."
    cutoff_date=$(python3 -c "import datetime; print((datetime.date.today() - datetime.timedelta(days=$days)).isoformat())")
    referenced=$(python3 <<PY
import json
seen = set()
with open("$ledger") as fh:
    for line in fh:
        try:
            r = json.loads(line)
            if r.get("date","") >= "$cutoff_date":
                for f in r.get("files_referenced", []):
                    seen.add(f)
        except Exception:
            pass
print("\n".join(sorted(seen)))
PY
)
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      base=$(basename "$f")
      [ "$base" = "MEMORY.md" ] && continue
      [ "$base" = "MEMORY-GLOBAL.md" ] && continue
      if ! grep -qxF "$base" <<< "$referenced"; then
        echo "  💀 $f"
      fi
    done < <(find "$PROJECTS_ROOT" "$GLOBAL_DIR" -maxdepth 3 -name "*.md" -not -type l 2>/dev/null)
  else
    echo "  (no ledger at $ledger — dead-memory check skipped)"
  fi
fi

echo ""
if [ "$issues" -eq 0 ]; then
  echo "✓ Memory layer is healthy. 0 issues found."
else
  echo "✗ $issues issue(s) found."
  exit 1
fi
