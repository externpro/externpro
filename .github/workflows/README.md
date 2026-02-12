# GitHub Actions

This directory contains reusable GitHub Actions for building and releasing the project. These actions are designed to be used by other repositories.

For externpro integration guidance (including `xpinit` preconditions and how to vendor/copy the caller workflow templates), see `../README.md`.

## Actions

### 1. `build-linux.yml` - Reusable Linux Build Action

Builds the project in a Docker container on Linux systems.

**Inputs:**
- `artifact-pattern` (optional): Pattern to search for artifact files (default: `[repository-name]-*-xpro.tar.xz`)
- `cmake-workflow-preset` (optional): CMake workflow preset (default: `Linux`)
- `arch-list` (optional): JSON array of target architectures as a string (default: `["amd64","arm64"]`)
- `buildpro-images` (optional): JSON array of buildpro images as a string (default: `["rocky8-gcc9","rocky9-gcc13","rocky10-gcc15"]`)

**Caller permissions:**
- `contents: read`
- `pull-requests: write`
- `packages: write` (required to push build container images to GHCR)

These can be set at the top of the caller workflow via `permissions:` and/or per job (as shown below).

**Usage:**
```yaml
jobs:
  linux:
    permissions:
      contents: read
      pull-requests: write
      packages: write
    uses: externpro/externpro/.github/workflows/build-linux.yml@25.06
    with:
      cmake-workflow-preset: Linux # Release and Debug
    secrets: inherit
```

### 2. `build-macos.yml` - Reusable macOS Build Action

Builds the project on macOS (aka Darwin) systems.

**Inputs:**
- `artifact-pattern` (optional): Pattern to search for artifact files (default: `[repository-name]-*-xpro.tar.xz`)
- `cmake-workflow-preset` (optional): CMake workflow preset (default: `Darwin`)

**Caller permissions:**
- `contents: read`
- `pull-requests: write`

These can be set at the top of the caller workflow via `permissions:` and/or per job (as shown below).

**Usage:**
```yaml
jobs:
  macos:
    permissions:
      contents: read
      pull-requests: write
    uses: externpro/externpro/.github/workflows/build-macos.yml@25.06
    with:
      cmake-workflow-preset: Darwin # Release and Debug
    secrets: inherit
```

### 3. `build-windows.yml` - Reusable Windows Build Action

Builds the project on Windows systems.

**Inputs:**
- `artifact-pattern` (optional): Pattern to search for artifact files (default: `[repository-name]-*-xpro.tar.xz`)
- `cmake-workflow-preset` (optional): CMake workflow preset (default: `Windows`)

**Caller permissions:**
- `contents: read`
- `pull-requests: write`

These can be set at the top of the caller workflow via `permissions:` and/or per job (as shown below).

**Usage:**
```yaml
jobs:
  windows:
    permissions:
      contents: read
      pull-requests: write
    uses: externpro/externpro/.github/workflows/build-windows.yml@25.06
    with:
      cmake-workflow-preset: Windows # Release and Debug
    secrets: inherit
```

### 4. `release-from-build.yml` - Reusable Release Asset Upload Action

Downloads build artifacts and uploads them as GitHub release assets. This workflow also generates SLSA build provenance attestations for the artifacts.

**Required Permissions:**
```yaml
permissions:
  contents: write     # Required for creating releases and uploading assets
  id-token: write     # Required for OIDC token generation
  attestations: write # Required for uploading attestations
```

**Inputs:**
- `workflow_run_url` (required): URL of the workflow run to download artifacts from (e.g., `https://github.com/owner/repo/actions/runs/123456789`)
- `artifact_pattern` (optional): Pattern to match artifact files (default: `*.tar.xz`)
- `release_body_template` (optional): Template for the release body (includes placeholders like `{workflow_run_url}`)

**Outputs:**
- `release_id`: The ID of the release
- `release_url`: The URL of the release
- `release_tag`: The detected release tag
- `is_prerelease`: Whether the release is marked as a prerelease

**Features:**
- Automatically detects release tag from artifact filenames (e.g., `xpv1.2.3` or `xpv1.2.3-4-g1234abc`)
- Determines prerelease status based on tag format (tags with `-#-g<hash>` suffix are prereleases)
- Always creates a release and fails if it already exists (strict release creation)
- Always creates releases as drafts
- Downloads artifacts from a specified workflow run
- Calculates SHA256 hashes for all artifacts and includes them in alphabetically sorted release notes
- Supports common build artifact formats: `.tar.xz`, `.zip`, `.tar.gz`, `.exe`, `.msi`, `.deb`, `.rpm`
- Replaces existing assets with the same name
- Provides detailed logging of upload process

