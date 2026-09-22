---
description: First-timer setup — interview, then install obsidiankit and create your vault. `/setup join <git-url>` clones a shared vault.
argument-hint: "[join <git-url> [local-path]]"
---

You are onboarding someone who may never have used Obsidian, may be new to slash commands and agent instruction files, and has cloned this repo because a teammate told them to. Be warm, be brief, and **ask before you assume**. Use the `AskUserQuestion` tool for every choice below — never make them type paths or answers into chat when a picker will do. Batch related questions into one call (max 4 per call). Every question gets an automatic "Other" option, so offer the common cases and let "Other" catch the rest.

**Not Claude Code?** This file is plain markdown; any agent can follow it. Without a structured-question tool, ask each round's questions in chat as short numbered lists and wait for the answer. Wherever this file says `~/.claude/…`, read "your agent's equivalent" — the installer detects Claude Code, Codex and Gemini CLI itself and falls back to `~/AGENTS.md`.

`$ARGUMENTS` decides the mode:

- **empty** → **Mode A: set up my own vault** (the default; go to Step 1).
- starts with `join` → **Mode B: join a shared vault** (go to the Join section at the bottom).

---

# Mode A — set up my own vault

## Step 1 — Preflight (silent, one Bash call)

Gather facts before asking anything, so the questions are informed and you never ask what you can detect:

```sh
KIT="$(pwd)"
echo "kit=$KIT"
for d in .claude .codex .gemini; do [ -d "$HOME/$d" ] && echo "agent_dir=$d"; done
[ -f "$HOME/AGENTS.md" ] && echo "home_agents_md=yes"
command -v git >/dev/null && echo "git=$(git --version)" || echo "git=missing"
( [ -d /Applications/Obsidian.app ] || [ -d "$HOME/Applications/Obsidian.app" ] || command -v obsidian >/dev/null || (command -v flatpak >/dev/null && flatpak list 2>/dev/null | grep -qi obsidian) ) && echo "obsidian_app=yes" || echo "obsidian_app=no"
command -v gh >/dev/null && gh auth status >/dev/null 2>&1 && echo "gh=authed" || echo "gh=no"
grep -lF "BEGIN obsidiankit managed section" "$HOME/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md" "$HOME/.gemini/GEMINI.md" "$HOME/AGENTS.md" 2>/dev/null | sed 's/^/installed_in=/'
grep -hE "^(Vault root|Slash command):" "$HOME/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md" "$HOME/.gemini/GEMINI.md" "$HOME/AGENTS.md" 2>/dev/null | sort -u
[ -d "$HOME/Obsidian" ] && echo "default_vault_exists=yes" || echo "default_vault_exists=no"
echo "siblings:"; ls -d "$(dirname "$KIT")"/*/ 2>/dev/null | xargs -n1 basename | grep -v "^$(basename "$KIT")$" | head -8
```

Interpret:

- No `agent_dir=` line and no `home_agents_md=yes` → the installer will create `~/AGENTS.md` and they must point their agent at it. Say so up front. For Claude Code specifically, running `claude` once creates `~/.claude/`.
- Any `installed_in=` line → this is **not** a first-timer. Say so, show the current vault root and command name from the grep, and offer two paths: **update in place** (re-run `./install.sh` with the same values via `OBSIDIANKIT_VAULT`, `OBSIDIANKIT_COMMAND`, `OBSIDIANKIT_YES=1`) or **start the interview anyway** (they want to move the vault or rename the command). Skip the primer either way.
- `obsidian_app=no` → not a blocker (the vault is just a folder of markdown). Note it; the handoff will link https://obsidian.md.
- `gh=no` → the GitHub-backup question below loses its "yes" option; offer "local git only" and "skip" instead, and mention `gh auth login` in the handoff.

## Step 2 — Interview, round 1 (one AskUserQuestion call, 3 questions)

1. **"Have you used Obsidian before?"** header `Obsidian`
   - Never used it — *I'll explain the two ideas that matter before we install.*
   - Installed, but no real vault yet — *Skip the basics, show me the workflow.*
   - Daily user — *Just install; I know vaults, tags, wikilinks.*

2. **"How familiar are you with slash commands and agent instruction files (CLAUDE.md / AGENTS.md)?"** header `Agent CLI`
   - New to both — *I'll explain what the installer writes and why.*
   - I use slash commands, instruction files are fuzzy
   - Comfortable with both

