# externpro GitHub Actions Integration

This directory contains GitHub Actions building blocks (reusable workflows, composite actions, and caller workflow templates) intended to be vendored into other repositories via an `externpro/externpro` git submodule.

## Quick map

- `.devcontainer/.github/wf-templates/`
  - Caller workflow templates (copy these into the target repo’s `.github/workflows/`)
- `.devcontainer/.github/workflows/`
  - Reusable workflows meant to be called from other repos
- `.devcontainer/.github/actions/`
  - Composite actions and helper scripts used by reusable workflows

## `xpinit` (initialize externpro in a repo)

`xpinit` is intended for projects that want to initialize externpro for the first time or re-initialize from a new BASE upstream tag/ref (i.e. moving the project to be based on a new upstream release).

### Preconditions (do this before running `xpinit`)

1. Attempt to find the project on GitHub and fork it, OR start a new project on GitHub.
2. Identify an upstream BASE tag if the repo was forked, OR create a tag `v0` for the first commit of the repo if started from a new project.
3. Create a branch named `xpro` and make it the default branch for the repo (GitHub repo settings).
   - Delete the existing `xpro` branch if updating to a new BASE upstream tag and `xpro` is currently based on an older BASE upstream tag.
   - If this is a forked repo:
     - `git checkout -b xpro <BASE-tag-of-upstream-repo>`
     - push `xpro` to GitHub (may need to be a forced push if updating to a newer BASE upstream tag)
   - If this is a new project, name the default branch `xpro`.
4. Add externpro as a git submodule:

   ```sh
   git submodule add https://github.com/externpro/externpro .devcontainer
   ```

5. Copy `.devcontainer/.github/wf-templates/xpinit.yml` into the repo’s `.github/workflows/` directory (create it if it does not exist) and commit.
6. Push the `xpro` branch to GitHub. At this point the branch is based on the BASE tag (or `v0`), has the externpro submodule, and contains the `xpinit` workflow.

### Running `xpinit`

- Go to the repo’s **Actions** tab.
- Select **xpInit externpro**.
- Click **Run workflow**.

### Required secrets

The caller workflow templates (`xpinit`, `xpupdate`, and `xptag`) map a repository secret named `XPRO_TOKEN` to the reusable workflows’ `automation_token` secret.

`XPRO_TOKEN` should be a PAT or fine-grained token with:
- read/write to the repository contents
- permission to update workflows (`.github/workflows/*`)

For step-by-step instructions (with screenshots) on creating a fine-grained PAT and adding `XPRO_TOKEN` to a repo, see:

- [Creating a fine-grained PAT](secrets-and-tokens.md#creating-a-fine-grained-pat)
- [Adding `XPRO_TOKEN` to the repository](secrets-and-tokens.md#adding-xpro_token-to-the-repository)
