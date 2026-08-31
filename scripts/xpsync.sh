#!/usr/bin/env bash
cd "$( dirname "$0" )/../.."
cd .devcontainer
git fetch --all
git checkout main
git merge origin/main
cd ..
if [ -f ".github/workflows/xpinit.yml" ]; then
  git rm .github/workflows/xpinit.yml
fi
if [ -f ".github/workflows/xpupdate.yml" ]; then
  git rm .github/workflows/xpupdate.yml
fi
if [ ! -f ".github/workflows/xpsync.yml" ]; then
  cp .devcontainer/.github/wf-templates/xpsync.yml .github/workflows/xpsync.yml
  git add .github/workflows/xpsync.yml
fi
if [ -n "$(git status --porcelain .github/workflows/)" ]; then
  git checkout -b xpsyncWorkflow
  git commit -m "workflows: xp[init|update] -> xpsync" -m "- issue https://github.com/externpro/externpro/issues/340"
  git push cm xpsyncWorkflow
fi
OWNER_REPO=$(git remote get-url origin | sed -E 's/.*[:\/]([^\/]+)\/([^\/.]+)(\.git)?$/\1\/\2/')
gh pr create --repo ${OWNER_REPO} --head xpsyncWorkflow --base xpro
