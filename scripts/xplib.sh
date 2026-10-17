#!/usr/bin/env bash
# xplib.sh — shared helpers for externpro shell scripts and workflow steps.
# Source this file; it is not meant to be executed directly.
#
# Consumers: scripts/migrate-layout.sh, scripts/bootstrap.sh,
# scripts/ensure-presets.sh, .github/workflows/sync-externpro.yml.

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo "xplib.sh is a library — source it, don't run it" >&2
  exit 1
fi

# stage_symlink <link-path> <target>
# Stages a symlink via the index (mode 120000) rather than the working tree,
# so the committed entry is a real symlink even on platforms (Windows) where
# `ln -s` produces a copy or plain-text file. Never `git add` a symlink path.
# Stages only — the caller owns the commit.
stage_symlink() {
  local link="$1" target="$2" blob
  blob=$(printf '%s' "$target" | git hash-object -w --stdin)
  git update-index --add --cacheinfo "120000,$blob,$link"
}

# is_index_link_path <path>
# Paths staged via stage_symlink — must never be passed to `git add`
# (a plain add of a symlink path on Windows stages mode 100644).
is_index_link_path() {
  case "$1" in
    .devcontainer|docker-compose.sh|docker-compose.yml) return 0 ;;
    *) return 1 ;;
  esac
}
