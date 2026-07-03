#!/usr/bin/env bash
# install-launchd.sh — install (or remove) a macOS launchd agent that runs
# sync.sh on a 4-hourly schedule between 09:00 and 21:00 local time.
#
# Catches drift that the SessionStop hook misses: files edited outside Claude
# Code, sessions left open for days, plans/settings/agents dirty without
# memory churn.
#
# Usage:
#   install-launchd.sh             install or update the launchd job
#   install-launchd.sh --uninstall remove it
#   install-launchd.sh --status    show current state
set -euo pipefail

LABEL="team.yourorbit.claude-memory.daily"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
SKILL_DIR="$HOME/.claude/skills/claude-memory"
SYNC_SCRIPT="$SKILL_DIR/scripts/sync.sh"
LOG="$HOME/.claude/memory-sync.log"
UID_=$(id -u)

ACTION="install"
case "${1:-}" in
  --uninstall) ACTION="uninstall" ;;
  --status) ACTION="status" ;;
  -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
esac

case "$ACTION" in

  install)
    [ -x "$SYNC_SCRIPT" ] || { echo "✗ sync.sh not executable at $SYNC_SCRIPT" >&2; exit 1; }

    # If already loaded, unload first so we install fresh
    if launchctl print "gui/$UID_/$LABEL" >/dev/null 2>&1; then
      launchctl bootout "gui/$UID_/$LABEL" 2>/dev/null || true
    fi

    mkdir -p "$(dirname "$PLIST")"

    cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>cd \$HOME/.claude &amp;&amp; $SYNC_SCRIPT --quiet 2&gt;&gt;$LOG</string>
    </array>

    <key>StartCalendarInterval</key>
    <array>
        <dict><key>Hour</key><integer>9</integer><key>Minute</key><integer>0</integer></dict>
        <dict><key>Hour</key><integer>13</integer><key>Minute</key><integer>0</integer></dict>
        <dict><key>Hour</key><integer>17</integer><key>Minute</key><integer>0</integer></dict>
        <dict><key>Hour</key><integer>21</integer><key>Minute</key><integer>0</integer></dict>
    </array>

    <key>StandardOutPath</key>
    <string>$LOG</string>
    <key>StandardErrorPath</key>
    <string>$LOG</string>

    <key>RunAtLoad</key>
    <false/>

    <!-- If the machine was asleep at the scheduled time, run as soon as it wakes -->
    <key>StartCalendarIntervalRunAtLoad</key>
    <false/>
</dict>
</plist>
EOF

    # Bootstrap (load) the agent
    launchctl bootstrap "gui/$UID_" "$PLIST"

    echo "✓ Installed launchd agent: $LABEL"
    echo "  Plist:    $PLIST"
    echo "  Sync:    $SYNC_SCRIPT"
    echo "  Log:     $LOG"
    echo "  Schedule: 09:00, 13:00, 17:00, 21:00 daily (local time)"
    echo ""
    echo "Verify with: $0 --status"
    ;;

  uninstall)
    if launchctl print "gui/$UID_/$LABEL" >/dev/null 2>&1; then
      launchctl bootout "gui/$UID_/$LABEL"
      echo "✓ Unloaded $LABEL"
    else
      echo "  (not loaded)"
    fi

    if [ -f "$PLIST" ]; then
      rm "$PLIST"
      echo "✓ Removed $PLIST"
    fi
    ;;

  status)
    echo "Label:  $LABEL"
    echo "Plist:  $PLIST"
    if [ -f "$PLIST" ]; then
      echo "        ✓ plist exists"
    else
      echo "        ✗ plist missing"
    fi

    if launchctl print "gui/$UID_/$LABEL" >/dev/null 2>&1; then
      echo "        ✓ agent loaded"
      echo ""
      echo "── launchctl print summary ──"
      launchctl print "gui/$UID_/$LABEL" 2>/dev/null | grep -E "^\s*(state|last exit code|runs)\s*=" | sed 's/^/    /' || true
    else
      echo "        ✗ agent not loaded"
    fi

    echo ""
    echo "Recent log lines:"
    if [ -f "$LOG" ]; then
      tail -5 "$LOG" | sed 's/^/    /'
    else
      echo "    (no log yet)"
    fi
    ;;
esac
