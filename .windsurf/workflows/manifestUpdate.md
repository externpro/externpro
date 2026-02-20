---
auto_execution_mode: 3
---
# manifestUpdate

## Goal
Update an externpro submodule checkout and its workflow templates in a consumer repo.

## When to run
- When you want to bring a repo that uses externpro (as a submodule) up to the latest `.devcontainer`.
- When you want to refresh `.github/workflows` from externpro-provided templates.
- When you want to modify cmake to use `xpExternPackage()` instead of `xpPackageDevel()` to generate a manifest file.

## Inputs
- None.

## Preconditions
- Working tree does not have unrelated/uncommitted changes. A modified `.devcontainer` submodule pointer is expected after the pre-step.
- You are in the consumer repo (the repo that vendors externpro as a submodule).
- `.devcontainer` is a git submodule.
- `.devcontainer` points to `https://github.com/externpro/externpro`.

## How to run in Windsurf
In the Windsurf Cascade prompt, run:
`/manifestUpdate`

## User pre-step (do this before running `/manifestUpdate`)
Update `.devcontainer` to the HEAD of `origin/main` so the workflow definitions and templates you are about to use are current.

```sh
cd .devcontainer
git fetch --all
git merge origin/main
```

Review externpro changes for the repo being updated.

In consumer repos, the repository name (root source directory name) typically matches the externpro package variable in `.devcontainer/cmake/pros.cmake`:
`set(xp_<dep> ...)` where `<dep>` is the lowercase repo name.

Use the `BASE` and `TAG` values from that `xp_<dep>` entry to review the changes externpro carries on top of upstream.

Options:
- GitLens: compare `BASE...TAG`
- GitHub: `https://github.com/externpro/<repo>/compare/<BASE>...<TAG>`
- Windsurf terminal (run from the repo root you opened in Windsurf):
```sh
git fetch --tags --all
git diff <BASE>..<TAG>
```

Note: `buildpro` is a special-case dev repo and is not expected to appear as an `xp_<dep>` entry in `pros.cmake`.

## Workflow
### Confirmation policy
Run steps without stopping for confirmation until a commit is ready to be reviewed.

Only stop at the commit gates (staged diff is available) and ask:
`Proceed? (y/N)`

Treat a reply of `y` as approval to continue.

### Step 1: Review the externpro diff for this repo
This step is required so Cascade can apply the later steps correctly.

Determine `<BASE>` and `<TAG>` from `.devcontainer/cmake/pros.cmake` by locating the `xp_<dep>` entry for this repo.

`<BASE>` may be overridden when it can be inferred reliably from how the project determines its version in CMake (for example via `project(... VERSION ...)`, a `*_VERSION` variable, or a version header). If you override `<BASE>`, ensure the chosen tag exists upstream and matches the inferred version.

```sh
git fetch --tags --all
git diff <BASE>..<TAG>
```

### Step 2: Create a branch
```sh
git checkout -b manifestUpdate
```

Verify the working tree is clean except for the expected `.devcontainer` submodule pointer update.
```sh
git status
```
If unrelated files are modified, stop and ask the user how to proceed.

### Step 3: Commit the `.devcontainer` submodule pointer
```sh
cd .devcontainer
XP_TAG=$(git describe --tags)
echo "externpro ${XP_TAG}"
```

```sh
cd ..
git add .devcontainer
git diff --staged -- .devcontainer
```

Ask the user to review the staged changes above and confirm `Proceed? (y/N)`.

```sh
git commit -m "externpro ${XP_TAG}" .devcontainer
```

### Step 4: Update `.github/workflows` from templates and commit
```sh
cp .devcontainer/.github/wf-templates/xp*.yml .github/workflows/
```
Review the changes.
If the consumer repo uses non-default CMake workflow presets ending in `Release` (e.g. `LinuxRelease`, `DarwinRelease`, `WindowsRelease`) in its existing `xpbuild.yml`, preserve those values after copying the templates.

