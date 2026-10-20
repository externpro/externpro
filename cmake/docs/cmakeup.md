# CMake Update Checklist

```
git switch xpro
git reset --soft <current_tag>
git restore --staged .
git stash push --include-untracked -m "stash xpro bootstrap files" -- .github/workflows/xp*.yml CMakePresets* xpPresets* docker-compose* .gitmodules
git stash push --include-untracked -m "stash .github" -- .github/
git stash push -m "stash changes to tracked files"
git switch --detach <new_tag>
git push cm <new_tag>
git branch -D xpro
git switch -c xpro
git push --force-with-lease cm xpro
git submodule add https://github.com/externpro/externpro .externpro
./.externpro/scripts/bootstrap.sh
git stash pop stash@{1}
<keep .github/release-tag.json as-is>
git add .github/release-tag.json
git commit -m "add .github/release-tag.json" .github/release-tag.json
<modify .github/workflows/ as needed (upstream workflows)>
git commit -m "workflows: upstream ..." .github/workflows/
git push cm xpro
git switch -c xpsync
rm .github/workflows/xp*.yml .gitmodules CMakePresets*.json xpPresets*.json docker-compose*
git stash pop stash@{2}
<add/commit changes to bootstrap files>
<update .github/release-tag.json>
git commit -m "update .github/release-tag.json" .github/release-tag.json
git stash pop stash@{0}
git add -p .gitignore
git commit -m "gitignore: externpro ignores" .gitignore
<changes to make cmake externpro-ready>
git add -p .
git commit -m "cmake: xpExternPackage, externpro-ready"
git push cm xpsync
<clean up 'git stash list'>
```
