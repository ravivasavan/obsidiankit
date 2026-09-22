#!/usr/bin/env bash
# obsidiankit installer — agent-agnostic
# Sets up Obsidian-vault knowledge-capture conventions for CLI coding agents
# (Claude Code, Codex, Gemini CLI, and any agent that reads AGENTS.md):
#   - The /<command> dispatcher (lesson / decision / preference / reference / glossary)
#     at ~/.config/obsidiankit/<command>.md (canonical copy, any agent can read it),
#     mirrored into each agent's slash-command dir that exists:
#       ~/.claude/commands/<command>.md      Claude Code
#       ~/.codex/prompts/<command>.md        Codex CLI custom prompts
#   - A managed section (between BEGIN/END markers) in every global instructions
#     file that exists: ~/.claude/CLAUDE.md, ~/.codex/AGENTS.md, ~/.gemini/GEMINI.md,
#     ~/AGENTS.md. If none exist, ~/AGENTS.md is created.
#   - A vault folder skeleton (sources/, journal/, inbox/, wiki/), onboarding README,
#     and a .gitignore that keeps Obsidian's per-device workspace files out of git
#
# First time here? Open your agent in this directory and ask it to run the setup
# interview (Claude Code: type /setup; others: see AGENTS.md). This script is the
# mechanical layer.
#
# Re-running is safe: command files are overwritten, managed sections are replaced
# (not appended), the vault skeleton uses mkdir -p, and the vault README/.gitignore
# are not overwritten if you've customised them.
#
# Env-var overrides (scripted installs / testing):
#   OBSIDIANKIT_VAULT       skip vault prompt
#   OBSIDIANKIT_COMMAND     skip command-name prompt
#   OBSIDIANKIT_YES=1       skip the final confirmation
#   OBSIDIANKIT_AGENTS_MD   extra instructions file to manage (path), or "none"
#                           to skip ~/AGENTS.md entirely

set -euo pipefail

# ---------- paths ----------

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
CODEX_DIR="${CODEX_DIR:-$HOME/.codex}"
GEMINI_DIR="${GEMINI_DIR:-$HOME/.gemini}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/obsidiankit"

MARKER_BEGIN="<!-- BEGIN obsidiankit managed section -->"
MARKER_END="<!-- END obsidiankit managed section -->"

# ---------- helpers ----------

bold()   { printf "\033[1m%s\033[0m\n" "$*"; }
dim()    { printf "\033[2m%s\033[0m\n" "$*"; }
ok()     { printf "  \033[32m✓\033[0m %s\n" "$*"; }
warn()   { printf "  \033[33m!\033[0m %s\n" "$*"; }
fail()   { printf "  \033[31m✗\033[0m %s\n" "$*" >&2; }

