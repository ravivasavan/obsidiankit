---
description: Health check the wiki — broken links, orphans, stubs, contradictions, new-article candidates.
---

Run a read-mostly health check over `wiki/`. **Flag, don't fix.** The human decides what to act on. Skip checks for layers this vault doesn't have (e.g. no `wiki/sources/`, no `wiki/overview.md`).

**Checks:**

1. **Broken wikilinks** — every `[[target]]` should resolve to an existing page. List unresolved targets with the pages that reference them.
2. **Orphan pages** — pages nothing links to. List them.
3. **Missing sources** — any page with `author: agent` but no `sources:` entry, or with `sources:` pointing to a file that doesn't exist.
4. **Stub pages** — agent-authored pages under 100 words. Suggest whether to expand, merge, or delete.
5. **Near-duplicates** — concept/entity pages with overlapping content. Suggest merges; don't merge automatically.
6. **Contradictions** — claims across pages that disagree. List the pages and the conflicting claims verbatim.
7. **New-article candidates** — concepts/entities mentioned across 3+ pages but without their own page.
8. **Stale pages** — `updated` frontmatter older than 90 days on pages whose source files have changed.
9. **Overview drift** — does `wiki/overview.md` still reflect the current wiki? Suggest specific edits (but don't apply — overview is sensitive).

**Output:**
- Write the full report to `wiki/_lint-report.md` (overwriting previous).
- Append a one-line summary to `wiki/log.md` with counts per check.
- Return a short summary in chat: "N broken links, M orphans, K new-article candidates. Full report at wiki/_lint-report.md."

**Do not auto-fix anything.** Exception: you may update `wiki/index.md` since it's mechanical.
