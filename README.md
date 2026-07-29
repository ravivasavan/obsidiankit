# obsidiankit

A small Claude Code package for capturing durable project knowledge — postmortems, decisions, working-style preferences, external references, and glossary terms — into an Obsidian vault, structured so each entry is **discoverable from both Obsidian** (graph view, tag search) **and the project's current state file** (`next.md`).

> Renamed from **obsikit** on 2026-07-29, and restructured from five `/<prefix>-*` commands into one `/obsidian` dispatcher. Migrating: re-run `./install.sh`, then delete the old `~/.claude/commands/<prefix>-{lesson,decision,preference,reference,glossary}.md` files.

## What it is

A one-shot installer that sets up:

1. **One dispatcher slash command** in `~/.claude/commands/` — `/obsidian` (name configurable). First argument picks the category, the rest is the slug or term. Single letters work; a bare invocation asks which category fits:

   ```
   /obsidian lesson pnpm-blocks-postinstall
   /obsidian l pnpm-blocks-postinstall      # same thing
   /obsidian d cardpager-v2                 # decision
   /obsidian p                              # preference, slug derived
   /obsidian g CR80                         # glossary (term required)
   /obsidian                                # → category picker
   ```

2. **A managed section in `~/.claude/CLAUDE.md`** so every Claude session — across every repo on your machine — knows the conventions: read `next.md` at session start, capture durable knowledge under the vault's `sources/` tree, link every entry from the top of `next.md`.
3. **A vault folder skeleton** (`sources/`, `journal/`, `inbox/`, `wiki/`) plus a `README.md` at the vault root describing how it all fits together.

The five categories don't overlap:

| Subcommand | Folder | Use for |
|---|---|---|
| `/obsidian l[esson]` | `lessons/` | Postmortems, gotchas, bugs that bit you |
| `/obsidian d[ecision]` | `decisions/` | ADR-style architectural / design / scope decisions |
| `/obsidian p[reference]` | `preferences/` | How you like things done (dual-writes to Claude memory) |
| `/obsidian r[eference]` | `references/` | Dashboards, sibling repos, people, vendors — *where to look* |
| `/obsidian g[lossary]` | `glossary/` | Project vocabulary, acronyms, domain terms — *what a term means* |

## Multi-vault setups

The command is registry-aware: if your `~/.claude/CLAUDE.md` defines a vault registry (e.g. shared team vaults alongside a personal vault, routed at write time), `/obsidian` resolves the target vault first — explicit instruction > repo declaration > pattern match > ask — and uses the single-project layout (`sources/<category>/`, `journal/next.md`) inside team vaults. Without a registry, everything lands in the single vault you configure at install time.

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
git clone https://github.com/ravivasavan/obsidiankit.git ~/Projects/obsidiankit
cd ~/Projects/obsidiankit
./install.sh
```

The installer prompts for two things:

1. **Path to your Obsidian vault** — where the folder skeleton + README go, and where all captured notes will live. Default: `~/Obsidian`.
2. **Slash-command name** — what to call the dispatcher. Default: `obsidian`. Pick anything kebab-safe.

It then:

1. Creates the vault folder skeleton (`sources/projects/`, `journal/`, `inbox/`, `wiki/`) at the path you gave.
2. Drops `README.md` at the vault root (skipped if one already exists — your customisations are safe).
3. Writes the dispatcher command file to `~/.claude/commands/<command>.md` with your vault path templated in.
4. Adds (or replaces) a managed section in `~/.claude/CLAUDE.md` between `<!-- BEGIN obsidiankit managed section -->` markers. Re-runs are safe — the old section is stripped before the new one is written.

Scripted installs: `OBSIDIANKIT_VAULT=… OBSIDIANKIT_COMMAND=… OBSIDIANKIT_YES=1 ./install.sh`

After installing, **start a fresh Claude Code session** (or run `/clear` in an existing one) so the updated CLAUDE.md is picked up.

## What the installer changes

| Path | Action |
|---|---|
| `<vault>/sources/projects/`, `journal/`, `inbox/`, `wiki/` | created with `mkdir -p` (idempotent) |
| `<vault>/README.md` | written if missing, **not overwritten** |
| `~/.claude/commands/<command>.md` | written (overwritten on re-run) |
| `~/.claude/CLAUDE.md` | managed section between BEGIN/END markers added or replaced; everything else untouched |

Nothing else on your machine is modified.

## Re-installing / updating

`git pull` the repo and re-run `./install.sh`. Use the same command name and vault path as last time and the installer will cleanly replace the managed CLAUDE.md section and overwrite the command file. Your vault contents — including the README and every note you've captured — are untouched.

## Uninstalling

```sh
# 1. Remove the dispatcher command
rm ~/.claude/commands/<command>.md

# 2. Remove the managed section from CLAUDE.md
#    (delete everything between the BEGIN/END markers, inclusive)
$EDITOR ~/.claude/CLAUDE.md
```

Your vault and the notes inside it stay put.

## Layout of this repo

```
obsidiankit/
├── README.md            (this file)
├── install.sh           (the installer)
├── commands/obsidian.md (the dispatcher template with {{VAULT_ROOT}}/{{COMMAND}} placeholders)
├── claude-md/snippet.md (the managed CLAUDE.md section)
└── vault/README.md      (the vault-root onboarding doc)
```

## License

MIT.
