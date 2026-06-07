# externpro bootstrap script

**Script location**: [`bootstrap.sh`](../../scripts/bootstrap.sh)

The `bootstrap.sh` script automates the initial setup of externpro in a repository, from initial configuration to pushing changes and preparing for the xpInit workflow.

## Prerequisites

Before running the bootstrap script, you must:

**Add externpro as a submodule:**
```bash
git submodule add https://github.com/externpro/externpro .devcontainer
```

**Note:** Be aware of any conflicts with an existing `.devcontainer` directory or a `.gitignore` entry that ignores `.devcontainer`.

### Required Utilities

The bootstrap script requires these utilities to be installed:

- **git** - Required for all repository operations
- **cmake** - Required for verifying CMake preset configuration

### Optional Utilities

These utilities enhance the bootstrap experience but are not required:

- **gh (GitHub CLI)** - Automatically detects XPRO_TOKEN configuration and default branch settings
- **Browser utilities** - For automatic URL opening:
  - **macOS**: `open` (built-in)
  - **Linux**: `xdg-open` (typically installed)
  - **Windows**: `start` (built-in)

The script will work without the optional utilities, but will provide manual instructions instead of automated detection and URL opening.

## What the Script Does

The bootstrap script performs the following automated actions:

1. **Creates/switches to `xpro` branch** - All changes are made in a dedicated branch
2. **Commits externpro submodule** - Creates first commit with submodule and version tag from `git describe --tags`
3. **Copies GitHub workflow** - Copies `.devcontainer/.github/wf-templates/xpinit.yml` to `.github/workflows/`
4. **Copies CMake presets** - Copies CMakePresets files from `.devcontainer/cmake/presets/` to repository root
5. **Handles file conflicts** - Overwrites existing files with commit confirmation for tracked files
6. **Commits bootstrap changes** - Creates second commit with setup files
7. **Pushes to remote** - Automatically pushes `xpro` branch using smart remote selection
8. **Verifies default branch** - Checks if `xpro` is set as default branch and provides setup instructions
9. **XPRO_TOKEN detection** - Checks if XPRO_TOKEN is configured and provides setup assistance

## Features

### Git & Repository Management
- **Branch management** - Automatic `xpro` branch creation and management
- **Two-commit strategy** - Separates submodule commit from bootstrap setup
- **Smart remote selection** - Prefers git protocol remotes over https for the same repository
- **Upstream tracking** - Automatically sets up branch tracking after push
- **Automatic push** - Pushes changes to remote with verification

### File Handling
- **File comparison** - Only prompts for confirmation when files actually differ
- **File conflict handling** - Smart detection and confirmation for tracked vs untracked files
- **Overwrite strategy** - Always copies files, with commit confirmation for tracked files

### User Experience
- **Error handling** - Comprehensive error checking and user-friendly messages
- **Colored output** - Easy-to-read status messages
- **Cross-platform** - Single bash script works everywhere
- **Validation** - Verifies setup and provides detailed next steps

### Automation & Integration
- **XPRO_TOKEN automation** - Detects token configuration and provides pre-filled setup URLs
- **Browser integration** - Opens setup URLs automatically on supported platforms
- **Default branch guidance** - Checks and guides on setting `xpro` as default branch
- **Direct links** - Provides clickable URLs for PAT creation, repository settings, and workflow execution

## Running the Script

**Note**: The bootstrap script is safe to run multiple times. You can re-run it to verify setup completion, check XPRO_TOKEN configuration, or troubleshoot issues. The script will detect existing files and configurations and only take actions that are needed.

### On macOS and Linux
```bash
./.devcontainer/scripts/bootstrap.sh
```

### On Windows
The script works on Windows using any bash environment:
- **Git Bash** (included with Git for Windows)
- **WSL** (Windows Subsystem for Linux)
- **GitHub CLI** (gh) bash environment

```bash
./.devcontainer/scripts/bootstrap.sh
```

## Platform Compatibility

- ✅ macOS (native bash)
- ✅ Linux (native bash)
- ✅ Windows (via Git Bash, WSL, or GitHub CLI)

## After Running the Script

Once the bootstrap script completes, follow these steps:

1. **List available cmake presets:**
   ```bash
   cmake --list-presets
   ```

2. **Configure with cmake:**
   ```bash
   cmake --preset=<platform>
   ```

3. **Run cmake workflow and fix any issues:**
   ```bash
   cmake --workflow --preset=<platform>
   ```
   *(Commit and push any cmake configuration changes)*

4. **With XPRO_TOKEN configured, run the xpInit workflow** (direct link provided by script)
