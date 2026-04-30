# Outreach — zk-reindex-launchd

Tracks where this project has been announced or discussed publicly, what's awaiting response, and the cadence rules for re-engagement. Schema follows `~/admin-technical/conventions/outreach-tracking.md`.

## Project metadata

- **Repo**: <https://github.com/johntrandall/zk-reindex-launchd>
- **Public since**: 2026-04-29
- **Maintainer handle (default)**: `johntrandall` on GitHub, Reddit, Hacker News
- **License**: MIT

## Channels

Status vocabulary: ✅ resolved · ⏳ open · 📅 scheduled · 🚩 needs-followup

| URL | Status | Posted | Last checked | Account | Notes |
|---|---|---|---|---|---|
| <https://github.com/johntrandall/zk-reindex-launchd> | ✅ resolved | 2026-04-29 | 2026-04-30 | johntrandall | Repo public, MIT, v0.1.0 tagged |
| <https://github.com/johntrandall/homebrew-tap> | ✅ resolved | 2026-04-29 | 2026-04-30 | johntrandall | Tap public; `brew audit --strict --new` + `brew test` pass |
| <https://github.com/fhoehl/awesome-zettelkasten/pull/8> | ⏳ open | 2026-04-29 | 2026-04-30 | johntrandall | Add zk-reindex-launchd to Misc section |
| <https://github.com/fhoehl/awesome-zettelkasten/pull/9> | ⏳ open | 2026-04-29 | 2026-04-30 | johntrandall | Fix existing `[zk]` link → zk-org/zk |
| <https://github.com/koei-kaji/zk-utils/pull/9> | ⏳ open | 2026-04-29 | 2026-04-30 | johntrandall | README freshness note + corrective followup comment |
| <https://github.com/zk-org/zk/discussions/700> | ⏳ open | 2026-04-29 | 2026-04-30 | johntrandall | Share-category post + corrective followup comment |
| <https://www.reddit.com/r/Zettelkasten/comments/1s9yh59/comment/oiz0et8/> | ⏳ open | 2026-04-29 | 2026-04-30 | johntrandall | Apr Self-Promo top-level comment (edited via Markdown mode after rendering bugs) |
| <https://www.reddit.com/r/Zettelkasten/comments/1s9yh59/comment/oizf5v0/> | ⏳ open | 2026-04-29 | 2026-04-30 | johntrandall | Followup reply with corrected pitch + zk-utils relationship |
| <https://www.reddit.com/r/Zettelkasten/comments/1s9yh59/comment/oj5kry9/> | ⏳ open | 2026-04-30 | 2026-04-30 | johntrandall | Reply to u/Barycenter0's glossary question; promised README glossary (delivered same day) |
| r/Zettelkasten May 2026 Self-Promo (auto-posts ~2026-05-01) | 📅 scheduled | — | — | johntrandall | OmniFocus task scheduled. Skip if no v0.X update since April. |
| r/macapps top-level post | 📅 scheduled | — | — | johntrandall | OmniFocus task. Verify sub rules first; stagger ~1 wk from Show HN. |
| Show HN | 📅 scheduled | — | — | johntrandall | OmniFocus task. Cheap submission; flop is acceptable. Best window: weekday 9-11am ET. |

## Cadence rules

- **Monthly Self-Promo threads**: post once per release cycle, not once per month. Only re-post when there's actual news (new version, real feature, community-requested fix). Reposting the same announcement reads as spam to regulars.
- **Top-level posts on any sub**: read sub rules first (r/Zettelkasten Rule 13 forces tools into the monthly Self-Promo thread; r/macapps allows top-level). Once-per-major-release is the implicit ceiling.
- **GitHub PRs / Discussions**: respond to maintainer questions promptly; otherwise let them mature. Don't bump.
- **Reddit replies**: respond to genuine questions within 24-48h. Genuine questions are gifts — they reveal accessibility gaps in the README.

## Account routing

- **Tool announcements, technical discussion, anything tied to the GitHub identity**: `johntrandall`
- **Personal opinions, lifestyle subreddits**: `johnrover` (never used for this project)

See `~/.claude/projects/-Users-johnrandall-admin-technical/memory/reference-reddit-handles.md` for full handle policy.

## Drafts (proposed but not yet posted)

### r/macapps top-level post

> **Title**: zk-reindex-launchd: a 50-line macOS LaunchAgent that keeps your zk note index fresh
>
> **Body**: re-use the Reddit Apr Self-Promo comment with macapps-appropriate framing — emphasize macOS LaunchAgent, less zk-jargon (link to README glossary).

### Show HN

> **Title**: Show HN: zk-reindex-launchd – auto-reindex zk notebooks on macOS via LaunchAgent
>
> **Body**: 1-paragraph "why I built this" — multiple AI agents writing markdown directly need fresh `zk list --link-to`, `zk graph` results without manual `zk index`. Pure zk-utils-MCP users don't need this; it fills the gap for mixed-tool workflows.

## Field-report style retro

v0.1.0 launch (2026-04-29):

- **Worked**: modest tone in the zk-org Discussion (no "first of its kind" claims). Prior-art research established that ad-hoc `fswatch | xargs zk index` recipes already exist; this tool is a packaged, tuned version, not novel.
- **Worked**: split awesome-zettelkasten PR into two commits (addition + link fix) so link-correctness fix isn't blocked on review of the new entry.
- **Lesson**: Reddit r/Zettelkasten Rule 13 was easy to miss on a quick read. Always scan sidebar rules *before* drafting — the comment textbox on the submit page hides them.
- **Lesson**: Reddit's comment editor is Lexical (rich-text), not a plain textarea. Use the **Markdown mode toggle** + MCP `fill` tool. Never `type_text` in default WYSIWYG mode. See skill `reddit-comment-authoring`.
- **Lesson**: Audience-test the README. u/Barycenter0's glossary question was a gift that exposed a real accessibility gap (delivered glossary same day).
