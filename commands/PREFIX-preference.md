---
description: Capture a working-style preference as a tagged Obsidian note AND save to Claude memory so future sessions apply it automatically
argument-hint: "[optional kebab-slug — leave blank to derive one]"
---

Capture how the user likes things done. Dual-writes to **Obsidian** (human-readable, browsable) and **Claude memory** (Claude follows it next session without being re-told). Use when you notice yourself being corrected the same way twice, or when the user states an opinion Claude should remember.

**Arguments:** `$ARGUMENTS` — optional kebab-case slug.

## Steps

1. **Determine the project + scope.** cwd basename → vault project. Then **ask the user whether the preference is project-scoped or global**:
   - **Project-scoped** (default) — applies only to this codebase / domain. Memory goes to per-project Claude memory.
   - **Global** — applies across every project. Memory goes into `~/.claude/CLAUDE.md` as a new rule.

2. **Pick a date + slug.** Today as `YYYY-MM-DD`. Slug from `$ARGUMENTS` or derived.

3. **Compose the preference note.** Write to:
   ```
   {{VAULT_ROOT}}/sources/projects/<project>/preferences/<YYYY-MM-DD>-<slug>.md
   ```
   Create the `preferences/` folder if missing.

   Structure:

   ```markdown
   ---
   tags: [preference, <area>, <area>/<subarea>]
   date: YYYY-MM-DD
   project: <project>
   area: <repo-or-component>
   scope: <project | global>
   related: [[<other-slug>]]
   ---

   # <Short imperative title — the preference itself>

   ## TL;DR
   One sentence: the preference, stated as a directive.

   ## Why
   The motivation. What past experience, value, or constraint shaped this? Without the why, future-you will second-guess the rule.

   ## How to apply
   When does this kick in? What does it look like in practice? Code / commit / PR / review examples welcome.

   ## When NOT to apply
   The edge cases or exceptions. Every preference has limits.
   ```

   Tags: always `preference` + area tags. Don't use `#postmortem` — preferences are forward-looking, not incident-driven.

4. **Dual-write to Claude memory.**

   - If scope is **project**: write a feedback memory at `~/.claude/projects/<encoded-cwd>/memory/feedback_<slug>.md` with frontmatter:
     ```markdown
     ---
     name: <slug>
     description: <one-line summary>
     metadata:
       type: feedback
     ---

     <preference body, structured as: rule, then **Why:** and **How to apply:** lines>
     ```
     Then add a line to `MEMORY.md` in that directory: `- [<short title>](feedback_<slug>.md) — <one-line hook>`.

     The `<encoded-cwd>` is derived from the current working directory using Claude Code's path-encoding scheme — find an existing memory dir under `~/.claude/projects/` matching the current project's cwd; it's already there if Claude has been used in this repo before.

   - If scope is **global**: append a new section to `~/.claude/CLAUDE.md` with a clear heading (e.g. `## <Topic> — <directive>`). Use the same body structure (TL;DR, why, how to apply, when not to apply) but adapted to CLAUDE.md's tone. Make it absolute and unambiguous.

5. **Link from `next.md`.** `next.md` lives at `{{VAULT_ROOT}}/journal/<project>/next.md` (human-write session-state zone, excluded from vault ingestion). Add under the `## Preferences` section at the top of that file (create the section just below `## Decisions` if missing). Bare-slug wikilink — no `preferences/` prefix:

   ```markdown
   ## Preferences
   - [[<slug>|<short title>]] — <scope> · #tag1 #tag2
   ```

   For global preferences, also note in the entry that it's reflected in `~/.claude/CLAUDE.md`.

6. **Confirm to the user.** Report all three writes: Obsidian path, Claude memory path (or CLAUDE.md section), and the `next.md` line.

## Skip / refuse cases

- **Don't fabricate preferences.** If the conversation didn't reveal a real opinion or correction, ask the user to state the preference directly.
- If the user has stated something that's actually a **lesson** (postmortem) or **decision** (chose X over Y) — not a working-style preference — redirect to `/{{PREFIX}}-lesson` or `/{{PREFIX}}-decision` instead.
- Don't write contradicting preferences. If a preference already exists in `preferences/` or in `MEMORY.md` that conflicts, surface it and ask whether to update the existing one rather than adding a new one.
