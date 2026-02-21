#!/usr/bin/env bash
set -euo pipefail

trap 'echo "sync-caller-workflows failed at line $LINENO" >&2' ERR

echo "Analyzing workflow template updates..."
WORKFLOW_DIR="${WORKFLOW_DIR:?}"
TEMPLATE_DIR="${TEMPLATE_DIR:?}"
GITHUB_OUTPUT="${GITHUB_OUTPUT:-/dev/null}"
PRESERVE_EXISTING_BRANCHES="${PRESERVE_EXISTING_BRANCHES:-false}"
# Preserve dropped jobs (drop template jobs that are not present in the existing repo workflow)
PRESERVE_DROPPED_JOBS="${PRESERVE_DROPPED_JOBS:-true}"
# Which workflow files should apply the dropped-jobs rule.
# Default: only xpbuild.yml needs this (to drop macos/windows for linux-only repos).
JOB_DROP_WORKFLOWS="${JOB_DROP_WORKFLOWS:-xpbuild.yml}"
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
  repo_jobs=""
  repo_jobs=$(yq eval '.jobs | keys | .[]' "$workflow_backup" 2>/dev/null | grep -v null || true)
  if [ "$PRESERVE_DROPPED_JOBS" = "true" ] && printf ' %s ' "$JOB_DROP_WORKFLOWS" | grep -q " ${template_name} "; then
    tmpl_jobs=$(yq eval '.jobs | keys | .[]' "$template_file" 2>/dev/null | grep -v null || true)
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
  fi
  # 3) Preserve repo-added jobs.<job>.with keys (added keys only)
  local renamed_keys_accum
  renamed_keys_accum=""
  local unknown_legacy_keys_accum
  unknown_legacy_keys_accum=""
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
$job =~ s/\r\z//;
my $backup=$ENV{BACKUP_FILE};
open(my $fh, "<", $backup) or next;
local $/;
my $b = <$fh>;
close($fh);
my $with_blk = "";
if ($b =~ m/^  \Q$job\E:\s*\r?\n(?:(?!^  \S).*(?:\n|\z))*?^(    with:\n(?:(?:^      .*?(?:\n|\z))*))/m) {
  $with_blk = $1;
}
if (length($with_blk)) {
  # Rename known legacy kebab-case keys to snake_case in-place.
  my %map = (
    "artifact-pattern" => "artifact_pattern",
    "cmake-workflow-preset" => "cmake_workflow_preset",
    "arch-list" => "arch_list",
    "buildpro-images" => "buildpro_images",
    "enable-tmate" => "enable_tmate",
    "name-suffix" => "name_suffix",
    "cmake-version" => "cmake_version",
    "cmake-preset" => "cmake_preset",
    "no-install-preset" => "no_install_preset",
    "workflow-run-url" => "workflow_run_url",
  );
  for my $k (keys %map) {
    my $v = $map{$k};
    $with_blk =~ s/^(\s{6})\Q$k\E:/$1$v:/mg;
  }
  # Insert the with: block under the correct job by scanning lines.
  $with_blk =~ s/\n\z//;
  my @with_lines = split(/\n/, $with_blk, -1);
  my @lines = split(/\n/, $_, -1);
  my @out;
  my $in_job = 0;
  my $inserted = 0;
  for (my $i = 0; $i < @lines; $i++) {
    my $line = $lines[$i];
    $line =~ s/\r\z//;
    if ($line =~ /^  \Q$job\E:\s*\r?$/) {
      $in_job = 1;
    } elsif ($in_job && $line =~ /^  \S/ && $line !~ /^  \Q$job\E:\s*\r?$/) {
      $in_job = 0;
    }
    if ($in_job && !$inserted && $line =~ /^    uses: .*$/) {
      # If this job already has a with: block, do not insert another.
      my $has_with = 0;
      for (my $j = $i + 1; $j < @lines; $j++) {
        my $l2 = $lines[$j];
        $l2 =~ s/\r\z//;
        last if $l2 =~ /^  \S/;
        if ($l2 =~ /^    with:$/) { $has_with = 1; last; }
      }
      push @out, $line;
      if (!$has_with) {
        push @out, @with_lines;
        $inserted = 1;
      }
      next;
    }
    push @out, $line;
  }
  $_ = join("\n", @out);
}
' "$workflow_file" 2>/dev/null || true
      REPORT="${REPORT}🔧 ${template_name}: preserved with block jobs.${job}.with\n"
      # Track renamed legacy keys (for report).
      repo_with_keys=$(yq eval ".jobs.${job}.with | keys | .[]" "$workflow_backup" 2>/dev/null | grep -v null || true)
      local renamed_keys
      renamed_keys=$(printf '%s\n' "$repo_with_keys" | grep -E '^(artifact-pattern|cmake-workflow-preset|arch-list|buildpro-images|enable-tmate|name-suffix|cmake-version|cmake-preset|no-install-preset|workflow-run-url)$' || true)
      if [ -n "$renamed_keys" ]; then
        renamed_keys_accum=$(printf '%s\n%s' "$renamed_keys_accum" "$renamed_keys" | sed '/^$/d' | sort -u)
      fi
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
      # Destination key name (auto-rename known legacy kebab-case keys to snake_case).
      local dest_key
      dest_key="$key"
      case "$key" in
        artifact-pattern) dest_key="artifact_pattern";;
        cmake-workflow-preset) dest_key="cmake_workflow_preset";;
        arch-list) dest_key="arch_list";;
        buildpro-images) dest_key="buildpro_images";;
        enable-tmate) dest_key="enable_tmate";;
        name-suffix) dest_key="name_suffix";;
        cmake-version) dest_key="cmake_version";;
        cmake-preset) dest_key="cmake_preset";;
        no-install-preset) dest_key="no_install_preset";;
        workflow-run-url) dest_key="workflow_run_url";;
      esac
      if [ "$dest_key" != "$key" ]; then
        renamed_keys_accum=$(printf '%s\n%s' "$renamed_keys_accum" "$key" | sed '/^$/d' | sort -u)
      elif printf '%s' "$key" | grep -q -- '-'; then
        unknown_legacy_keys_accum=$(printf '%s\n%s' "$unknown_legacy_keys_accum" "$key" | sed '/^$/d' | sort -u)
      fi
      # Extract and insert in perl to avoid Bash expanding GitHub expressions like "${{ ... }}".
      JOB="$job" SRC_KEY="$key" DEST_KEY="$dest_key" BACKUP_FILE="$workflow_backup" perl -0777 -i -pe '
