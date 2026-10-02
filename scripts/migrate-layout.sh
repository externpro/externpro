#!/usr/bin/env bash
# migrate-layout.sh — migrate the externpro submodule from .devcontainer/ to
# .externpro/ in the superproject this script is run from.
#
# Shared by scripts/bootstrap.sh and .github/workflows/sync-externpro.yml
# ("one implementation, two callers"). Run from the SUPERPROJECT root.
# Idempotent: exits 0 immediately unless .gitmodules registers an externpro
# submodule at path .devcontainer.
#
# IMPORTANT for callers: this script lives inside the directory it moves —
# bash reads script files incrementally, so a plain
#   bash .devcontainer/scripts/migrate-layout.sh
# can fail mid-run when `git mv` relocates the file. Copy it out first:
#   tmp=$(mktemp) && cp .devcontainer/scripts/migrate-layout.sh "$tmp" && bash "$tmp"
#
# Everything is staged but NOT committed — the caller owns the commit.
set -euo pipefail

# commit_symlink <link-path> <target>
# Commits a symlink via the index (mode 120000) rather than the working tree,
# so the committed entry is a real symlink even on platforms (Windows) where
# `ln -s` produces a copy or plain-text file. Never `git add` a symlink path.
commit_symlink() {
  local link="$1" target="$2" blob
  blob=$(printf '%s' "$target" | git hash-object -w --stdin)
  git update-index --add --cacheinfo "120000,$blob,$link"
}

# --- detect legacy layout ---------------------------------------------------
# Only migrate when .gitmodules registers a submodule at path .devcontainer
# whose URL is externpro/externpro. A .devcontainer dir/link/file that isn't
# an externpro submodule is left untouched.
[ -f .gitmodules ] || exit 0
dc_path=$(git config -f .gitmodules --get 'submodule..devcontainer.path' 2>/dev/null || true)
dc_url=$(git config -f .gitmodules --get 'submodule..devcontainer.url' 2>/dev/null || true)
if [ "$dc_path" != ".devcontainer" ] || ! echo "$dc_url" | grep -qE 'externpro/externpro(\.git)?$'; then
  exit 0  # nothing to migrate
fi

echo "Migrating externpro submodule: .devcontainer -> .externpro"

# --- move the submodule -----------------------------------------------------
git submodule update --init .devcontainer  # git mv needs it populated
git mv .devcontainer .externpro            # moves worktree + gitlink, updates .gitmodules path
git config -f .gitmodules --rename-section \
  submodule..devcontainer submodule..externpro
git submodule sync                         # refresh .git/config for new path/name
git config --remove-section submodule..devcontainer || true  # drop stale local section
git add .gitmodules

# --- .devcontainer discovery link (only if the path is free) ----------------
staged_links=()
if [ ! -e .devcontainer ] && [ ! -L .devcontainer ]; then
  ln -s .externpro .devcontainer || true   # best-effort for the working tree
  commit_symlink .devcontainer .externpro
  staged_links+=(.devcontainer)
else
  echo "note: .devcontainer already exists (dir/link/file) — leaving it" \
    "untouched; externpro devcontainer auto-discovery is skipped"
fi

# --- root compose links ------------------------------------------------------
# Re-point paths that are absent or already symlinks (a stale link into
# .devcontainer/ dangles after git mv and must be re-pointed). A project-owned
# regular file is left untouched.
for pair in \
  "docker-compose.sh .externpro/compose.pro.sh" \
  "docker-compose.yml .externpro/compose.bld.yml"; do
  set -- $pair
  if [ ! -e "$1" ] || [ -L "$1" ]; then
    ln -sf "$2" "$1" || true               # best-effort for the working tree
    commit_symlink "$1" "$2"
    staged_links+=("$1")
  else
    echo "warning: $1 is a project-owned regular file — left untouched"
  fi
done

# --- verification -------------------------------------------------------------
# Assert the expected index state: 160000 gitlink for .externpro, 120000 for
# each link we staged. Display the entries for CI logs, then fail loudly if
# any mode is wrong rather than leaving a half-migrated repo.
echo "Post-migration index state:"
git ls-files -s .externpro .devcontainer docker-compose.sh docker-compose.yml
fail=0
git ls-files -s -- .externpro | grep -q '^160000' \
  || { echo "ERROR: .externpro is not a 160000 submodule gitlink" >&2; fail=1; }
for l in "${staged_links[@]+"${staged_links[@]}"}"; do
  git ls-files -s -- "$l" | grep -q '^120000' \
    || { echo "ERROR: $l is not a 120000 symlink entry" >&2; fail=1; }
done
[ "$fail" -eq 0 ] || exit 1
echo "Migration complete (staged, not committed)."
