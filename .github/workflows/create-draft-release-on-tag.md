---
name: Create Draft Release on Tag
on:
  create: null
permissions:
  contents: read
engine: copilot
tools:
  bash:
    - git:*
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
          env:
            GH_TOKEN: ${{ github.token }}
            GH_REPO: ${{ github.repository }}
          run: |
            set -euo pipefail
            if [ ! -f "$GH_AW_AGENT_OUTPUT" ]; then
              echo "Missing GH_AW_AGENT_OUTPUT" >&2
              exit 1
            fi

            item_json=$(jq -c '.items[] | select(.type == "create_draft_release")' "$GH_AW_AGENT_OUTPUT" | head -n1)
            if [ -z "$item_json" ]; then
              echo "Missing required agent output item: type=create_draft_release" >&2
              exit 1
            fi

            TAG=$(printf '%s' "$item_json" | jq -r '.tag')
            TITLE=$(printf '%s' "$item_json" | jq -r '.title')
            NOTES=$(printf '%s' "$item_json" | jq -r '.notes')
            PRERELEASE=$(printf '%s' "$item_json" | jq -r '.prerelease')
            DRAFT=$(printf '%s' "$item_json" | jq -r '.draft')
            GEN=$(printf '%s' "$item_json" | jq -r '.generate_notes')
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

            if [ -z "$NOTES" ]; then
              echo "Agent did not provide release notes (notes is empty)." >&2
              exit 1
            fi

            notes_trim=$(printf '%s' "$NOTES" | sed '/^[[:space:]]*$/d')
            notes_non_heading=$(printf '%s\n' "$notes_trim" | grep -vE '^[[:space:]]*#' || true)
            notes_non_url_bullets=$(printf '%s\n' "$notes_non_heading" | grep -E '^[[:space:]]*[-*+]' | grep -vE '^[[:space:]]*[-*+] https?://' || true)
            if [ -z "$(printf '%s' "$notes_non_url_bullets" | tr -d '[:space:]')" ]; then
              echo "Agent-provided release notes are too low-content (headings and/or URL-only bullets)." >&2
              echo "--- Agent notes excerpt (first 60 lines, truncated) ---" >&2
              printf '%s\n' "$notes_trim" | head -n 60 >&2
              echo "--- end excerpt ---" >&2
              exit 1
            fi

            if ! printf '%s\n' "$NOTES" | grep -Eq 'https://github\.com/[^/]+/[^/]+/compare/'; then
              echo "Agent-provided release notes are missing required compare URL(s)." >&2
              echo "--- Agent notes excerpt (first 60 lines, truncated) ---" >&2
              printf '%s\n' "$notes_trim" | head -n 60 >&2
              echo "--- end excerpt ---" >&2
              exit 1
            fi

            release_exists=false
            release_is_draft=false
            release_info_json=$(gh release view "$TAG" --repo "$GH_REPO" --json isDraft 2>/dev/null || true)
            if [ -n "$release_info_json" ]; then
              release_exists=true
              release_is_draft=$(printf '%s' "$release_info_json" | jq -r '.isDraft')
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

            if [ -n "$GEN_BODY" ]; then
              trimmed=$(printf '%s' "$GEN_BODY" | sed '/^[[:space:]]*$/d')
              if [ "$(printf '%s\n' "$trimmed" | wc -l | tr -d ' ')" = "1" ] && printf '%s' "$trimmed" | grep -Eq '^\*\*Full Changelog\*\*:'; then
                GEN_BODY=""
              fi
            fi
            if [ -n "$NOTES" ] || [ -n "$GEN_BODY" ]; then
              notes_file="${RUNNER_TEMP:-/tmp}/gh-aw-release-notes.md"
              printf '' >"$notes_file"
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

            if [ "$release_exists" = true ]; then
              if [ "$release_is_draft" != "true" ]; then
                echo "Release already exists and is not a draft for tag: $TAG" >&2
                exit 1
              fi

              edit_args=(--title "$TITLE")
              if [ "$DRAFT" = "true" ]; then
                edit_args+=(--draft)
              fi
              if [ "$PRERELEASE" = "true" ]; then
                edit_args+=(--prerelease)
              fi
              if [ -n "$NOTES" ] || [ -n "$GEN_BODY" ]; then
                edit_args+=(--notes-file "$notes_file")
              fi
              gh release edit "$TAG" "${edit_args[@]}" --repo "$GH_REPO"
            else
              gh release create "${args[@]}" --repo "$GH_REPO"
            fi
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

