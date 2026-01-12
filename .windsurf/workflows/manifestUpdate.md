# manifestUpdate

## Goal
Update an externpro submodule checkout and its workflow templates in a consumer repo.

## When to run
- When you want to bring a repo that uses externpro (as a submodule) up to the latest `.devcontainer`.
- When you want to refresh `.github/workflows` from externpro-provided templates.

## Inputs
- None.

## Preconditions
- Working tree is clean.
- You are in the consumer repo (the repo that vendors externpro as a submodule).
- `.devcontainer` is a git submodule.
- `.devcontainer` points to `https://github.com/externpro/externpro`.

## Workflow
### Step 0: Identify the repo's `xp_<dep>` and review externpro changes
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

### Step 1: Create a branch
```sh
git checkout -b manifestUpdate
```

### Step 2: Update `.devcontainer` to the HEAD of `origin/main` and commit
```sh
cd .devcontainer
git fetch --all
git merge origin/main
git describe --tags
```
Save the output of `git describe --tags` for the next commit message.

```sh
cd ..
git commit -m "externpro <git describe --tags>" .devcontainer
```

### Step 3: Update `.github/workflows` from templates and commit
```sh
cp .devcontainer/.github/wf-templates/xp*.yml .github/workflows/
```
Review the changes.
If the project uses `[Darwin|Linux|Windows]Release` presets, it may need to keep `cmake-workflow-preset`.

Commit message:
`workflows: externpro@<version-from-yml>`

Where `<version-from-yml>` is the version referenced in the workflow file (e.g. `build-linux.yml@<version>`, `build-macos.yml@<version>`, `build-windows.yml@<version>`).

## Outputs
- Updated `.devcontainer`
- Updated `.github/workflows`

## Notes / Decisions to confirm
- Should this workflow also include `git push` and opening a PR?
