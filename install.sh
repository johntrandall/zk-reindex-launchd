#!/usr/bin/env bash
# install.sh — install zk-reindex-launchd as a per-user LaunchAgent.
#
# Idempotent: re-running re-installs the script + plist, bootouts any
# previous instance, and bootstraps a fresh one. Existing config is
# preserved.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DEST="$HOME/.local/bin/zk-reindex-all"
PLIST_DEST="$HOME/Library/LaunchAgents/com.zk-reindex-all.plist"
LOG_DEST="$HOME/Library/Logs/zk-reindex-all.log"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zk-reindex-launchd"
CONFIG_FILE="$CONFIG_DIR/notebooks.conf"
LABEL="com.zk-reindex-all"

# Sanity checks
if ! command -v zk >/dev/null 2>&1; then
  echo "WARNING: 'zk' is not on your PATH. Install it first:"
  echo "  brew install zk"
  echo "Continuing — you can install zk before the next reindex cycle fires."
  echo
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ERROR: this installer is macOS-only (uses launchd)." >&2
  exit 1
fi

# Create dirs
mkdir -p "$HOME/.local/bin" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs" "$CONFIG_DIR"

# Install script
install -m 755 "$REPO_DIR/bin/zk-reindex-all" "$BIN_DEST"
echo "Installed script:  $BIN_DEST"

# Render plist from template
sed "s|__HOME__|$HOME|g" "$REPO_DIR/launchd/com.zk-reindex-all.plist" > "$PLIST_DEST"
echo "Installed plist:   $PLIST_DEST"

# Seed config if absent
if [[ ! -f "$CONFIG_FILE" ]]; then
  cat > "$CONFIG_FILE" <<EOF
# zk-reindex-launchd: notebooks to reindex
# Format: <path>[:<maxdepth>]
# Lines starting with # are comments; blank lines are ignored.
#
# Examples:
#   $HOME/notes              # full-depth scan
#   $HOME/Obsidian:3         # cap descent at 3 levels
#   $HOME/dev:2              # only catch <project>/.zk, skip repo subtrees
#
# Edits take effect on the next cycle (~5 min) — no service reload needed.

EOF
  echo "Seeded config:     $CONFIG_FILE"
  echo
  echo "  -> Edit $CONFIG_FILE to list your zk notebooks."
  echo "     Until you do, the agent uses the built-in defaults"
  echo "     (~/Documents, ~/Desktop, ~/notes, ~/Notes, ~/Obsidian, ~/Vault)."
else
  echo "Config preserved:  $CONFIG_FILE"
fi

# Reload launchd (idempotent)
launchctl bootout "gui/$(id -u)" "$PLIST_DEST" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_DEST"
echo "LaunchAgent loaded: $LABEL"

echo
echo "Installed. Tail the log to see reindexes happen:"
echo "  tail -f $LOG_DEST"
echo
echo "Uninstall: $REPO_DIR/uninstall.sh"
