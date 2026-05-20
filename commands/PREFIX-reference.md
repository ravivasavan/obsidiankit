---
description: Capture a pointer to an external resource (dashboard, repo, person, doc, tool) as a tagged Obsidian note, linked from next.md
argument-hint: "[optional kebab-slug — leave blank to derive one]"
---

Capture pointers to things outside the codebase. Use for "the X dashboard is at Y", "bugs go in Linear project Z", "Alex is our US printer contact". This is **where to look**, not **what a term means** (that's `/{{PREFIX}}-glossary`).

**Arguments:** `$ARGUMENTS` — optional kebab-case slug.

## Steps

1. **Determine the project.** cwd basename → vault project. Ask if ambiguous.

2. **Identify the kind.** A reference is one of:
   - `dashboard` — Grafana, Sentry, Linear, observability surfaces
   - `repo` — sibling repos / forks / internal services
   - `person` — contact: who owns X, who to ask about Y
   - `doc` — external documentation, Notion page, Confluence, design doc
   - `tool` — service or CLI in use (Render, Vercel, etc.)
   - `channel` — Slack channel, email alias, mailing list
   - `vendor` — external vendor, printer, partner

   If unclear, ask the user.

3. **Pick a date + slug.** Today as `YYYY-MM-DD`. Slug from `$ARGUMENTS` or derived — usually the resource name (e.g. `linear-ingest-project`, `alex-us-printer`).

4. **Compose the reference note.** Write to:
   ```
   {{VAULT_ROOT}}/sources/projects/<project>/references/<YYYY-MM-DD>-<slug>.md
   ```
   Create the `references/` folder if missing.

   Structure:

   ```markdown
   ---
   tags: [reference, external, <kind>, <area>]
   date: YYYY-MM-DD
   project: <project>
   area: <repo-or-component>
   kind: <dashboard | repo | person | doc | tool | channel | vendor>
   url: <https://… or n/a>
   owner: <person or team, if known>
   related: [[<other-slug>]]
   ---

   # <Resource name — short>

   ## TL;DR
   What this is and when to consult it. One sentence.

   ## Where
   The URL, repo path, Slack channel, person's email — whatever locator gets you there. Plural if there's both a UI and an API endpoint.

   ## What it's for
   What you can find / do here that you can't elsewhere. Be specific.

   ## When to consult
   The trigger conditions — "before deploying changes to the request path", "when a partner asks about X", "every Monday standup".

   ## Owner / contact
   Who owns this resource or knows its quirks. Include Slack handle or email if relevant. For person-kind references, the person *is* the resource — capture role, time zone, and how they prefer to be reached.

   ## Notes
   Quirks, gotchas, access requirements, login flow — anything not obvious from the URL.
   ```

   Tags: always `reference` + `external` + the `kind` value + area tags. Hierarchical tags help (`#external/vendor`, `#external/dashboard`).

5. **Link from `next.md`.** `next.md` lives at `{{VAULT_ROOT}}/journal/<project>/next.md` (human-write session-state zone, excluded from vault ingestion). Add under the `## References` section at the top of that file (create the section just below `## Preferences` if missing). Bare-slug wikilink — no `references/` prefix:

   ```markdown
   ## References
   - [[<slug>|<resource name>]] — <kind> · #tag1 #tag2
   ```

6. **Confirm to the user.** Report the file path, kind, URL captured, and `next.md` line.

## Skip / refuse cases

- **Don't write a reference for an internal repo file.** That's just code — point to it via path:line in conversation. References are for things *outside* the current codebase.
- **Don't write references for resources that aren't load-bearing.** A random article you skimmed isn't a reference; the dashboard that pages oncall is.
- **Don't duplicate existing references.** Check `references/` first; if one exists for the same resource, update it instead.
- If the "resource" is actually a project-internal term (e.g. "CR80 means…"), redirect to `/{{PREFIX}}-glossary`.
