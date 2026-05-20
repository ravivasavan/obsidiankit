---
description: Capture a postmortem-style lesson as a tagged Obsidian note in the current project's vault, linked from next.md
argument-hint: "[optional kebab-slug — leave blank to derive one]"
---

Capture the learning from this session as a standalone tagged note in the project's Obsidian vault, following the global "Lessons" rule in `~/.claude/CLAUDE.md`.

**Arguments:** `$ARGUMENTS` — optional kebab-case slug. If blank, derive a short descriptive slug from the conversation context (e.g. `oauth-refresh-races`, `git-checkout-discards-edits`).

## Steps

1. **Determine the project.** Take the current working directory basename, lowercase it, and map to a folder under `{{VAULT_ROOT}}/sources/projects/<project>/`. If the basename doesn't map cleanly (e.g. `my-app-mobile` → `my-app`), ask the user which vault project this session belongs to. Don't guess silently.

2. **Pick a date + slug.** Today's date (YYYY-MM-DD) as a prefix. Slug from `$ARGUMENTS` or derived from the conversation — keep it short, kebab-case, descriptive.

3. **Compose the lesson.** Write to:
   ```
   {{VAULT_ROOT}}/sources/projects/<project>/lessons/<YYYY-MM-DD>-<slug>.md
   ```
   Create the `lessons/` folder if missing.

   Use this structure (drawn from the global rule):

   ```markdown
   ---
   tags: [postmortem, <area>, <area>/<subarea>, gotcha, ...]
   date: YYYY-MM-DD
   project: <project>
   area: <repo-or-component>
   severity: <low|medium|high>
   related: [[<other-lesson-slug>]]
   ---

   # <Short imperative title>

   ## TL;DR
   One or two sentences. The takeaway, not the story.

   ## What happened
   The incident with concrete evidence — the failing code, the command run, the visible symptom. Quote the actual diff / output where useful.

   ## Root cause
   *Why* it happened, not just *what*. This is the part that survives.

   ## The rule
   The going-forward fix or guideline. Make it actionable. Code snippets welcome.

   ## How to detect / verify
   What to check so it doesn't recur. Tests, assertions, inspectors, manual smoke checks.
   ```

   Pick **semantic tags** for the conversation's topic. Use hierarchical `area/subarea` syntax where it helps:
   - `git`, `git/safety`, `git/binary-files`
   - `python`, `typescript`, `react`, `next`
   - `api`, `api/auth`, `api/rate-limiting`
   - Always include `postmortem` for incidents and `gotcha` for non-obvious behaviors.

   Use Obsidian `[[wikilinks]]` for cross-references, not markdown links. If a related lesson already exists in the same `lessons/` folder, link it in the `related:` frontmatter.

4. **Link from `next.md`.** `next.md` lives at `{{VAULT_ROOT}}/journal/<project>/next.md` (the journal/ tree is the human-write session-state zone; vault ingestion skips it, so it won't be promoted into the wiki). Add (or update) a `## Lessons` section at the **top** of that file, above the active work threads. Each entry is a single line, with a **bare-slug** wikilink (no `lessons/` prefix — Obsidian resolves by basename, which is safer if the file ever moves under sources/):

   ```markdown
   - [[<YYYY-MM-DD>-<slug>|<short title>]] — #tag1 #tag2 #tag3
   ```

   Inline tags after the link make the entry itself searchable. If the section doesn't exist yet, create it just below the `# Next` heading.

5. **Confirm to the user.** Report the file path written, the tags used, and the `next.md` line added. Keep it tight.

## Skip / refuse cases

If the conversation has no clear lesson — i.e. routine task completion, no surprise, nothing worth re-learning — say so and offer to capture something specific instead. Don't fabricate a lesson to satisfy the command.

If there are multiple distinct lessons in one session (e.g. two separate bugs hit), write **separate files** — one per learning — not a combined note. Each gets its own tags and entry in `next.md`.
