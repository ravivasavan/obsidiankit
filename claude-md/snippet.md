# Obsidian vault — session continuity and knowledge capture

This section is managed by obsikit. Re-running the installer will overwrite everything between the BEGIN/END markers.

Vault root: `{{VAULT_ROOT}}`
Slash-command prefix: `{{PREFIX}}` (commands appear as `/{{PREFIX}}-lesson`, `/{{PREFIX}}-decision`, etc.)

## Session continuity — always use next.md in the Obsidian vault

**Applies to every project, every session.**

The vault is the single source of truth. `next.md` lives in the Obsidian vault under `journal/` (the human-write session-state zone, excluded from vault ingestion), not in the project repo:

```
{{VAULT_ROOT}}/journal/<project>/next.md
```

`<project>` is the lowercase project name as it appears in the vault. Derive it from:
1. The current working directory basename, lowercased (e.g. `~/code/my-app` → `my-app`).
2. If a matching folder exists at `{{VAULT_ROOT}}/sources/projects/<basename>/` or `{{VAULT_ROOT}}/journal/<basename>/`, use it.
3. If not, check whether the basename clearly maps to an existing vault project (e.g. `my-app-mobile` → `my-app/`). If ambiguous, ask the user which vault project this session belongs to before creating anything new.

At the **start** of every session:
- Read `{{VAULT_ROOT}}/journal/<project>/next.md`.
- If the folder or file doesn't exist (and the project is unambiguous), create them automatically. Don't ask first.
- Briefly acknowledge what's there (current focus, next steps, open questions) so the user knows you've loaded it.

**During** the session:
- Update `next.md` as work progresses — when focus shifts, when a step completes, when a new blocker or open question surfaces. Keep it current, not retrospective.

At the **end** of every session (or when wrapping up a chunk of work):
- Refresh `next.md` so the next session can resume cleanly. Capture: current focus, next steps, blockers, open questions.

Format is free-form notes — no rigid structure. Example shape:

```
# Next

Current focus: <what we're in the middle of>

Next up:
- <step>
- <step>

Open: <questions, blockers, decisions pending>
```

Keep it short and signal-dense. If `next.md` grows stale or contradicts current work, rewrite it rather than appending. Never write `next.md` into the project repo itself.

## Vault knowledge capture — tagged Obsidian notes, linked from next.md

**Applies to every project, every session.**

The Obsidian vault is the long-term knowledge base. Don't bury durable knowledge inside `next.md` — it gets archived with session state. Instead, write standalone tagged notes in the right vault subfolder and link them from the top of `next.md` so they're discoverable both via Obsidian tag search and from the project's current state file.

### Categories — when to use which

Each category has a dedicated slash command under the `/{{PREFIX}}-` namespace. They don't overlap; pick the one that matches the *kind* of knowledge:

| Command | Folder | Use for |
|---|---|---|
| `/{{PREFIX}}-lesson` | `lessons/` | Postmortems, gotchas, bugs that bit us. Non-obvious behaviors we'd re-learn the hard way. Always include `#postmortem`. |
| `/{{PREFIX}}-decision` | `decisions/` | Architectural / design / vendor / scope decisions. ADR-style. Use when picking between approaches and the *rationale* matters. |
| `/{{PREFIX}}-preference` | `preferences/` | How the user likes things done. Working style, opinions, conventions. **Dual-writes to Claude memory** so Claude follows it next session. |
| `/{{PREFIX}}-reference` | `references/` | Pointers to external resources — dashboards, sibling repos, people, vendors, tools, Slack channels. *Where to look.* |
| `/{{PREFIX}}-glossary` | `glossary/` | Project vocabulary, acronyms, domain terms, standards. *What a term means.* |

If a session's knowledge doesn't fit any of these cleanly, write it as a `lesson` (the most flexible category) or ask the user.

### Shared conventions

All notes follow these rules:

**Filename:** `{{VAULT_ROOT}}/sources/projects/<project>/<folder>/<slug>.md` where `<folder>` is the category folder above. Notes live under `sources/` (the human-write input tree) on purpose: anything in there can be picked up by downstream vault tooling (search, ingestion, etc.) that should ignore session scratch. Most categories prefix the slug with the date (`YYYY-MM-DD-<slug>`) for chronological ordering; glossary entries use just the term-derived slug (timeless).

**Frontmatter:** Always YAML, always tagged. Tags drive Obsidian search — pick semantic ones, use hierarchical `area/subarea` syntax where it helps (`api/auth`, `git/safety`, `external/vendor`). Each command's `.md` file in `~/.claude/commands/` spells out the exact frontmatter fields for that category.

**Wikilinks:** Use Obsidian `[[wikilinks]]` (not markdown links) so they survive renames and show up as graph nodes. Cross-reference related notes via the `related:` frontmatter field. In `next.md`, use **bare-slug** wikilinks (e.g. `[[2026-05-19-postgres-connection-pool-exhausted]]`) — no folder prefix — because the category folder is not a sibling of `next.md` (next.md lives in `journal/`, category notes in `sources/projects/...`). Obsidian resolves by basename, and date-prefixed slugs are unique enough.

**Linked from next.md:** Always add a category-specific section at the **top** of the project's `next.md`, above the active work threads. One line per entry, with the wikilink and inline `#tags` so the entry itself is searchable. The five sections in order:

```markdown
## Lessons
## Decisions
## Preferences
## References
## Glossary
```

Create only the sections that have entries — don't pre-emptively add empty sections.

### When NOT to write any note

- Routine task completion ("ran migration, 0 failures")
- Pure code/config that already lives in the repo (the repo is canon)
- Ephemeral session state (use `next.md`)
- Fabricated content — if there's no real knowledge worth capturing, say so

### Goal

Make Obsidian a searchable, durable record of *why* things are the way they are — across every project — so the same gotchas don't get re-discovered, past decisions don't get second-guessed, and context already paid for doesn't get rebuilt.
