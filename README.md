# obsikit

A small Claude Code package for capturing durable project knowledge — postmortems, decisions, working-style preferences, external references, and glossary terms — into an Obsidian vault, structured so each entry is **discoverable from both Obsidian** (graph view, tag search) **and the project's current state file** (`next.md`).

## What it is

A one-shot installer that sets up:

1. **Five slash commands** in `~/.claude/commands/` — `/<prefix>-lesson`, `/<prefix>-decision`, `/<prefix>-preference`, `/<prefix>-reference`, `/<prefix>-glossary`. Invoke any of them inside a Claude Code session to capture the conversation's takeaway as a structured, tagged markdown note in the right vault folder, with a wikilink added to the project's `next.md`.
2. **A managed section in `~/.claude/CLAUDE.md`** so every Claude session — across every repo on your machine — knows the conventions: read `next.md` at session start, capture durable knowledge under `sources/projects/<project>/<category>/`, link every entry from the top of `next.md`.
3. **A vault folder skeleton** (`sources/`, `journal/`, `inbox/`, `wiki/`) plus a `README.md` at the vault root describing how it all fits together.

The five categories don't overlap:

| Command | Folder | Use for |
|---|---|---|
| `/<prefix>-lesson` | `lessons/` | Postmortems, gotchas, bugs that bit you |
| `/<prefix>-decision` | `decisions/` | ADR-style architectural / design / scope decisions |
| `/<prefix>-preference` | `preferences/` | How you like things done (dual-writes to Claude memory) |
| `/<prefix>-reference` | `references/` | Dashboards, sibling repos, people, vendors — *where to look* |
| `/<prefix>-glossary` | `glossary/` | Project vocabulary, acronyms, domain terms — *what a term means* |

## Why

Long-running projects accumulate non-obvious knowledge — a gotcha you hit at 2am, a decision you'd second-guess in six months, a working-style preference you keep having to re-state. The default places that knowledge ends up — Slack scrollback, commit messages, your head — are all lossy. This kit pushes it into a vault that's:

- **Browsable in Obsidian** with proper tags, frontmatter, and graph backlinks
- **Reachable from the project's current state file** so Claude can surface relevant prior knowledge on demand
- **Structured** enough that the categories themselves nudge you toward writing the part that survives (the *rule*, the *rationale*, the *why*), not the play-by-play

## Prerequisites

- [Claude Code](https://docs.claude.com/claude-code) installed (you should already have `~/.claude/`)
- An Obsidian vault, or a folder you intend to open as one. (If you don't have one, the installer will create the directory; just point [Obsidian](https://obsidian.md) at it after.)
- `bash` 3.2+ and `awk` (standard on macOS and Linux)

## Install

```sh
git clone https://github.com/ravivasavan/obsikit.git ~/Projects/obsikit
cd ~/Projects/obsikit
./install.sh
```

The installer prompts for two things:

1. **Path to your Obsidian vault** — where the folder skeleton + README go, and where all captured notes will live. Default: `~/Obsidian`.
2. **Slash-command prefix** — what to call the commands. Default: `obsi` (giving you `/obsi-lesson`, `/obsi-decision`, etc.). Pick anything kebab-safe — `kb`, `vault`, your initials, whatever.

It then:

1. Creates the vault folder skeleton (`sources/projects/`, `journal/`, `inbox/`, `wiki/`) at the path you gave.
2. Drops `README.md` at the vault root (skipped if one already exists — your customisations are safe).
3. Writes the five slash-command files to `~/.claude/commands/<prefix>-*.md` with your vault path templated in.
4. Adds (or replaces) a managed section in `~/.claude/CLAUDE.md` between `<!-- BEGIN obsikit managed section -->` markers. Re-runs are safe — the old section is stripped before the new one is written.

After installing, **start a fresh Claude Code session** (or run `/clear` in an existing one) so the updated CLAUDE.md is picked up.

## What the installer changes

| Path | Action |
|---|---|
| `<vault>/sources/projects/`, `journal/`, `inbox/`, `wiki/` | created with `mkdir -p` (idempotent) |
| `<vault>/README.md` | written if missing, **not overwritten** |
| `~/.claude/commands/<prefix>-{lesson,decision,preference,reference,glossary}.md` | written (overwritten on re-run) |
| `~/.claude/CLAUDE.md` | managed section between BEGIN/END markers added or replaced; everything else untouched |

Nothing else on your machine is modified.

## Re-installing / updating

`git pull` the repo and re-run `./install.sh`. Use the same prefix and vault path as last time and the installer will cleanly replace the managed CLAUDE.md section and overwrite the slash-command files. Your vault contents — including the README and every note you've captured — are untouched.

## Uninstalling

The installer doesn't ship an uninstall script (yet). To remove obsikit manually:

```sh
# 1. Remove the slash commands
rm ~/.claude/commands/<prefix>-{lesson,decision,preference,reference,glossary}.md

# 2. Remove the managed section from CLAUDE.md
#    (delete everything between the BEGIN/END markers, inclusive)
$EDITOR ~/.claude/CLAUDE.md
```

Your vault and the notes inside it stay put.

## Usage

After install, every Claude Code session will read `<vault>/journal/<project>/next.md` on startup and treat the conventions as global. To capture something:

```
/<prefix>-lesson           # derives a slug from the conversation
/<prefix>-lesson my-slug   # explicit kebab slug
/<prefix>-glossary CR80    # term is required for glossary
```

Each command writes the note to the right folder and adds a one-line wikilink at the top of the project's `next.md`. The category section in `next.md` is created lazily — only when it has entries.

For the full convention guide, see `<vault>/README.md` once installed, or `vault/README.md` in this repo.

## Layout of this repo

```
obsikit/
├── README.md            (this file)
├── install.sh           (the installer)
├── commands/            (slash-command templates with {{VAULT_ROOT}}/{{PREFIX}} placeholders)
├── claude-md/snippet.md (the managed CLAUDE.md section)
└── vault/README.md      (the vault-root onboarding doc)
```

## License

MIT.
