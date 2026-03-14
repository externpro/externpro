# Release flow (tag -> build -> draft release)

This page documents the default externpro release flow when using the `xp*.yml` caller workflows.

## Overview

1. A pull request is opened against `xpro`.
2. `xpBuild` runs on the PR (Linux/macOS/Windows).
3. If a maintainer adds the `release:tag` label and merges the PR, `xpTag` tags the merge commit.
4. The tag push triggers `xpBuild` again for the tag.
5. After the tagged `xpBuild` completes successfully, `xpRelease` creates a draft GitHub Release from those artifacts.

## `xpTag` -> `tag-release.yml`

- **Trigger**
  - `pull_request` `closed`
- **Condition**
  - PR merged into `xpro`
  - PR has label `release:tag`
- **What happens**
  - `xpTag` calls `tag-release.yml`.
  - `tag-release.yml` reads `.github/release-tag.json` in the merge commit.
  - If the intent file is missing or invalid, the workflow comments on the PR with instructions and fails.
  - Otherwise it creates an **annotated tag** (prefer `xpv*`) at the merge commit and pushes it.

## Tag push -> `xpBuild`

The default `xpbuild.yml` template triggers on tag pushes matching `xpv*`.

## `xpRelease` -> `release-from-build.yml`

- **Trigger**
  - `workflow_run` on `xpBuild` completion
- **Condition**
  - build succeeded
  - the build was for a tag ref starting with `xpv`
- **What happens**
  - `xpRelease` dispatches itself at the tag and passes the originating build run URL.
  - The dispatched run calls `release-from-build.yml`.
  - `release-from-build.yml`:
    - downloads artifacts from the referenced run
    - computes SHA256 checksums
    - generates build provenance attestations
    - creates a **draft** GitHub Release (fails if it already exists)
    - uploads artifacts (and a manifest if present) as release assets
    - release assets are tracked and kept as part of the GitHub Release (not just as ephemeral workflow artifacts)

## Notes

- Tag pushes created using `github.token` may not trigger downstream workflows; see [Secrets and tokens](secrets-and-tokens.md).
