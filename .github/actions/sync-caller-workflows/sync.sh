#!/usr/bin/env bash
set -euo pipefail

trap 'echo "sync-caller-workflows failed at line $LINENO" >&2' ERR

echo "Analyzing workflow template updates..."
WORKFLOW_DIR="${WORKFLOW_DIR:?}"
TEMPLATE_DIR="${TEMPLATE_DIR:?}"
PRESERVE_EXISTING_BRANCHES="${PRESERVE_EXISTING_BRANCHES:-false}"
GITHUB_OUTPUT="${GITHUB_OUTPUT:-/dev/null}"
CREATE_MISSING_WORKFLOWS="${CREATE_MISSING_WORKFLOWS:-true}"
WORKFLOWS_UPDATED=false
UNEXPECTED_DIFFS=false
DRIFT_DETECTED=false
REPORT=""

ensure_template_dir() {
  # Check if template directory exists
  if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "No workflow templates found in $TEMPLATE_DIR"
    echo "workflows_updated=false" >> "$GITHUB_OUTPUT"
    exit 0
  fi
}

stage_authoritative_copy() {
  local template_name="$1"
  local workflow_file="$2"
  local template_file="$3"
  local preserved_release_artifact_pattern
  preserved_release_artifact_pattern=""
  if [ "$template_name" = "xprelease.yml" ] && [ -f "$workflow_file.backup" ]; then
    preserved_release_artifact_pattern=$(yq eval '.jobs.release-from-build.with.artifact_pattern // ""' "$workflow_file.backup" 2>/dev/null || true)
    if [ -z "$preserved_release_artifact_pattern" ] || [ "$preserved_release_artifact_pattern" = "null" ]; then
      preserved_release_artifact_pattern=$(yq eval '.jobs.release-from-build.with."artifact-pattern" // ""' "$workflow_file.backup" 2>/dev/null || true)
    fi
    if [ -z "$preserved_release_artifact_pattern" ] || [ "$preserved_release_artifact_pattern" = "null" ]; then
      preserved_release_artifact_pattern=""
    fi
  fi
  cp "$template_file" "$workflow_file"
  if [ "$template_name" = "xprelease.yml" ] && [ -n "$preserved_release_artifact_pattern" ]; then
    yq eval ".jobs.release-from-build.with.artifact_pattern = \"${preserved_release_artifact_pattern}\"" -i "$workflow_file" 2>/dev/null || true
  fi

  if [ "$template_name" = "xprelease.yml" ]; then
    yq eval 'del(.jobs.release-from-build.with."artifact-pattern")' -i "$workflow_file" 2>/dev/null || true
  fi

  local diff_out
  diff_out=$(diff -u "$workflow_file.backup" "$workflow_file" || true)
  if [ -z "$diff_out" ]; then
    echo "No changes needed for $template_name"
    mv "$workflow_file.backup" "$workflow_file"
    return 0
  fi
  git add "$workflow_file"
  WORKFLOWS_UPDATED=true
  rm "$workflow_file.backup"
  echo "✓ $template_name synced from template"
  REPORT="${REPORT}✓ $template_name: Synced from template\n"
}

