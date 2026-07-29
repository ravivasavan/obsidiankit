#!/usr/bin/env bash
# obsidiankit installer
# Sets up Obsidian-vault knowledge-capture conventions for Claude Code:
#   - 1 dispatcher slash command at ~/.claude/commands/<command>.md (default: obsidian)
#     covering lesson / decision / preference / reference / glossary
#   - A managed section in ~/.claude/CLAUDE.md wiring the conventions globally
#   - A vault folder skeleton (sources/, journal/, inbox/, wiki/) and onboarding README
#
# Re-running is safe: command files are overwritten, the CLAUDE.md managed section
# is replaced (not appended), the vault skeleton uses mkdir -p, and the vault
# README is not overwritten if you've customised it.

set -euo pipefail

# ---------- paths ----------

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
COMMANDS_DIR="$CLAUDE_DIR/commands"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"

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
  # Replace {{VAULT_ROOT}} and {{COMMAND}} in the file at $1, write to stdout.
  # Uses awk + env vars (no sed delimiters to clash with paths).
  VAULT_ROOT="$VAULT_ROOT" COMMAND="$COMMAND" awk '
    {
      gsub(/\{\{VAULT_ROOT\}\}/, ENVIRON["VAULT_ROOT"])
      gsub(/\{\{COMMAND\}\}/,   ENVIRON["COMMAND"])
      print
    }
  ' "$1"
}

# ---------- preflight ----------

bold "obsidiankit installer"
echo

if [ ! -d "$CLAUDE_DIR" ]; then
  fail "$CLAUDE_DIR not found."
  echo "  Install Claude Code first: https://docs.claude.com/claude-code" >&2
  exit 1
fi

# ---------- prompts ----------
# Env-var overrides (useful for scripted installs / testing):
#   OBSIDIANKIT_VAULT    skip vault prompt
#   OBSIDIANKIT_COMMAND  skip command-name prompt
#   OBSIDIANKIT_YES=1    skip the final confirmation

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
echo "  Command:       $COMMANDS_DIR/${COMMAND}.md  (lesson/decision/preference/reference/glossary as subcommands)"
echo "  Vault cmds:    $VAULT_ROOT/.claude/commands/{ingest,inbox,ask,lint}.md"
echo "  CLAUDE.md:     $CLAUDE_MD  (managed section between BEGIN/END markers)"
echo "  Vault layout:  sources/projects, journal, inbox, wiki  (+ README.md at vault root)"
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
ok "vault tree at $VAULT_ROOT"

# ---------- 2. vault README ----------

vault_readme="$VAULT_ROOT/README.md"
if [ -e "$vault_readme" ]; then
  warn "$vault_readme already exists — not overwriting"
else
  substitute "$KIT_DIR/vault/README.md" > "$vault_readme"
  ok "wrote $vault_readme"
fi

# ---------- 3. slash commands ----------

echo
bold "Installing slash commands"
mkdir -p "$COMMANDS_DIR"
src="$KIT_DIR/commands/obsidian.md"
dst="$COMMANDS_DIR/${COMMAND}.md"
if [ ! -f "$src" ]; then
  fail "missing template: $src"
  exit 1
fi
substitute "$src" > "$dst"
ok "wrote $dst"

# Vault-scoped ops commands: live inside the vault repo so every
# collaborator who clones the vault gets them.
mkdir -p "$VAULT_ROOT/.claude/commands"
for op in ingest inbox ask lint; do
  substitute "$KIT_DIR/vault-commands/${op}.md" > "$VAULT_ROOT/.claude/commands/${op}.md"
  ok "wrote $VAULT_ROOT/.claude/commands/${op}.md"
done

# ---------- 4. CLAUDE.md managed section ----------

echo
bold "Updating CLAUDE.md"

# Make sure file exists before we read it.
touch "$CLAUDE_MD"

# Strip any existing managed section (idempotent re-install).
if grep -qF "$MARKER_BEGIN" "$CLAUDE_MD"; then
  tmp="$(mktemp)"
  awk -v b="$MARKER_BEGIN" -v e="$MARKER_END" '
    $0 == b { skip = 1; next }
    $0 == e { skip = 0; next }
    !skip   { print }
  ' "$CLAUDE_MD" > "$tmp"
  mv "$tmp" "$CLAUDE_MD"
  warn "replaced existing managed section"
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
' "$CLAUDE_MD" > "$tmp"
mv "$tmp" "$CLAUDE_MD"

# Append fresh section, separated from existing content by exactly one blank line.
{
  [ -s "$CLAUDE_MD" ] && echo
  echo "$MARKER_BEGIN"
  substitute "$KIT_DIR/claude-md/snippet.md"
  echo "$MARKER_END"
} >> "$CLAUDE_MD"
ok "managed section written to $CLAUDE_MD"

# ---------- done ----------

echo
bold "Done."
dim "Open a fresh Claude Code session (or run /clear) and try:  /${COMMAND} l my-first-lesson"
dim "Vault README:  $vault_readme"
