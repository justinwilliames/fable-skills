#!/usr/bin/env bash
# sync.sh — bidirectional sync of ~/.claude memory layer with the
# private GitHub backup repo. Pulls remote, refreshes federation symlinks,
# stages memory + skill changes, commits with a generated message, pushes.
#
# Safe to run repeatedly. Idempotent. Exit 0 = nothing to do or successful sync.
set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
GLOBAL_DIR="$CLAUDE_DIR/memory-global"
PROJECTS_ROOT="$CLAUDE_DIR/projects"
DRY_RUN=0
QUIET=0
SKIP_PULL=0

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --quiet) QUIET=1 ;;
    --no-pull) SKIP_PULL=1 ;;
    -h|--help)
      sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "unknown flag: $1" >&2; exit 2 ;;
  esac
  shift
done

log() { [ "$QUIET" -eq 1 ] || echo "[claude-memory] $*"; }
run() { [ "$DRY_RUN" -eq 1 ] && echo "DRY: $*" || eval "$@"; }

cd "$CLAUDE_DIR"

# Refuse if not a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "✗ $CLAUDE_DIR is not a git working tree. Did you wipe .git?" >&2
  exit 1
fi

# ---- 1. Pull ---------------------------------------------------------------
if [ "$SKIP_PULL" -eq 0 ]; then
  log "Pulling latest from origin..."
  if ! run git pull --rebase --autostash origin main 2>&1 | tail -3; then
    echo "✗ Pull failed. Resolve manually before re-running sync." >&2
    exit 1
  fi
fi

# ---- 2. Refresh federation symlinks ---------------------------------------
# For every file in memory-global/, ensure a symlink _global_<name> exists
# in every tracked per-cwd memory dir.
if [ -d "$GLOBAL_DIR" ]; then
  log "Refreshing federation symlinks..."
  shopt -s nullglob
  global_files=("$GLOBAL_DIR"/*.md)
  shopt -u nullglob

  # Skip MEMORY-GLOBAL.md from federation — it's the index, not a memory body
  for memory_dir in "$PROJECTS_ROOT"/*/memory; do
    [ -d "$memory_dir" ] || continue
    # Skip if this IS the global dir somehow
    [ "$memory_dir" = "$GLOBAL_DIR" ] && continue

    for src in "${global_files[@]}"; do
      base="$(basename "$src")"
      [ "$base" = "MEMORY-GLOBAL.md" ] && continue
      target="$memory_dir/_global_$base"
      if [ ! -L "$target" ]; then
        # Relative symlink so it survives across machines / different homes
        rel_src="$(python3 -c "import os.path,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))" "$src" "$memory_dir")"
        run ln -s "'$rel_src'" "'$target'"
      fi
    done
  done

  # Remove stale symlinks (file deleted from memory-global/)
  for memory_dir in "$PROJECTS_ROOT"/*/memory; do
    [ -d "$memory_dir" ] || continue
    for link in "$memory_dir"/_global_*.md; do
      [ -L "$link" ] || continue
      if [ ! -e "$link" ]; then
        log "Removing stale symlink: $link"
        run rm "'$link'"
      fi
    done
  done
fi

# ---- 3. Stage changes ------------------------------------------------------
# Build a concise commit message from what's actually changing.
status_output=$(git status --porcelain)
if [ -z "$status_output" ]; then
  log "Nothing to sync."
  exit 0
fi

log "Staging changes..."
run git add -A

# Detect skill changes vs memory changes vs config changes for the commit msg
added_memory=$(echo "$status_output" | awk '/^A |^\?\? /{print $2}' | grep -E 'memory/.+\.md$' || true)
modified_memory=$(echo "$status_output" | awk '/^.M |^M /{print $2}' | grep -E 'memory/.+\.md$' || true)
added_global=$(echo "$status_output" | awk '/^A |^\?\? /{print $2}' | grep -E '^memory-global/' || true)
skill_change=$(echo "$status_output" | grep -c '^.M skills/\|^?? skills/' || true)
settings_change=$(echo "$status_output" | grep -c 'settings.json' || true)

msg_parts=()
[ -n "$added_memory" ] && msg_parts+=("add $(echo "$added_memory" | wc -l | xargs) memories")
[ -n "$modified_memory" ] && msg_parts+=("update $(echo "$modified_memory" | wc -l | xargs) memories")
[ -n "$added_global" ] && msg_parts+=("promote $(echo "$added_global" | wc -l | xargs) to global")
[ "$skill_change" -gt 0 ] && msg_parts+=("skill updates")
[ "$settings_change" -gt 0 ] && msg_parts+=("settings.json")

if [ ${#msg_parts[@]} -eq 0 ]; then
  commit_msg="sync: misc changes"
else
  commit_msg="sync: $(IFS=, ; echo "${msg_parts[*]}")"
fi

# ---- 4. Commit ------------------------------------------------------------
if [ "$DRY_RUN" -eq 1 ]; then
  echo "DRY: would commit with message: $commit_msg"
  echo "DRY: staged changes:"
  git diff --cached --stat
  exit 0
fi

log "Committing: $commit_msg"
git commit -m "$commit_msg" 2>&1 | tail -3

# ---- 5. Push ---------------------------------------------------------------
log "Pushing to origin..."
git push origin main 2>&1 | tail -3
log "✓ Sync complete."
