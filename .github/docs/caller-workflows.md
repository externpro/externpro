# Caller workflows (vendored into a project repo)

The caller workflows live in the *project* repository under `.github/workflows/` and typically come from templates in `externpro/externpro` under `.github/wf-templates/`.

They provide stable entrypoints for common operations while delegating the actual implementation to reusable workflows hosted in `externpro/externpro`.

## Templates

Copy these templates into the project repo:

- [`xpsync.yml`](../wf-templates/xpsync.yml)
- [`xpbuild.yml`](../wf-templates/xpbuild.yml)
- [`xptag.yml`](../wf-templates/xptag.yml)
- [`xprelease.yml`](../wf-templates/xprelease.yml)

## `xpSync` (`xpsync.yml`)

- **Trigger**
  - manual `workflow_dispatch`
- **Calls**
  - [`sync-externpro.yml`](../workflows/sync-externpro.yml)
- **Purpose**
  - Handles both initial externpro setup and ongoing updates
- **When to use**
  - **First-time externpro initialization** in a repo
  - **Ongoing updates** to externpro submodule pointer
  - **Re-initialization** when moving to a new BASE upstream tag/ref
  - Any externpro maintenance tasks

### Preconditions (before running `xpSync`)

**Required (manual)**:
1. Start a new repo or fork the upstream repo.
2. Identify a BASE tag (fork) or create `v0` at the first commit (new repo).
3. Add externpro as a submodule:

```sh
git submodule add https://github.com/externpro/externpro .devcontainer
```

**Then choose one of the following**:

**Automated Setup**: Run the [bootstrap script](../docs/bootstrap.md) to perform the manual steps listed below (plus additional automation like XPRO_TOKEN setup and default branch configuration).

**Manual Setup**:

4. Create branch `xpro` and set it as the default branch.
5. Commit the submodule addition.
6. Copy `.devcontainer/.github/wf-templates/xpsync.yml` into the repo's `.github/workflows/` and commit.
7. Push `xpro` to GitHub.

For the repo wiring and CMake integration checklist, see [How-to: adopt externpro](../../cmake/docs/how-to-adopt-externpro.md).

### What `sync-externpro` does (high level)

- Validates the externpro submodule path (`.devcontainer`).
- Creates a unique `xpsync-*` branch.
- Detects and applies patches from `patches/*.patch` via `git am` (advanced feature for custom modifications).
  > **Note**: This feature is primarily used for specialized cases like the externpro/tutorial repository. Most repositories will not need patch files.
- Updates externpro submodule to `target_ref` (branch/tag/commit, defaults to `main`).
- Adds/updates:
  - `docker-compose.sh` + `docker-compose.yml` links
  - `CMakePresets*`
  - `.github/workflows/xp*.yml` caller workflows
  - `.github/release-tag.json` (release intent)
  - `.gitignore` externpro entries
- Configures/snapshots dependency artifacts.
- Pushes a branch and opens a PR (labels include `xpsync`, `dependencies`), closing superseded `xpsync-*` PRs.

### Inputs

- `target_ref` (default: `main`)
  - update externpro to a branch/tag/commit
- `preserve_existing_branches` (default: `false`)
  - preserve branch filters in existing caller workflows rather than taking them from templates

## `xpBuild` (`xpbuild.yml`)

- **Triggers (default template)**
  - pull request targeting `xpro`
  - tag push matching `xpv*`
  - manual `workflow_dispatch`
- **Calls**
  - [`build-linux.yml`](../workflows/build-linux.yml)
  - [`build-macos.yml`](../workflows/build-macos.yml)
  - [`build-windows.yml`](../workflows/build-windows.yml)
- **Purpose**
  - run the standard build matrix and produce artifacts for release/tag builds

## `xpTag` (`xptag.yml`)

- **Trigger (default template)**
  - pull request `closed`
- **Condition**
  - PR merged into `xpro` and PR has label `release:tag`
- **Calls**
  - [`tag-release.yml`](../workflows/tag-release.yml)
- **Purpose**
  - on merge, create and push a signed/annotated tag based on `.github/release-tag.json`

## `xpRelease` (`xprelease.yml`)

- **Triggers (default template)**
  - `workflow_run` after `xpBuild` completes
  - manual `workflow_dispatch` with a `workflow_run_url`
- **Behavior**
  - automatically dispatches a release run when a successful `xpBuild` completes for an `xpv*` tag
- **Calls**
  - [`release-from-build.yml`](../workflows/release-from-build.yml)
- **Purpose**
  - create a draft GitHub Release from a build run's artifacts (and attach provenance)