Minimum content requirements for `notes`:
- `## Summary` must contain 2-5 bullets.
- Include at least one additional section with at least 3 bullets total across those sections (for example `## Changes` and/or `## Fixes & reliability improvements`).
- Do not output headings-only notes. If there are no meaningful changes, explicitly say so in bullets.
- Always include a `## Compare` section containing the compare URL(s) described below.

Before you emit the safe output:
- Verify `notes` contains at least one bullet under `## Summary`.
- Verify there is at least one additional section besides `## Summary` and `## Compare`.
- Verify there are at least 3 bullets total across the additional section(s).
- Verify `## Compare` exists and contains at least one URL matching `https://github.com/externpro/externpro/compare/`.
- If any of these checks fail, do not emit the safe output. Instead, re-run `git` commands and rewrite `notes` until the checks pass.

If this workflow is triggered for a branch create event (not a tag), do nothing and finish with a noop safe output.

When generating release notes (`notes`) as the agent:
- Determine the created tag name from the create event.
- Use the bash tool to compute changes locally with `git` and generate release notes from that data.
- Before writing `notes`, you MUST run `git log` and `git diff --name-status` for the computed range so the notes are grounded in concrete repository changes.
- After running those commands, create a short internal checklist for yourself (do not include it in `notes`) with:
  - The `TAG` and computed `PREV_TAG`
  - The top commit subjects in the range (at least 5 if available)
  - The list of changed files / statuses (at least 10 if available)
- Only mention changes in `notes` that are supported by the `git log` subjects and/or `git diff --name-status` file list. If you are not sure a change happened, omit it.
- Fetch tags locally and compute the previous tag using the repo's tag scheme:
  - Tags are `YY.REV` for releases and `YY.REV.PATCH` for prereleases.
  - `YY` is the year, `REV` is the revision, `PATCH` is the prerelease patch.
  - The "previous tag" is the greatest semver-ish tag less than the current tag.
  - Examples:
    - previous of `25.07.16` is `25.07.15`
    - previous of `25.07.1` is `25.07`
    - previous of `26.01` is the latest `25.*` tag
- Recommended commands:
  - `git fetch --tags --force`
  - `git tag --list | grep -E '^v?[0-9]+\.[0-9]+(\.[0-9]+)?$'` (list candidate tags)
  - Determine `PREV_TAG` as the greatest tag less than `TAG` in `YY.REV[.PATCH]` numeric order.
  - `git log --no-decorate --pretty=format:'%h %s' "${PREV_TAG}..${TAG}"`
  - `git diff --name-status "${PREV_TAG}..${TAG}"`
- Use `git log` and `git diff` between `PREV_TAG..TAG` to gather the concrete changes and write curated release notes in the style below.
- The `notes` field must be non-empty.
- Include compare URL(s) in a `## Compare` section:
  - Always include `https://github.com/externpro/externpro/compare/<PREV_TAG>...<TAG>` when `PREV_TAG` is known.
  - If `TAG` is a release (`YY.REV`) and `PREV_TAG` is a prerelease (`YY.REV.PATCH`), include a second compare URL: `https://github.com/externpro/externpro/compare/<PREV_RELEASE_TAG>...<TAG>` where `<PREV_RELEASE_TAG>` is `YY.REV`.

Use the safe output job `create-draft-release` exactly once.

Output JSON schema for the safe output job:
- type: `create_draft_release`
- tag: the created tag name (from the create event context)
- title: the created tag name
- notes: markdown release notes body using the style described above
- draft: true
- generate_notes: true
- prerelease: boolean, derived from tag format (major.minor => false, major.minor.patch => true)

Example safe output JSON (shape and minimum content; values must match the actual tag and computed previous tag):
```json
{
  "type": "create_draft_release",
  "tag": "25.07.16",
  "title": "25.07.16",
  "prerelease": true,
  "draft": true,
  "generate_notes": true,
  "notes": "## Summary\n- Add agent output validation excerpt to improve debugging when notes are rejected\n- Improve notes validation to count common bullet markers and require substantive content\n\n## Changes\n- Update release note validation to treat '*', '+', and '-' bullets consistently\n- Print a truncated excerpt of agent-provided notes when validation fails\n- Recompile the agentic workflow lockfile\n\n## Compare\n- https://github.com/externpro/externpro/compare/25.07.15...25.07.16"
}
```
