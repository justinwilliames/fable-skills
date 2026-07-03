#!/usr/bin/env bash
# promote-global.sh — promote a per-cwd memory file to the global tier.
# Moves the file to memory-global/, adds `scope: global` frontmatter, creates
# symlinks back into every tracked per-cwd memory dir, appends to
# MEMORY-GLOBAL.md.
#
# Usage:
#   promote-global.sh <memory_filename>         promote to global
#   promote-global.sh --demote <memory_filename> reverse (global → per-cwd)
set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
GLOBAL_DIR="$CLAUDE_DIR/memory-global"
PROJECTS_ROOT="$CLAUDE_DIR/projects"
DEMOTE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --demote) DEMOTE=1 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) FILE="$1" ;;
  esac
  shift
done

if [ -z "${FILE:-}" ]; then
  echo "Usage: promote-global.sh [--demote] <memory_filename>" >&2
  exit 2
fi

mkdir -p "$GLOBAL_DIR"

if [ "$DEMOTE" -eq 0 ]; then
  # ----- Promote -----
  # Find the source file in any per-cwd memory dir
  src=""
  for d in "$PROJECTS_ROOT"/*/memory; do
    [ -f "$d/$FILE" ] && src="$d/$FILE" && break
  done

  if [ -z "$src" ]; then
    # Maybe they passed a path
    [ -f "$FILE" ] && src="$FILE"
  fi

  if [ -z "$src" ] || [ ! -f "$src" ]; then
    echo "✗ Could not find $FILE in any memory dir." >&2
    exit 1
  fi

  base="$(basename "$src")"
  dest="$GLOBAL_DIR/$base"

  if [ -e "$dest" ]; then
    echo "✗ Already exists in global: $dest" >&2
    exit 1
  fi

  echo "Promoting $base to global tier..."

  # Copy to global, add scope: global to frontmatter if not present
  if grep -q "^scope: global" "$src"; then
    cp "$src" "$dest"
  else
    # Insert scope: global before closing frontmatter ---
    python3 <<PY
import re, sys
content = open("$src").read()
m = re.match(r'^(---\n.*?\n)(---\n)(.*)$', content, re.DOTALL)
if m:
    head, close, body = m.groups()
    if 'scope:' not in head:
        head += 'scope: global\n'
    new = head + close + body
else:
    # No frontmatter — add one
    new = "---\nscope: global\n---\n\n" + content
open("$dest", "w").write(new)
PY
  fi

  # Delete the original
  rm "$src"

  # Create relative symlink at the original location
  rel="$(python3 -c "import os.path; print(os.path.relpath('$dest', '$(dirname "$src")'))")"
  ln -s "$rel" "$(dirname "$src")/_global_$base"

  # Symlink into every OTHER per-cwd memory dir
  for d in "$PROJECTS_ROOT"/*/memory; do
    [ -d "$d" ] || continue
    [ "$d" = "$(dirname "$src")" ] && continue
    rel="$(python3 -c "import os.path; print(os.path.relpath('$dest', '$d'))")"
    target="$d/_global_$base"
    [ -L "$target" ] || ln -s "$rel" "$target"
  done

  # Append to MEMORY-GLOBAL.md (create if missing)
  global_index="$GLOBAL_DIR/MEMORY-GLOBAL.md"
  [ -f "$global_index" ] || cat > "$global_index" <<EOF
# Global memory index

These memories are visible in every Claude session regardless of working
directory. Promoted via \`promote-global.sh\`.

EOF
  # Extract description from frontmatter for the index entry
  desc=$(python3 -c "
import re
m = re.search(r'^---\n(.*?)\n---', open('$dest').read(), re.DOTALL)
if m:
    for line in m.group(1).splitlines():
        if line.startswith('description:'):
            print(line.split(':', 1)[1].strip()); break
")
  echo "- [$base]($base) — ${desc:-no description}" >> "$global_index"

  echo "✓ Promoted. Now symlinked into $(find "$PROJECTS_ROOT" -name "_global_$base" -type l | wc -l | xargs) projects."

else
  # ----- Demote -----
  src="$GLOBAL_DIR/$FILE"
  if [ ! -f "$src" ]; then
    echo "✗ $FILE not in global tier." >&2
    exit 1
  fi

  # Pick destination: most-recently-active memory dir
  dest_dir=$(find "$PROJECTS_ROOT" -maxdepth 2 -type d -name memory | head -1)
  if [ -z "$dest_dir" ]; then
    echo "✗ No per-cwd memory dir to demote into." >&2
    exit 1
  fi

  base="$(basename "$src")"

  # Strip scope: global from frontmatter
  python3 <<PY
import re
content = open("$src").read()
new = re.sub(r'^scope: global\n', '', content, count=1, flags=re.MULTILINE)
open("$dest_dir/$base", "w").write(new)
PY

  # Remove the global file and all symlinks
  rm "$src"
  find "$PROJECTS_ROOT" -name "_global_$base" -type l -delete

  # Remove from MEMORY-GLOBAL.md
  global_index="$GLOBAL_DIR/MEMORY-GLOBAL.md"
  if [ -f "$global_index" ]; then
    grep -v "($base)" "$global_index" > "$global_index.tmp" && mv "$global_index.tmp" "$global_index"
  fi

  echo "✓ Demoted $base to $dest_dir."
fi