abs_path() {
  # Expand ~ and resolve relative paths without requiring the target to exist.
  local p="$1"
  p="${p/#\~\//$HOME/}"
  case "$p" in
    /*) printf "%s" "$p" ;;
    *)  printf "%s/%s" "$(pwd)" "$p" ;;
  esac
}

substitute() {
  # Replace {{VAULT_ROOT}}, {{COMMAND}} and {{DISPATCHER}} in the file at $1, write to stdout.
  # Uses awk + env vars (no sed delimiters to clash with paths).
  VAULT_ROOT="$VAULT_ROOT" COMMAND="$COMMAND" DISPATCHER="$CONFIG_DIR/$COMMAND.md" awk '
    {
      gsub(/\{\{VAULT_ROOT\}\}/, ENVIRON["VAULT_ROOT"])
      gsub(/\{\{COMMAND\}\}/,    ENVIRON["COMMAND"])
      gsub(/\{\{DISPATCHER\}\}/, ENVIRON["DISPATCHER"])
      print
    }
  ' "$1"
}

write_managed_section() {
  # Replace (or append) the managed section in the instructions file at $1.
  local file="$1" tmp
  mkdir -p "$(dirname "$file")"
  touch "$file"

  if grep -qF "$MARKER_BEGIN" "$file"; then
    tmp="$(mktemp)"
    awk -v b="$MARKER_BEGIN" -v e="$MARKER_END" '
      $0 == b { skip = 1; next }
      $0 == e { skip = 0; next }
      !skip   { print }
    ' "$file" > "$tmp"
    mv "$tmp" "$file"
    warn "replaced existing managed section in $file"
  fi

  # Normalize trailing blank lines so re-runs don't accumulate whitespace.
  tmp="$(mktemp)"
  awk '
    { lines[NR] = $0 }
    END {
      last = 0
      for (i = NR; i >= 1; i--) {
        if (lines[i] !~ /^[[:space:]]*$/) { last = i; break }
      }
      for (i = 1; i <= last; i++) print lines[i]
    }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"

  {
    [ -s "$file" ] && echo
    echo "$MARKER_BEGIN"
    substitute "$KIT_DIR/instructions/snippet.md"
    echo "$MARKER_END"
  } >> "$file"
  ok "managed section written to $file"
}

# ---------- preflight: which agents are here? ----------

bold "obsidiankit installer"
echo

INSTRUCTION_FILES=()
COMMAND_DIRS=()

[ -d "$CLAUDE_DIR" ] && { INSTRUCTION_FILES+=("$CLAUDE_DIR/CLAUDE.md"); COMMAND_DIRS+=("$CLAUDE_DIR/commands"); }
[ -d "$CODEX_DIR" ]  && { INSTRUCTION_FILES+=("$CODEX_DIR/AGENTS.md"); COMMAND_DIRS+=("$CODEX_DIR/prompts"); }
[ -d "$GEMINI_DIR" ] && INSTRUCTION_FILES+=("$GEMINI_DIR/GEMINI.md")

case "${OBSIDIANKIT_AGENTS_MD:-}" in
  none) ;;
  "")   [ -f "$HOME/AGENTS.md" ] && INSTRUCTION_FILES+=("$HOME/AGENTS.md") ;;
  *)    INSTRUCTION_FILES+=("$(abs_path "$OBSIDIANKIT_AGENTS_MD")") ;;
esac

if [ "${#INSTRUCTION_FILES[@]}" -eq 0 ]; then
  warn "no agent config found (~/.claude, ~/.codex, ~/.gemini, ~/AGENTS.md)."
  warn "creating ~/AGENTS.md — point your agent's global instructions at it."
  INSTRUCTION_FILES+=("$HOME/AGENTS.md")
fi

# ---------- prompts ----------

default_vault="$HOME/Obsidian"
if [ -n "${OBSIDIANKIT_VAULT:-}" ]; then
  VAULT_INPUT="$OBSIDIANKIT_VAULT"
elif [ -t 0 ]; then
  read -r -p "Path to your Obsidian vault [$default_vault]: " VAULT_INPUT || VAULT_INPUT=""
else
  VAULT_INPUT=""
fi
VAULT_INPUT="${VAULT_INPUT:-$default_vault}"
VAULT_ROOT="$(abs_path "$VAULT_INPUT")"

default_command="obsidian"
if [ -n "${OBSIDIANKIT_COMMAND:-}" ]; then
  COMMAND_INPUT="$OBSIDIANKIT_COMMAND"
elif [ -t 0 ]; then
  read -r -p "Slash-command name [$default_command]: " COMMAND_INPUT || COMMAND_INPUT=""
else
  COMMAND_INPUT=""
fi
COMMAND="${COMMAND_INPUT:-$default_command}"

if ! [[ "$COMMAND" =~ ^[a-z][a-z0-9-]*$ ]]; then
  fail "command name must be lowercase letters/digits/hyphens, starting with a letter"
  exit 1
fi

# ---------- plan ----------

echo
bold "Plan"
echo "  Vault root:    $VAULT_ROOT"
echo "  Dispatcher:    $CONFIG_DIR/${COMMAND}.md  (canonical; lesson/decision/preference/reference/glossary)"
for d in "${COMMAND_DIRS[@]:-}"; do [ -n "$d" ] && echo "  Command copy:  $d/${COMMAND}.md"; done
for f in "${INSTRUCTION_FILES[@]}"; do echo "  Instructions:  $f  (managed section between BEGIN/END markers)"; done
echo "  Vault cmds:    $VAULT_ROOT/.claude/commands/{ingest,inbox,ask,lint}.md"
echo "  Vault layout:  sources/projects, journal, inbox, wiki  (+ README.md and .gitignore at vault root)"
echo

if [ "${OBSIDIANKIT_YES:-0}" = "1" ]; then
  confirm="y"
elif [ -t 0 ]; then
  read -r -p "Proceed? [y/N] " confirm || confirm=""
else
  confirm="y"
fi
case "$confirm" in [yY]*) ;; *) echo "aborted"; exit 0 ;; esac

# ---------- 1. vault skeleton ----------

echo
bold "Creating vault skeleton"
mkdir -p "$VAULT_ROOT"/sources/projects
mkdir -p "$VAULT_ROOT"/journal
mkdir -p "$VAULT_ROOT"/inbox
mkdir -p "$VAULT_ROOT"/wiki
# Git doesn't track empty directories; keep the skeleton intact across clones.
for d in sources/projects journal inbox wiki; do
  [ -n "$(ls -A "$VAULT_ROOT/$d" 2>/dev/null)" ] || touch "$VAULT_ROOT/$d/.gitkeep"
done
ok "vault tree at $VAULT_ROOT"

# ---------- 2. vault README + .gitignore ----------

vault_readme="$VAULT_ROOT/README.md"
if [ -e "$vault_readme" ]; then
  warn "$vault_readme already exists — not overwriting"
else
  substitute "$KIT_DIR/vault/README.md" > "$vault_readme"
  ok "wrote $vault_readme"
fi

vault_gitignore="$VAULT_ROOT/.gitignore"
if [ -e "$vault_gitignore" ]; then
  warn "$vault_gitignore already exists — not overwriting"
else
  cp "$KIT_DIR/vault/gitignore" "$vault_gitignore"
  ok "wrote $vault_gitignore"
fi

# ---------- 3. dispatcher command ----------

echo
bold "Installing the /${COMMAND} dispatcher"
src="$KIT_DIR/commands/obsidian.md"
if [ ! -f "$src" ]; then
  fail "missing template: $src"
  exit 1
fi

# Canonical, agent-neutral copy.
mkdir -p "$CONFIG_DIR"
substitute "$src" > "$CONFIG_DIR/${COMMAND}.md"
ok "wrote $CONFIG_DIR/${COMMAND}.md"

# Per-agent slash-command copies.
for d in "${COMMAND_DIRS[@]:-}"; do
  [ -n "$d" ] || continue
  mkdir -p "$d"
  substitute "$src" > "$d/${COMMAND}.md"
  ok "wrote $d/${COMMAND}.md"
done

# Vault-scoped ops commands: live inside the vault repo so every
# collaborator who clones the vault gets them.
mkdir -p "$VAULT_ROOT/.claude/commands"
for op in ingest inbox ask lint; do
  substitute "$KIT_DIR/vault-commands/${op}.md" > "$VAULT_ROOT/.claude/commands/${op}.md"
  ok "wrote $VAULT_ROOT/.claude/commands/${op}.md"
done

# ---------- 4. managed sections ----------

echo
bold "Updating agent instructions"
for f in "${INSTRUCTION_FILES[@]}"; do
  write_managed_section "$f"
done

# ---------- done ----------

echo
bold "Done."
dim "Start a fresh agent session so the new instructions load, then try:  /${COMMAND} l my-first-lesson"
dim "Vault README:  $vault_readme"
