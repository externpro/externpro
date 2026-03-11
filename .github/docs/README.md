# externpro GitHub Actions Integration

The `.github/` directory contains GitHub Actions building blocks (reusable workflows, composite actions, and caller workflow templates) intended to be vendored into other repositories via an `externpro/externpro` git submodule.

## Quick map

- [`.github/wf-templates/`](../wf-templates/)
  - Caller workflow templates vendored into project repos (copied into the project’s `.github/workflows/`)
- [`.github/workflows/`](../workflows/)
  - Reusable workflows called by the caller workflows
- [`.github/actions/`](../actions/)
  - Composite actions used by the reusable workflows

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
