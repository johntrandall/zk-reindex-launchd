# zk-reindex-launchd

A set-and-forget background reindexer for [zk](https://github.com/zk-org/zk) (the plain-text Zettelkasten CLI) on macOS. One LaunchAgent quietly runs [`zk index`](https://zk-org.github.io/zk/notes/note-frontmatter.html) across every notebook on your Mac on a schedule. Install once, edit your notes for years, never think about indexing again.

## Why

[`zk index`](https://github.com/zk-org/zk) is incremental and fast — but it's manual. Every edit you make is invisible to `zk list`, `zk graph`, the [zk LSP](https://zk-org.github.io/zk/tips/editors-integration.html), or any MCP/agent layer over zk until you remember to run `zk index`. With one notebook that's annoying. With several scattered across your Mac (a writing vault, a research notebook, project-level ADR repos, an Obsidian vault) it's a constant low-grade tax.

**The set-and-forget pattern:**

1. `zk init` your notebooks wherever they live.
2. List them once in `~/.config/zk-reindex-launchd/notebooks.conf` (one path per line, optional `:maxdepth`).
3. Install the LaunchAgent.
4. **Done.** From now on, every query — `zk list --link-to ADR-000.md`, an MCP server's `get_linking_notes`, your editor's LSP backlinks — sees a current index. You never type `zk index` again.

The agent polls every 5 minutes (configurable). Idle cost is ~200ms wall time and zero SSD writes per cycle — well below the noise floor of macOS background work like Spotlight, Time Machine, or any cloud sync.

## What it solves vs. what it doesn't

| Solves | Doesn't solve |
|---|---|
| Stale `zk index` after edits | Editing/authoring notes (use your editor) |
| Notebooks scattered across folders | Cross-notebook queries (zk is per-notebook) |
| Forgetting to reindex after `git pull` | Real-time sub-second freshness (use a file watcher if you need that) |
| Running `zk index` on N machines | Syncing the notebook itself (use git, iCloud, etc.) |

## Design choices

- **Polling, not file watching.** `zk index` is incremental and fast (mtime+size checks before re-parsing). On idle systems, a full cycle is well under a second of CPU and ~zero SSD writes. Polling is bulletproof across sleep/wake, immune to fswatch wedges, and trivial to debug.
- **Conservative allowlist by default, opt-in to broader scans.** Default scans common notebook locations (`~/Documents`, `~/Desktop`, `~/notes`, `~/Notes`, `~/Obsidian`, `~/Vault`). Override with `ZK_REINDEX_ROOTS=/path1:/path2`. Even with smart exclusions, scanning `~/dev` (with hundreds of cloned repos) takes 5-10s per cycle — `find` has to list every directory it doesn't prune, regardless of whether it's looking for `.zk`. The allowlist keeps the no-op cost under ~1 second on real workstations.
- **Smart exclusions for any path being scanned.** Within whatever roots you pick, prunes at directory boundaries: `~/Library`, VM disks, container caches, `node_modules`, language tool caches, Apple media bundles, sync mounts. Keeps walks of large user dirs manageable.
- **Stateless.** Each cycle is a fresh `find`. Add a notebook anywhere with `zk init` and it's picked up on the next cycle — no service restart.
- **Nested-notebook dedup.** If notebook B is inside notebook A (e.g. a git submodule that's itself a notebook clone), only A is reindexed.

## Install

### Homebrew (recommended)

```bash
brew tap johntrandall/tap
brew install johntrandall/tap/zk-reindex-launchd
brew services start johntrandall/tap/zk-reindex-launchd
```

The formula seeds a starter config at `~/.config/zk-reindex-launchd/notebooks.conf`, declares a dependency on `zk`, and registers the LaunchAgent via `brew services`.

### Manual

```bash
git clone https://github.com/johntrandall/zk-reindex-launchd.git
cd zk-reindex-launchd
./install.sh
```

The installer:

- Installs `bin/zk-reindex-all` to `~/.local/bin/`
- Renders the plist template into `~/Library/LaunchAgents/com.zk-reindex-all.plist` (substituting `__HOME__` for your real `$HOME`)
- Seeds a starter `~/.config/zk-reindex-launchd/notebooks.conf` if you don't have one
- Bootstraps the LaunchAgent (idempotent — re-run anytime to re-install)

Then edit your config:

```bash
$EDITOR ~/.config/zk-reindex-launchd/notebooks.conf
# Add one line per notebook root: <absolute path>[:<maxdepth>]
# Saves take effect on the next cycle — no reload needed.
```

Verify:

```bash
launchctl list | grep zk-reindex-all
tail -f ~/Library/Logs/zk-reindex-all.log
```

## Uninstall

If installed via Homebrew:

```bash
brew services stop johntrandall/tap/zk-reindex-launchd
brew uninstall zk-reindex-launchd
brew untap johntrandall/tap   # optional, if no other formulae from this tap
```

If installed manually:

```bash
./uninstall.sh           # keeps your notebooks.conf
./uninstall.sh --purge   # also removes ~/.config/zk-reindex-launchd/
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
