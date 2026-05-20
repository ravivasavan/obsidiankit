---
description: Define a project term, acronym, or domain concept as a tagged Obsidian note, linked from next.md
argument-hint: "[term — required, e.g. CR80 or 'die cut line']"
---

Define vocabulary specific to the project — acronyms, domain terms, internal jargon, standard references. Use when you find yourself explaining the same term twice, or when ramping a new collaborator would require a definition.

**Arguments:** `$ARGUMENTS` — the term being defined. Required. The slug derives from this: lowercase, replace spaces/punctuation with hyphens (e.g. `CR80` → `cr80`, `die cut line` → `die-cut-line`).

## Steps

1. **Determine the project.** cwd basename → vault project. Ask if ambiguous.

2. **Validate the term.** If `$ARGUMENTS` is empty, ask the user what term to define. Don't guess from context — the term is the whole point of a glossary entry.

3. **Pick the slug.** Lowercase the term, replace non-alphanumeric with hyphens, collapse repeated hyphens. Example: `ISO/IEC 7810 ID-1` → `iso-iec-7810-id-1`.

4. **Compose the glossary note.** Write to:
   ```
   {{VAULT_ROOT}}/sources/projects/<project>/glossary/<slug>.md
   ```
   Create the `glossary/` folder if missing.

   No date prefix — glossary entries are timeless and identified by the term, not when it was defined. The frontmatter still includes `date` for the original capture.

   Structure:

   ```markdown
   ---
   tags: [glossary, vocabulary, <area>]
   date: YYYY-MM-DD
   project: <project>
   area: <repo-or-component>
   term: <the term, as the user uses it>
   aliases: [<other spellings, synonyms, expansions>]
   see-also: [[<related-term-slug>]]
   ---

   # <Term>

   ## Definition
   The shortest accurate definition. One or two sentences. Resist the urge to give history first — start with what the term *means*.

   ## In context
   How the term shows up in the project: where it appears, what it triggers, why it matters. Concrete examples or filename references welcome.

   ## Standard / source
   If the term comes from an external standard (ISO, RFC, industry convention, vendor doc), cite it. Otherwise, note "internal" and where the convention originated (a decision, a person, a vendor conversation).

   ## Don't confuse with
   Related terms that are subtly different, with the distinction stated. This is where glossary entries earn their keep — disambiguating things that *look* the same.
   ```

   Tags: always `glossary` + `vocabulary` + area tags. If the term comes from a standard, add `#standard`.

5. **Link from `next.md`.** `next.md` lives at `{{VAULT_ROOT}}/journal/<project>/next.md` (human-write session-state zone, excluded from vault ingestion). Add under the `## Glossary` section at the top of that file (create just below `## References` if missing). Glossary lines are terse — just the term and one-line definition. Bare-slug wikilink — no `glossary/` prefix:

   ```markdown
   ## Glossary
   - [[<slug>|<Term>]] — <one-line definition>
   ```

   No tags in the next.md line for glossary entries — the linked note has them, and the inline definition is what matters here.

6. **Confirm to the user.** Report the file path, the definition you wrote, and any `see-also` entries you linked.

## Skip / refuse cases

- **Don't write a glossary entry for a term defined plainly in code or config.** If `MAX_RETRIES = 3` is in the code, it's not glossary-worthy. Glossary is for terms whose meaning isn't obvious from where they appear.
- **Don't write a glossary entry for something that's really a reference.** "Linear" isn't a glossary term; the Linear-INGEST project is a reference. Acronyms / specifications / domain concepts → glossary. Tools / services / people → reference.
- If the term already exists in `glossary/`, update the existing file instead of creating a duplicate. Surface the existing definition and ask whether to revise.
