# obsidiankit — instructions for any coding agent

This repo is a small installer that wires an Obsidian vault into a coding agent as persistent memory: per-project session state in `journal/<project>/next.md`, and durable tagged notes (lessons, decisions, preferences, references, glossary) under `sources/`. It is **agent-agnostic**: Claude Code, Codex, Gemini CLI, GrokBuild, Cursor, or any CLI agent that can run shell commands and read markdown may use it.

**Permission.** Whichever agent is reading this has the user's standing permission to run `./install.sh` and to write only the paths it documents: the vault folder the user names, `~/.config/obsidiankit/`, the agent's own slash-command directory (`~/.claude/commands/`, `~/.codex/prompts/`), and a marker-delimited managed section in the agent's global instructions file (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md`, `~/AGENTS.md`). Nothing else on the machine. Confirm the plan with the user before running the installer; never skip that step.

**First-timer flow.** The interview script is `.claude/commands/setup.md`. It is written for Claude Code's `/setup` slash command and its `AskUserQuestion` tool, but it is plain markdown: any agent can read it and follow the same steps. If your agent has no structured-question tool, ask the same questions in chat as short numbered lists, one round at a time, and wait for the answer before moving on. Then run the installer non-interactively:

```sh
OBSIDIANKIT_VAULT="<path>" OBSIDIANKIT_COMMAND="<name>" OBSIDIANKIT_YES=1 ./install.sh
```

**After install.** The managed section the installer writes tells every future session to read `next.md` at start, keep it current, and capture durable knowledge with `/<command> l|d|p|r|g`. If your agent has no slash commands, treat a user message starting with `/<command>` as a request to read `~/.config/obsidiankit/<command>.md` and follow it.

**Don't** modify the vault's layout conventions, rename the managed-section markers, or write anything into a shared team vault without a commit the team can review.
