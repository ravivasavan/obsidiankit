#!/usr/bin/env bash
# vault-doctor — confirm a shared Obsidian vault is a real, current git clone.
#
#   vault-doctor.sh <vault-path> [<owner>/<repo> | <git-url>]
#
# Fails (exit 1) when the folder is not the root of a git work tree, has no
# `origin`, or `origin` points somewhere other than the expected repo. Warns
# (exit 0) when it can't reach the remote, when the clone is behind, or when
# the vault sits inside a cloud-sync folder that can copy it without `.git`.
#
# Why: a vault that was copied or synced instead of cloned looks normal in
# Obsidian, but pull-at-start and push-at-wrap fail without anyone noticing,
# and the agent quietly reads and writes a stale copy.

set -uo pipefail

red()   { printf "  \033[31m✗\033[0m %s\n" "$*"; }
amber() { printf "  \033[33m!\033[0m %s\n" "$*"; }
green() { printf "  \033[32m✓\033[0m %s\n" "$*"; }

# github.com:owner/repo(.git), https://github.com/owner/repo(.git), owner/repo -> owner/repo
slug() {
  printf "%s" "$1" | sed -E 's#^(git@|ssh://git@|https?://)([^/:]+)[:/]##; s#\.git$##; s#/$##' | tr 'A-Z' 'a-z'
}

[ $# -ge 1 ] || { echo "usage: vault-doctor.sh <vault-path> [<owner>/<repo>]"; exit 2; }
VAULT="${1/#\~\//$HOME/}"
EXPECTED="${2:-}"
status=0

echo "vault-doctor: $VAULT"

if [ ! -d "$VAULT" ]; then
  red "folder does not exist"; exit 1
fi

top="$(git -C "$VAULT" rev-parse --show-toplevel 2>/dev/null || true)"
real="$(cd "$VAULT" && pwd -P)"
if [ -z "$top" ]; then
  red "not a git repo (no .git). This is a copy, not a clone."
  red "fix: move this folder aside, then: git clone <url> \"$VAULT\""
  exit 1
fi
if [ "$(cd "$top" && pwd -P)" != "$real" ]; then
  red "git root is $top, not the vault folder. The vault is nested inside another repo."
  exit 1
fi
green "git work tree"

origin="$(git -C "$VAULT" remote get-url origin 2>/dev/null || true)"
if [ -z "$origin" ]; then
  red "no 'origin' remote, so pull and push have nowhere to go"
  [ -n "$EXPECTED" ] && red "fix: git -C \"$VAULT\" remote add origin https://github.com/$(slug "$EXPECTED").git"
  exit 1
fi
if [ -n "$EXPECTED" ] && [ "$(slug "$origin")" != "$(slug "$EXPECTED")" ]; then
  red "origin is $origin, expected $(slug "$EXPECTED")"
  exit 1
fi
green "origin $origin"

case "$real" in
  *"/Library/Mobile Documents/"*|*"/Library/CloudStorage/"*|*"/Dropbox/"*|*"/Dropbox ("*|*"/Google Drive/"*|*"/OneDrive"*|*"/iCloud Drive/"*)
    amber "vault is inside a cloud-sync folder. Sync tools can copy it without .git or fight git; move it under ~/Projects."
    ;;
esac

if git -C "$VAULT" fetch --quiet origin 2>/dev/null; then
  branch="$(git -C "$VAULT" rev-parse --abbrev-ref HEAD 2>/dev/null)"
  upstream="$(git -C "$VAULT" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  if [ -z "$upstream" ]; then
    amber "branch '$branch' has no upstream; run: git -C \"$VAULT\" branch -u origin/$branch"
  else
    read -r behind ahead < <(git -C "$VAULT" rev-list --left-right --count "$upstream...HEAD")
    [ "$behind" -gt 0 ] && amber "$behind commit(s) behind $upstream; pull before reading" || green "up to date with $upstream"
    [ "$ahead" -gt 0 ] && amber "$ahead local commit(s) not pushed"
  fi
else
  amber "could not reach origin (offline or no access). Say so before working from this copy."
fi

[ -n "$(git -C "$VAULT" status --porcelain 2>/dev/null)" ] && amber "uncommitted changes in the vault"

exit $status
