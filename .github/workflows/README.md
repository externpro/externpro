# GitHub Actions

This directory contains reusable GitHub Actions for building and releasing the project. These actions are designed to be used by other repositories.

## Actions

### 1. `build-linux.yml` - Reusable Linux Build Action

Builds the project in a Docker container on Linux systems.

**Inputs:**
- `cmake-workflow-preset` (optional): CMake workflow preset (default: `Linux`)
- `runon` (optional): Runner to use (default: `ubuntu-latest`)

**Usage:**
```yaml
jobs:
  build-linux:
    uses: externpro/externpro/.github/workflows/build-linux.yml@25.04
    with:
      cmake-workflow-preset: Linux # Release and Debug
    secrets: inherit
```

### 2. `build-windows.yml` - Reusable Windows Build Action

Builds the project on Windows systems.

**Inputs:**
- `cmake-workflow-preset` (optional): CMake workflow preset (default: `Windows`)

**Usage:**
```yaml
jobs:
  build-windows:
    uses: externpro/externpro/.github/workflows/build-windows.yml@25.04
    with:
      cmake-workflow-preset: Windows # Release and Debug
    secrets: inherit
```

### 3. `release-from-build.yml` - Reusable Release Asset Upload Action

Downloads build artifacts and uploads them as GitHub release assets.

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
- Automatically detects release tag from artifact filenames (e.g., `v1.2.3` or `v1.2.3-4-g1234abc`)
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
    uses: externpro/externpro/.github/workflows/release-from-build.yml@25.04
    with:
      workflow_run_url: https://github.com/owner/repo/actions/runs/123456789
      artifact_pattern: "*.tar.xz"
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
    uses: externpro/externpro/.github/workflows/release-from-build.yml@25.04
    with:
      workflow_run_url: ${{ github.event.inputs.workflow_run_url }}
      artifact_pattern: "*.tar.xz"
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

### Customizing CMake Workflow Presets and Linux Runner

You can customize the CMake workflow presets and Linux runner used for builds:

```yaml
jobs:
  build-linux:
    uses: externpro/externpro/.github/workflows/build-linux.yml@25.04
    with:
      cmake-workflow-preset: LinuxRelease  # Use release preset
      runon: ubuntu-24.04-arm # Use ARM64 runner
    secrets: inherit

  build-windows:
    uses: externpro/externpro/.github/workflows/build-windows.yml@25.04
    with:
      cmake-workflow-preset: WindowsRelease  # Use release preset
    secrets: inherit
```

### Using Different Artifact Patterns

To upload different types of artifacts:

```yaml
jobs:
  release-from-build:
    uses: externpro/externpro/.github/workflows/release-from-build.yml@25.04
    with:
      workflow_run_url: https://github.com/owner/repo/actions/runs/123456789
      artifact_pattern: "*.zip"  # Upload ZIP files instead
    secrets: inherit
```

### Prerelease Detection

Note: Prerelease status is automatically determined from the tag format. Tags with `-#-g<hash>` suffix (like `v1.2.3-4-g1234abc`) are marked as prereleases. All releases are created as drafts regardless of prerelease status.

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
   - Ensure artifact filenames contain version tags in the format `v#.#.#` or `v#.#.#.#`
   - Version tags can also include git hash suffixes like `v1.2.3-4-g1234abc`
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