**Usage:**
```yaml
jobs:
  release-from-build:
    uses: externpro/externpro/.github/workflows/release-from-build.yml@25.06
    with:
      workflow_run_url: https://github.com/owner/repo/actions/runs/123456789
      artifact_pattern: "*.tar.xz"
    permissions:
      contents: write
      id-token: write
      attestations: write
    secrets: inherit
```

### Repository-Specific Workflows

Each repository should have its own `release.yml` workflow file that calls the reusable `release-from-build.yml` action. For example:

**Example: Repository Release Workflow**

```yaml
name: Release
on:
  workflow_dispatch:
    inputs:
      workflow_run_url:
        description: 'URL of the workflow run containing artifacts to upload'
        required: true
        type: string
jobs:
  release-from-build:
    uses: externpro/externpro/.github/workflows/release-from-build.yml@25.06
    with:
      workflow_run_url: ${{ github.event.inputs.workflow_run_url }}
      artifact_pattern: "*.tar.xz"
    permissions:
      contents: write
      id-token: write
      attestations: write
    secrets: inherit
```

## Usage Examples

### Creating a Release from Build Artifacts

**Manual release creation:**
   - Run a build workflow to generate artifacts
   - Copy the URL of the successful workflow run
   - Go to Actions tab in GitHub
   - Select the repository's "Release" workflow
   - Click "Run workflow"
   - Enter the workflow run URL
   - Click "Run workflow"
   
The workflow will automatically:
   - Detect the version tag from artifact filenames
   - Create a release with that tag
   - Determine if it should be a prerelease based on the tag format
   - Always create releases as drafts

### Customizing CMake Workflow Presets and Linux Build Matrix

You can customize the CMake workflow preset, and the Linux build matrix (architectures and build container images) used for builds:

```yaml
jobs:
  linux:
    permissions:
      contents: read
      pull-requests: write
      packages: write
    uses: externpro/externpro/.github/workflows/build-linux.yml@25.06
    with:
      cmake-workflow-preset: LinuxRelease  # Use release preset
      arch-list: '["arm64"]'
      buildpro-images: '["rocky9-gcc13"]'
    secrets: inherit

  windows:
    permissions:
      contents: read
      pull-requests: write
    uses: externpro/externpro/.github/workflows/build-windows.yml@25.06
    with:
      cmake-workflow-preset: WindowsRelease  # Use release preset
    secrets: inherit
```

### Using Different Artifact Patterns

To upload different types of artifacts:

build.yml
```yaml
permissions:
  contents: read
  pull-requests: write
jobs:
  linux:
    permissions:
      contents: read
      pull-requests: write
      packages: write
    uses: externpro/externpro/.github/workflows/build-linux.yml@25.06
    with:
      artifact-pattern: "${{ github.event.repository.name }}-*.zip"
      cmake-workflow-preset: LinuxRelease
    secrets: inherit
```

release.yml
```yaml
jobs:
  release-from-build:
    uses: externpro/externpro/.github/workflows/release-from-build.yml@25.06
    with:
      workflow_run_url: https://github.com/owner/repo/actions/runs/123456789
      artifact_pattern: "*.zip"  # Upload ZIP files instead
    permissions:
      contents: write
      id-token: write
      attestations: write
    secrets: inherit
```

### Prerelease Detection

Note: Prerelease status is automatically determined from the tag format. Tags with `-#-g<hash>` suffix (like `xpv1.2.3-4-g1234abc`) are marked as prereleases. All releases are created as drafts regardless of prerelease status.

## Requirements

- Repository must have `GITHUB_TOKEN` with appropriate permissions
- Build workflows must upload artifacts using `actions/upload-artifact@v4`
- GitHub CLI (`gh`) is used for release management (automatically available in GitHub Actions)

## Troubleshooting

### Common Issues

1. **"Release already exists" error:**
   - The workflow is designed to fail if a release with the detected tag already exists
   - Delete the existing release or use a different build with different version tags

2. **"Could not determine version tag from filename" error:**
   - Ensure artifact filenames contain version tags in the format `xpv#.#.#` or `xpv#.#.#.#`
   - Version tags can also include git hash suffixes like `xpv1.2.3-4-g1234abc`
   - Check the artifact names in the Actions tab

3. **"Artifact not found" error:**
   - Check that the build workflows completed successfully
   - Verify the artifact pattern matches your build outputs
   - Check the artifact names in the Actions tab

4. **Permission errors:**
   - Ensure `secrets: inherit` is used when calling reusable workflows
   - Check repository settings for Actions permissions

### Debugging

To debug issues:

1. Check the workflow logs in the Actions tab
2. Look for the "Find and prepare artifacts for upload" step to see what artifacts were found and their hashes
3. Verify the artifact pattern matches your expected files
4. Check the "Determine tag from artifacts" step to ensure the version tag was extracted correctly
5. Check the release page to see if assets were uploaded correctly
6. For permission issues, ensure the GITHUB_TOKEN has the required scopes (repo for private repos, public_repo for public repos)
