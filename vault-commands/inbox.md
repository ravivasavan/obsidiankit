---
description: Process inbox/ notes — classify, file into wiki, archive originals.
---

Process every `.md` file in `inbox/` (not including `inbox/_archive/` or `inbox/README.md`).

**Hard rules:**
- You may **move** inbox files (via Bash `mv`) but never **edit** them.
- Every fact you promote into the wiki must cite the inbox note in its `sources:` frontmatter as `inbox/_archive/<date>/<original-filename>`.

**Procedure per note:**

1. Read the note. Classify as one of: `concept`, `entity`, `source-note` (a pointer to external material already in `sources/`), `question` (no answer yet), or `journal` (personal — **do not promote**, move straight to archive).
2. For `concept` / `entity`: merge into the matching `wiki/concepts/<slug>.md` or `wiki/entities/<slug>.md`. Create the page if it doesn't exist.
3. For `source-note`: update the corresponding `wiki/sources/<topic>/<slug>.md` with the new observation — or, in vaults without a `wiki/sources/` layer, update the concept/entity pages that cite that source.
4. For `question`: append to `wiki/open-questions.md` (create if needed), tagged by topic.
5. For `journal`: do not read deeply, do not quote, just move.
6. After promotion, move the original to `inbox/_archive/YYYY-MM-DD/<original-filename>` (today's date).
7. Append a summary line to `wiki/log.md`.

**Report:** notes processed, where each one went. Keep it terse.
