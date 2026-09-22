# obsidiankit

A small, agent-agnostic package (Claude Code, Codex, Gemini CLI, or any CLI agent that reads `AGENTS.md`) for capturing durable project knowledge — postmortems, decisions, working-style preferences, external references, and glossary terms — into an Obsidian vault, structured so each entry is **discoverable from both Obsidian** (graph view, tag search) **and the project's current state file** (`next.md`).

> Renamed from **obsikit** on 2026-07-29, and restructured from five `/<prefix>-*` commands into one `/obsidian` dispatcher. Migrating: re-run `./install.sh`, then delete the old `~/.claude/commands/<prefix>-{lesson,decision,preference,reference,glossary}.md` files.

## First time here? Start with `/setup`

You don't need to know Obsidian, slash commands, or what a vault is. Clone the repo, open your coding agent inside it, and let it interview you. With Claude Code:

```sh
git clone https://github.com/ravivasavan/obsidiankit.git ~/Projects/Personal/obsidiankit
cd ~/Projects/Personal/obsidiankit
claude
```

then type **`/setup`**. Using Codex, GrokBuild, Gemini CLI or another agent instead? Say *"run the obsidiankit setup interview"* — the repo's `AGENTS.md` tells the agent where the script is and grants it permission to run the installer. Either way it asks a handful of multiple-choice questions (have you used Obsidian, where should the vault live, back it up to a private GitHub repo?), explains the two ideas that matter at whatever depth you picked, shows you the plan, and only then runs the installer with your answers. It finishes by seeding your first project's `next.md` and opening the vault in Obsidian.

`/setup` is a repo-scoped command (`.claude/commands/setup.md`), so it works before anything is installed. Later, when a teammate hands you a shared vault URL, come back and run **`/setup join <git-url>`** — it clones the vault, checks its layout, summarises the team's conventions, and adds a row to your vault registry.

If you'd rather drive the installer yourself, see [Install](#install) below.

## What it is

A one-shot installer that sets up:

1. **One dispatcher slash command** — `/obsidian` (name configurable). The canonical copy lives at `~/.config/obsidiankit/obsidian.md` so any agent can read it; it's mirrored into `~/.claude/commands/` (Claude Code) and `~/.codex/prompts/` (Codex) when those exist. First argument picks the category, the rest is the slug or term. Single letters work; a bare invocation asks which category fits:

   ```
   /obsidian lesson pnpm-blocks-postinstall
   /obsidian l pnpm-blocks-postinstall      # same thing
   /obsidian d cardpager-v2                 # decision
   /obsidian p                              # preference, slug derived
   /obsidian g CR80                         # glossary (term required)
   /obsidian                                # → category picker
   ```

2. **Four vault-ops commands inside the vault repo** — `<vault>/.claude/commands/{ingest,inbox,ask,lint}.md`. They live *in the vault* on purpose: anyone who clones a shared vault gets `/ingest` (compile sources into the wiki), `/inbox` (process captures), `/ask` (answer from the wiki, file the answer back), and `/lint` (wiki health check) with zero setup. Layer-aware: vaults without a `wiki/sources/` summary layer compile straight into concepts/entities.
3. **A managed section in every global agent-instructions file you have** — `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md`, `~/AGENTS.md` (created if none exist) — so every agent session, across every repo on your machine, knows the conventions: read `next.md` at session start, capture durable knowledge under the vault's `sources/` tree, link every entry from the top of `next.md`.
4. **A vault folder skeleton** (`sources/`, `journal/`, `inbox/`, `wiki/`) plus a `README.md` at the vault root describing how it all fits together.

The five categories don't overlap:

