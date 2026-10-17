#!/usr/bin/env bash
# ensure-presets.sh — migrate a consuming repo's root preset files to the
# xpPresets model: managed CMakePresets.json symlink, real xpPresets.json
# only for special-includes repos, project-owned xpPresetsBase.json.
#
# Shared by scripts/bootstrap.sh and .github/workflows/sync-externpro.yml
# ("one implementation, two callers"). Run from anywhere:
#   ensure-presets.sh [repo-root] [externpro-dir]   (defaults: . .externpro)
#
# Everything is staged but NOT committed — the caller owns the commit.
# Idempotent. Skips gracefully (warn + exit 0) when the submodule predates
# the xpPresets rename or python3 is unavailable. Foreign files — upstream
# CMakePresets.json, unrelated symlinks, an xpPresets.json symlink — are
# warned about and left untouched.
set -euo pipefail

REPO="${1:-.}"
SUB="${2:-.externpro}"

SUB="$(cd "$SUB" 2>/dev/null && pwd)" || {
  echo "presets: WARNING externpro dir not found at ${2:-.externpro} — skipping" >&2
  exit 0
}
cd "$REPO"

# --- preconditions -----------------------------------------------------------
command -v python3 >/dev/null 2>&1 || {
  echo "presets: WARNING python3 not found — cannot compare presets JSON, skipping" >&2
  exit 0
}
TEMPLATE="$SUB/cmake/presets/xpPresets.json"
BASE_TEMPLATE="$SUB/cmake/presets/xpPresetsBase.json"
if [ ! -f "$TEMPLATE" ] || [ ! -f "$BASE_TEMPLATE" ]; then
  echo "presets: WARNING $SUB predates the xpPresets rename — skipping" >&2
  exit 0
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/xplib.sh"   # stage_symlink

# --- helpers -----------------------------------------------------------------
report() { echo "presets: $*"; }
warn()   { echo "presets: WARNING $*"; }

real_xp() { [ -f xpPresets.json ] && [ ! -L xpPresets.json ]; }

link_target() {
  if real_xp; then echo "xpPresets.json"; else echo ".externpro/cmake/presets/xpPresets.json"; fi
}

# Update the worktree link (best-effort) and stage mode 120000.
make_link() {
  ln -sf "$1" "$2" 2>/dev/null || true
  stage_symlink "$2" "$1"
}

# Remove a path the script owns: git rm if tracked, rm if untracked.
xp_remove() {
  if git ls-files --error-unmatch "$1" >/dev/null 2>&1; then
    git rm -q "$1" 2>/dev/null \
      || { git rm -qf "$1"; warn "$1 had uncommitted changes — removed anyway"; }
  else
    rm -f "$1"
  fi
}

# Parse + normalize + apply known fixes to a presets file. Prints two lines:
#   XPINC=0|1   — any include under .externpro/cmake/presets/
#   <canonical> — whole document, key-sorted, fixes applied
# Prints UNPARSEABLE and nothing else on JSON errors.
presets_probe() {
  python3 - "$1" <<'PY'
import json, sys
try:
    doc = json.load(open(sys.argv[1]))
except Exception:
    print("UNPARSEABLE")
    sys.exit(0)
incs = doc.get("include", [])
if not isinstance(incs, list):
    incs = [incs]
fixed = []
for i in incs:
    i = i.replace(".devcontainer/", ".externpro/")
    if i == ".externpro/cmake/presets/xpWindowsVs2022.json":
        fixed += [".externpro/cmake/presets/xpMswVs2022.json",
                  ".externpro/cmake/presets/xpMswVs2026.json"]
    else:
        fixed.append(i)
doc["include"] = fixed
has_xp_includes = any(i.startswith(".externpro/cmake/presets/") for i in fixed)
print("XPINC=%d" % (1 if has_xp_includes else 0))
print(json.dumps(doc, sort_keys=True, separators=(",", ":")))
PY
}

# Same fixes as presets_probe, but rewrites <file> in place, pretty-printed.
presets_fix_write() {
  python3 - "$1" <<'PY'
import json, sys
doc = json.load(open(sys.argv[1]))
incs = doc.get("include", [])
if not isinstance(incs, list):
    incs = [incs]
fixed = []
for i in incs:
    i = i.replace(".devcontainer/", ".externpro/")
    if i == ".externpro/cmake/presets/xpWindowsVs2022.json":
        fixed += [".externpro/cmake/presets/xpMswVs2022.json",
                  ".externpro/cmake/presets/xpMswVs2026.json"]
    else:
        fixed.append(i)
doc["include"] = fixed
with open(sys.argv[1], "w") as f:
    json.dump(doc, f, indent=2)
    f.write("\n")
PY
}

template_canon=$(python3 -c \
  'import json,sys;print(json.dumps(json.load(open(sys.argv[1])),sort_keys=True,separators=(",",":")))' \
  "$TEMPLATE")

