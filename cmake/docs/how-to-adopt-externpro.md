# How-to: adopt externpro in a project

This page describes the typical steps to modify a project to build with externpro, and to leverage externpro CMake, docker build images, and GitHub Actions workflows to create xpro packages.

## Project setup

1. Find the upstream project and fork it (or create a new repo)

- Note: there is no requirement to use the `externpro` GitHub organization.

2. Add externpro as a git submodule

```bash
git submodule add https://github.com/externpro/externpro .devcontainer
```

3. Add docker-compose links

```bash
ln -s .devcontainer/compose.pro.sh docker-compose.sh
ln -s .devcontainer/compose.bld.yml docker-compose.yml
```

4. Add CMakePresets

```bash
cp .devcontainer/cmake/presets/CMakePresets* .
```

5. Update `.gitignore` with externpro ignores

```
# externpro
.env
_bld*/
docker-compose.override.yml
```

Note: steps 3-5 can also be handled by running the `xpInit` caller workflow (`.github/workflows/xpinit.yml`, copied from [`xpinit.yml`](../../.github/wf-templates/xpinit.yml)). See the `xpInit` docs in [Caller workflows](../../.github/docs/caller-workflows.md#xpinit-xpinityml).

## GitHub Actions workflows

For the recommended first-time workflow setup (including copying `xpinit.yml` and prerequisites before running it), see [xpInit preconditions](../../.github/docs/caller-workflows.md#preconditions-before-running-xpinit).

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