| Subcommand | Folder | Use for |
|---|---|---|
| `/obsidian l[esson]` | `lessons/` | Postmortems, gotchas, bugs that bit you |
| `/obsidian d[ecision]` | `decisions/` | ADR-style architectural / design / scope decisions |
| `/obsidian p[reference]` | `preferences/` | How you like things done (dual-writes to the agent's memory) |
| `/obsidian r[eference]` | `references/` | Dashboards, sibling repos, people, vendors — *where to look* |
| `/obsidian g[lossary]` | `glossary/` | Project vocabulary, acronyms, domain terms — *what a term means* |

## Multi-vault setups

The command is registry-aware: if your global instructions file defines a vault registry (e.g. shared team vaults alongside a personal vault, routed at write time), `/obsidian` resolves the target vault first — explicit instruction > repo declaration > pattern match > ask — and uses the single-project layout (`sources/<category>/`, `journal/next.md`) inside team vaults. Without a registry, everything lands in the single vault you configure at install time.

## Why

Long-running projects accumulate non-obvious knowledge — a gotcha you hit at 2am, a decision you'd second-guess in six months, a working-style preference you keep having to re-state. The default places that knowledge ends up — Slack scrollback, commit messages, your head — are all lossy. This kit pushes it into a vault that's:

- **Browsable in Obsidian** with proper tags, frontmatter, and graph backlinks
- **Reachable from the project's current state file** so the agent can surface relevant prior knowledge on demand
- **Structured** enough that the categories themselves nudge you toward writing the part that survives (the *rule*, the *rationale*, the *why*), not the play-by-play

## Prerequisites

- A CLI coding agent. Detected automatically: [Claude Code](https://docs.claude.com/claude-code) (`~/.claude/`), Codex (`~/.codex/`), Gemini CLI (`~/.gemini/`). Anything else: the installer writes to `~/AGENTS.md`, and you point your agent's global instructions at it.
- An Obsidian vault, or a folder you intend to open as one. (If you don't have one, the installer will create the directory; just point [Obsidian](https://obsidian.md) at it after.)
- `bash` 3.2+ and `awk` (standard on macOS and Linux)

## Install

The manual path. `/setup` (above) runs exactly this for you.

```sh
git clone https://github.com/ravivasavan/obsidiankit.git ~/Projects/Personal/obsidiankit
cd ~/Projects/Personal/obsidiankit
./install.sh
```

The installer prompts for two things:

1. **Path to your Obsidian vault** — where the folder skeleton + README go, and where all captured notes will live. Default: `~/Obsidian`.
2. **Slash-command name** — what to call the dispatcher. Default: `obsidian`. Pick anything kebab-safe.

It then:

1. Creates the vault folder skeleton (`sources/projects/`, `journal/`, `inbox/`, `wiki/`) at the path you gave.
2. Drops `README.md` and a `.gitignore` at the vault root (each skipped if it already exists — your customisations are safe).
3. Writes the dispatcher to `~/.config/obsidiankit/<command>.md` with your vault path templated in, plus a copy in each detected agent's command directory.
4. Adds (or replaces) a managed section in each detected global instructions file between `<!-- BEGIN obsidiankit managed section -->` markers. Re-runs are safe — the old section is stripped before the new one is written.

Scripted installs: `OBSIDIANKIT_VAULT=… OBSIDIANKIT_COMMAND=… OBSIDIANKIT_YES=1 ./install.sh`. Add `OBSIDIANKIT_AGENTS_MD=<path>` to manage an extra instructions file, or `=none` to leave `~/AGENTS.md` alone.

After installing, **start a fresh agent session** (Claude Code: `/clear` also works) so the updated instructions are picked up.

## What the installer changes

| Path | Action |
|---|---|
| `<vault>/sources/projects/`, `journal/`, `inbox/`, `wiki/` | created with `mkdir -p` (idempotent) |
| `<vault>/README.md` | written if missing, **not overwritten** |
| `<vault>/.gitignore` | written if missing (excludes Obsidian per-device workspace files), **not overwritten** |
| `<vault>/.claude/commands/{ingest,inbox,ask,lint}.md` | written (overwritten on re-run) |
| `~/.config/obsidiankit/<command>.md` | written (overwritten on re-run) — canonical, agent-neutral |
| `~/.claude/commands/<command>.md` | written if `~/.claude/` exists (overwritten on re-run) |
| `~/.codex/prompts/<command>.md` | written if `~/.codex/` exists (overwritten on re-run) |
| `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md`, `~/AGENTS.md` | for each that exists: managed section between BEGIN/END markers added or replaced; everything else untouched. `~/AGENTS.md` is created only if no other target exists. |

Nothing else on your machine is modified.

## Re-installing / updating

`git pull` the repo and re-run `./install.sh`. Use the same command name and vault path as last time and the installer will cleanly replace the managed CLAUDE.md section and overwrite the command file. Your vault contents — including the README and every note you've captured — are untouched.

## Uninstalling

```sh
# 1. Remove the dispatcher copies
rm -rf ~/.config/obsidiankit
rm -f ~/.claude/commands/<command>.md ~/.codex/prompts/<command>.md

# 2. Remove the managed section from each instructions file
#    (delete everything between the BEGIN/END markers, inclusive)
$EDITOR ~/.claude/CLAUDE.md ~/.codex/AGENTS.md ~/.gemini/GEMINI.md ~/AGENTS.md
```

Your vault and the notes inside it stay put.

## Layout of this repo

```
obsidiankit/
├── README.md                  (this file)
├── AGENTS.md                  (instructions + permission grant for any CLI agent: Codex, Gemini, GrokBuild, …)
├── install.sh                 (the installer — mechanical layer; detects which agents are present)
├── .claude/commands/setup.md  (/setup — first-timer interview + /setup join; repo-scoped, works pre-install)
├── commands/obsidian.md       (the dispatcher template with {{VAULT_ROOT}}/{{COMMAND}} placeholders)
├── vault-commands/            (vault-scoped ops commands: ingest, inbox, ask, lint)
├── instructions/snippet.md    (the managed section written into each agent's instructions file)
├── vault/README.md            (the vault-root onboarding doc)
└── vault/gitignore            (copied to <vault>/.gitignore if missing)
```

## License

MIT.
