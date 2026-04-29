# Publication plan

Where this tool is announced, what's been done, and what's next. Maintained as the project evolves.

## Channels

| Channel | Audience | Status | Last action | Notes |
|---|---|---|---|---|
| GitHub repo (`johntrandall/zk-reindex-launchd`) | Anyone landing via search/links | ✅ live | 2026-04-29 | Public, MIT, README leads with brew install |
| Homebrew tap (`johntrandall/homebrew-tap`) | macOS Homebrew users | ✅ live | 2026-04-29 | `brew audit --strict --new` passes; `brew test` passes |
| awesome-zettelkasten | Zettelkasten community discovering tools | ⏳ PR open | 2026-04-29 | [PR #8](https://github.com/fhoehl/awesome-zettelkasten/pull/8) addition; [PR #9](https://github.com/fhoehl/awesome-zettelkasten/pull/9) link fix (separate) |
| zk-org/zk Discussion ([#700](https://github.com/zk-org/zk/discussions/700)) | zk community | ✅ posted | 2026-04-29 | "Share" category, modest tone |
| r/Zettelkasten Self-Promo monthly thread | Zettelkasten users on Reddit | ✅ posted Apr | 2026-04-29 | Comment in [Apr 2026 thread](https://www.reddit.com/r/Zettelkasten/comments/1s9yh59/comment/oiz0et8/). Posted as `johntrandall`. |
| `koei-kaji/zk-mcp` README | (was) MCP wrapper users | ❌ blocked | 2026-04-29 | Upstream archived 2026-01-01. Author replaced it with `koei-kaji/zk-utils` — see next row. |
| `koei-kaji/zk-utils` README | Users of the maintained MCP wrapper successor | ⏳ PR open | 2026-04-29 | [PR #9](https://github.com/koei-kaji/zk-utils/pull/9). Highest precision channel — these users hit the staleness problem this tool solves. |
| r/macapps | macOS dev-tool users | ⏳ planned | — | Top-level post; johntrandall account |
| Show HN | Generalist tech audience | ⏳ planned (low expectation) | — | Cheap submission; flop is acceptable |
| lobste.rs | Unix/macOS dev tooling | ❌ skip unless invited | — | Requires invite |
| r/commandline | CLI tool users | 🟡 maybe | — | Lower precision than r/macapps; revisit if traction |
| awesome-macos lists | Long-tail discoverability | 🟡 later | — | Find a maintained list, PR after some traction |
| r/ObsidianMD | Obsidian users | ❌ skip | — | Off-topic; mod-removal risk |
| r/SelfHosted | Self-hosters | ❌ skip | — | This is a CLI, not a service |
| r/programming | Generic | ❌ skip | — | Too generic, vote-throttled |
| dev.to / Medium long-form | "Why I built this" | ❌ skip unless writing | — | High effort vs payoff |
| Twitter/Bluesky/Mastodon | Whoever follows | ❌ skip unless following exists | — | Low signal otherwise |

## Cadence rules

### Monthly Self-Promo threads (r/Zettelkasten)
A fresh `<Month> <Year> Self-Promotions | Tools, Books, and Courses` thread is auto-posted by AutoModerator on the 1st of each month at ~21:45 UTC.

- **Default:** post once per release cycle, not once per month. If `v0.2.0` shipped this month with real changes, post in this month's thread mentioning what's new. Otherwise let the prior month's comment stand.
- **Anti-pattern:** repeating the same announcement every month — reads as spam to regulars and may attract mod attention.

### Top-level posts in any sub
- **Read the rules first.** r/Zettelkasten Rule 13 forces tool announcements into the monthly Self-Promo thread; r/macapps allows top-level. Never assume.
- **Once per major release** is the implicit rule everywhere. Don't re-post the same content if nothing's changed.

### "Best place to spend marketing effort"
**The koei-kaji/zk-utils README mention.** Anyone running an MCP wrapper over zk has the *exact* problem this tool solves. A single inline reference in those docs outperforms a dozen Reddit posts because it's there at the moment of need. (Originally targeted `koei-kaji/zk-mcp`, but that repo was archived 2026-01-01; the same author's `zk-utils` is the active successor.)

## Account routing

- **`johntrandall`** — developer/professional handle, used for all tool announcements above. Brand-coherent with the GitHub identity.
- **`johnrover`** — personal handle, never used for tool announcements.
- **`johnrandall`** (no t) — retired 2026-04-29.

See `~/.claude/projects/-Users-johnrandall-admin-technical/memory/reference-reddit-handles.md`.

## Field-report style retro

Brief notes from the v0.1.0 launch (2026-04-29):

- **Worked:** the modest tone in the zk-org Discussion (no "first of its kind" claims) — the prior-art research established that ad-hoc `fswatch | xargs zk index` recipes already exist; this tool is a packaged, tuned version, not a novel idea.
- **Worked:** splitting the awesome-zettelkasten PR into two commits (addition + link fix) so the link-correctness fix isn't blocked on review of the new entry.
- **Lesson:** Reddit r/Zettelkasten Rule 13 was easy to miss on a quick read. Always scan sidebar rules *before* drafting a post — the comment textbox on the submit page hides them.
- **Lesson:** Reddit's comment editor is Lexical (rich-text), not a plain `<textarea>`. `fill_form` via DevTools sets a no-op `value` that doesn't persist; use `type_text` (keystroke simulation) for Reddit comment composition.