# --- 0. pre-existing root xpPresets.json -------------------------------------
# Real file is legal only as a special-includes file: normalize stale
# .devcontainer/ includes in place. A symlink here is foreign — leave it.
if [ -L xpPresets.json ]; then
  warn "xpPresets.json is a symlink — foreign, left untouched"
elif real_xp && grep -q '\.devcontainer/' xpPresets.json; then
  presets_fix_write xpPresets.json
  git add xpPresets.json
  report "xpPresets.json: normalized .devcontainer/ include paths in place"
fi

# --- 1-3. CMakePresets.json --------------------------------------------------
if [ -f CMakePresets.json ] && [ ! -L CMakePresets.json ]; then
  probe=$(presets_probe CMakePresets.json)
  if [ "$probe" = "UNPARSEABLE" ]; then
    warn "CMakePresets.json is not parseable JSON — foreign, left untouched"
  else
    xp_inc=$(echo "$probe" | head -1)
    canon=$(echo "$probe" | tail -1)
    if real_xp; then
      # existing special-includes file wins — never clobber it
      if [ "$canon" = "$template_canon" ]; then
        xp_remove CMakePresets.json
        make_link xpPresets.json CMakePresets.json
        report "CMakePresets.json: duplicate of template removed, symlink -> xpPresets.json staged"
      else
        warn "CMakePresets.json differs and root xpPresets.json exists — ambiguous, left untouched"
      fi
    elif [ "$canon" = "$template_canon" ]; then
      xp_remove CMakePresets.json
      make_link .externpro/cmake/presets/xpPresets.json CMakePresets.json
      report "CMakePresets.json: matched template (post-normalization), symlink -> $(link_target) staged"
    elif [ "$xp_inc" = "XPINC=1" ]; then
      # externpro includes beyond the template — becomes the real xpPresets.json
      if [ -e xpPresets.json ] || [ -L xpPresets.json ]; then
        warn "CMakePresets.json has externpro includes but xpPresets.json exists — left untouched"
      elif git ls-files --error-unmatch CMakePresets.json >/dev/null 2>&1; then
        git mv CMakePresets.json xpPresets.json
        presets_fix_write xpPresets.json
        git add xpPresets.json
        make_link xpPresets.json CMakePresets.json
        report "CMakePresets.json: special externpro includes — moved to xpPresets.json, symlink staged"
      else
        mv CMakePresets.json xpPresets.json
        presets_fix_write xpPresets.json
        git add xpPresets.json
        make_link xpPresets.json CMakePresets.json
        report "CMakePresets.json: special externpro includes — moved (untracked) to xpPresets.json, symlink staged"
      fi
    else
      warn "CMakePresets.json has no externpro includes — upstream/foreign, left untouched"
    fi
  fi
elif [ -L CMakePresets.json ]; then
  old_target=$(readlink CMakePresets.json)
  case "$old_target" in
    xpPresets.json|.devcontainer/*|.externpro/*)
      new_target=$(link_target)
      if [ "$old_target" != "$new_target" ]; then
        make_link "$new_target" CMakePresets.json
        report "CMakePresets.json: repointed symlink $old_target -> $new_target"
      fi
      ;;
    *) warn "CMakePresets.json is a symlink to $old_target — foreign, left untouched" ;;
  esac
else
  make_link "$(link_target)" CMakePresets.json
  report "CMakePresets.json: absent — staged symlink -> $(link_target)"
fi

# --- 4-5. CMakePresetsBase.json -> xpPresetsBase.json --------------------------
# Project-owned real file: content carried verbatim, never auto-rewritten.
if [ -f CMakePresetsBase.json ] && [ ! -L CMakePresetsBase.json ]; then
  if [ -e xpPresetsBase.json ]; then
    if git ls-files --error-unmatch CMakePresetsBase.json >/dev/null 2>&1; then
      git rm -q CMakePresetsBase.json
      warn "CMakePresetsBase.json removed — existing xpPresetsBase.json kept (old copy in git history)"
    else
      warn "CMakePresetsBase.json is untracked and xpPresetsBase.json exists — left for manual removal"
    fi
  elif git ls-files --error-unmatch CMakePresetsBase.json >/dev/null 2>&1; then
    git mv CMakePresetsBase.json xpPresetsBase.json
    report "CMakePresetsBase.json -> xpPresetsBase.json (renamed, content verbatim)"
  else
    mv CMakePresetsBase.json xpPresetsBase.json
    git add xpPresetsBase.json
    report "CMakePresetsBase.json -> xpPresetsBase.json (untracked rename)"
  fi
fi
if [ ! -e xpPresetsBase.json ]; then
  cp "$BASE_TEMPLATE" xpPresetsBase.json
  git add xpPresetsBase.json
  report "xpPresetsBase.json: copied from externpro template (project-owned, never auto-rewritten)"
fi