3. **"Where should your vault live?"** header `Vault path`
   - `~/Obsidian` (default) — *A folder in your home directory. Fine for one vault.*
   - `~/Projects/Personal/obsidian` — *Sits beside your code. What the kit author uses; makes room for team vaults at `~/Projects/<Team>/…` later.*
   - I already have a vault — *Pick this, then type its path in Other.*
   If `default_vault_exists=yes`, say so in the `~/Obsidian` description: *exists already; we install into it, nothing is overwritten.*

## Step 3 — Interview, round 2 (one AskUserQuestion call, up to 4 questions)

4. **"Slash command name?"** header `Command`
   - `/obsidian` (Recommended) — *What the docs and your teammates use.*
   - `/vault` — *Shorter to type.*
   - `/kb` — *Shorter still.*
   Validate: lowercase letters, digits, hyphens, starts with a letter. Anything else → ask again.

5. **"Back the vault up with git?"** header `Git`
   - If `gh=authed`: **Private GitHub repo (Recommended)** — *git init, then `gh repo create --private` and push. Your notes are safe and cloneable to another machine.* / **Local git only** — *History, no remote. Add one later.* / **No git for now**
   - If `gh=no`: **Local git only (Recommended)** / **No git for now** — and say GitHub backup needs `gh auth login` first.

6. Only if they chose a GitHub repo: **"Repo name?"** header `Repo name`
   - `obsidian` (Recommended) — *Matches the team convention: `<you>/obsidian`.*
   - `<vault folder basename>` — *Same name as the folder.*
   - `notes`

7. **"Which project should get its first next.md?"** header `First project`
   Offer up to three of the `siblings:` from preflight (these are folders next to this kit, likely their real repos), plus **Skip — the first real session will create it**. `next.md` is per-project session memory; seeding one shows them the shape immediately.

## Step 4 — Primer (sized by their round-1 answers)

Print this *before* the plan, in plain prose, no headers. Scale it:

- **Never used Obsidian** → all four paragraphs.
- **Installed / fuzzy on instruction files** → paragraphs 2–4.
- **Daily user + comfortable** → paragraph 4 only, two sentences.

1. *What a vault is.* A vault is a plain folder of markdown files. Obsidian is a viewer that adds tag search, backlinks and a graph on top; it never locks the files. That means git works, Claude can read and write it directly, and nothing is trapped in an app.

2. *Two kinds of memory.* `journal/<project>/next.md` is the agent's working memory: current focus, next steps, open questions. The agent reads it when a session starts and rewrites it as work moves. Everything under `sources/` is long-term memory: standalone tagged notes that outlive any one session.

3. *Five categories, one command.* `/<command> l` lesson (something bit us), `d` decision (chose between real options), `p` preference (how you like things done; also saved to the agent's own memory), `r` reference (where to look), `g` glossary (what a term means). Each writes a tagged note under `sources/projects/<project>/<category>/` and links it from the top of that project's `next.md`.

4. *The daily loop.* Open your agent in any repo → it loads that project's `next.md` and says what it found → you work → when something durable surfaces, `/<command> <letter> <slug>` → at the end, `next.md` is refreshed. The installer wires that loop into your agent's global instructions file so it runs in every repo on this machine, not just this one.

## Step 5 — Plan and confirm

Show a short plan table (vault path, command name, git choice, first project) and what will be written: the vault skeleton, README and `.gitignore`, `<vault>/.claude/commands/{ingest,inbox,ask,lint}.md`, the dispatcher at `~/.config/obsidiankit/<command>.md` plus a copy in each detected agent's command directory, and a managed section between BEGIN/END markers in each detected instructions file (the installer's own Plan output lists them exactly). Say explicitly: nothing else on the machine is touched, and re-running is safe. Then one AskUserQuestion: **"Go ahead?"** with **Yes, install** / **Change something** (loop back to the relevant round) / **Stop here**.

## Step 6 — Install (Bash)

```sh
OBSIDIANKIT_VAULT="<path>" OBSIDIANKIT_COMMAND="<command>" OBSIDIANKIT_YES=1 ./install.sh
```

Show the installer's output. If it fails, show the error verbatim and stop; do not improvise around a failed install.

## Step 7 — Post-install

Run only what they chose:

