# CMake Update Checklist

## Core Updates
- <input type="checkbox"> cp .devcontainer/.github/wf-templates/xpupdate.yml .github/workflows
- <input type="checkbox"> Update `cmake_minimum_required` to 4.3 (related to issue https://github.com/externpro/externpro/issues/315)
- <input type="checkbox"> Remove `set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES)` from root CMakeLists.txt (related to issue https://github.com/externpro/externpro/issues/316)
- <input type="checkbox"> Update CMakePresetsBase.json, removing `XP_NAMESPACE` and use `if(COMMAND` as mentioned in issue https://github.com/externpro/externpro/issues/307#issuecomment-4130807987 and reduce the number of changes from upstream
- <input type="checkbox"> Take care if projects already have a `<package-name>-config.cmake` or `<PackageName>Config.cmake` file (issue https://github.com/externpro/externpro/issues/308#issuecomment-4210162967)

## xpExternPackage() Updates
- <input type="checkbox"> Remove `xpExternPackage` deprecated params: `NAMESPACE`, `ALIAS_NAMESPACE`, `FIND_THREADS`
- <input type="checkbox"> Ensure Package Name and Target Namespace match (see issue https://github.com/externpro/externpro/issues/307)
- <input type="checkbox"> Consider if `DEFAULT_TARGETS` param of `xpExternPackage()` should be used (as done in `fmt` with commit https://github.com/externpro/fmt/commit/d0bd083703073108f3a7961e6cd4dc3670c3dcf4)
- <input type="checkbox"> Attempt to auto-infer `DEPS` and `PVT_DEPS` (see issue https://github.com/externpro/externpro/issues/320) using cmake option `XP_EXTERNPACKAGE_AUDIT_DEPS` in CMakePresetsBase.json
- <input type="checkbox"> Consider if `EXPORT` param needs to be used when `TARGETS_FILE` param doesn't cut it for CPS and SBOM, see commit https://github.com/externpro/externpro/commit/99f4a84acce94e5091625ab1dff402b33b504cee

## Configuration Updates
- <input type="checkbox"> Turn on SBOM in CMakePresetsBase.json (as done in `spdlog` with commit https://github.com/externpro/spdlog/commit/b513b3790eff942a683fde627141605574588a87)
- <input type="checkbox"> If `find_package` isn't working with CPS, use `FIND_PACKAGE_CMAKE_SCRIPT` cmake option in CMakePresetsBase.json (support added with commit https://github.com/externpro/externpro/commit/0c316b415584aa56ddf1984939ad8fa116a8425c and used by buildpro currently with commit https://github.com/externpro/buildpro/commit/15c7c305315791172ca2ef91e75cec01eba7bc73)

## Verification
- <input type="checkbox"> Verify .json manifest file (related to issue https://github.com/externpro/externpro/issues/318)
- <input type="checkbox"> Verify Visual Studio 2026 builds (related to issue https://github.com/externpro/externpro/issues/245)

## Release Updates
- <input type="checkbox"> Make a clean git commit history (follow similar steps that were done with spdlog https://github.com/externpro/spdlog/pull/9#issue-4190607786)
- <input type="checkbox"> Update to newer release of project, if available
