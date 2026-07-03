#!/usr/bin/env bash
# session-start.sh — runs at SessionStart. Pulls latest memory from remote
# without blocking session startup. Silent on success, brief warning on failure.
# Capped at 3s to avoid stalling Claude Code.
exec 2>/dev/null
{
  cd "$HOME/.claude" || exit 0
  timeout 3 git pull --rebase --autostash origin main >/dev/null 2>&1 || true
} &
disown
exit 0
