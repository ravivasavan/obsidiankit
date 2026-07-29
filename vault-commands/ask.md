---
description: Answer a question from the wiki and file the answer back as a new page.
argument-hint: "<question>"
---

Answer the following question using the wiki, and **file the answer back** as a new wiki page so future queries build on it.

**Question:** $ARGUMENTS

**Procedure:**

1. Search `wiki/` for relevant pages. Start with `wiki/index.md` (if present), then `wiki/concepts/`, `wiki/entities/`, and `wiki/sources/` where that layer exists. Do not search `journal/` — it's off-limits.
2. If the question cannot be answered from existing wiki content alone:
   - Check `sources/` for unprocessed material that could answer it.
   - If relevant sources exist but aren't in the wiki, note this in the answer and suggest running `/ingest <topic>` first.
   - Do not fabricate. Say "I don't know from the current wiki" if that's the truth.
3. Compose the answer as a new page at `wiki/concepts/<slug-of-question>.md` with frontmatter:
   ```yaml
   ---
   author: agent
   kind: answer
   question: "<the question>"
   created: YYYY-MM-DD
   sources: [<wiki pages and sources/ files cited>]
   tags: [answer, ...]
   ---
   ```
4. The body: direct answer first, then reasoning, then a `## Sources` section with `[[wikilinks]]` to every page you drew from.
5. Update `wiki/index.md` and append to `wiki/log.md`.
6. In chat, summarize the answer in 3-5 lines and link to the new page. Don't dump the whole answer — the point is it lives in the wiki.

**Output format override:** if the question asks for slides, return a Marp-formatted page; if it asks for a chart, save a matplotlib image under `wiki/assets/` and embed it. Default is markdown.
