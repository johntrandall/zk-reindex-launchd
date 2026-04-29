# zk-reindex-launchd

Auto-reindex all your [zk](https://github.com/zk-org/zk) notebooks on macOS via a single LaunchAgent. Polls every 60 seconds, auto-discovers new notebooks, costs essentially nothing on idle.

## Why

`zk` doesn't auto-update its index when files change. A new note or edit means stale results from `zk list`, `zk graph`, or any MCP/LSP layer over zk — until you remember to run `zk index`. This tool runs `zk index` for you across every notebook on your Mac, so queries always return current data.

It works for any number of notebooks scattered across your home directory. You don't list them — the script discovers them by scanning for `.zk/` folders.

## Design choices

- **Polling, not file watching.** `zk index` is incremental and fast (mtime+size checks before re-parsing). On idle systems, a full cycle is well under a second of CPU and ~zero SSD writes. Polling is bulletproof across sleep/wake, immune to fswatch wedges, and trivial to debug.
- **Conservative allowlist by default, opt-in to broader scans.** Default scans common notebook locations (`~/Documents`, `~/Desktop`, `~/notes`, `~/Notes`, `~/Obsidian`, `~/Vault`). Override with `ZK_REINDEX_ROOTS=/path1:/path2`. Even with smart exclusions, scanning `~/dev` (with hundreds of cloned repos) takes 5-10s per cycle — `find` has to list every directory it doesn't prune, regardless of whether it's looking for `.zk`. The allowlist keeps the no-op cost under ~1 second on real workstations.
- **Smart exclusions for any path being scanned.** Within whatever roots you pick, prunes at directory boundaries: `~/Library`, VM disks, container caches, `node_modules`, language tool caches, Apple media bundles, sync mounts. Keeps walks of large user dirs manageable.
- **Stateless.** Each cycle is a fresh `find`. Add a notebook anywhere with `zk init` and it's picked up on the next cycle — no service restart.
- **Nested-notebook dedup.** If notebook B is inside notebook A (e.g. a git submodule that's itself a notebook clone), only A is reindexed.

## Install

```bash
git clone https://github.com/<your-username>/zk-reindex-launchd.git ~/dev/zk-reindex-launchd
cd ~/dev/zk-reindex-launchd

# 1. Install the script
mkdir -p ~/.local/bin
install -m 755 bin/zk-reindex-all ~/.local/bin/zk-reindex-all

# 2. Generate and install the LaunchAgent plist
mkdir -p ~/Library/LaunchAgents ~/Library/Logs
sed "s|__HOME__|$HOME|g" launchd/com.zk-reindex-all.plist \
  > ~/Library/LaunchAgents/com.zk-reindex-all.plist

# 3. Bootstrap the LaunchAgent (also runs immediately due to RunAtLoad)
launchctl bootstrap gui/$(id -u) \
  ~/Library/LaunchAgents/com.zk-reindex-all.plist
```

Verify:

```bash
# Should show the LaunchAgent
launchctl list | grep zk-reindex-all

# Tail the log to see reindexes happen
tail -f ~/Library/Logs/zk-reindex-all.log
```

## Uninstall

```bash
launchctl bootout gui/$(id -u) \
  ~/Library/LaunchAgents/com.zk-reindex-all.plist

trash ~/Library/LaunchAgents/com.zk-reindex-all.plist
trash ~/.local/bin/zk-reindex-all
trash ~/Library/Logs/zk-reindex-all.log
```

## Configuration

### Primary: config file with per-root depth

`~/.config/zk-reindex-launchd/notebooks.conf` (created automatically if you run `bin/install.sh`, or hand-author it):

```
# zk-reindex-launchd: notebooks to reindex
# Format: <path>[:<maxdepth>]
# Lines starting with # are comments; blank lines are ignored.

# Canonical knowledge base — depth 2 catches <root>/.zk and <root>/<sub>/.zk
/Users/me/admin-technical:2

# Obsidian vault — full-depth scan
/Users/me/Obsidian

# Active dev projects — only catch <project>/.zk, skip repo subtrees
/Users/me/dev:2
```

**Hot-reloadable:** edits take effect on the next cycle, no `launchctl` reload needed.

**Why per-root depth?** Some roots have notebooks at known depth (e.g., `~/dev/<project>/.zk`); descending arbitrarily into project subtrees is wasted work and slows the scan from ~200 ms to multiple seconds. Set `maxdepth=2` for those. Use no depth for vaults where notebooks may be nested arbitrarily.

### Fallback: env vars

If no config file exists, the script reads:

| Variable | Default | Effect |
|---|---|---|
| `ZK_BIN` | `zk` on PATH | Path to the `zk` binary |
| `ZK_REINDEX_CONFIG` | `~/.config/zk-reindex-launchd/notebooks.conf` | Override config file path |
| `ZK_REINDEX_ROOTS` | (built-in defaults) | Colon-separated roots, no per-root depth |
| `ZK_REINDEX_EXCLUDES` | (none) | Extra paths to prune (merged with built-in list) |

Built-in defaults (when neither config file nor `ZK_REINDEX_ROOTS` is set):
`~/Documents`, `~/Desktop`, `~/notes`, `~/Notes`, `~/Obsidian`, `~/Vault`.

Resolution order: **config file → `ZK_REINDEX_ROOTS` → defaults**. The first one set wins.

## Built-in exclusion list

These paths under `$HOME` are pruned at the directory boundary — never descended into:

```
~/Library                    # Apple-managed system data, app prefs, iCloud cache, Mail
~/Pictures                   # Photos.app library, Photo Booth, etc. (Apple bundles)
~/Music                      # Apple Music, iTunes, GarageBand libraries
~/Movies                     # iMovie, TV.app, Final Cut libraries
~/Applications               # User-installed apps
~/Public, ~/Sites            # Legacy macOS share folders
~/Downloads                  # Transient files
~/.Trash, ~/.Trashes         # Trash variants
~/.tmutil                    # Time Machine local snapshots
~/.dropbox.cache             # Dropbox sync cache
# VMs and container disk images — can be tens of GB
~/.lume, ~/.tart, ~/.utm, ~/.colima, ~/.lima
~/.orbstack, ~/OrbStack
~/Parallels
~/VirtualBox VMs
~/.vagrant.d
```

These directory names are pruned at any depth:

```
.git .hg .svn
node_modules .npm .pnpm-store .yarn
.cargo .rustup .gem .nvm .rvm .pyenv
.gradle .m2 .ivy2 .sbt
.docker .vagrant .android
.venv venv __pycache__ .pytest_cache .mypy_cache .ruff_cache .ipynb_checkpoints
target build dist out .next .nuxt .svelte-kit .turbo
.cache .ccache .terraform
```

These name globs are also pruned (Apple "package" bundles and similar):

```
*.photoslibrary *.musiclibrary *.tvlibrary *.imovielibrary
*.fcpbundle *.logicx *.band *.aplibrary
*.graffle *.ooutline *.oplx
*.xcworkspace *.xcodeproj
```

## Costs

On a 128 GB workstation with ~835 notes in one notebook, a typical no-op cycle:

- ~50–100 ms of CPU time
- 0 bytes written to disk
- ~1 KB read (mtime checks on changed files only)

This is well below the noise floor of macOS background work (Spotlight `mds`, Time Machine `backupd`, iCloud sync). Cycle every 60 s = ~1 minute of CPU per day, which is nothing.

When something changes, the cost is bounded by what changed: zk re-parses changed files and updates SQLite FTS rows. Still well under a second for typical edits.

## Roadmap / things left out

- **macOS only** for now. The script is portable bash, but the install path uses launchd. Linux users can adapt the script behind a systemd timer.
- **No event-driven mode.** Polling is the right default; if sub-10s latency matters for your workflow, run a Python `watchdog` supervisor as a separate LaunchAgent — they don't conflict.
- **No CLI flags.** Configuration is via env vars only. Keep it simple.

## License

MIT — see [LICENSE](LICENSE).
