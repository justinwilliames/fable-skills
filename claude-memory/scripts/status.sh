#!/usr/bin/env bash
# status.sh — read-only drift report for the memory layer.
# Shows: uncommitted memory changes, untracked memory files, broken symlinks,
# remote-ahead state, memory-global tier contents, total memory file counts.
set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
GLOBAL_DIR="$CLAUDE_DIR/memory-global"
PROJECTS_ROOT="$CLAUDE_DIR/projects"

cd "$CLAUDE_DIR"

echo "═══ claude-memory status ═══"
echo ""
echo "Working tree:      $CLAUDE_DIR"
echo "Remote:            $(git config --get remote.origin.url 2>/dev/null || echo 'none')"
echo "Branch:            $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'detached')"
echo ""

# ---- Git state ------------------------------------------------------------
git fetch origin --quiet 2>/dev/null || true
local_head=$(git rev-parse HEAD 2>/dev/null || echo "")
remote_head=$(git rev-parse origin/main 2>/dev/null || echo "")
if [ -n "$local_head" ] && [ -n "$remote_head" ]; then
  ahead=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo 0)
  behind=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
  echo "Local vs remote:   $ahead ahead, $behind behind"
fi
echo ""

# ---- Uncommitted memory changes -------------------------------------------
mem_changes=$(git status --porcelain | grep -E 'memory/.+\.md$|^.. memory-global/' || true)
if [ -z "$mem_changes" ]; then
  echo "✓ No uncommitted memory changes."
else
  echo "✗ Uncommitted memory changes:"
  echo "$mem_changes" | sed 's/^/    /'
fi
echo ""

# ---- Counts per memory dir ------------------------------------------------
echo "Per-project memory counts:"
for memory_dir in "$PROJECTS_ROOT"/*/memory; do
  [ -d "$memory_dir" ] || continue
  proj=$(basename "$(dirname "$memory_dir")")
  total=$(find "$memory_dir" -maxdepth 1 -name "*.md" | wc -l | xargs)
  globals=$(find "$memory_dir" -maxdepth 1 -name "_global_*.md" -type l 2>/dev/null | wc -l | xargs)
  own=$((total - globals))
  echo "    $proj"
  echo "        own memories:    $own"
  echo "        global symlinks: $globals"
done
echo ""

# ---- Global tier ----------------------------------------------------------
if [ -d "$GLOBAL_DIR" ]; then
  global_count=$(find "$GLOBAL_DIR" -maxdepth 1 -name "*.md" ! -name "MEMORY-GLOBAL.md" | wc -l | xargs)
  echo "Global memory tier: $global_count files"
  if [ "$global_count" -gt 0 ]; then
    find "$GLOBAL_DIR" -maxdepth 1 -name "*.md" ! -name "MEMORY-GLOBAL.md" -exec basename {} \; | sed 's/^/    /' | head -20
  fi
else
  echo "Global memory tier: not initialised (run promote-global.sh to create)"
fi
echo ""

# ---- Broken symlinks ------------------------------------------------------
broken=0
for memory_dir in "$PROJECTS_ROOT"/*/memory; do
  [ -d "$memory_dir" ] || continue
  for link in "$memory_dir"/_global_*.md; do
    [ -L "$link" ] || continue
    if [ ! -e "$link" ]; then
      echo "✗ Broken symlink: $link"
      broken=$((broken + 1))
    fi
  done
done
[ "$broken" -eq 0 ] && echo "✓ No broken symlinks." || echo "  $broken broken symlinks — run sync.sh to repair."
echo ""

# ---- MEMORY.md size check -------------------------------------------------
echo "MEMORY.md index sizes (200-line truncation cap):"
for memory_dir in "$PROJECTS_ROOT"/*/memory; do
  [ -f "$memory_dir/MEMORY.md" ] || continue
  lines=$(wc -l < "$memory_dir/MEMORY.md" | xargs)
  proj=$(basename "$(dirname "$memory_dir")")
  if [ "$lines" -gt 180 ]; then
    echo "    ⚠  $proj: $lines lines (approaching cap)"
  else
    echo "    ✓  $proj: $lines lines"
  fi
done
