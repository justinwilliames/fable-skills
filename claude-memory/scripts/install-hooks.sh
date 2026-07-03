#!/usr/bin/env bash
# install-hooks.sh — patches ~/.claude/settings.json to add SessionStart pull
# and SessionStop sync hooks. Idempotent. Preserves existing hooks.
#
# Usage:
#   install-hooks.sh             install or update hooks
#   install-hooks.sh --uninstall remove claude-memory hooks
set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
SKILL_DIR="$CLAUDE_DIR/skills/claude-memory"
SESSION_START_HOOK="$SKILL_DIR/hooks/session-start.sh"
SESSION_STOP_HOOK="$SKILL_DIR/hooks/session-stop.sh"

UNINSTALL=0
[ "${1:-}" = "--uninstall" ] && UNINSTALL=1

if [ ! -f "$SETTINGS" ]; then
  echo "✗ No settings.json at $SETTINGS" >&2
  exit 1
fi

# Ensure hook scripts are executable
chmod +x "$SESSION_START_HOOK" "$SESSION_STOP_HOOK" "$SKILL_DIR"/scripts/*.sh 2>/dev/null || true

# Back up settings.json before mutating
cp "$SETTINGS" "$SETTINGS.bak"

python3 <<PY
import json
from pathlib import Path

settings_path = Path("$SETTINGS")
data = json.loads(settings_path.read_text())
data.setdefault("hooks", {})

uninstall = $UNINSTALL == 1
start_cmd = "$SESSION_START_HOOK"
stop_cmd = "$SESSION_STOP_HOOK"

def filter_matchers(matchers, exclude_cmd):
    out = []
    for m in matchers:
        new_hooks = [h for h in m.get("hooks", []) if h.get("command") != exclude_cmd]
        if new_hooks:
            m["hooks"] = new_hooks
            out.append(m)
    return out

def add_to_event(event_key, cmd):
    matchers = data["hooks"].get(event_key, [])
    # Remove existing entries for this cmd before re-adding (idempotent update)
    matchers = filter_matchers(matchers, cmd)
    # Append a new matcher block with this single hook
    matchers.append({
        "matcher": "",
        "hooks": [{"type": "command", "command": cmd, "timeout": 5}],
    })
    data["hooks"][event_key] = matchers

if uninstall:
    for event_key in ("SessionStart", "Stop"):
        if event_key in data["hooks"]:
            data["hooks"][event_key] = filter_matchers(data["hooks"][event_key], start_cmd if event_key == "SessionStart" else stop_cmd)
            if not data["hooks"][event_key]:
                del data["hooks"][event_key]
    print("Uninstalled claude-memory hooks.")
else:
    add_to_event("SessionStart", start_cmd)
    add_to_event("Stop", stop_cmd)
    print("Installed claude-memory hooks:")
    print(f"  SessionStart → {start_cmd}")
    print(f"  Stop         → {stop_cmd}")

settings_path.write_text(json.dumps(data, indent=2) + "\n")
PY

# Wire the settings.json secret-redaction clean filter + hooks path (idempotent).
# Pairs with the tracked .gitattributes (settings.json filter=redactsecrets): the
# secret VALUES are blanked in the committed blob while the working tree keeps
# them. core.hooksPath ensures the pre-commit secret scanner runs as the backstop.
if [ "$UNINSTALL" = 0 ] && git -C "$CLAUDE_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "$CLAUDE_DIR" config filter.redactsecrets.clean "$CLAUDE_DIR/.githooks/redact-settings.sh"
  git -C "$CLAUDE_DIR" config filter.redactsecrets.smudge cat
  git -C "$CLAUDE_DIR" config core.hooksPath .githooks
  chmod +x "$CLAUDE_DIR/.githooks/redact-settings.sh" "$CLAUDE_DIR/.githooks/pre-commit" 2>/dev/null || true
  echo "✓ wired settings.json redaction filter + .githooks path"
fi

echo "✓ settings.json patched. Backup at $SETTINGS.bak"
echo ""
echo "Active hooks now:"
python3 -c "
import json
data = json.loads(open('$SETTINGS').read())
for event, matchers in data.get('hooks', {}).items():
    print(f'  {event}:')
    for m in matchers:
        for h in m.get('hooks', []):
            print(f'    → {h.get(\"command\")}')
"
