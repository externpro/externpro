#!/usr/bin/env bash
set -euo pipefail

trap 'echo "sync-caller-workflows failed at line $LINENO" >&2' ERR

echo "Analyzing workflow template updates..."
WORKFLOW_DIR="${WORKFLOW_DIR:?}"
TEMPLATE_DIR="${TEMPLATE_DIR:?}"
PRESERVE_EXISTING_BRANCHES="${PRESERVE_EXISTING_BRANCHES:-false}"
WORKFLOWS_UPDATED=false
UNEXPECTED_DIFFS=false
REPORT=""
# Check if template directory exists
if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "No workflow templates found in $TEMPLATE_DIR"
  echo "workflows_updated=false" >> "$GITHUB_OUTPUT"
  exit 0
fi
# Install yq for YAML processing
if ! command -v yq &> /dev/null; then
  echo "Installing yq..."
  wget -qO /tmp/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
  chmod +x /tmp/yq
  export PATH="/tmp:$PATH"
fi
# Process each template file
for template_file in "$TEMPLATE_DIR"/*.yml; do
  if [ ! -f "$template_file" ]; then
    continue
  fi
  template_name=$(basename "$template_file")
  workflow_file="$WORKFLOW_DIR/$template_name"
  echo "=== Analyzing $template_name ==="
  # Check if workflow file exists - if not, copy from template
  if [ ! -f "$workflow_file" ]; then
    echo "Workflow $template_name not found, copying from template..."
    cp "$template_file" "$workflow_file"
    echo "✓ Created new workflow $template_name from template"
    REPORT="$REPORT✓ $template_name: Created new workflow from template\n"
    git add "$workflow_file"
    WORKFLOWS_UPDATED=true
    continue
  fi
  # Extract version from template
  set +o pipefail
  TEMPLATE_VERSION=$(yq eval '.jobs.*.uses | sub(".*@", "")' "$template_file" 2>/dev/null | head -1)
  set -o pipefail
  if [ -z "$TEMPLATE_VERSION" ]; then
    echo "No version tag found in template $template_name, skipping"
    continue
  fi
  echo "Template version: $TEMPLATE_VERSION"
  # Get current version from workflow
  set +o pipefail
  CURRENT_VERSION=$(yq eval '.jobs.*.uses | sub(".*@", "")' "$workflow_file" 2>/dev/null | head -1)
  set -o pipefail
  echo "Current version: $CURRENT_VERSION"
  # Create backup
  cp "$workflow_file" "$workflow_file.backup"
  # Extract and report preserved customizations before updating
  echo "Extracting preserved customizations..."
  PRESERVED_REPORT=""
  # Dynamically extract all with: keys to create exclusion pattern
  WITH_KEYS=$(yq eval '.jobs.*.with | keys | .[]' "$workflow_file.backup" 2>/dev/null | grep -v null || true)
  if [ "$template_name" = "xprelease.yml" ]; then
    WITH_KEYS=$(echo "$WITH_KEYS" | grep -v '^workflow_run_url$' || true)
  fi
  if [ -n "$WITH_KEYS" ]; then
    echo "Found with: customization keys:"
    echo "$WITH_KEYS"
    # Create dynamic exclusion pattern for all with: keys
    DYNAMIC_EXCLUSION_PATTERN="with:|$(echo "$WITH_KEYS" | sed 's/$/:/' | tr '\n' '|')"
    DYNAMIC_EXCLUSION_PATTERN=$(echo "$DYNAMIC_EXCLUSION_PATTERN" | sed 's/|$//') # Remove trailing |
    echo "Dynamic exclusion pattern: $DYNAMIC_EXCLUSION_PATTERN"
  else
    DYNAMIC_EXCLUSION_PATTERN="with:"
  fi
  # Extract values for each found key (for reporting)
  while IFS= read -r key; do
    if [ -n "$key" ]; then
      VALUES=$(yq eval ".jobs.*.with.$key" "$workflow_file.backup" 2>/dev/null | grep -v null || true)
      if [ -n "$VALUES" ]; then
        echo "Found $key customizations:"
        echo "$VALUES"
        PRESERVED_REPORT="$PRESERVED_REPORT🔧 $key: $(echo "$VALUES" | tr '\n' ', ' | sed 's/,$//')\n"
      fi
    fi
  done <<< "$WITH_KEYS"
  # Extract and compare branches if preserving existing branches
  if [ "$PRESERVE_EXISTING_BRANCHES" = "true" ]; then
    CURRENT_BRANCHES=$(yq eval '.on.push.branches // [] | .[]' "$workflow_file.backup" 2>/dev/null | tr '\n' ', ' | sed 's/,$//' || true)
    TEMPLATE_BRANCHES=$(yq eval '.on.push.branches // [] | .[]' "$template_file" 2>/dev/null | tr '\n' ', ' | sed 's/,$//' || true)
    if [ -n "$CURRENT_BRANCHES" ] && [ -n "$TEMPLATE_BRANCHES" ] && [ "$CURRENT_BRANCHES" != "$TEMPLATE_BRANCHES" ]; then
      echo "Branches differ from template:"
      echo "  Current: $CURRENT_BRANCHES"
      echo "  Template: $TEMPLATE_BRANCHES"
      PRESERVED_REPORT="$PRESERVED_REPORT🌿 branches: $CURRENT_BRANCHES (template: $TEMPLATE_BRANCHES)\n"
    fi
  fi
  # Update version tag (targeted edit to avoid reformatting YAML)
  if [ "$TEMPLATE_VERSION" != "$CURRENT_VERSION" ]; then
    python3 - "$workflow_file" "$TEMPLATE_VERSION" <<'PY'
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
  fi
  # Update branches unless preserving existing branches
  if [ "$PRESERVE_EXISTING_BRANCHES" != "true" ]; then
    echo "Updating branches from template..."
    CURRENT_BRANCHES_JSON=$(yq eval -o=json '.on.push.branches // []' "$workflow_file.backup" 2>/dev/null)
    TEMPLATE_BRANCHES_JSON=$(yq eval -o=json '.on.push.branches // []' "$template_file" 2>/dev/null)
    if [ -n "$CURRENT_BRANCHES_JSON" ] && [ -n "$TEMPLATE_BRANCHES_JSON" ] && [ "$CURRENT_BRANCHES_JSON" = "$TEMPLATE_BRANCHES_JSON" ]; then
      echo "Branches already match template"
    else
      TEMPLATE_BRANCHES=$(yq eval '.on.push.branches // [] | .[]' "$template_file" 2>/dev/null | tr '\n' ',' | sed 's/,$//' || true)
      if [ -n "$TEMPLATE_BRANCHES" ]; then
        yq eval ".on.push.branches = [$(echo \"$TEMPLATE_BRANCHES\" | sed 's/,/, /g')]" -i "$workflow_file"
        yq eval ".on.pull_request.branches = [$(echo \"$TEMPLATE_BRANCHES\" | sed 's/,/, /g')]" -i "$workflow_file"
        echo "Updated branches to: $TEMPLATE_BRANCHES"
      fi
    fi
  fi
  # Perform diff analysis
  echo "Performing diff analysis..."
  DIFF_OUTPUT=$(diff -u "$workflow_file.backup" "$workflow_file" || true)
  if [ -n "$DIFF_OUTPUT" ]; then
    # Analyze the diff to ensure only expected changes
    VERSION_ONLY_DIFF=$(echo "$DIFF_OUTPUT" | grep -E "^\+.*@|^\-.*@" || true)
    BRANCHES_BEFORE_JSON=$(yq eval -o=json '.on.push.branches // []' "$workflow_file.backup" 2>/dev/null || true)
    BRANCHES_AFTER_JSON=$(yq eval -o=json '.on.push.branches // []' "$workflow_file" 2>/dev/null || true)
    if [ -z "$BRANCHES_BEFORE_JSON" ]; then
      BRANCHES_BEFORE_JSON='[]'
    fi
    if [ -z "$BRANCHES_AFTER_JSON" ]; then
      BRANCHES_AFTER_JSON='[]'
    fi
    BRANCHES_CHANGED=false
    if [ -n "$BRANCHES_BEFORE_JSON" ] && [ -n "$BRANCHES_AFTER_JSON" ] && [ "$BRANCHES_BEFORE_JSON" != "$BRANCHES_AFTER_JSON" ]; then
      BRANCHES_CHANGED=true
    fi
    BRANCHES_DIFF=$(echo "$DIFF_OUTPUT" | grep -E "^\+.*branches|^\-.*branches" || true)
    # Exclude known customizations from "unexpected diffs" using dynamic pattern
    OTHER_DIFF=$(echo "$DIFF_OUTPUT" \
      | grep -E '^[\+\-]' \
      | grep -v -E '^[\+\-]{2,3}' \
      | grep -v -E '@' \
      | grep -v -E 'branches' \
      | grep -v -E "$DYNAMIC_EXCLUSION_PATTERN" \
      || true)
    echo "Changes detected:"
    if [ -n "$VERSION_ONLY_DIFF" ]; then
      echo "$VERSION_ONLY_DIFF"
    fi
    if [ "$BRANCHES_CHANGED" = true ] && [ -n "$BRANCHES_DIFF" ]; then
      echo "$BRANCHES_DIFF"
    fi
    if [ -n "$OTHER_DIFF" ]; then
      echo "$OTHER_DIFF"
    fi
    if [ -n "$OTHER_DIFF" ] && [ "$PRESERVE_EXISTING_BRANCHES" = "true" ]; then
      echo "WARNING: Unexpected changes detected in $template_name"
      echo "$OTHER_DIFF"
      REPORT="$REPORT⚠️ $template_name: Unexpected structural differences detected\n"
      UNEXPECTED_DIFFS=true
    elif [ -n "$OTHER_DIFF" ] && [ "$PRESERVE_EXISTING_BRANCHES" != "true" ]; then
      # Filter out branch changes from "other" diff
      FILTERED_OTHER=$(echo "$OTHER_DIFF" | grep -v -E "branches|^\-\-\-|^\+\+\+" || true)
      if [ -n "$FILTERED_OTHER" ]; then
        echo "WARNING: Unexpected changes detected in $template_name (excluding branches)"
        echo "$FILTERED_OTHER"
        REPORT="$REPORT⚠️ $template_name: Unexpected structural differences detected\n"
        UNEXPECTED_DIFFS=true
      fi
    fi
    # Report expected changes
    if [ -n "$VERSION_ONLY_DIFF" ]; then
      echo "✓ Version updated: $CURRENT_VERSION → $TEMPLATE_VERSION"
      REPORT="$REPORT✓ $template_name: Version updated $CURRENT_VERSION → $TEMPLATE_VERSION\n"
    fi
    if [ "$BRANCHES_CHANGED" = true ] && [ "$PRESERVE_EXISTING_BRANCHES" != "true" ]; then
      echo "✓ Branches updated from template"
      REPORT="$REPORT✓ $template_name: Branches updated from template\n"
    fi
    # Report preserved customizations
    if [ -n "$PRESERVED_REPORT" ]; then
      echo "🔧 Preserved customizations:"
      echo -e "$PRESERVED_REPORT"
      REPORT="$REPORT\n### Preserved Customizations\n$PRESERVED_REPORT"
    fi
    git add "$workflow_file"
    WORKFLOWS_UPDATED=true
    rm "$workflow_file.backup"
  else
    echo "No changes needed for $template_name"
    mv "$workflow_file.backup" "$workflow_file"
  fi
done
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
  echo "workflow_report<<EOF" >> "$GITHUB_OUTPUT"
  echo -e "$REPORT" >> "$GITHUB_OUTPUT"
  echo "EOF" >> "$GITHUB_OUTPUT"
  echo "unexpected_diffs=false" >> "$GITHUB_OUTPUT"
  echo "Workflow updates staged successfully"
else
  echo "workflows_updated=false" >> "$GITHUB_OUTPUT"
  echo "unexpected_diffs=false" >> "$GITHUB_OUTPUT"
  echo "No workflow updates needed"
fi
