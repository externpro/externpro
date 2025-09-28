# How-to: modify a project to build with externpro

... and utilize externpro cmake, docker build images, and github actions shared workflows to create devel packages

1. attempt to find project on github, then fork or start a new project on github
   * there is no requirement to use the externpro organization, projects can be hosted anywhere
1. add externpro repository as a git submodule
   ```bash
   git submodule add https://github.com/externpro/externpro .devcontainer
   ```
   * you may need to consider removing an existing `.devcontainer/` directory
     * examples:
       [hdf5](https://github.com/externpro/externpro/blob/main/cmake/README.md#hdf5)
1. add docker-compose links
   ```bash
   ln -s .devcontainer/compose.pro.sh docker-compose.sh
   ln -s .devcontainer/compose.bld.yml docker-compose.yml
   ```
1. add CMakePresets
   ```bash
   cp .devcontainer/cmake/presets/CMakePresets* .
   ```
1. create or modify `.gitignore` with externpro ignores
   ```
   # externpro
   .env
   _bld*/
   docker-compose.override.yml
   ```
1. consider updating the default branch name to `dev` if it is not already
1. GitHub Actions workflows
   * add GitHub Actions workflows from externpro
      ```bash
      mkdir -p .github/workflows
      cp .devcontainer/.github/wf-templates/xp*.yml .github/workflows/
      ```
   * consider modifying `.github/workflows/xpbuild.yml`'s `cmake-workflow-preset` to be `[Linux|Windows]Release` if the project doesn't need to build a `Debug` version of a library (for example, the project only builds an executable or a header-only library)
   * you may need to disable or modify the trigger of existing "upstream" GitHub Actions workflows
      * examples:
        [fmt](https://github.com/externpro/externpro/blob/main/cmake/README.md#fmt)
        [geos](https://github.com/externpro/externpro/blob/main/cmake/README.md#geos)
        [hdf5](https://github.com/externpro/externpro/blob/main/cmake/README.md#hdf5)
        [spdlog](https://github.com/externpro/externpro/blob/main/cmake/README.md#spdlog)
1. possibly modify CMakePresetsBase.json
   * add a `cacheVariables` section to set variables
     * `XP_INSTALL_CMAKEDIR` is a common one I add... and then modify CMakeLists.txt to use it in determining whether the project is being built via externpro cmake or not
   ```diff
   diff --git a/CMakePresetsBase.json b/CMakePresetsBase.json
   index 09653d8a..65047105 100644
   --- a/CMakePresetsBase.json
   +++ b/CMakePresetsBase.json
   @@ -4,7 +4,10 @@
         {
          "name": "config-base",
          "hidden": true,
   -      "binaryDir": "${sourceDir}/_bld-${presetName}"
   +      "binaryDir": "${sourceDir}/_bld-${presetName}",
   +      "cacheVariables": {
   +        "XP_INSTALL_CMAKEDIR": "share/cmake"
   +      }
        }
      ]
    }
   ```
1. modify root CMakeLists.txt (and possibly other cmake files depending on where things are)
   * consider if `cmake_minimum_required` should be modified
   * before the `project()` call...
     ```cmake
     set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES .devcontainer/cmake/xproinc.cmake)
     project(foo)
     ```
     * see [xproinc](https://github.com/externpro/externpro/blob/main/cmake/xproinc.cmake) to examine what it does currently, but as of this documentation it:
       * defines `CMAKE_INSTALL_PREFIX` if it's not already defined
       * appends `.devcontainer/cmake/` directory to `CMAKE_MODULE_PATH`, if it's not already in `CMAKE_MODULE_PATH`
       * includes [pros](https://github.com/externpro/externpro/blob/main/cmake/pros.cmake), which defines the default dependencies/projects provided by externpro
       * calls `cmake_language(SET_DEPENDENCY_PROVIDER` to set externpro as the dependency provider so all `find_package()` calls are routed through the `externpro_provide_dependency()` macro also defined in `xproinc`
   * there really is no reason to modify the `project()` call... if the cmake `project()` call has a `VERSION` argument just keep it as-is -- `xpPackageDevel()` (more specifically `xpGetVersionString()`) uses `git describe --tags` to get the version string (and possibly a 'dirtyrepo' marker if the repository is 'dirty'), so the `VERSION` doesn't have to be specified in `project()` if it's not already specified there in existing cmake
   * set preprocessor, compiler, linker flags by including `xpflags.cmake` so all externpro-built projects are built with a common set of flags https://github.com/externpro/externpro/blob/main/cmake/xpflags.cmake
     ```cmake
     include(xpflags)
     ```
   * setup for and call `xpPackageDevel()`...
     * the extraction of a devel package happens by calling `xpFindPkg()`, which calls `ipGetPrefixPath()`, which assumes the `PKG_NAME` is the same as the repository name (https://github.com/externpro/externpro/blob/25.05/cmake/xpfunmac.cmake#L1356)
     * so in the creation of the devel package, if the `project()` name (which becomes `CMAKE_PROJECT_NAME`) doesn't match the repository name, then
       ```cmake
       set(CPACK_PACKAGE_NAME "<repository-name>") # before calling `xpPackageDevel()`
       ```
   * conditionally set `install()` arguments `COMPONENT` and `NAMESPACE` if project is externpro-built, for example:
     ```cmake
     if(DEFINED XP_INSTALL_CMAKEDIR) # externpro-built
       set(XP_COMPONENT "devel") # why they are referred to as `devel` packages
       set(XP_NAMESPACE "xpro::") # helps distinguish an externpro-built package from a non-externpro-built package
     else() # whatever these values are in pre-existing cmake
       set(XP_COMPONENT "bar")
       set(XP_NAMESPACE "foo::")
     endif()
     ```
     or perhaps instead of `XP_[COMPONENT|NAMESPACE]`... use variable names to match the existing project variable naming
   * consider some way of disabling the `install()` of `pkgconfig` related files, as there is no need for them in externpro devel packages

projects that modify existing cmake
* [fmt](https://github.com/externpro/externpro/blob/main/cmake/README.md#fmt)
* [geos](https://github.com/externpro/externpro/blob/main/cmake/README.md#geos)
* [googletest](https://github.com/externpro/externpro/blob/main/cmake/README.md#googletest)
* [hdf5](https://github.com/externpro/externpro/blob/main/cmake/README.md#hdf5)
* [spdlog](https://github.com/externpro/externpro/blob/main/cmake/README.md#spdlog)
* [sqlite3](https://github.com/externpro/externpro/blob/main/cmake/README.md#sqlite3)
* [zlib](https://github.com/externpro/externpro/blob/main/cmake/README.md#zlib)

projects that introduce cmake
* [argon2](https://github.com/externpro/externpro/blob/main/cmake/README.md#argon2)
* [node-addon-api](https://github.com/externpro/externpro/blob/main/cmake/README.md#node-addon-api)

projects that add cmake to replace autotools/configure/make
* [librttopo](https://github.com/externpro/externpro/blob/main/cmake/README.md#librttopo)
* [libspatialite](https://github.com/externpro/externpro/blob/main/cmake/README.md#libspatialite)
* [spatialite-tools](https://github.com/externpro/externpro/blob/main/cmake/README.md#spatialite-tools)

projects that add cmake and repackage binaries built elsewhere
* [libiconv](https://github.com/externpro/externpro/blob/main/cmake/README.md#libiconv)
* [nasm](https://github.com/externpro/externpro/blob/main/cmake/README.md#nasm)
* [nodeng](https://github.com/externpro/externpro/blob/main/cmake/README.md#nodeng)
* [nodexp](https://github.com/externpro/externpro/blob/main/cmake/README.md#nodexp)
* [nvjpeg2000](https://github.com/externpro/externpro/blob/main/cmake/README.md#nvjpeg2000)
* [patch](https://github.com/externpro/externpro/blob/main/cmake/README.md#patch) on Windows

projects that add cmake but use existing build system
* [patch](https://github.com/externpro/externpro/blob/main/cmake/README.md#patch) on Linux
