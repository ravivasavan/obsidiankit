---
description: Ingest sources/ into the wiki — compile summaries, extract concepts/entities, wire backlinks.
argument-hint: "[topic]"
---

Ingest raw source material into the wiki.

**Scope:** $ARGUMENTS (if empty, walk all of `sources/`; otherwise restrict to `sources/<topic>/`). `<topic>` is any subfolder of `sources/` — project folders in multi-project vaults, category folders (`decisions/`, `lessons/`, …) in single-project team vaults.

**Vault layers:** check whether this vault maintains a `wiki/sources/` per-source summary layer.
- **Layer present** → follow the procedure below as written.
- **Layer absent** (single-project team vaults drop it deliberately, to keep one note per name) → skip the summary pages entirely: compile concepts/entities *directly* from raw sources, citing raw paths in `sources:` frontmatter. A source counts as already-ingested when at least one wiki page cites it and that page's `updated` is not older than the source file's mtime. Never create `wiki/sources/` in a vault that doesn't have it.

**Hard rules (from CLAUDE.md):**
- Never edit anything in `sources/`, `journal/`, or human-authored files in `inbox/`.
- Every page you create must carry `author: agent` frontmatter and cite its sources in `sources:`.
- Use Obsidian `[[wikilinks]]`, never relative paths.

**Procedure:**

1. List files in scope. Diff against `wiki/sources/<topic>/` — skip already-summarized sources unless their mtime is newer than the corresponding wiki page.
2. For each new/updated source:
   - Read it. Produce `wiki/sources/<topic>/<slug>.md` with: one-paragraph summary, key claims (bulleted), extracted concepts, extracted entities, `## Sources` backlink.
   - For every extracted concept not already in `wiki/concepts/`, create a stub page with the definition and a `[[wikilink]]` back to the source page.
   - Same for entities → `wiki/entities/`.
   - For existing concept/entity pages, append new claims and update the `sources:` frontmatter list.
3. Update `wiki/index.md` — the catalog of every page, grouped by type.
4. Append an entry to `wiki/log.md` with timestamp, scope, files processed, pages created, pages updated.
5. Report back: counts only (X sources ingested, Y concepts created, Z entities touched). Flag anything suspicious — unclear claims, duplicate concepts that might want merging, sources you couldn't parse.

**Do not:**
- Auto-merge near-duplicate pages — flag them in the report instead.
- Fabricate connections. If two concepts aren't clearly related in the sources, don't link them.
- Touch `wiki/overview.md` — that's a separate `/lint` concern.
