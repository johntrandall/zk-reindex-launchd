# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-04-29

### Added
- Initial release.
- `bin/zk-reindex-all` — bash script that auto-discovers `.zk/` notebooks under configured roots and runs `zk index` in each.
- `launchd/com.zk-reindex-all.plist` — template plist for a per-user LaunchAgent (5-minute interval, RunAtLoad, low-priority IO).
- `install.sh` / `uninstall.sh` — idempotent installers. `uninstall.sh --purge` also removes config.
- Per-root `:maxdepth` configuration via `~/.config/zk-reindex-launchd/notebooks.conf` (one path per line, optional `:N` suffix).
- Smart exclusion list: `~/Library`, media folders (Pictures/Music/Movies), VM disks (Tart/Lume/UTM/Colima/Lima/OrbStack/Parallels/VMware/VirtualBox/Vagrant), legacy cloud-sync mount points (Dropbox/OneDrive/Box/pCloud/Tresorit/Sync.com/MEGA/Nextcloud/ownCloud/Resilio/SynologyDrive), language-tool caches, JS framework build caches, k8s/container caches, editor state, ML caches, macOS volume metadata, Apple bundle globs (`*.app`, `*.framework`, `*.xcworkspace`, etc.).
- Homebrew formula at `johntrandall/homebrew-tap` with `service do` block for native `brew services` integration.

[Unreleased]: https://github.com/johntrandall/zk-reindex-launchd/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/johntrandall/zk-reindex-launchd/releases/tag/v0.1.0