restore_preserved_with_keys() {
  local workflow_file="$1"
  local workflow_backup="$2"

  local jobs
  jobs=$(yq eval '.jobs | keys | .[]' "$workflow_backup" 2>/dev/null | grep -v null || true)
  if [ -z "$jobs" ]; then
    return 0
  fi
  while IFS= read -r job; do
    [ -z "$job" ] && continue
    local current_with_json
    current_with_json=$(yq eval -o=json ".jobs.${job}.with // {}" "$workflow_file" 2>/dev/null || true)
    if [ -z "$current_with_json" ] || [ "$current_with_json" = "null" ]; then
      current_with_json='{}'
    fi
    local preserved_with_json
    preserved_with_json=$(yq eval -o=json ".jobs.${job}.with // {}" "$workflow_backup" 2>/dev/null || true)
    if [ -z "$preserved_with_json" ] || [ "$preserved_with_json" = "null" ]; then
      preserved_with_json='{}'
    fi

    # Normalize preserved caller inputs from kebab-case to snake_case.
    # This allows a caller repo to keep its custom values while we standardize template inputs.
    preserved_with_json=$(python3 -c 'import json,sys
raw=(sys.stdin.read() or "").strip() or "{}"
try:
  data=json.loads(raw)
except Exception:
  data={}
if not isinstance(data, dict):
  data={}
mapping={
  "artifact-pattern":"artifact_pattern",
  "cmake-workflow-preset":"cmake_workflow_preset",
  "arch-list":"arch_list",
  "buildpro-images":"buildpro_images",
  "enable-tmate":"enable_tmate",
  "name-suffix":"name_suffix",
  "cmake-version":"cmake_version",
  "cmake-preset":"cmake_preset",
  "no-install-preset":"no_install_preset",
  "workflow-run-url":"workflow_run_url",
}
for old,new in mapping.items():
  if new not in data and old in data:
    data[new]=data[old]
  if old in data:
    del data[old]
sys.stdout.write(json.dumps(data))
' <<< "$preserved_with_json")

    if [ "$current_with_json" = "{}" ] && [ "$preserved_with_json" = "{}" ]; then
      continue
    fi
    # Merge caller backup with: into the copied template.
    # - Template keys remain if caller doesn't specify them.
    # - Caller values override template values when both exist.
    yq eval ".jobs.${job}.with = ((.jobs.${job}.with // {}) *+ ${preserved_with_json})" -i "$workflow_file"
    # Ensure any legacy kebab-case keys are removed after merge.
    yq eval "del(.jobs.${job}.with.\"artifact-pattern\") | del(.jobs.${job}.with.\"cmake-workflow-preset\") | del(.jobs.${job}.with.\"arch-list\") | del(.jobs.${job}.with.\"buildpro-images\") | del(.jobs.${job}.with.\"enable-tmate\") | del(.jobs.${job}.with.\"name-suffix\") | del(.jobs.${job}.with.\"cmake-version\") | del(.jobs.${job}.with.\"cmake-preset\") | del(.jobs.${job}.with.\"no-install-preset\") | del(.jobs.${job}.with.\"workflow-run-url\")" -i "$workflow_file" 2>/dev/null || true
    yq eval ".jobs.${job}.with = (.jobs.${job}.with | sort_keys(.))" -i "$workflow_file" 2>/dev/null || true
    local merged_with_json
    merged_with_json=$(yq eval -o=json ".jobs.${job}.with // {}" "$workflow_file" 2>/dev/null || true)
    if [ -z "$merged_with_json" ] || [ "$merged_with_json" = "null" ]; then
      merged_with_json='{}'
    fi
    if [ "$merged_with_json" = "{}" ]; then
      yq eval "del(.jobs.${job}.with)" -i "$workflow_file" 2>/dev/null || true
    fi
  done <<< "$jobs"
}

sync_job_secrets_from_template() {
  local workflow_file="$1"
  local template_file="$2"
  local jobs
  jobs=$(yq eval '.jobs | keys | .[]' "$template_file" 2>/dev/null | grep -v null || true)
  if [ -z "$jobs" ]; then
    return 0
  fi
  while IFS= read -r job; do
    [ -z "$job" ] && continue
    # Allow repos to intentionally omit/disable template jobs.
    # Only sync secrets for jobs that already exist in the repo workflow.
    local job_exists
    job_exists=$(yq eval ".jobs.${job} != null" "$workflow_file" 2>/dev/null || echo "false")
    if [ "$job_exists" != "true" ]; then
      continue
    fi
    local tmpl_secrets_json
    tmpl_secrets_json=$(yq eval -o=json ".jobs.${job}.secrets" "$template_file" 2>/dev/null || true)
    if [ -z "$tmpl_secrets_json" ] || [ "$tmpl_secrets_json" = "null" ]; then
      yq eval "del(.jobs.${job}.secrets)" -i "$workflow_file" 2>/dev/null || true
      continue
    fi
    yq eval ".jobs.${job}.secrets = ${tmpl_secrets_json}" -i "$workflow_file"
  done <<< "$jobs"
}

sync_workflow_name_from_template() {
  local workflow_file="$1"
  local template_file="$2"
  local tmpl_name
  tmpl_name=$(yq eval '.name // ""' "$template_file" 2>/dev/null || true)
  if [ -n "$tmpl_name" ] && [ "$tmpl_name" != "null" ]; then
    yq eval ".name = \"${tmpl_name}\"" -i "$workflow_file"
  fi
}

detect_template_drift() {
  local template_name="$1"
  local workflow_file="$2"
  local template_file="$3"
  local tmp_t
  local tmp_w
  tmp_t=$(mktemp)
  tmp_w=$(mktemp)
  # Preserve caller-specific customizations: we intentionally do not force-template jobs.*.with values.
  yq eval -o=json 'del(.jobs.*.with)' "$template_file" > "$tmp_t" 2>/dev/null || echo "{}" > "$tmp_t"
  yq eval -o=json 'del(.jobs.*.with)' "$workflow_file" > "$tmp_w" 2>/dev/null || echo "{}" > "$tmp_w"
  # Repos may intentionally disable platform jobs (e.g. omit jobs.macos/jobs.windows).
  # Do not treat missing jobs in the repo workflow as template drift.
  python3 - "$tmp_t" "$tmp_w" <<'PY'
import json
import sys
tmpl_path = sys.argv[1]
wf_path = sys.argv[2]
def load(path):
  try:
    with open(path, 'r', encoding='utf-8') as f:
      return json.load(f)
  except Exception:
    return {}
tmpl = load(tmpl_path)
wf = load(wf_path)
wf_jobs = wf.get('jobs')
tmpl_jobs = tmpl.get('jobs')
if isinstance(wf_jobs, dict) and isinstance(tmpl_jobs, dict):
  allowed = set(wf_jobs.keys())
  tmpl['jobs'] = {k: v for k, v in tmpl_jobs.items() if k in allowed}
with open(tmpl_path, 'w', encoding='utf-8') as f:
  json.dump(tmpl, f, sort_keys=True)
with open(wf_path, 'w', encoding='utf-8') as f:
  json.dump(wf, f, sort_keys=True)
PY
  local drift_diff
  drift_diff=$(diff -u "$tmp_t" "$tmp_w" || true)
  rm -f "$tmp_t" "$tmp_w"
  if [ -n "$drift_diff" ]; then
    echo "WARNING: Template drift detected in $template_name (outside preserved customizations)"
    REPORT="${REPORT}⚠️ $template_name: Template drift detected (outside preserved customizations)\n"
    DRIFT_DETECTED=true
  fi
}

ensure_yq() {
  # Install yq for YAML processing
  if ! command -v yq &> /dev/null; then
    echo "Installing yq..."
    wget -qO /tmp/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
    chmod +x /tmp/yq
    export PATH="/tmp:$PATH"
  fi
}

extract_uses_ref() {
  local path="$1"
  set +o pipefail
  local ref
  ref=$(grep -E '^\s*uses:\s*[^#]+@' "$path" 2>/dev/null | head -1 | sed 's/.*@//' || true)
  set -o pipefail
  echo "$ref"
}

extract_preserved_customizations() {
  local template_name="$1"
  local workflow_backup="$2"
  local template_file="$3"
  echo "Extracting preserved customizations..."
  PRESERVED_REPORT=""
  # Extract caller with: keys (preserved customizations)
  WITH_KEYS=$(yq eval '.jobs.*.with | keys | .[]' "$workflow_backup" 2>/dev/null | grep -v null || true)
  # Also extract template with: keys so new template options don't trip "unexpected diffs"
  TEMPLATE_WITH_KEYS=$(yq eval '.jobs.*.with | keys | .[]' "$template_file" 2>/dev/null | grep -v null || true)
  EXCLUSION_WITH_KEYS=$(printf '%s\n%s\n' "${WITH_KEYS}" "${TEMPLATE_WITH_KEYS}" | sort -u | grep -v '^$' || true)
  if [ "$template_name" = "xprelease.yml" ]; then
    WITH_KEYS=$(echo "$WITH_KEYS" | grep -v '^workflow_run_url$' || true)
  fi
  if [ -n "$EXCLUSION_WITH_KEYS" ]; then
    echo "Found with: customization keys:"
    echo "$WITH_KEYS"
    # Create dynamic exclusion pattern for all with: keys
    DYNAMIC_EXCLUSION_PATTERN="with:|$(echo "$EXCLUSION_WITH_KEYS" | sed 's/$/:/' | tr '\n' '|')"
    DYNAMIC_EXCLUSION_PATTERN=$(echo "$DYNAMIC_EXCLUSION_PATTERN" | sed 's/|$//') # Remove trailing |
    echo "Dynamic exclusion pattern: $DYNAMIC_EXCLUSION_PATTERN"
  else
    DYNAMIC_EXCLUSION_PATTERN="with:"
  fi
  # Extract values for each found key (for reporting)
  while IFS= read -r key; do
    if [ -n "$key" ]; then
      VALUES=$(yq eval ".jobs.*.with.$key" "$workflow_backup" 2>/dev/null | grep -v null || true)
      if [ -n "$VALUES" ]; then
        echo "Found $key customizations:"
        echo "$VALUES"
        VALUES_ESCAPED=$(echo "$VALUES" | sed 's/\$/\\\$/g')
        PRESERVED_REPORT="${PRESERVED_REPORT}🔧 $key: $(echo "$VALUES_ESCAPED" | tr '\n' ', ' | sed 's/,$//')\n"
      fi
    fi
  done <<< "$WITH_KEYS"
  # Extract and compare branches if preserving existing branches
  if [ "$PRESERVE_EXISTING_BRANCHES" = "true" ]; then
    CURRENT_BRANCHES=$(yq eval '.on.push.branches // [] | .[]' "$workflow_backup" 2>/dev/null | tr '\n' ', ' | sed 's/,$//' || true)
    TEMPLATE_BRANCHES=$(yq eval '.on.push.branches // [] | .[]' "$template_file" 2>/dev/null | tr '\n' ', ' | sed 's/,$//' || true)
    if [ -n "$CURRENT_BRANCHES" ] && [ -n "$TEMPLATE_BRANCHES" ] && [ "$CURRENT_BRANCHES" != "$TEMPLATE_BRANCHES" ]; then
      echo "Branches differ from template:"
      echo "  Current: $CURRENT_BRANCHES"
      echo "  Template: $TEMPLATE_BRANCHES"
      PRESERVED_REPORT="${PRESERVED_REPORT}🌿 branches: $CURRENT_BRANCHES (template: $TEMPLATE_BRANCHES)\n"
    fi
  fi
}

update_version_ref_in_place() {
  local workflow_file="$1"
  local new_ref="$2"
  python3 - "$workflow_file" "$new_ref" <<'PY'
import re
import sys
path = sys.argv[1]
new_ref = sys.argv[2]
with open(path, 'r', encoding='utf-8') as f:
  lines = f.readlines()
# Replace the ref portion of any "uses: ...@<ref>" line while preserving formatting.
# This avoids yq rewriting the entire YAML and causing cosmetic diffs (e.g. branches spacing).
uses_re = re.compile(r'^(\s*uses:\s*[^#\n]*?)@([^\s#]+)(.*)$')
changed = False
out = []
for line in lines:
  nl = '\n' if line.endswith('\n') else ''
  m = uses_re.match(line)
  if m:
    if m.group(2) != new_ref:
      out.append(f"{m.group(1)}@{new_ref}{m.group(3)}{nl}")
      changed = True
    else:
      out.append(line)
  else:
    out.append(line)
if changed:
  with open(path, 'w', encoding='utf-8') as f:
    f.writelines(out)
PY
}

sync_triggers_from_template() {
  local workflow_file="$1"
  local template_file="$2"
  if [ "$PRESERVE_EXISTING_BRANCHES" = "true" ]; then
    return 0
  fi
  echo "Updating triggers from template..."
  # push.branches
  TEMPLATE_PUSH_BRANCHES_JSON=$(yq eval -o=json '.on.push.branches // []' "$template_file" 2>/dev/null || true)
  if [ -z "$TEMPLATE_PUSH_BRANCHES_JSON" ]; then
    TEMPLATE_PUSH_BRANCHES_JSON='[]'
  fi
  if [ "$TEMPLATE_PUSH_BRANCHES_JSON" != "[]" ]; then
    yq eval ".on.push.branches = $TEMPLATE_PUSH_BRANCHES_JSON" -i "$workflow_file"
  else
    # Remove push.branches if the template does not specify it.
    yq eval 'del(.on.push.branches)' -i "$workflow_file" 2>/dev/null || true
  fi
  # push.tags
  TEMPLATE_PUSH_TAGS_JSON=$(yq eval -o=json '.on.push.tags // []' "$template_file" 2>/dev/null || true)
  if [ -z "$TEMPLATE_PUSH_TAGS_JSON" ]; then
    TEMPLATE_PUSH_TAGS_JSON='[]'
  fi
  if [ "$TEMPLATE_PUSH_TAGS_JSON" != "[]" ]; then
    yq eval ".on.push.tags = $TEMPLATE_PUSH_TAGS_JSON" -i "$workflow_file"
  else
    yq eval 'del(.on.push.tags)' -i "$workflow_file" 2>/dev/null || true
  fi
  # pull_request.branches
  TEMPLATE_PR_BRANCHES_JSON=$(yq eval -o=json '.on.pull_request.branches // []' "$template_file" 2>/dev/null || true)
  if [ -z "$TEMPLATE_PR_BRANCHES_JSON" ]; then
    TEMPLATE_PR_BRANCHES_JSON='[]'
  fi
  if [ "$TEMPLATE_PR_BRANCHES_JSON" != "[]" ]; then
    yq eval ".on.pull_request.branches = $TEMPLATE_PR_BRANCHES_JSON" -i "$workflow_file"
  else
    yq eval 'del(.on.pull_request.branches)' -i "$workflow_file" 2>/dev/null || true
  fi
}

normalize_trigger_formatting() {
  local workflow_file="$1"
  local template_file="$2"
  if [ "$PRESERVE_EXISTING_BRANCHES" = "true" ]; then
    return 0
  fi
  # Normalize trigger formatting to match the template as closely as possible.
  # yq may rewrite single-item arrays into different styles (block vs flow) and may drop quotes.
  python3 - "$workflow_file" "$template_file" <<'PY'
import re
import sys
workflow_path = sys.argv[1]
template_path = sys.argv[2]
with open(template_path, 'r', encoding='utf-8') as f:
  t_lines = f.readlines()
# Capture the exact, single-line formatting from the template (if present).
template_push_tags_line = None
template_pr_branches_line = None
for line in t_lines:
  if template_push_tags_line is None and re.match(r'^\s+tags:\s*\[.*\]\s*$', line):
    template_push_tags_line = line.rstrip('\n')
  if template_pr_branches_line is None and re.match(r'^\s+branches:\s*\[.*\]\s*$', line) and 'pull_request' in ''.join(t_lines[max(0, t_lines.index(line)-3):t_lines.index(line)+1]):
    template_pr_branches_line = line.rstrip('\n')
with open(workflow_path, 'r', encoding='utf-8') as f:
  w_lines = f.readlines()
def indent_len(s: str) -> int:
  return len(s) - len(s.lstrip(' '))
out = []
i = 0
in_on = False
in_push = False
in_pr = False
on_indent = None
push_indent = None
pr_indent = None
while i < len(w_lines):
  line = w_lines[i]
  # Track whether we're inside the on: section.
  if re.match(r'^\s*on:\s*$', line):
    in_on = True
    on_indent = indent_len(line)
    in_push = False
    in_pr = False
    out.append(line)
    i += 1
    continue
  if in_on:
    # Leaving on: section when indentation decreases.
    if line.strip() and indent_len(line) <= (on_indent or 0) and not re.match(r'^\s*(push|pull_request|workflow_dispatch):', line):
      in_on = False
      in_push = False
      in_pr = False
      on_indent = None
  if in_on and re.match(r'^\s*push:\s*$', line):
    in_push = True
    in_pr = False
    push_indent = indent_len(line)
    out.append(line)
    i += 1
    continue
  if in_on and re.match(r'^\s*pull_request:\s*$', line):
    in_pr = True
    in_push = False
    pr_indent = indent_len(line)
    out.append(line)
    i += 1
    continue
  # Rewrite push.tags to match template formatting; skip any block-list form that yq wrote.
  if in_push and re.match(r'^\s*tags:\s*', line):
    if template_push_tags_line is not None:
      tags_indent = indent_len(line)
      out.append(' ' * tags_indent + template_push_tags_line.strip() + '\n')
      i += 1
      # If tags was written as a block sequence, skip its items.
      while i < len(w_lines):
        nxt = w_lines[i]
        if nxt.strip() == '':
          out.append(nxt)
          i += 1
          continue
        if indent_len(nxt) <= tags_indent:
          break
        i += 1
      continue
  # Rewrite pull_request.branches similarly.
  if in_pr and re.match(r'^\s*branches:\s*', line):
    if template_pr_branches_line is not None:
      b_indent = indent_len(line)
      out.append(' ' * b_indent + template_pr_branches_line.strip() + '\n')
      i += 1
      # Skip any block sequence items.
      while i < len(w_lines):
        nxt = w_lines[i]
        if nxt.strip() == '':
          out.append(nxt)
          i += 1
          continue
        if indent_len(nxt) <= b_indent:
          break
        i += 1
      continue
  out.append(line)
  i += 1
with open(workflow_path, 'w', encoding='utf-8') as f:
  f.writelines(out)
PY
}

analyze_diff_and_stage() {
  local template_name="$1"
  local workflow_file="$2"
  local template_file="$3"
  local current_version="$4"
  local template_version="$5"
  echo "Performing diff analysis..."
  detect_template_drift "$template_name" "$workflow_file" "$template_file"
  DIFF_OUTPUT=$(diff -u "$workflow_file.backup" "$workflow_file" || true)
  if [ -z "$DIFF_OUTPUT" ]; then
    echo "No changes needed for $template_name"
    mv "$workflow_file.backup" "$workflow_file"
    return 0
  fi
  # Analyze the diff to ensure only expected changes
  VERSION_ONLY_DIFF=$(echo "$DIFF_OUTPUT" | grep -E "^\+.*@|^\-.*@" || true)
  BRANCHES_BEFORE_JSON=$(yq eval -o=json '.on.push.branches // []' "$workflow_file.backup" 2>/dev/null || true)
  BRANCHES_AFTER_JSON=$(yq eval -o=json '.on.push.branches // []' "$workflow_file" 2>/dev/null || true)
  TAGS_BEFORE_JSON=$(yq eval -o=json '.on.push.tags // []' "$workflow_file.backup" 2>/dev/null || true)
  TAGS_AFTER_JSON=$(yq eval -o=json '.on.push.tags // []' "$workflow_file" 2>/dev/null || true)
  PR_BRANCHES_BEFORE_JSON=$(yq eval -o=json '.on.pull_request.branches // []' "$workflow_file.backup" 2>/dev/null || true)
  PR_BRANCHES_AFTER_JSON=$(yq eval -o=json '.on.pull_request.branches // []' "$workflow_file" 2>/dev/null || true)
  if [ -z "$BRANCHES_BEFORE_JSON" ]; then
    BRANCHES_BEFORE_JSON='[]'
  fi
  if [ -z "$BRANCHES_AFTER_JSON" ]; then
    BRANCHES_AFTER_JSON='[]'
  fi
  if [ -z "$TAGS_BEFORE_JSON" ]; then
    TAGS_BEFORE_JSON='[]'
  fi
  if [ -z "$TAGS_AFTER_JSON" ]; then
    TAGS_AFTER_JSON='[]'
  fi
  if [ -z "$PR_BRANCHES_BEFORE_JSON" ]; then
    PR_BRANCHES_BEFORE_JSON='[]'
  fi
  if [ -z "$PR_BRANCHES_AFTER_JSON" ]; then
    PR_BRANCHES_AFTER_JSON='[]'
  fi
  BRANCHES_CHANGED=false
  if [ -n "$BRANCHES_BEFORE_JSON" ] && [ -n "$BRANCHES_AFTER_JSON" ] && [ "$BRANCHES_BEFORE_JSON" != "$BRANCHES_AFTER_JSON" ]; then
    BRANCHES_CHANGED=true
  fi
  BRANCHES_DIFF=$(echo "$DIFF_OUTPUT" | grep -E "^\+.*branches|^\-.*branches" || true)
  TAGS_CHANGED=false
  if [ -n "$TAGS_BEFORE_JSON" ] && [ -n "$TAGS_AFTER_JSON" ] && [ "$TAGS_BEFORE_JSON" != "$TAGS_AFTER_JSON" ]; then
    TAGS_CHANGED=true
  fi
  TAGS_DIFF=$(echo "$DIFF_OUTPUT" | grep -E "^\+.*tags|^\-.*tags" || true)
  NAME_BEFORE=$(yq eval '.name // ""' "$workflow_file.backup" 2>/dev/null || true)
  NAME_AFTER=$(yq eval '.name // ""' "$workflow_file" 2>/dev/null || true)
  NAME_CHANGED=false
  if [ -n "$NAME_BEFORE" ] && [ -n "$NAME_AFTER" ] && [ "$NAME_BEFORE" != "$NAME_AFTER" ]; then
    NAME_CHANGED=true
  fi
  NAME_DIFF=$(echo "$DIFF_OUTPUT" | grep -E "^[\+\-]name:" || true)
  PR_BRANCHES_CHANGED=false
  if [ -n "$PR_BRANCHES_BEFORE_JSON" ] && [ -n "$PR_BRANCHES_AFTER_JSON" ] && [ "$PR_BRANCHES_BEFORE_JSON" != "$PR_BRANCHES_AFTER_JSON" ]; then
    PR_BRANCHES_CHANGED=true
  fi
  PR_BRANCHES_DIFF=$(echo "$DIFF_OUTPUT" | grep -E "^\+.*pull_request|^\-.*pull_request|^\+.*branches|^\-.*branches" || true)
  # Exclude known customizations from "unexpected diffs" using dynamic pattern
  OTHER_DIFF=$(echo "$DIFF_OUTPUT" \
    | grep -E '^[\+\-]' \
    | grep -v -E '^[\+\-]{2,3}' \
    | grep -v -E '@' \
    | grep -v -E '^[\+\-]name:' \
    | grep -v -E 'branches' \
    | grep -v -E 'tags' \
    | grep -v -E 'secrets' \
    | grep -v -E "$DYNAMIC_EXCLUSION_PATTERN" \
    || true)
  echo "Changes detected:"
  if [ -n "$VERSION_ONLY_DIFF" ]; then
    echo "$VERSION_ONLY_DIFF"
  fi
  if [ "$NAME_CHANGED" = true ] && [ -n "$NAME_DIFF" ]; then
    echo "$NAME_DIFF"
  fi
  if [ "$BRANCHES_CHANGED" = true ] && [ -n "$BRANCHES_DIFF" ]; then
    echo "$BRANCHES_DIFF"
  fi
  if [ "$TAGS_CHANGED" = true ] && [ -n "$TAGS_DIFF" ]; then
    echo "$TAGS_DIFF"
  fi
  if [ -n "$OTHER_DIFF" ]; then
    echo "$OTHER_DIFF"
  fi
  if [ -n "$OTHER_DIFF" ] && [ "$PRESERVE_EXISTING_BRANCHES" = "true" ]; then
    echo "WARNING: Unexpected changes detected in $template_name"
    echo "$OTHER_DIFF"
    REPORT="${REPORT}⚠️ $template_name: Unexpected structural differences detected\n"
    UNEXPECTED_DIFFS=true
  elif [ -n "$OTHER_DIFF" ] && [ "$PRESERVE_EXISTING_BRANCHES" != "true" ]; then
    # Filter out branch changes from "other" diff
    FILTERED_OTHER=$(echo "$OTHER_DIFF" | grep -v -E "branches|tags|^[\+\-]\s*-\s*|^\-\-\-|^\+\+\+" || true)
    if [ -n "$FILTERED_OTHER" ]; then
      echo "WARNING: Unexpected changes detected in $template_name (excluding branches)"
      echo "$FILTERED_OTHER"
      REPORT="${REPORT}⚠️ $template_name: Unexpected structural differences detected\n"
      UNEXPECTED_DIFFS=true
    fi
  fi
  # Report expected changes
  if [ -n "$VERSION_ONLY_DIFF" ]; then
    echo "✓ Version updated: $current_version → $template_version"
    REPORT="${REPORT}✓ $template_name: Version updated $current_version → $template_version\n"
  fi
  if [ "$PRESERVE_EXISTING_BRANCHES" != "true" ]; then
    if [ "$NAME_CHANGED" = true ]; then
      echo "✓ workflow name updated from template"
      REPORT="${REPORT}✓ $template_name: workflow name updated from template\n"
    fi
    if [ "$BRANCHES_CHANGED" = true ]; then
      echo "✓ push.branches updated from template"
      REPORT="${REPORT}✓ $template_name: push.branches updated from template\n"
    fi
    if [ "$TAGS_CHANGED" = true ]; then
      echo "✓ push.tags updated from template"
      REPORT="${REPORT}✓ $template_name: push.tags updated from template\n"
    fi
    if [ "$PR_BRANCHES_CHANGED" = true ]; then
      echo "✓ pull_request.branches updated from template"
      REPORT="${REPORT}✓ $template_name: pull_request.branches updated from template\n"
    fi
  fi
  # Report preserved customizations
  if [ -n "$PRESERVED_REPORT" ]; then
    echo "🔧 Preserved customizations:"
    echo -e "$PRESERVED_REPORT"
    REPORT="${REPORT}\n### Preserved Customizations\n${PRESERVED_REPORT}"
  fi
  git add "$workflow_file"
  WORKFLOWS_UPDATED=true
  rm "$workflow_file.backup"
}

finalize_report_and_outputs() {
  # Generate final report
  if [ -n "$REPORT" ]; then
    echo "=== Workflow Update Report ==="
    echo -e "$REPORT"
    echo "================================"
  fi
  # Fail if unexpected diffs were found
  if [ "$UNEXPECTED_DIFFS" = true ]; then
    echo "ERROR: Unexpected structural differences detected. Manual review required."
    echo "unexpected_diffs=true" >> "$GITHUB_OUTPUT"
    exit 1
  fi
  if [ "$WORKFLOWS_UPDATED" = true ]; then
    echo "workflows_updated=true" >> "$GITHUB_OUTPUT"
    echo "Workflow updates staged successfully"
  else
    echo "workflows_updated=false" >> "$GITHUB_OUTPUT"
    echo "No workflow updates needed"
  fi
  if [ -n "$REPORT" ]; then
    SAFE_REPORT=$(printf "%b" "$REPORT" | sed 's/\$/\\\$/g')
    echo "workflow_report<<EOF" >> "$GITHUB_OUTPUT"
    echo "$SAFE_REPORT" >> "$GITHUB_OUTPUT"
    echo "EOF" >> "$GITHUB_OUTPUT"
  fi
  echo "unexpected_diffs=false" >> "$GITHUB_OUTPUT"
  echo "drift_detected=${DRIFT_DETECTED}" >> "$GITHUB_OUTPUT"
}

process_template_file() {
  local template_file="$1"
  if [ ! -f "$template_file" ]; then
    return 0
  fi
  local template_name
  template_name=$(basename "$template_file")
  local workflow_file
  workflow_file="$WORKFLOW_DIR/$template_name"
  echo "=== Analyzing $template_name ==="
  # Check if workflow file exists - if not, copy from template
  if [ ! -f "$workflow_file" ]; then
    if [ "$CREATE_MISSING_WORKFLOWS" = "true" ]; then
      echo "Workflow $template_name not found, copying from template..."
      cp "$template_file" "$workflow_file"
      echo "✓ Created new workflow $template_name from template"
      REPORT="${REPORT}✓ $template_name: Created new workflow from template\n"
      git add "$workflow_file"
      WORKFLOWS_UPDATED=true
      return 0
    fi
    echo "Workflow $template_name not found, skipping (CREATE_MISSING_WORKFLOWS=false)"
    return 0
  fi
  TEMPLATE_VERSION=$(extract_uses_ref "$template_file")
  if [ -z "$TEMPLATE_VERSION" ]; then
    echo "No version tag found in template $template_name, skipping"
    return 0
  fi
  echo "Template version: $TEMPLATE_VERSION"
  CURRENT_VERSION=$(extract_uses_ref "$workflow_file")
  echo "Current version: $CURRENT_VERSION"
  # Create backup
  cp "$workflow_file" "$workflow_file.backup"
  if [ "$template_name" != "xpbuild.yml" ]; then
    if [ "$template_name" = "xpupdate.yml" ]; then
      echo "$template_name is authoritative; syncing from template (preserving caller with: customizations)"
      extract_preserved_customizations "$template_name" "$workflow_file.backup" "$template_file"
      cp "$template_file" "$workflow_file"
      restore_preserved_with_keys "$workflow_file" "$workflow_file.backup"
      analyze_diff_and_stage "$template_name" "$workflow_file" "$template_file" "$CURRENT_VERSION" "$TEMPLATE_VERSION"
      return 0
    fi
    echo "$template_name is authoritative; syncing from template"
    stage_authoritative_copy "$template_name" "$workflow_file" "$template_file"
    return 0
  fi
  extract_preserved_customizations "$template_name" "$workflow_file.backup" "$template_file"
  # Update version tag (targeted edit to avoid reformatting YAML)
  if [ "$TEMPLATE_VERSION" != "$CURRENT_VERSION" ]; then
    update_version_ref_in_place "$workflow_file" "$TEMPLATE_VERSION"
  fi
  # Update triggers unless preserving existing branches
  # Notes:
  # - Some workflows (e.g. xpbuild) intentionally migrate from push.branches -> push.tags.
  # - pull_request.branches should follow the template (often differs from push.*).
  sync_workflow_name_from_template "$workflow_file" "$template_file"
  sync_triggers_from_template "$workflow_file" "$template_file"
  normalize_trigger_formatting "$workflow_file" "$template_file"
  sync_job_secrets_from_template "$workflow_file" "$template_file"
  restore_preserved_with_keys "$workflow_file" "$workflow_file.backup"
  analyze_diff_and_stage "$template_name" "$workflow_file" "$template_file" "$CURRENT_VERSION" "$TEMPLATE_VERSION"
}

main() {
  ensure_template_dir
  ensure_yq
  # Process each template file
  for template_file in "$TEMPLATE_DIR"/*.yml; do
    process_template_file "$template_file"
  done
  finalize_report_and_outputs
}

main
