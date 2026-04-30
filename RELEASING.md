# Releasing

Procedure for cutting a new version. ~5 minutes per release.

## 1. Update CHANGELOG.md

Move `## [Unreleased]` content under a new `## [X.Y.Z] - YYYY-MM-DD` heading. Add the new comparison link at the bottom.

## 2. Commit + tag + push

```bash
cd ~/dev/zk-reindex-launchd
git add CHANGELOG.md
git commit -m "chore: release v0.X.Y"
git tag v0.X.Y
git push && git push --tags
```

GitHub auto-generates the tarball at `https://github.com/johntrandall/zk-reindex-launchd/archive/refs/tags/v0.X.Y.tar.gz`.

## 3. Bump the Homebrew formula

```bash
SHA=$(curl -sL "https://github.com/johntrandall/zk-reindex-launchd/archive/refs/tags/v0.X.Y.tar.gz" | shasum -a 256 | awk '{print $1}')
echo "$SHA"

cd /tmp && rm -rf homebrew-tap && \
  git clone https://github.com/johntrandall/homebrew-tap.git && \
  cd homebrew-tap

# Edit Formula/zk-reindex-launchd.rb:
#   - bump url to .../v0.X.Y.tar.gz
#   - replace sha256 with the value above
#   - bump any documented version strings (none currently)

git add Formula/zk-reindex-launchd.rb
git commit -m "zk-reindex-launchd v0.X.Y"
git push
```

## 4. Verify the tap

```bash
brew update
brew upgrade johntrandall/tap/zk-reindex-launchd
brew test johntrandall/tap/zk-reindex-launchd
```

`brew test` runs the formula's `test do` block (no-roots smoke test). Should print "no notebooks under" and exit 0.

## 5. (Optional) Promote the release

If the change is user-visible, mention in the next month's r/Zettelkasten Self-Promotions thread. Only re-post when there's actual news (new feature, real bug-fix, community-requested behavior) — repeating the same announcement reads as spam to subreddit regulars.

## Versioning policy

This project follows Semantic Versioning:

- **MAJOR (1.x.0)** — breaking changes to the config file format, the script's CLI/env contract, or the LaunchAgent label.
- **MINOR (0.x.0)** — new features (new exclusion categories, new env vars, new install paths).
- **PATCH (0.0.x)** — bug fixes, doc tweaks, README/CHANGELOG-only changes.

The script is bash and the plist is XML — there's no compiled artifact, so a "release" is just a git tag + Homebrew formula bump.
