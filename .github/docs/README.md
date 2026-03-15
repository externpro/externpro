# externpro GitHub Actions Integration

The `.github/` directory contains GitHub Actions building blocks (reusable workflows, composite actions, and caller workflow templates) intended to be vendored into other repositories via an `externpro/externpro` git submodule.

An "xpro package" is an externpro-produced release artifact (plus its manifest metadata) that downstream projects can consume via `find_package()`.

## Quick map

- [`.github/wf-templates/`](../wf-templates/)
  - Caller workflow templates vendored into project repos (copied into the project’s `.github/workflows/`)
- [`.github/workflows/`](../workflows/)
  - Reusable workflows called by the caller workflows
- [`.github/actions/`](../actions/)
  - Composite actions used by the reusable workflows

## Happy path (first-time repo setup)

This is the typical flow for adopting externpro workflows in a project repo:

1. Create (or fork) the repo and create branch `xpro` (set it as the default branch).
2. Add externpro as a submodule at `.devcontainer`:
   ```sh
   git submodule add https://github.com/externpro/externpro .devcontainer
   ```
3. Copy the `xpInit` caller workflow template into the repo and commit.
4. Configure `XPRO_TOKEN`.
5. Run `xpInit` (Actions tab). It opens a PR that standardizes presets, workflows, and repo wiring.
6. Merge the PR. Builds run via `xpBuild`. If you add the `release:tag` label, merging also drives tag -> tagged build -> draft release.

See:
- [xpInit preconditions](caller-workflows.md#preconditions-before-running-xpinit)
- [Secrets and tokens](secrets-and-tokens.md)
- [Release flow](release-flow.md)
- [Architecture overview](architecture-overview.md)

## Secrets quick reference

- `XPRO_TOKEN`
  - Used by caller workflow templates as `secrets.XPRO_TOKEN`, passed through to reusable workflows as `automation_token`.
  - Required for `xpinit`.
  - Commonly needed for `xpupdate` (push/PR/label operations).
  - Recommended for `xptag` when tag pushes must trigger downstream workflows.
  - Setup details: see [Secrets and tokens](secrets-and-tokens.md).

## Documentation index

- [Caller workflows](caller-workflows.md)
  - `xpinit`, `xpupdate`, `xpbuild`, `xptag`, `xprelease` (what triggers them and what they call)
- [Reusable workflows](reusable-workflows.md)
  - `init-externpro`, `update-externpro`, `build-*`, `tag-release`, `release-from-build`
- [Release flow](release-flow.md)
  - PR merge + `release:tag` -> tag -> tagged build -> draft GitHub Release
- [Build customization](build-customizations.md)
  - Linux arch/toolchain matrix, Windows toolchain matrix, and common knobs
- [Supply chain](supply-chain.md)
  - SBOM and provenance/attestations
- [Secrets and tokens](secrets-and-tokens.md)
  - `XPRO_TOKEN`, when it’s required, and how to configure it
- [Architecture overview](architecture-overview.md)
  - How the workflow and packaging pieces fit together
