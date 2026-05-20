#!/usr/bin/env bash
# obsikit installer
# Sets up Obsidian-vault knowledge-capture conventions for Claude Code:
#   - 5 slash commands under ~/.claude/commands/<prefix>-{lesson,decision,preference,reference,glossary}.md
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

MARKER_BEGIN="<!-- BEGIN obsikit managed section -->"
MARKER_END="<!-- END obsikit managed section -->"

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
  # Replace {{VAULT_ROOT}} and {{PREFIX}} in the file at $1, write to stdout.
  # Uses awk + env vars (no sed delimiters to clash with paths).
  VAULT_ROOT="$VAULT_ROOT" PREFIX="$PREFIX" awk '
    {
      gsub(/\{\{VAULT_ROOT\}\}/, ENVIRON["VAULT_ROOT"])
      gsub(/\{\{PREFIX\}\}/,     ENVIRON["PREFIX"])
      print
    }
  ' "$1"
}

# ---------- preflight ----------

bold "obsikit installer"
echo

if [ ! -d "$CLAUDE_DIR" ]; then
  fail "$CLAUDE_DIR not found."
  echo "  Install Claude Code first: https://docs.claude.com/claude-code" >&2
  exit 1
fi

# ---------- prompts ----------
# Env-var overrides (useful for scripted installs / testing):
#   OBSIKIT_VAULT    skip vault prompt
#   OBSIKIT_PREFIX   skip prefix prompt
#   OBSIKIT_YES=1    skip the final confirmation

default_vault="$HOME/Obsidian"
if [ -n "${OBSIKIT_VAULT:-}" ]; then
  VAULT_INPUT="$OBSIKIT_VAULT"
elif [ -t 0 ]; then
  read -r -p "Path to your Obsidian vault [$default_vault]: " VAULT_INPUT || VAULT_INPUT=""
else
  VAULT_INPUT=""
fi
VAULT_INPUT="${VAULT_INPUT:-$default_vault}"
VAULT_ROOT="$(abs_path "$VAULT_INPUT")"

default_prefix="obsi"
if [ -n "${OBSIKIT_PREFIX:-}" ]; then
  PREFIX_INPUT="$OBSIKIT_PREFIX"
elif [ -t 0 ]; then
  read -r -p "Slash-command prefix [$default_prefix]: " PREFIX_INPUT || PREFIX_INPUT=""
else
  PREFIX_INPUT=""
fi
PREFIX="${PREFIX_INPUT:-$default_prefix}"

if ! [[ "$PREFIX" =~ ^[a-z][a-z0-9-]*$ ]]; then
  fail "prefix must be lowercase letters/digits/hyphens, starting with a letter"
  exit 1
fi

# ---------- plan ----------

echo
bold "Plan"
echo "  Vault root:    $VAULT_ROOT"
echo "  Commands:      $COMMANDS_DIR/${PREFIX}-{lesson,decision,preference,reference,glossary}.md"
echo "  CLAUDE.md:     $CLAUDE_MD  (managed section between BEGIN/END markers)"
echo "  Vault layout:  sources/projects, journal, inbox, wiki  (+ README.md at vault root)"
echo

if [ "${OBSIKIT_YES:-0}" = "1" ]; then
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
for cat in lesson decision preference reference glossary; do
  src="$KIT_DIR/commands/PREFIX-${cat}.md"
  dst="$COMMANDS_DIR/${PREFIX}-${cat}.md"
  if [ ! -f "$src" ]; then
    fail "missing template: $src"
    exit 1
  fi
  substitute "$src" > "$dst"
  ok "wrote $dst"
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
dim "Open a fresh Claude Code session (or run /clear) and try:  /${PREFIX}-lesson"
dim "Vault README:  $vault_readme"
