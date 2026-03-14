# Packaging a project as an xpro package (xpExternPackage)

`xpExternPackage()` is the central externpro helper for turning a CMake project into an "xpro" package.

It is implemented in [`cmake/xpfunmac.cmake`](../xpfunmac.cmake).

At a high level it:

- generates a consumer "use" config (`xpuse-<pkg>-config.cmake`)
- generates a per-release manifest (`<repo>-<tag>.manifest.cmake`)
- writes build metadata (`sysinfo.txt`)
- optionally generates dependency reports (`xprodeps.md` and `xprodeps.svg`) when dependency metadata is provided
- configures basic archive packaging (TXZ) for the produced artifacts

## Typical placement

Call `xpExternPackage()` from your top-level `CMakeLists.txt` after `project()`.

In repos that integrate externpro via `CMAKE_PROJECT_TOP_LEVEL_INCLUDES`, the dependency provider is typically set up before `project()` (see [Dependency provider](dependency-provider.md)).

## Key named arguments

`xpExternPackage()` accepts a mix of "use script" parameters and "manifest" parameters.

### Use script parameters

- `REPO_NAME`
  - Use when `CMAKE_PROJECT_NAME` does not match the repository name.
  - This affects naming of generated files and the package identity used in the consumer config.

- `TARGETS_FILE`
  - A targets file name (without `.cmake`) to include from the consumer config.

- `LIBRARIES`
  - List of library target names that the consumer could link against.

- `EXE` / `EXE_PATH`
  - `EXE`: a CMake executable target name.
  - `EXE_PATH`: a relative executable path inside the package when the executable is not a CMake target.
  - Only one may be set.

- `DEPS`
  - List of externpro dependency names. Used to generate `xpFindPkg(PKGS ...)` in the consumer config.

- `PVT_DEPS`
  - Private dependencies written to the manifest but not included in the consumer config.

- `FIND_THREADS`
  - Emits `find_package(Threads REQUIRED)` into the consumer config.

### Manifest metadata parameters

These fields are written into the generated `*.manifest.cmake` file:

- `WEB`
  - Project homepage URL.
- `UPSTREAM`
  - Upstream source repository URL.
- `LICENSE`
  - License identifier and/or URL for the project.
- `DESC`
  - Short description used in dependency reporting.
- `ATTRIBUTION`
  - Attribution text to include in the manifest when required by the project.
- `BASE`
  - The upstream tag/commit that the externpro changes are based on.
- `XPDIFF`
  - The externpro diff type for this project (see [Diff types](diff-types.md)).

## Generated files (in the build directory)

- `xpuse-<repo>-config.cmake`
  - Consumer entry point used by `xpFindPkg()` / `find_package(xpuse-<repo>)`.

- `<REPO_NAME>-<VER>.manifest.cmake`
  - Machine-readable metadata for the release.

- `sysinfo.txt`
  - Build machine details plus compiler prefix.

- `xprodeps.md` and `xprodeps.svg` (optional)
  - Generated when `DEPS` or `PVT_DEPS` is provided.
  - The graph generation depends on Graphviz `dot` being available.

## Packaging behavior

`xpExternPackage()` configures a default archive package (TXZ) and sets:

- `CPACK_PACKAGE_NAME` to `REPO_NAME`
- `CPACK_PACKAGE_VERSION` to `<git-describe-version>-<compiler-prefix>`
- `CPACK_SYSTEM_NAME` based on OS and architecture

It then includes `CPack`.

For multi-generator / MSI / RPM packaging, use [`cmake/xpcpack.cmake`](../xpcpack.cmake) instead (see [Packaging](packaging.md)).
