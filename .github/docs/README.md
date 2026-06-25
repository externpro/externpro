# externpro GitHub Actions Integration

The `.github/` directory contains GitHub Actions building blocks (reusable workflows, composite actions, and caller workflow templates) intended to be vendored into other repositories via an `externpro/externpro` git submodule.

An "xpro package" is an externpro-produced release artifact (plus its manifest metadata) that downstream projects can consume via `find_package()`.

## Quick map

- [`.github/wf-templates/`](../wf-templates/)
  - Caller workflow templates vendored into project repos (copied into the project's `.github/workflows/`)
- [`.github/workflows/`](../workflows/)
  - Reusable workflows called by the caller workflows
- [`.github/actions/`](../actions/)
  - Composite actions used by the reusable workflows

## Happy path (first-time repo setup)

This is the typical flow for adopting externpro workflows in a project repo:

1. Create (or fork) the repo.
2. Add externpro as a submodule at `.devcontainer`:
   ```sh
   git submodule add https://github.com/externpro/externpro .devcontainer
   ```
3. Run the bootstrap script:
   ```sh
   ./.devcontainer/scripts/bootstrap.sh
   ```
   The script creates the `xpro` branch, copies workflow templates, checks XPRO_TOKEN configuration, and commits the setup.
4. Verify the setup works locally:
   ```sh
   cmake --list-presets
   cmake --preset=<platform>
   cmake --workflow --preset=<platform>
   ```
   Commit and push any cmake configuration changes.
5. Run `xpSync` workflow:
   - **Via Actions tab**: https://github.com/OWNER/REPO/actions/workflows/xpsync.yml
   - **Via CLI**: `gh workflow run xpsync.yml --ref xpro --repo OWNER/REPO`

   This opens a PR that standardizes presets, workflows, and repo wiring.
6. Merge the PR. Builds run via `xpBuild`. If you add the `release:tag` label, merging also drives tag -> tagged build -> draft release.

See:
- [Bootstrap guide](bootstrap.md)
- [xpSync preconditions](caller-workflows.md#preconditions-before-running-xpsync)
- [Secrets and tokens](secrets-and-tokens.md)
- [Release flow](release-flow.md)
- [Architecture overview](architecture-overview.md)

## Secrets quick reference

- `XPRO_TOKEN`
  - Used by caller workflow templates as `secrets.XPRO_TOKEN`, passed through to reusable workflows as `automation_token`.
  - Required for `xpsync` when workflow changes are needed.
  - Recommended for `xptag` when tag pushes must trigger downstream workflows.
  - Setup details: see [Secrets and tokens](secrets-and-tokens.md).
- `GHCR_TOKEN`
  - Classic PAT with `read:packages` and `write:packages` scopes.
  - Used by `xpbuild` for GHCR push retry on permission errors.
  - Optional: `github.token` works for most GHCR operations.
  - Setup details: see [Secrets and tokens](secrets-and-tokens.md).

## Documentation index

- [Caller workflows](caller-workflows.md)
  - `xpsync`, `xpbuild`, `xptag`, `xprelease` (what triggers them and what they call)
- [Reusable workflows](reusable-workflows.md)
  - `sync-externpro`, `build-*`, `tag-release`, `release-from-build`
- [Release flow](release-flow.md)
  - PR merge + `release:tag` -> tag -> tagged build -> draft GitHub Release
- [Build customization](build-customizations.md)
  - Linux arch/toolchain matrix, Windows toolchain matrix, and common knobs
- [Supply chain](supply-chain.md)
  - SBOM and provenance/attestations
- [Secrets and tokens](secrets-and-tokens.md)
  - `XPRO_TOKEN` and `GHCR_TOKEN`, when they're required, and how to configure them
- [Architecture overview](architecture-overview.md)
  - How the workflow and packaging pieces fit together