Policy:
- Do copy the templates (the template structure is authoritative; for example linux should typically be a single job).
- After copying, re-apply only the consumer repo's non-default `cmake_workflow_preset` values that end in `Release`.
- Do not add extra linux jobs (e.g. `linux-arm64`) solely to force architecture selection.
- Do not set `arch_list` unless the consumer repo has a specific reason to deviate; the default should build the intended architectures.

If the project has a `cmake_workflow_preset` workflow, it MUST be preserved.

If `cmake_workflow_preset` exists, ensure it is not overwritten by the template copy step (restore it if needed) before staging `xp*.yml`.

```sh
XP_WF_TAG=$(grep -hE "uses: externpro/externpro/.github/workflows/.*@" .github/workflows/xp*.yml | head -1 | sed -E 's/.*@([^ ]+).*/\1/')
echo "workflows: externpro@${XP_WF_TAG}"
git add .github/workflows/xp*.yml
git diff --staged -- .github/workflows/xp*.yml
```

Ask the user to review the staged changes above and confirm `Proceed? (y/N)`.

```sh
git commit -m "workflows: externpro@${XP_WF_TAG}"
```

### Step 5: Update `CMakePresetsBase.json` if needed
Compare the consumer repo's `CMakePresetsBase.json` against the externpro presets in `.devcontainer/cmake/presets/`.

```sh
diff -u CMakePresetsBase.json .devcontainer/cmake/presets/CMakePresetsBase.json || true
```

If the diff is empty, no action is required.

If the diff shows changes are needed:
- Update the consumer repo presets to match externpro as closely as possible.
- Keep the consumer repo's `configurePresets.cacheVariables` intact (do not delete or rewrite existing keys just because externpro's template differs).
  - In particular, do not remove `XP_NAMESPACE` here unless the consumer repo is already transitioning away from it for reasons outside this workflow.
- If the consumer repo still has `XP_INSTALL_CMAKEDIR` in `cacheVariables`, remove it and set `XP_NAMESPACE` to `xpro` instead.
- Ensure `buildPresets` exists and matches what externpro provides in `.devcontainer/cmake/presets/` (some consumer repos may be missing `buildPresets` entirely).

```sh
git add CMakePresets*.json
git diff --staged -- CMakePresets*.json
```

Ask the user to confirm the staged changes shown above are expected and confirm `Proceed? (y/N)`.

```sh
git commit -m "CMakePresets: updates from externpro cmake/presets"
```

### Step 6: Remove `include(xpflags)` and `include(GNUInstallDirs)` if they were added
From the Step 1 diff (`BASE...TAG`), if externpro added either of these lines, delete them in the local working copy:
- `include(xpflags)`
- `include(GNUInstallDirs)`

If they were not added by externpro, leave them as-is.

### Step 7: Replace `xpPackageDevel()` with `xpExternPackage()`
Update the project CMake to call `xpExternPackage()` instead of `xpPackageDevel()`.

