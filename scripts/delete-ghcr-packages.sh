#!/usr/bin/env bash
# delete-ghcr-packages.sh - delete GHCR container packages (bldimg-*) created by
# the build-linux workflow in a forked repository.
# Details: .devcontainer/.github/docs/secrets-and-tokens.md ("Deleting GHCR
# packages in a fork")
set -euo pipefail

dry_run=true
org=false
repo=""
owner=""
pattern=""
env_file=""

usage() {
  cat <<'EOF'
Usage: delete-ghcr-packages.sh [options]

Delete GHCR container packages created by the build-linux workflow in a
forked repo. Lists matches by default; pass --yes to delete.

  -n, --dry-run      list matching packages without deleting (default)
  -y, --yes          delete the matching packages
  -r, --repo NAME    repo name to match (default: basename of origin remote)
  -o, --owner NAME   package owner (default: authenticated user)
      --org          treat --owner as an organization
  -p, --pattern GLOB package name glob (default: '<repo>/bldimg-*')
  -e, --env-file F   .env file containing GHCR_TOKEN
  -h, --help         show this help

Token: GHCR_TOKEN env var, a .env file, or `gh auth token` — a classic PAT
with read:packages and delete:packages scopes:
  https://github.com/settings/tokens/new?scopes=read:packages,delete:packages

Examples:
  delete-ghcr-packages.sh           # dry-run: list <repo>/bldimg-* packages
  delete-ghcr-packages.sh -y        # delete them
  delete-ghcr-packages.sh -r myrepo -y  # orphaned pkgs after repo deleted
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run)  dry_run=true ;;
    -y|--yes)      dry_run=false ;;
    -r|--repo)     repo="$2"; shift ;;
    -o|--owner)    owner="$2"; shift ;;
    --org)         org=true ;;
    -p|--pattern)  pattern="$2"; shift ;;
    -e|--env-file) env_file="$2"; shift ;;
    -h|--help)     usage; exit 0 ;;
    *) echo "ERROR: unknown option '$1' (try --help)" >&2; exit 1 ;;
  esac
  shift
done

command -v gh >/dev/null || { echo "ERROR: gh CLI required (https://cli.github.com)" >&2; exit 1; }

# --- token resolution -------------------------------------------------------
if [ -z "${GHCR_TOKEN:-}" ]; then
  candidates=("${env_file}" ".env")
  if top=$(git rev-parse --show-toplevel 2>/dev/null); then
    candidates+=("${top}/.env")
  fi
  for f in "${candidates[@]}"; do
    [ -n "${f}" ] && [ -f "${f}" ] || continue
    val=$(grep -E '^[[:space:]]*GHCR_TOKEN[[:space:]]*=' "${f}" | tail -1 | cut -d= -f2- \
          | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/^"\(.*\)"$/\1/; s/^'"'"'\(.*\)'"'"'$/\1/')
    if [ -n "${val}" ]; then
      GHCR_TOKEN="${val}"
      echo "Using GHCR_TOKEN from ${f}"
      break
    fi
  done
fi
if [ -z "${GHCR_TOKEN:-}" ]; then
  if GHCR_TOKEN=$(gh auth token 2>/dev/null) && [ -n "${GHCR_TOKEN}" ]; then
    echo "Using token from 'gh auth token' (requires read:packages,delete:packages scopes;"
    echo "add them with: gh auth refresh -s read:packages,delete:packages)"
  else
    echo "ERROR: no token found. Set GHCR_TOKEN or create a .env file (see --help)." >&2
    exit 1
  fi
fi
export GH_TOKEN="${GHCR_TOKEN}"

# --- repo/owner resolution --------------------------------------------------
if [ -z "${repo}" ]; then
  url=$(git remote get-url origin 2>/dev/null) \
    || { echo "ERROR: no origin remote; pass --repo NAME" >&2; exit 1; }
  repo=$(basename "${url}" .git | tr '[:upper:]' '[:lower:]')
fi
if [ -z "${owner}" ]; then
  owner=$(gh api user --jq .login) \
    || { echo "ERROR: could not determine authenticated user (check token scopes)" >&2; exit 1; }
fi
owner=$(echo "${owner}" | tr '[:upper:]' '[:lower:]')
[ -z "${pattern}" ] && pattern="${repo}/bldimg-*"

# --- list packages ----------------------------------------------------------
if ${org}; then
  list_ep="/orgs/${owner}/packages?package_type=container&per_page=100"
  del_ep="/orgs/${owner}/packages/container"
else
  self=$(gh api user --jq .login | tr '[:upper:]' '[:lower:]')
  if [ "${owner}" = "${self}" ]; then
    list_ep="/user/packages?package_type=container&per_page=100"
    del_ep="/user/packages/container"
  else
    list_ep="/users/${owner}/packages?package_type=container&per_page=100"
    del_ep="/users/${owner}/packages/container"
  fi
fi

echo "Listing container packages for '${owner}' matching '${pattern}' ..."
names=$(gh api --paginate "${list_ep}" --jq '.[].name') \
  || { echo "ERROR: failed to list packages (check token/owner)" >&2; exit 1; }

matched=()
while IFS= read -r n; do
  [ -z "${n}" ] && continue
  # shellcheck disable=SC2254
  case "${n}" in ${pattern}) matched+=("${n}") ;; esac
done <<< "${names}"

if [ ${#matched[@]} -eq 0 ]; then
  echo "No matching packages found."
  exit 0
fi
printf '  %s\n' "${matched[@]}"

if ${dry_run}; then
  echo "Dry run: re-run with --yes to delete ${#matched[@]} package(s)."
  exit 0
fi

# --- delete -----------------------------------------------------------------
rc=0
for n in "${matched[@]}"; do
  enc="${n//\//%2F}"
  echo "Deleting ${owner}/${n} ..."
  if gh api -X DELETE "${del_ep}/${enc}" >/dev/null; then
    echo "  deleted ${n}"
  else
    echo "  FAILED to delete ${n}" >&2
    rc=1
  fi
done
exit ${rc}
