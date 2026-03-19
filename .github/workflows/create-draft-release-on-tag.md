---
name: Create Draft Release on Tag
on:
  create: null
permissions:
  contents: read
  metadata: read
engine: copilot
safe-outputs:
  jobs:
    create-draft-release:
      description: Create a draft GitHub release for the new tag
      runs-on: ubuntu-latest
      permissions:
        contents: write
      inputs:
        tag:
          description: Tag name to create the release from
          required: true
          type: string
        title:
          description: Release title
          required: true
          type: string
        notes:
          description: Markdown body for the release notes
          required: false
          type: string
        prerelease:
          description: Whether the release should be marked as a prerelease
          required: false
          type: boolean
        draft:
          description: Whether the release should be a draft
          required: false
          type: boolean
          default: "true"
        generate_notes:
          description: Whether to use GitHub auto-generated release notes
          required: false
          type: boolean
          default: "true"
      steps:
        - name: Create draft release
          shell: bash
          run: |
            set -euo pipefail
            if [ ! -f "$GH_AW_AGENT_OUTPUT" ]; then
              echo "Missing GH_AW_AGENT_OUTPUT" >&2
              exit 1
            fi
            TAG=$(jq -r '.items[] | select(.type == "create_draft_release") | .tag' "$GH_AW_AGENT_OUTPUT" | head -n1)
            TITLE=$(jq -r '.items[] | select(.type == "create_draft_release") | .title' "$GH_AW_AGENT_OUTPUT" | head -n1)
            NOTES=$(jq -r '.items[] | select(.type == "create_draft_release") | .notes' "$GH_AW_AGENT_OUTPUT" | head -n1)
            PRERELEASE=$(jq -r '.items[] | select(.type == "create_draft_release") | .prerelease' "$GH_AW_AGENT_OUTPUT" | head -n1)
            DRAFT=$(jq -r '.items[] | select(.type == "create_draft_release") | .draft' "$GH_AW_AGENT_OUTPUT" | head -n1)
            GEN=$(jq -r '.items[] | select(.type == "create_draft_release") | .generate_notes' "$GH_AW_AGENT_OUTPUT" | head -n1)
            if [ -z "$TAG" ] || [ "$TAG" = "null" ]; then
              echo "Missing required output field: tag" >&2
              exit 1
            fi
            if [ -z "$TITLE" ] || [ "$TITLE" = "null" ]; then
              TITLE="$TAG"
            fi
            if [ -z "$PRERELEASE" ] || [ "$PRERELEASE" = "null" ]; then
              t="$TAG"
              if [[ "$t" == v* ]]; then
                t="${t#v}"
              fi
              if [[ "$t" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                PRERELEASE=true
              elif [[ "$t" =~ ^[0-9]+\.[0-9]+$ ]]; then
                PRERELEASE=false
              else
                PRERELEASE=false
              fi
            fi
            if [ "$NOTES" = "null" ]; then
              NOTES=""
            fi
            if gh release view "$TAG" >/dev/null 2>&1; then
              echo "Release already exists for tag: $TAG" >&2
              exit 1
            fi
            args=("$TAG" --title "$TITLE")
            if [ "$DRAFT" = "true" ]; then
              args+=(--draft)
            fi
            if [ "$PRERELEASE" = "true" ]; then
              args+=(--prerelease)
            fi
            GEN_BODY=""
            if [ "$GEN" = "true" ]; then
              GEN_BODY=$(gh api -X POST "repos/${GITHUB_REPOSITORY}/releases/generate-notes" -f tag_name="$TAG" --jq .body)
            fi
            if [ -n "$NOTES" ] || [ -n "$GEN_BODY" ]; then
              notes_file="${RUNNER_TEMP:-/tmp}/gh-aw-release-notes.md"
              : >"$notes_file"
              if [ -n "$NOTES" ]; then
                printf "%s\n" "$NOTES" >>"$notes_file"
              fi
              if [ -n "$GEN_BODY" ]; then
                if [ -n "$NOTES" ]; then
                  printf "\n---\n\n## GitHub auto-generated notes\n\n" >>"$notes_file"
                fi
                printf "%s\n" "$GEN_BODY" >>"$notes_file"
              fi
              args+=(--notes-file "$notes_file")
            fi
            gh release create "${args[@]}"
---
# Create draft release on tag creation
When a new git tag is created in this repository:
- Create a new GitHub Release for that tag.
- The release must be a draft.
- Use GitHub auto-generated release notes.
- If the tag is `major.minor` (e.g. `25.06` or `v25.06`) then it is NOT a prerelease.
- If the tag is `major.minor.patch` (e.g. `25.06.7` or `v25.06.7`) then mark it as a prerelease.
- If a release already exists for the tag, do not create a second one (report that it already exists).

Release notes style:
- Provide a short `Summary` section (2-5 bullets).
- Follow with consistent sections as applicable:
  - `Highlights`
  - `New features`
  - `Changes`
  - `Fixes & reliability improvements`
  - `Upgrade and Migration Notes`
  - `Notes for downstream integrators`
- Keep the content developer-focused:
  - Call out affected workflows/actions/scripts and any behavior changes.
  - Include file paths where helpful.
  - Link issues/PRs when relevant.
- Prefer concise bullets under headings.

If this workflow is triggered for a branch create event (not a tag), do nothing and finish with a noop safe output.

Use the safe output job `create-draft-release` exactly once.

Output JSON schema for the safe output job:
- type: `create_draft_release`
- tag: the created tag name (from the create event context)
- title: the created tag name
- notes: markdown release notes body using the style described above
- draft: true
- generate_notes: true
- prerelease: boolean, derived from tag format (major.minor => false, major.minor.patch => true)
