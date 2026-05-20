---
description: Capture an architectural / design decision (ADR-style) as a tagged Obsidian note in the current project's vault, linked from next.md
argument-hint: "[optional kebab-slug — leave blank to derive one]"
---

Capture a decision (architectural, design, vendor, scope, etc.) as a standalone tagged note in the project's Obsidian vault. Use this when picking between approaches and the *rationale* would be useful to revisit later.

**Arguments:** `$ARGUMENTS` — optional kebab-case slug. If blank, derive a short descriptive slug from the conversation context (e.g. `postgres-vs-sqlite-for-dev`, `single-pr-vs-split-refactor`).

## Steps

1. **Determine the project.** cwd basename → lowercase → map to `{{VAULT_ROOT}}/sources/projects/<project>/`. If ambiguous, ask. Don't guess silently.

2. **Pick a date + slug.** Today as `YYYY-MM-DD`. Slug from `$ARGUMENTS` or derived. Keep it short and kebab-case. If the project uses ADR numbering (look for existing `decisions/NNNN-*.md`), continue the sequence: `NNNN-<slug>.md` instead of date-prefixed.

3. **Compose the decision note.** Write to:
   ```
   {{VAULT_ROOT}}/sources/projects/<project>/decisions/<YYYY-MM-DD-or-NNNN>-<slug>.md
   ```
   Create the `decisions/` folder if missing.

   Structure:

   ```markdown
   ---
   tags: [decision, adr, <area>, <area>/<subarea>]
   date: YYYY-MM-DD
   project: <project>
   area: <repo-or-component>
   status: <proposed | accepted | superseded | deprecated>
   supersedes: [[<slug>]]      # optional
   superseded-by: [[<slug>]]   # optional, fill in later
   related: [[<other-slug>]]
   ---

   # <Short imperative title — the decision itself>

   ## TL;DR
   One sentence: what we decided.

   ## Context
   The situation that required a decision. What constraints / pressures / requirements drove it?

   ## Decision
   What we chose, stated as a directive ("Use X. Don't use Y."). Include any scope limits.

   ## Alternatives considered
   Each alternative with one or two lines on why it was rejected. List at least 2 — if there was no real alternative, this probably isn't a decision worth recording.

   ## Consequences
   What this enables. What it forecloses. What follow-up work it implies. Any debt accepted.
   ```

   Tags should reflect the **area** of the decision. Always include `decision` and `adr`. Add area-specific tags (`#frontend`, `#api`, `#infra`, etc.). If the decision affects a vendor or external party, tag `#vendor` or `#external`.

4. **Link from `next.md`.** `next.md` lives at `{{VAULT_ROOT}}/journal/<project>/next.md` (human-write session-state zone, excluded from vault ingestion). Add the entry under the `## Decisions` section at the top of that file (create the section just below `## Lessons` if missing). Use a **bare-slug** wikilink (no `decisions/` prefix — Obsidian resolves by basename):

   ```markdown
   ## Decisions
   - [[<slug>|<short title>]] — <status> · #tag1 #tag2
   ```

5. **Confirm to the user.** Report the file path, the status field, the alternatives listed, and the `next.md` line added.

## Skip / refuse cases

- If the conversation is exploring options but hasn't actually settled on one, **don't write a decision**. Offer to draft it once a choice is made, or write it with status `proposed` and flag that explicitly.
- If the "decision" is trivially obvious or doesn't have real alternatives, don't write it. Decisions earn a note by being genuinely contested choices.
- If the conversation contains multiple distinct decisions, write **separate files** — one per decision — not a combined note.
