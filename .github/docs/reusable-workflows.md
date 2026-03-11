# Reusable workflows (provided by externpro/externpro)

Reusable workflows live in `.github/workflows/` and are intended to be called from project repositories via `uses: externpro/externpro/.github/workflows/<workflow>.yml@<ref>`.

## Build workflows

### `build-linux.yml`

Builds the project inside buildpro-based Docker containers on Linux, and runs a build matrix across architectures and buildpro toolchains.

- **Inputs**
  - `artifact_pattern` (default: `${{ github.event.repository.name }}-*-xpro.tar.xz`)
  - `cmake_workflow_preset_suffix` (default: empty)
  - `arch_list` (default: `["amd64","arm64"]`)
  - `buildpro_images` (default: `["rocky8-gcc9","rocky9-gcc13","rocky10-gcc15"]`)
  - `enable_tmate` (default: `false`)
- **Behavior**
  - builds and (if missing) publishes per-repo build images to GHCR (hash-tagged + `latest`)
  - runs the CMake build inside those containers
  - optional interactive debugging via `tmate` if the CMake workflow step fails
  - cleanup step prunes untagged images in GHCR
- **Caller permissions**
  - `contents: read`
  - `pull-requests: write`
  - `packages: write` (for pushing build images)

### `build-macos.yml`

Builds the project on GitHub-hosted macOS runners using the shared `cmake-build` action.

- **Inputs**
  - `artifact_pattern` (default: `${{ github.event.repository.name }}-*-xpro.tar.xz`)
  - `cmake_workflow_preset_suffix` (default: empty)
- **Caller permissions**
  - `contents: read`
  - `pull-requests: write` (included by default in the `xpbuild` template)

### `build-windows.yml`

Builds the project on GitHub-hosted Windows runners (matrix of Visual Studio toolchains) using the shared `cmake-build` action.

- **Inputs**
  - `artifact_pattern` (default: `${{ github.event.repository.name }}-*-xpro.tar.xz`)
  - `cmake_workflow_preset_suffix` (default: empty)
  - `vs_compilers` (default: `["Vs2022","Vs2026"]`)
- **Caller permissions**
  - `contents: read`
  - `pull-requests: write` (included by default in the `xpbuild` template)

## Repo automation workflows

### `init-externpro.yml`

Bootstraps a repo to use externpro and opens a PR with the changes.

- Adds docker-compose links.
- Adds CMake presets.
- Adds the `xp*.yml` caller workflows.
- Ensures `.github/release-tag.json` exists.
- Adds externpro entries to `.gitignore`.
- Optionally applies `patches/*.patch`.
- Configures/snapshots dependency artifacts.
- Pushes a branch and creates a PR (and closes superseded `xpinit-*` PRs).

### `update-externpro.yml`

Updates a repo’s externpro integration and opens a PR with the changes.

- Updates the externpro submodule pointer to a target ref (branch/tag/commit).
- Syncs caller workflows from templates.
- Compares/updates CMake presets.
- Updates dependency artifacts.
- Pushes a branch and creates a PR (and closes superseded `xpupdate-*` PRs).

### `tag-release.yml`

Creates and pushes a tag after a PR merge when release intent is present.

- Validates `.github/release-tag.json` in the merge commit.
- If missing, comments on the PR with instructions and fails.
- Creates an annotated tag (prefer `xpv*`) at the merge commit and pushes it.

### `release-from-build.yml`

Creates a draft GitHub Release from build workflow artifacts.

- Downloads artifacts from a referenced workflow run (`workflow_run_url`).
- Computes SHA256 checksums.
- Generates SLSA provenance attestations (GitHub Attestations) for artifacts.
- Creates a draft GitHub Release for the detected tag and uploads assets.

Caller must grant permissions:

```yaml
permissions:
  contents: write
  id-token: write
  attestations: write
```