- **Git, local or GitHub.** Inside the vault: `git init -b main` (if no `.git`), confirm `.gitignore` exists (the installer writes one that excludes Obsidian's per-device workspace files), `git add -A`, `git commit -m "Initial vault"`. Write the commit with their own git identity; add no attribution trailer to someone else's vault.
- **GitHub.** `gh repo create <name> --private --source=. --remote=origin --push`. If the name is taken, `gh` says so; ask for another.
- **First project.** Write `<vault>/journal/<project>/next.md`:

  ```markdown
  # Next

  Current focus: <one line — ask them, or "Getting started with <project>">

  Next up:
  - Open your agent in <project> and confirm it loads this file
  - Capture the first real lesson or decision with /<command>

  Open: —
  ```

- **Open Obsidian** (only if `obsidian_app=yes`). macOS: `open "obsidian://open?path=<vault>"`. If Obsidian shows an empty window or a picker, tell them: *Open folder as vault → choose `<path>`*. Linux: same URI via `xdg-open`.

## Step 8 — Verify and hand off

One Bash call: `ls ~/.config/obsidiankit/<command>.md`, `grep -c "obsidiankit managed section" <each instructions file the installer listed>` (expect 2 each), `find <vault> -maxdepth 2 -type d | sort`. Report what exists.

Then the handoff, short and imperative:

1. Start a **fresh** agent session (Claude Code: `/clear` also works) so the new instructions are loaded.
2. `cd` into a real project, start your agent, and watch it read `next.md` (or create one).
3. Try `/<command> l my-first-lesson` the first time something surprises you.
4. If `obsidian_app=no`: install Obsidian from https://obsidian.md and open `<vault>` as a vault.
5. If `gh=no` and they wanted backup: `gh auth login`, then `gh repo create --private --source=<vault> --push`.
6. When a teammate gives you a shared vault URL: come back here and run `/setup join <url>`.

---

# Mode B — join a shared vault

`$ARGUMENTS` = `join <git-url> [local-path]`. Team vaults are single-project: notes go to `<vault>/sources/<category>/`, session state to `<vault>/journal/next.md`, and they sync **only via git** — pull at session start, push at session wrap.

1. **Preflight (Bash):** `git ls-remote <url>` to confirm access. Derive `<org>` and `<repo>` from the URL. Check whether the global instructions file already has a `## Vault registry` section.
2. **Ask where to clone** (one AskUserQuestion) unless `[local-path]` was given:
   - `~/Projects/<Org>/<org>-obsidian` (Recommended) — *Beside that team's code; matches the convention the kit author uses.*
   - Next to your personal vault — *`<personal-vault-parent>/<org>-obsidian`.*
   - Other → type a path.
3. **Clone** and **verify** the layout: `sources/`, `journal/`, `.claude/commands/` should exist. If `.claude/commands/` is missing, say the vault predates the kit's vault-ops commands and offer to copy `vault-commands/*.md` from this repo into it (a commit for the team to review, not a silent push).
4. **Read** the vault's own `CLAUDE.md` and `README.md` and summarise the team's conventions in three to five lines: what belongs in this vault, what stays personal, any naming rules.
5. **Registry row.** Print this and offer to append it to the global instructions file (`~/.claude/CLAUDE.md`, or the agent's equivalent) under a `## Vault registry` heading placed **outside** the obsidiankit managed markers (create the heading and the table header on first use; add a row on later uses):

   ```markdown
   | Vault | Local path | GitHub | Scope |
   |---|---|---|---|
   | **<name>** | `<local-path>` | `<org>/<repo>` | Shared. <one line: what knowledge lives here> |
   ```

   Then state the routing rule they now need, in one sentence each: an explicit instruction wins; else a repo's own `CLAUDE.md` declaring `vault: <name>`; else project names matching `<name>*` route here; else the personal vault. And the ownership test: *who has to re-learn this if it is lost?* The team → this vault; only you → personal.
6. **Handoff:** `git pull` at every session start in this vault, `git push` at wrap; never compile one vault's wiki from another's sources; cross-vault mentions are name-only links.

---

## Tone and guardrails

- Never fabricate an answer to a question you could have asked. Never skip the confirmation before `install.sh`.
- If a Bash step fails, show the error and stop. A half-finished install is fixable; a guessed-at one is not.
- Keep every message short. The primer is the only place you may write more than a paragraph.
