#!/usr/bin/env bash
# ensure-gitignore.sh — ensure externpro-managed .gitignore entries exist and
# the '# externpro' comment heads the first managed entry.
#
# Shared by scripts/bootstrap.sh and .github/workflows/sync-externpro.yml.
# Missing entries are appended at EOF (existing content is never reordered);
# a missing or misplaced '# externpro' comment is inserted above / moved above
# the first managed entry, healing layouts where the entries predate the
# comment (e.g. appended by an older workflow).
#
# Usage: ensure-gitignore.sh [repo-root]   (default: current directory)

set -euo pipefail

repo_root="${1:-.}"
gi="$repo_root/.gitignore"
touch "$gi"

comment="# externpro"
entries=(".env" "_bld*/" "docker-compose.override.yml")

# first_line <literal> -> 1-based line number of its first exact match, or ""
first_line() {
    grep -nFx -- "$1" "$gi" 2>/dev/null | head -1 | cut -d: -f1 || true
}

# Ensure each managed entry exists (append missing at EOF)
added=false
for entry in "${entries[@]}"; do
    if grep -Fxq -- "$entry" "$gi"; then
        continue
    fi
    echo "adding to .gitignore: $entry"
    printf '%s\n' "$entry" >> "$gi"
    added=true
done

# Locate the first managed entry and the section comment (entries are
# guaranteed present at this point, so entry_ln is always set)
entry_ln=""
for entry in "${entries[@]}"; do
    ln=$(first_line "$entry")
    if [ -n "$ln" ] && { [ -z "$entry_ln" ] || [ "$ln" -lt "$entry_ln" ]; }; then
        entry_ln="$ln"
    fi
done
comment_ln=$(first_line "$comment")

if [ -n "$comment_ln" ] && [ "$comment_ln" -lt "$entry_ln" ]; then
    # comment already sits above the managed section
    [ "$added" = true ] || echo ".gitignore externpro entries already up to date"
    exit 0
fi

if [ -n "$comment_ln" ]; then
    # orphaned comment below the managed entries — remove it so it can be
    # re-inserted (it sits below entry_ln, so entry_ln is unaffected)
    awk -v n="$comment_ln" 'NR != n' "$gi" > "$gi.tmp" && mv "$gi.tmp" "$gi"
fi

# Insert the comment immediately above the first managed entry
awk -v n="$entry_ln" -v c="$comment" 'NR == n { print c } { print }' "$gi" > "$gi.tmp" && mv "$gi.tmp" "$gi"
echo "placed '$comment' section header above the first managed entry"