my $job=$ENV{JOB};
$job =~ s/\r\z//;
my $src_key=$ENV{SRC_KEY};
my $dest_key=$ENV{DEST_KEY};
my $backup=$ENV{BACKUP_FILE};
open(my $fh, "<", $backup) or next;
local $/;
my $b = <$fh>;
close($fh);
my $value = "";
if ($b =~ m/^  \Q$job\E:\s*\r?\n(?:(?!^  \S).*(?:\n|\z))*?^    with:\n(?:(?!^    \S).*(?:\n|\z))*?^      \Q$src_key\E:\s*([^\n]*)$/m) {
  $value = $1;
}
next if $value eq "" || $value eq "null";
# Guardrails: GitHub workflow inputs are strings; also unquoted globs/flow collections can parse oddly.
if ($value !~ /^".*"\z/ && $value !~ /^\x27.*\x27\z/) {
  if ($value =~ /^\[.*\]\z/ || $value =~ /^\{.*\}\z/ || $value =~ /\*/) {
    $value = "\x27".$value."\x27";
  }
}
my $insert = "      ${dest_key}: ${value}\n";
# Insert deterministically:
# - If with: exists, insert at end of with: block (before next 4-space key)
# - Otherwise create with: immediately after uses:
my @lines = split(/\n/, $_, -1);
my @out;
my $in_job = 0;
my $in_with = 0;
my $inserted = 0;
my $dest_present = 0;
for (my $i=0; $i<@lines; $i++) {
  my $line = $lines[$i];
  $line =~ s/\r\z//;
  if ($line =~ /^  \Q$job\E:\s*\r?$/) {
    $in_job = 1;
    $in_with = 0;
  } elsif ($in_job && $line =~ /^  \S/ && $line !~ /^  \Q$job\E:\s*\r?$/) {
    # next job
    if ($in_with && !$inserted && !$dest_present) { push @out, "      ${dest_key}: ${value}"; $inserted=1; }
    $in_job = 0;
    $in_with = 0;
  }
  if ($in_job) {
    if ($line =~ /^    with:$/) {
      $in_with = 1;
    } elsif ($in_with) {
      if ($line =~ /^      \Q$dest_key\E:/) { $dest_present = 1; }
      if ($line =~ /^    \S/) {
        # leaving with: block
        if (!$inserted && !$dest_present) { push @out, "      ${dest_key}: ${value}"; $inserted=1; }
        $in_with = 0;
      }
    }
    # If no with block exists, create it right after uses:
    if (!$inserted && !$dest_present && !$in_with && $line =~ /^    uses: .*$/) {
      # Look ahead within this job: if a with: block already exists, do not create a new one.
      my $has_with = 0;
      for (my $j = $i + 1; $j < @lines; $j++) {
        my $l2 = $lines[$j];
        $l2 =~ s/\r\z//;
        last if $l2 =~ /^  \S/;          # next job / end jobs
        if ($l2 =~ /^    with:$/) { $has_with = 1; last; }
      }
      if (!$has_with) {
        push @out, $line;
        push @out, "    with:";
        push @out, "      ${dest_key}: ${value}";
        $inserted = 1;
        next;
      }
    }
  }
  push @out, $line;
}
if ($in_with && !$inserted && !$dest_present) { push @out, "      ${dest_key}: ${value}"; $inserted=1; }
$_ = join("\n", @out);
' "$workflow_file" 2>/dev/null || true
      REPORT="${REPORT}🔧 ${template_name}: preserved added with key jobs.${job}.with.${key}\n"
    done <<< "$added_keys"
  done <<< "$repo_jobs"
  if [ -n "$renamed_keys_accum" ]; then
    REPORT="${REPORT}🔧 workflow_call input keys renamed (kebab-case → snake_case):\n$(echo "$renamed_keys_accum" | sed 's/^/  - /')\n"
  fi
  if [ -n "$unknown_legacy_keys_accum" ]; then
    echo "WARNING: Unrecognized kebab-case 'with:' keys detected (no auto-rename applied):"
    echo "$unknown_legacy_keys_accum" | sed 's/^/  - /'
    REPORT="${REPORT}⚠️ Unrecognized kebab-case 'with:' keys detected (no auto-rename applied):\n$(echo "$unknown_legacy_keys_accum" | sed 's/^/  - /')\n"
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
