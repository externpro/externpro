# Caller workflows (vendored into a project repo)

The caller workflows live in the *project* repository under `.github/workflows/` and typically come from templates in `externpro/externpro` under `.github/wf-templates/`.

They provide stable entrypoints for common operations while delegating the actual implementation to reusable workflows hosted in `externpro/externpro`.

## Templates

Copy these templates into the project repo:

- [`xpinit.yml`](../wf-templates/xpinit.yml)
- [`xpupdate.yml`](../wf-templates/xpupdate.yml)
- [`xpbuild.yml`](../wf-templates/xpbuild.yml)
- [`xptag.yml`](../wf-templates/xptag.yml)
- [`xprelease.yml`](../wf-templates/xprelease.yml)

## `xpInit` (`xpinit.yml`)

- **Trigger**
  - manual `workflow_dispatch`
- **Calls**
  - [`init-externpro.yml`](../workflows/init-externpro.yml)
- **Purpose**
  - bootstrap a repo to "speak externpro": add standard compose links, presets, and caller workflows; initialize dependency metadata
- **When to use**
  - first-time externpro initialization in a repo
  - re-initialize when moving the project to a new BASE upstream tag/ref (i.e., a new upstream release)

### Preconditions (before running `xpInit`)

1. Start a new repo or fork the upstream repo.
2. Identify a BASE tag (fork) or create `v0` at the first commit (new repo).
3. Create branch `xpro` and set it as the default branch.
4. Add externpro as a submodule:

```sh
git submodule add https://github.com/externpro/externpro .devcontainer
```

5. Copy `.devcontainer/.github/wf-templates/xpinit.yml` into the repo’s `.github/workflows/` and commit.
6. Push `xpro` to GitHub.

For the repo wiring and CMake integration checklist, see [How-to: adopt externpro](../../cmake/docs/how-to-adopt-externpro.md).

### What `init-externpro` does (high level)

- Validates the externpro submodule path (`.devcontainer`).
- Creates a unique `xpinit-*` branch.
- Adds/updates:
  - `docker-compose.sh` + `docker-compose.yml` links
  - `CMakePresets*`
  - `.github/workflows/xp*.yml` caller workflows
  - `.github/release-tag.json` (release intent)
  - `.gitignore` externpro entries
- Optionally applies `patches/*.patch` via `git am`.
- Configures/snapshots dependency artifacts.
- Pushes a branch and opens a PR (labels include `xpinit`, `dependencies`), closing superseded `xpinit-*` PRs.

## `xpUpdate` (`xpupdate.yml`)

- **Trigger**
  - manual `workflow_dispatch`
- **Calls**
  - [`update-externpro.yml`](../workflows/update-externpro.yml)
- **Purpose**
  - update the externpro submodule pointer, sync caller workflows from templates, refresh presets/dependency artifacts, and open a PR

### Inputs

- `target_ref` (default: `main`)
  - update externpro to a branch/tag/commit
- `preserve_existing_branches` (default: `false`)
  - preserve branch filters in existing caller workflows rather than taking them from templates

### What `update-externpro` does (high level)

- Updates the externpro submodule to `target_ref` (if needed).
- Syncs `.github/workflows/` from templates (unless preserving).
- Compares/updates CMake presets.
- Updates dependency artifacts.
- If anything changed, pushes a branch and opens a PR (labels include `xpupdate`, `dependencies`), closing superseded `xpupdate-*` PRs.

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
  - create a draft GitHub Release from a build run’s artifacts (and attach provenance)