### Step 8: Add the correct `xpExternPackage()` parameters
 - If the project has a helper function that calls `xpPackageDevel()` (typically `callPackageDevel()`), remove that function and call `xpExternPackage()` directly.
 - Omit `REPO_NAME` unless the repository name does not match `project()`/`CMAKE_PROJECT_NAME`.
   - If the legacy CMake was forcing `CMAKE_PROJECT_NAME` to a value different from `project(...)`, remove that and use `REPO_NAME` only when needed to preserve the manifest repo name.
 - Do not invent namespace/alias policy. Infer from existing CMake structure.
 - Only pass `ALIAS_NAMESPACE` when there is an existing `else()` policy for when `XP_NAMESPACE` is not defined. If there is no `else()` conditional, do not pass `ALIAS_NAMESPACE`.
 - Do not introduce helper variables like `xpExternPackageArgs`. Prefer a direct `xpExternPackage(...)` call.
 - If there is no `else()` conditional for when `XP_NAMESPACE` is not defined, call `xpExternPackage(...)` only inside the `if(DEFINED XP_NAMESPACE)` block.
 - If there is no existing `else()` conditional for when `XP_NAMESPACE` is not defined, keep the prior pattern:
  - Prefer a namespace helper variable named `CMAKE_NAMESPACE` that does not include `::`:
    - `set(CMAKE_NAMESPACE ${XP_NAMESPACE})` when `XP_NAMESPACE` is defined
    - `set(CMAKE_NAMESPACE <default_namespace>)` when `XP_NAMESPACE` is not defined
  - Add `::` only at the call sites, e.g. `${CMAKE_NAMESPACE}::libfoo`.
 - Prefer fewer conditional paths; keep the existing non-externpro behavior intact instead of adding new conditionals.
 - Prefer `set(CMAKE_OPT_INSTALL ...)` after the `xpExternPackage(...)` call (since `xpExternPackage()` does not use it) so it stays close to the surrounding `if()/else()` conditional behavior.
 - Prefer `set(targetsFile ${PROJECT_NAME}-targets)`; do not introduce lowercasing unless the project already had it.
 - Since `xpExternPackage()` sets `XP_INSTALL_CMAKEDIR`, prefer this pattern so non-externpro builds still install exports correctly:
  - `if(DEFINED XP_NAMESPACE) ... xpExternPackage(...) ... elseif(NOT DEFINED XP_INSTALL_CMAKEDIR) set(XP_INSTALL_CMAKEDIR ${CMAKE_INSTALL_DATADIR}/cmake) endif()`
  - If the consumer repo needs to reference an install directory outside of `xpExternPackage()`, prefer `CMAKE_INSTALL_CMAKEDIR` (more generic) rather than `XP_INSTALL_CMAKEDIR`.
    - In the externpro path: `set(CMAKE_INSTALL_CMAKEDIR ${XP_INSTALL_CMAKEDIR})`
    - In the non-externpro path: set `CMAKE_INSTALL_CMAKEDIR` to the upstream default (e.g. `${CMAKE_INSTALL_LIBDIR}/cmake/<project>`)
  - Avoid introducing new direct uses of `XP_INSTALL_CMAKEDIR` outside of `xpExternPackage()`; treat it as the externpro-provided source value.
 - If the project has `set(CMAKE_INSTALL_DEFAULT_COMPONENT_NAME ...)` or `set(XP_INSTALL_CMAKEDIR ...)`, remove them (obsolete with `xpExternPackage()`).
 - If the project has `set(XP_OPT_INSTALL <bool>)`, rename it to `set(CMAKE_OPT_INSTALL <bool>)` and update all uses.
 - Prefer compact CMake style: avoid blank lines and avoid introducing extra namespace variables.
 - Only introduce a namespace helper variable (e.g. `CMAKE_NAMESPACE`) when the externpro diff is modifying existing CMake (e.g. `XPDIFF` is not `intro`) and preserving non-externpro behavior is important.
 - If CMake is being introduced (all CMake was added by the externpro diff, e.g. `XPDIFF` is `intro`), prefer the simpler `nameSpace` pattern so it can be empty when `XP_NAMESPACE` is not defined and can be used directly in `install(EXPORT ... NAMESPACE ${nameSpace})`.
  - Prefer making `nameSpace` an *argument list* so you never emit `NAMESPACE ""`:
    - `if(DEFINED XP_NAMESPACE) set(nameSpace NAMESPACE ${XP_NAMESPACE}::) endif()`
    - `install(EXPORT ... ${nameSpace})`
  - If you already have an `if(DEFINED XP_NAMESPACE)` block for `xpExternPackage(...)`, you can set `nameSpace` inside that block (before or after `xpExternPackage(...)`) so you don't need a second `if()` later:
    - `if(DEFINED XP_NAMESPACE) ... xpExternPackage(...) ... set(nameSpace NAMESPACE ${XP_NAMESPACE}::) ... endif()`
 - Assume `GNUInstallDirs` is already available via `.devcontainer/cmake/xproinc.cmake`; do not add conditional `include(GNUInstallDirs)` wrappers when converting.
 - Decide whether the `BASE` tag can be inferred from how the project determines its version in CMake (for example via `project(... VERSION ...)`, a `*_VERSION` variable, or a version header). If it can, use that to choose a correct upstream tag for `BASE`.
 - Copy the metadata from `.devcontainer/cmake/pros.cmake` for the `xp_<dep>` project being converted and make those `xpExternPackage()` parameters:
  - `XPBLD` becomes `XPDIFF` (preserve the quoting exactly as in `pros.cmake`, e.g. `XPDIFF "patch"`)
  - `BASE`
  - `DEPS`
  - `EXE_DEPS` becomes `PVT_DEPS`
  - `WEB`
  - `UPSTREAM`
  - `DESC`
  - `LICENSE`

 Sourcing checklist (do this before editing the `xpExternPackage(...)` call):
 - Copy values from `pros.cmake` verbatim, including quoting.
 - Omit keys that do not exist for this project in `pros.cmake` (do not invent values).
 - `BASE` is allowed to be overridden when it can be inferred reliably from the project version already determined in CMake (and the chosen tag exists upstream). If you override `BASE`, do not change other metadata unless it is also wrong.

 Parameter ordering/formatting:
 - First line: `xpExternPackage(REPO_NAME ... NAMESPACE ... ALIAS_NAMESPACE TODO:edit` (omit `REPO_NAME` unless needed)
 - Second line: start the line with `TARGETS_FILE` and keep `EXE` and `LIBRARIES` on the same line when present (only those that exist; use `EXE_PATH` instead of `EXE` when applicable)
 - Third line: `BASE` then `XPDIFF` then `FIND_THREADS` then `DEPS`
 - Fourth line: `WEB` then `UPSTREAM`
 - Fifth line: `DESC`
 - Sixth line: `LICENSE`
 - Closing `)`: indent like the parameter lines (two spaces beyond the `xpExternPackage(` start)

 Canonical template (match line breaks and ordering exactly; omit optional keys rather than reflowing lines):
 ```cmake
 xpExternPackage(REPO_NAME <repoName-if-needed> NAMESPACE <ns> ALIAS_NAMESPACE <alias-if-needed>
   TARGETS_FILE <targetsFile> EXE <exe> LIBRARIES <libs>
   BASE <baseTag> XPDIFF <xpDiff> FIND_THREADS DEPS <deps>
   WEB <web> UPSTREAM <upstream>
   DESC <desc>
   LICENSE <license>
   )
 ```

 Verification checklist (do this before `git add -p`):
 - Confirm the `xpExternPackage(` call has exactly these 6 parameter lines (plus the closing `)` line).
 - Confirm line 1 only contains `REPO_NAME` when required; otherwise it must start `xpExternPackage(NAMESPACE ...`.
 - Confirm line 2 starts with `TARGETS_FILE` and keeps `EXE`/`EXE_PATH` and `LIBRARIES` on the same line.
 - Confirm the `BASE/XPDIFF/DEPS` line appears before `WEB/UPSTREAM`.
 - Confirm `FIND_THREADS` is treated as a flag (present/absent), not as `FIND_THREADS <bool>`.
 - Confirm `DESC` and `LICENSE` are each on their own lines.

 Recommended sanity build (run after the conversion, before `git add -p`):
 - Configure and build using the repo's standard preset(s) (or at least a configure) to catch breakage before staging.

### Step 9: Stage the minimal set of changes
```sh
git add -p
```

### Step 10: Review the full diff from upstream `BASE`
Where `<BASE>` is the tag recorded in the `BASE` parameter of your `xpExternPackage()` call:
```sh
git diff <BASE>
```
Minimize the diff as much as possible so future externpro updates are easier.

### Step 11: Commit the changes
Suggested commit message:

```sh
git diff --staged
```

Ask the user to review the staged changes above and confirm `Proceed? (y/N)`.

```sh
git commit -m "cmake: xproinc enhancements and xpExternPackage()"
```

If `XP_` variables were renamed to `CMAKE_`, include this line in the commit message body:
```sh
git commit -m "cmake: xproinc enhancements and xpExternPackage()" \
  -m "also rename XP_ variables to be more generic (CMAKE_)"
```

## Outputs
- Updated `.devcontainer` submodule pointer
- Updated `.github/workflows`
- Updated project CMake to use `xpExternPackage()`
- Staged changes (`git add -p`)
- Commit created
