#!/usr/bin/env bash
# uninstall.sh — remove zk-reindex-launchd.
#
# Stops the LaunchAgent, removes the script, plist, and log. Config
# (~/.config/zk-reindex-launchd/) is preserved by default — pass
# --purge to remove it too.

set -uo pipefail

BIN_DEST="$HOME/.local/bin/zk-reindex-all"
PLIST_DEST="$HOME/Library/LaunchAgents/com.zk-reindex-all.plist"
LOG_DEST="$HOME/Library/Logs/zk-reindex-all.log"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zk-reindex-launchd"

PURGE=false
for arg in "$@"; do
  case "$arg" in
    --purge) PURGE=true ;;
    -h|--help)
      echo "Usage: $0 [--purge]"
      echo "  --purge   Also remove the config directory ($CONFIG_DIR)"
      exit 0
      ;;
    *) echo "Unknown arg: $arg" >&2; exit 1 ;;
  esac
done

# Stop the LaunchAgent if loaded
if [[ -f "$PLIST_DEST" ]]; then
  launchctl bootout "gui/$(id -u)" "$PLIST_DEST" 2>/dev/null || true
fi

# Remove files
removed=0
for f in "$PLIST_DEST" "$BIN_DEST" "$LOG_DEST"; do
  if [[ -f "$f" ]]; then
    rm -f "$f"
    echo "Removed: $f"
    removed=$((removed + 1))
  fi
done

if [[ "$PURGE" == true ]] && [[ -d "$CONFIG_DIR" ]]; then
  rm -rf "$CONFIG_DIR"
  echo "Removed: $CONFIG_DIR"
elif [[ -d "$CONFIG_DIR" ]]; then
  echo "Config preserved: $CONFIG_DIR (pass --purge to remove)"
fi

if [[ "$removed" -eq 0 ]]; then
  echo "Nothing was installed."
else
  echo "Uninstalled."
fi
