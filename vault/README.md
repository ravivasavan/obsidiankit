# Vault — Claude Code knowledge base

This vault is the long-term knowledge base for work assisted by Claude Code. It's structured so that *durable* knowledge (lessons, decisions, preferences, references, glossary) stays browsable in Obsidian *and* discoverable from each project's current state file. Session scratch lives separately so it can be archived without losing anything important.

This file lives at the vault root. Open the vault in Obsidian to get full graph-view + tag-search benefits.

---

## Folder layout

```
{{VAULT_ROOT}}/
├── sources/
│   └── projects/
│       └── <project>/
│           ├── lessons/           # postmortems, gotchas, bugs that bit us
│           ├── decisions/         # ADR-style architectural / design decisions
│           ├── preferences/       # how the user likes things done
│           ├── references/        # pointers to dashboards, repos, people
│           └── glossary/          # project vocabulary, acronyms, domain terms
├── journal/
│   └── <project>/
│       └── next.md                # current focus, next steps, open questions
├── inbox/                         # unfiled / unsorted notes (manual entry)
└── wiki/                          # optional downstream tooling output
```

**Why two top-level trees?**

- `sources/` is the human-write input layer. Anything durable goes here — content meant to be searched, linked to, and ingested by downstream tooling later. Tagged notes from the `/{{COMMAND}}` command all land under `sources/projects/<project>/<category>/`.
- `journal/` is the human-write session-state zone. `next.md` lives here. It's deliberately excluded from any downstream "ingest the vault" tooling so that ephemeral working notes don't pollute the knowledge layer.

`inbox/` and `wiki/` are optional — keep them empty if not in use. They're conventional landing zones if you later add inbox-processing or wiki-generation tooling.

---

## The five capture commands

When something worth remembering surfaces in a Claude session, invoke one of:

| Command | Use it when… |
|---|---|
| `/{{COMMAND}} lesson` | A bug, gotcha, or non-obvious behavior surprised you. The going-forward rule is the point. |
| `/{{COMMAND}} decision` | You chose between real alternatives and the *rationale* will matter again. |
| `/{{COMMAND}} preference` | You corrected Claude's approach and want it to stick across future sessions. Dual-writes to Claude memory. |
| `/{{COMMAND}} reference` | You named an external resource — a dashboard, a person, a sibling repo, a vendor — that's worth knowing how to find. |
| `/{{COMMAND}} glossary` | A project-specific term, acronym, or domain concept needs a one-place definition. |

Each command:
1. Writes a structured, tagged markdown note to the right `sources/projects/<project>/<category>/` folder.
2. Adds a bare-slug `[[wikilink]]` line at the top of the project's `next.md` so the entry is discoverable both via Obsidian tag search and from the project's session-state file.

The command files themselves live in `~/.claude/commands/` — open them to read the exact frontmatter schema each note uses.

---

## How `next.md` works

Every project gets one `next.md` at `{{VAULT_ROOT}}/journal/<project>/next.md`. Claude reads it at session start and updates it through the session.

Structure (free-form, but conventional):

```markdown
# Next

## Lessons
- [[2026-05-19-postgres-connection-pool-exhausted|Connection pool exhausted under load]] — #postgres #postmortem

## Decisions
- [[2026-05-15-sqlite-for-dev|SQLite for local dev, Postgres in prod]] — accepted · #adr #infra

## Preferences
- [[2026-05-10-no-leftover-comments|Don't leave commented-out code]] — global · #style

## References
- [[2026-05-12-grafana-api-latency|Grafana API latency board]] — dashboard · #external/dashboard

## Glossary
- [[idempotency-key|Idempotency key]] — Client-generated token to make a request safely retryable.

## Active thread — <topic> (YYYY-MM-DD)

Current focus: <what we're in the middle of>

Next up:
- <step>
- <step>

Open: <questions, blockers, decisions pending>
```

Capture sections at the top (alphabetical by command). Active threads below. The four capture sections only appear when they have entries — empty sections aren't created pre-emptively.

---

## What NOT to capture

Don't write any note for:

- **Routine task completion.** "Migration ran, 0 failures" isn't a lesson.
- **Code or config that lives in the repo.** The repo is canon. If `MAX_RETRIES = 3` is in source, it's not glossary-worthy.
- **Ephemeral session state.** That's what `next.md` is for.
- **Fabricated knowledge.** If a session didn't surface anything genuinely worth remembering, no note should be written. The commands will refuse rather than invent content.

The bar is: *would future-me, or a teammate ramping into this project, save time by reading this?* If yes, capture it. If no, skip.

---

## Maintenance

- **Renaming:** Keep slugs stable once written. Wikilinks reference by basename, so a rename in `sources/projects/.../lessons/` would break the `next.md` link. If a rename is unavoidable, update the matching line in `next.md` at the same time.
- **Cross-linking:** Use the `related:` frontmatter field to wire notes together. Obsidian's graph view rewards this.
- **Tag discipline:** Stick to hierarchical area tags (`api/auth`, `git/safety`, `external/vendor`) — they make tag search far more useful than a flat namespace.
- **Stale `next.md`:** Rewrite it rather than appending forever. It should reflect *current* state, not session history.

---

## Setup origin

This vault structure and the `/{{COMMAND}}` command were installed by **obsidiankit** — see the kit's README for re-install / update instructions. The CLAUDE.md section that wires these conventions into every Claude session lives at `~/.claude/CLAUDE.md` under a managed section delimited by `<!-- BEGIN obsidiankit managed section -->` markers.
