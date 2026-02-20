#!/usr/bin/env bash
set -euo pipefail

trap 'echo "sync-caller-workflows failed at line $LINENO" >&2' ERR

echo "Analyzing workflow template updates..."
WORKFLOW_DIR="${WORKFLOW_DIR:?}"
TEMPLATE_DIR="${TEMPLATE_DIR:?}"
GITHUB_OUTPUT="${GITHUB_OUTPUT:-/dev/null}"
PRESERVE_EXISTING_BRANCHES="${PRESERVE_EXISTING_BRANCHES:-false}"
WORKFLOWS_UPDATED=false
REPORT=""

ensure_template_dir() {
  # Check if template directory exists
  if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "No workflow templates found in $TEMPLATE_DIR"
    echo "workflows_updated=false" >> "$GITHUB_OUTPUT"
    exit 0
  fi
}

apply_preservation_rules() {
  local template_name="$1"
  local workflow_file="$2"
  local workflow_backup="$3"
  local template_file="$4"
  # 1) Preserve existing triggers when requested
  # If preserve_existing_branches=true, keep the repo's existing arrays for:
  # - on.push.branches
  # - on.pull_request.branches
  # while keeping everything else from the template.
  if [ "$PRESERVE_EXISTING_BRANCHES" = "true" ]; then
    local push_branches_json
    local pr_branches_json
    push_branches_json=$(yq eval -o=json '.on.push.branches // null' "$workflow_backup" 2>/dev/null || true)
    pr_branches_json=$(yq eval -o=json '.on.pull_request.branches // null' "$workflow_backup" 2>/dev/null || true)
    # Replace only the content inside the existing "[...]" flow-style lists in the copied template.
    # This keeps template formatting (indentation/spacing) and only changes the bracket contents.
    if [ -n "$push_branches_json" ] && [ "$push_branches_json" != "null" ]; then
      local push_branches_list
      push_branches_list=$(yq eval '.on.push.branches[]' "$workflow_backup" 2>/dev/null || true)
      push_branches_list=$(printf '%s\n' "$push_branches_list" | sed '/^$/d' | sed 's/\\/\\\\/g; s/"/\\"/g' | awk 'BEGIN{first=1}{if(!first){printf ", "}; printf "\"%s\"", $0; first=0}END{print ""}')
      if [ -n "$push_branches_list" ]; then
        perl -0777 -i -pe "s/(\n\s*push:\s*\n(?:(?!\n\S).)*?\n\s*branches:\s*\[)[^\]]*(\])/$1${push_branches_list}$2/s" "$workflow_file" 2>/dev/null || true
        REPORT="${REPORT}🔧 ${template_name}: preserved on.push.branches\n"
      fi
    fi
    if [ -n "$pr_branches_json" ] && [ "$pr_branches_json" != "null" ]; then
      local pr_branches_list
      pr_branches_list=$(yq eval '.on.pull_request.branches[]' "$workflow_backup" 2>/dev/null || true)
      pr_branches_list=$(printf '%s\n' "$pr_branches_list" | sed '/^$/d' | sed 's/\\/\\\\/g; s/"/\\"/g' | awk 'BEGIN{first=1}{if(!first){printf ", "}; printf "\"%s\"", $0; first=0}END{print ""}')
      if [ -n "$pr_branches_list" ]; then
        perl -0777 -i -pe "s/(\n\s*pull_request:\s*\n(?:(?!\n\S).)*?\n\s*branches:\s*\[)[^\]]*(\])/$1${pr_branches_list}$2/s" "$workflow_file" 2>/dev/null || true
        REPORT="${REPORT}🔧 ${template_name}: preserved on.pull_request.branches\n"
      fi
    fi
  fi
  # 2) Preserve dropped jobs (if repo removed jobs, keep them removed)
  local tmpl_jobs
  local repo_jobs
  tmpl_jobs=$(yq eval '.jobs | keys | .[]' "$template_file" 2>/dev/null | grep -v null || true)
  repo_jobs=$(yq eval '.jobs | keys | .[]' "$workflow_backup" 2>/dev/null | grep -v null || true)
  local jobs_to_drop
  jobs_to_drop=$(comm -23 <(printf '%s\n' "$tmpl_jobs" | sort) <(printf '%s\n' "$repo_jobs" | sort) || true)
  if [ -n "$jobs_to_drop" ]; then
    while IFS= read -r job; do
      [ -z "$job" ] && continue
      # Delete the entire job block, including a final line that may not end with a newline.
      JOB="$job" perl -0777 -i -pe 'my $job=$ENV{JOB}; s/(^jobs:\n.*?)(^  \Q$job\E:\n(?:(?!^  \S|^\S).*(?:\n|\z))*)/$1/ms;' "$workflow_file" 2>/dev/null || true
      REPORT="${REPORT}🔧 ${template_name}: preserved dropped job jobs.${job}\n"
    done <<< "$jobs_to_drop"
  fi
  # 3) Preserve repo-added jobs.<job>.with keys (added keys only)
  local legacy_keys_accum
  legacy_keys_accum=""
  while IFS= read -r job; do
    [ -z "$job" ] && continue
    local repo_with_keys
    local tmpl_with_keys
    local tmpl_with_json
    local repo_with_json
    tmpl_with_json=$(yq eval -o=json ".jobs.${job}.with // null" "$template_file" 2>/dev/null || true)
    repo_with_json=$(yq eval -o=json ".jobs.${job}.with // null" "$workflow_backup" 2>/dev/null || true)
    # If the template has no with block but the repo does, preserve the entire with block verbatim.
    # This is common for caller workflows like xpbuild where template defines uses/secrets but repo adds inputs.
    if [ "$tmpl_with_json" = "null" ] && [ -n "$repo_with_json" ] && [ "$repo_with_json" != "null" ]; then
      # Do the extraction/insertion entirely in perl to avoid Bash expanding "${{ ... }}".
      JOB="$job" BACKUP_FILE="$workflow_backup" perl -0777 -i -pe '
my $job=$ENV{JOB};
my $backup=$ENV{BACKUP_FILE};
open(my $fh, "<", $backup) or next;
local $/;
my $b = <$fh>;
close($fh);
my $with_blk = "";
if ($b =~ m/^  \Q$job\E:\n(?:(?!^  \S).*(?:\n|\z))*?^(    with:\n(?:(?:^      .*?(?:\n|\z))*))/m) {
  $with_blk = $1;
}
if (length($with_blk)) {
  $with_blk .= "\n" unless $with_blk =~ /\n\z/;
  s/(^  \Q$job\E:\n(?:(?!^  \S).*(?:\n|\z))*)(?=^  \S|\z)/$1.$with_blk/mse;
}
' "$workflow_file" 2>/dev/null || true
      REPORT="${REPORT}🔧 ${template_name}: preserved with block jobs.${job}.with\n"
      continue
    fi
    repo_with_keys=$(yq eval ".jobs.${job}.with | keys | .[]" "$workflow_backup" 2>/dev/null | grep -v null || true)
    tmpl_with_keys=$(yq eval ".jobs.${job}.with | keys | .[]" "$template_file" 2>/dev/null | grep -v null || true)
    local added_keys
    added_keys=$(comm -23 <(printf '%s\n' "$repo_with_keys" | sort) <(printf '%s\n' "$tmpl_with_keys" | sort) || true)
    if [ -z "$added_keys" ]; then
      continue
    fi
    while IFS= read -r key; do
      [ -z "$key" ] && continue
      # Extract and insert in perl to avoid Bash expanding GitHub expressions like "${{ ... }}".
      JOB="$job" KEY="$key" BACKUP_FILE="$workflow_backup" perl -0777 -i -pe '
my $job=$ENV{JOB};
my $key=$ENV{KEY};
my $backup=$ENV{BACKUP_FILE};
open(my $fh, "<", $backup) or next;
local $/;
my $b = <$fh>;
close($fh);
my $value = "";
if ($b =~ m/^  \Q$job\E:\n(?:(?!^  \S).*(?:\n|\z))*?^    with:\n(?:(?!^    \S).*(?:\n|\z))*?^      \Q$key\E:\s*([^\n]*)$/m) {
  $value = $1;
}
next if $value eq "" || $value eq "null";
# Guardrails: GitHub workflow inputs are strings; also unquoted globs/flow collections can parse oddly.
if ($value !~ /^".*"\z/ && $value !~ /^\x27.*\x27\z/) {
  if ($value =~ /^\[.*\]\z/ || $value =~ /^\{.*\}\z/ || $value =~ /\*/) {
    $value = "\x27".$value."\x27";
  }
}
my $insert = "      ${key}: ${value}\n";
# 1) If with: exists, append at end of with block (unless key already present).
if (m/^  \Q$job\E:\n(?:(?!^  \S).*(?:\n|\z))*?^    with:\n/ms) {
  if (m/^  \Q$job\E:\n(?:(?!^  \S).*(?:\n|\z))*?^    with:\n(?:(?!^    \S).*(?:\n|\z))*?^      \Q$key\E:/ms) {
    # key already present; do nothing
  } else {
    s/(^  \Q$job\E:\n(?:(?!^  \S).*(?:\n|\z))*?^    with:\n(?:(?:^      .*\n)*)?)/$1.$insert/mes;
  }
} else {
  # 2) No with: block: add one at the end of the job block.
  #    Insert before the next job (two-space indent) or end of file.
  s/(^  \Q$job\E:\n(?:(?!^  \S).*(?:\n|\z))*)(?=^  \S|\z)/$1."    with:\n".$insert/mse;
}
' "$workflow_file" 2>/dev/null || true
      REPORT="${REPORT}🔧 ${template_name}: preserved added with key jobs.${job}.with.${key}\n"
    done <<< "$added_keys"
    # Also warn on legacy kebab-case keys (no renames)
    local legacy_keys
    legacy_keys=$(printf '%s\n' "$repo_with_keys" | grep -E '^(artifact-pattern|cmake-workflow-preset|arch-list|buildpro-images|enable-tmate|name-suffix|cmake-version|cmake-preset|no-install-preset|workflow-run-url)$' || true)
    if [ -n "$legacy_keys" ]; then
      legacy_keys_accum=$(printf '%s\n%s' "$legacy_keys_accum" "$legacy_keys" | sed '/^$/d' | sort -u)
    fi
  done <<< "$repo_jobs"
  if [ -n "$legacy_keys_accum" ]; then
    echo "WARNING: Legacy kebab-case 'with:' keys detected; please rename to snake_case:"
    echo "$legacy_keys_accum" | sed 's/^/  - /'
    REPORT="${REPORT}⚠️ workflow_call input key rename needed (kebab-case → snake_case):\n$(echo "$legacy_keys_accum" | sed 's/^/  - /')\n"
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

finalize_report_and_outputs() {
  if [ -n "$REPORT" ]; then
    echo "=== Workflow Update Report ==="
    echo -e "$REPORT"
    echo "================================"
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
    echo "Workflow $template_name not found, copying from template..."
    cp "$template_file" "$workflow_file"
    echo "✓ Created new workflow $template_name from template"
    REPORT="${REPORT}✓ $template_name: Created new workflow from template\n"
    git add "$workflow_file"
    WORKFLOWS_UPDATED=true
    return 0
  fi
  # Create backup
  cp "$workflow_file" "$workflow_file.backup"
  # Template is always authoritative.
  cp "$template_file" "$workflow_file"
  apply_preservation_rules "$template_name" "$workflow_file" "$workflow_file.backup" "$template_file"

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
