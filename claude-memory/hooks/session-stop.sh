#!/usr/bin/env bash
# session-stop.sh — runs at SessionStop. Records memory ledger entry, syncs
# any new/modified memory back to GitHub. Runs in background; never blocks
# session teardown. Errors go to ~/.claude/memory-sync.log for inspection.
SKILL_DIR="$HOME/.claude/skills/claude-memory"
LOG="$HOME/.claude/memory-sync.log"

{
  # Record what got referenced this session
  bash "$SKILL_DIR/scripts/ledger.sh" || echo "[$(date -u +%FT%TZ)] ledger failed" >> "$LOG"

  # Only sync if memory or skill files changed (skip noisy no-op commits)
  cd "$HOME/.claude" || exit 0
  if git status --porcelain | grep -qE 'memory/|memory-global/|skills/claude-memory/'; then
    bash "$SKILL_DIR/scripts/sync.sh" --quiet --no-pull >> "$LOG" 2>&1 \
      || echo "[$(date -u +%FT%TZ)] sync failed (see above)" >> "$LOG"
  fi
} &
disown
exit 0
