# How-to: adopt externpro in a project

This page describes the typical steps to modify a project to build with externpro, and to leverage externpro CMake, docker build images, and GitHub Actions workflows to create xpro packages.

## Quick Start

For a streamlined adoption process:

1. **Add externpro as a submodule**:
   ```bash
   git submodule add https://github.com/externpro/externpro .devcontainer
   ```

2. **Run the bootstrap script**:
   ```bash
   ./.devcontainer/scripts/bootstrap.sh
   ```

3. **Verify the setup works locally**:
   ```bash
   cmake --list-presets
   cmake --preset=<platform>
   cmake --workflow --preset=<platform>
   ```
   Commit and push any cmake configuration changes.

4. **Run the xpSync workflow**:
   - **Via Actions tab**: https://github.com/OWNER/REPO/actions/workflows/xpsync.yml
   - **Via CLI**: `gh workflow run xpsync.yml --ref xpro --repo OWNER/REPO`

   Replace `OWNER/REPO` with your actual repository (e.g., `myusername/myproject`).

See the detailed breakdown below for what each step does and manual alternatives.

## Project setup

1. Find the upstream project and fork it (or create a new repo)

- Note: there is no requirement to use the `externpro` GitHub organization.

2. Add externpro as a git submodule

```bash
git submodule add https://github.com/externpro/externpro .devcontainer
```

3. Add CMakePresets

```bash
cp .devcontainer/cmake/presets/CMakePresets* .
```

4. Add docker-compose links (for Linux build container launching)

```bash
ln -s .devcontainer/compose.pro.sh docker-compose.sh
ln -s .devcontainer/compose.bld.yml docker-compose.yml
```

5. Update `.gitignore` with externpro ignores

```
# externpro
.env
_bld*/
docker-compose.override.yml
```

Note: The [Bootstrap Script](../../.github/docs/bootstrap.md) can automate most of this setup:
- **CMakePresets copying** - Copies CMakePresets.json and CMakePresetsBase.json
- **GitHub workflow setup** - Copies all xp*.yml workflow templates (only if they don't exist)
- **Docker-compose links** - Creates symbolic links for docker-compose.sh and docker-compose.yml
- **Git branch management** - Creates/switches to xpro branch and manages commits
- **Repository configuration** - Handles XPRO_TOKEN detection and default branch setup
- **Local validation** - Verifies cmake installation and preset functionality

The bootstrap script does NOT currently handle .gitignore updates.

Alternatively, steps 3-5 can be handled by running the `xpSync` caller workflow (`.github/workflows/xpsync.yml`, copied from [`xpsync.yml`](../../.github/wf-templates/xpsync.yml)). See the `xpSync` docs in [Caller workflows](../../.github/docs/caller-workflows.md#xpsync-xpsyncyml).

## GitHub Actions workflows

For the recommended first-time workflow setup (including copying `xpsync.yml` and prerequisites before running it), see [xpSync preconditions](../../.github/docs/caller-workflows.md#preconditions-before-running-xpsync).

- If you are doing this manually (or want to understand what the workflows are doing), the core step is simply to copy the caller workflow templates from `.devcontainer/.github/wf-templates/` into your repo’s `.github/workflows/`.

```bash
mkdir -p .github/workflows
cp .devcontainer/.github/wf-templates/xp*.yml .github/workflows/
git add .github/workflows
```

- Consider adjusting `.github/workflows/xpbuild.yml` input `cmake_workflow_preset_suffix` to match your project requirements (e.g. `Release`, `ReleaseNoInstall`).
- You may need to disable or modify triggers of existing upstream workflows.

If your repo default branch is not `xpro`, you will likely need to adjust the caller workflows (deviating from the templates) so:

- the expected branch triggers `xpbuild`, and
- `xptag` branch conditionals match your branching model.

## CMake integration

1. The CMakePresets automatically inject `CMAKE_PROJECT_TOP_LEVEL_INCLUDES` to point to `.devcontainer/cmake/xproinc.cmake`, so no manual setup is needed in your `CMakeLists.txt`.

1. `xproinc.cmake` (automatically included via CMakePresets) currently:
    - defines `CMAKE_INSTALL_PREFIX` if not already defined
    - appends `.devcontainer/cmake/` to `CMAKE_MODULE_PATH`
    - includes `pros.cmake` (default externpro dependency variables)
    - sets a dependency provider so `find_package()` calls can be satisfied by externpro
    - See [Dependency provider](dependency-provider.md) for details.

1. Versioning notes
    - If your `project()` call already includes `VERSION`, keep it.
    - `xpExternPackage()` uses `git describe --tags` (via `xpGetVersionString()`) to derive the package version string.

1. Repository naming
    - `xpFindPkg()` / download+extract expects the package name to match the repository name.
    - If the `project()` name (`CMAKE_PROJECT_NAME`) does not match the repository name, pass `REPO_NAME` to `xpExternPackage()`.
    - See [Extern package](extern-package.md).

## Learning by example

A good way to learn what should be modified or created is to examine the per-project diff links in [`cmake/README.md`](../README.md).

The diff taxonomy is documented in [Diff types](diff-types.md).
