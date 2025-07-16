# GitHub Actions Workflows

This directory contains GitHub Actions workflows for building and releasing the project.

## Workflows

### 1. `build-linux.yml` - Reusable Linux Build Workflow

Builds the project in a Docker container on Linux systems.

**Inputs:**
- `email` (required): Email for git configuration
- `runon` (optional): Runner to use (default: `ubuntu-latest`)
- `cmake-workflow-preset` (optional): CMake workflow preset (default: `Linux`)

**Usage:**
```yaml
jobs:
  build-linux:
    uses: ./.github/workflows/build-linux.yml
    with:
      email: user@example.com
      cmake-workflow-preset: LinuxRelease
    secrets: inherit
```

### 2. `build-windows.yml` - Reusable Windows Build Workflow

Builds the project on Windows systems.

**Inputs:**
- `cmake-workflow-preset` (optional): CMake workflow preset (default: `Windows`)

**Usage:**
```yaml
jobs:
  build-windows:
    uses: ./.github/workflows/build-windows.yml
    with:
      cmake-workflow-preset: WindowsRelease
    secrets: inherit
```

### 3. `upload-release-assets.yml` - Reusable Release Asset Upload Workflow

Downloads build artifacts and uploads them as GitHub release assets.

**Inputs:**
- `release_tag` (required): The tag name of the release
- `artifact_pattern` (optional): Pattern to match artifact files (default: `*.tar.xz`)
- `create_release` (optional): Whether to create the release if it doesn't exist (default: `false`)
- `release_name` (optional): Name for the release (only used if `create_release` is `true`)
- `release_body` (optional): Body text for the release (only used if `create_release` is `true`)
- `prerelease` (optional): Mark the release as a prerelease (default: `false`)
- `draft` (optional): Mark the release as a draft (default: `false`)

**Outputs:**
- `release_id`: The ID of the release
- `release_url`: The URL of the release

**Features:**
- Automatically discovers and uploads all artifacts matching the specified pattern
- Supports common build artifact formats: `.tar.xz`, `.zip`, `.tar.gz`, `.exe`, `.msi`, `.deb`, `.rpm`
- Can create releases automatically if they don't exist
- Replaces existing assets with the same name
- Provides detailed logging of upload process

**Usage:**
```yaml
jobs:
  upload-assets:
    uses: ./.github/workflows/upload-release-assets.yml
    with:
      release_tag: v1.0.0
      artifact_pattern: "*.tar.xz"
      create_release: true
      release_name: "Release v1.0.0"
      release_body: "Release notes here"
    secrets: inherit
```

### 4. `release.yml` - Complete Release Workflow

A complete workflow that builds for both Linux and Windows, then uploads the artifacts as release assets.

**Triggers:**
- Push to tags matching `v*` (e.g., `v1.0.0`, `v2.1.3`)
- Manual workflow dispatch with custom inputs

**Manual Trigger Inputs:**
- `tag` (required): Tag to create release for
- `create_release` (optional): Create release if it doesn't exist (default: `true`)
- `prerelease` (optional): Mark as prerelease (default: `false`)

**Workflow Steps:**
1. Builds the project for Linux using `build-linux.yml`
2. Builds the project for Windows using `build-windows.yml`
3. Uploads all build artifacts as release assets using `upload-release-assets.yml`

## Usage Examples

### Creating a Release from a Tag

1. **Automatic release on tag push:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
   This will automatically trigger the release workflow.

2. **Manual release creation:**
   - Go to Actions tab in GitHub
   - Select "Create Release" workflow
   - Click "Run workflow"
   - Enter the tag name and options
   - Click "Run workflow"

### Customizing Build Presets

You can customize the CMake workflow presets used for builds:

```yaml
jobs:
  build-linux:
    uses: ./.github/workflows/build-linux.yml
    with:
      email: ${{ github.actor }}@users.noreply.github.com
      cmake-workflow-preset: LinuxRelease  # Use release preset
    secrets: inherit

  build-windows:
    uses: ./.github/workflows/build-windows.yml
    with:
      cmake-workflow-preset: WindowsRelease  # Use release preset
    secrets: inherit
```

### Using Different Artifact Patterns

To upload different types of artifacts:

```yaml
jobs:
  upload-assets:
    uses: ./.github/workflows/upload-release-assets.yml
    with:
      release_tag: v1.0.0
      artifact_pattern: "*.zip"  # Upload ZIP files instead
    secrets: inherit
```

### Creating Prereleases

```yaml
jobs:
  upload-assets:
    uses: ./.github/workflows/upload-release-assets.yml
    with:
      release_tag: v1.0.0-beta.1
      create_release: true
      prerelease: true
      release_name: "Beta Release v1.0.0-beta.1"
    secrets: inherit
```

## Requirements

- Repository must have `GITHUB_TOKEN` with appropriate permissions
- Build workflows must upload artifacts using `actions/upload-artifact@v4`
- GitHub CLI (`gh`) is used for release management (automatically available in GitHub Actions)

## Troubleshooting

### Common Issues

1. **"Release not found" error:**
   - Set `create_release: true` to automatically create the release
   - Ensure the tag exists in the repository

2. **"Artifact not found" error:**
   - Check that the build workflows completed successfully
   - Verify the artifact pattern matches your build outputs
   - Check the artifact names in the Actions tab

3. **Permission errors:**
   - Ensure `secrets: inherit` is used when calling reusable workflows
   - Check repository settings for Actions permissions

### Debugging

To debug issues:

1. Check the workflow logs in the Actions tab
2. Look for the "List downloaded artifacts" step to see what was found
3. Verify the artifact pattern matches your expected files
4. Check the release page to see if assets were uploaded correctly
