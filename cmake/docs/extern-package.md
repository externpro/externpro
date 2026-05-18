# Packaging a project as an xpro package (xpExternPackage)

`xpExternPackage()` is the central externpro helper for turning a CMake project into an "xpro" package.

It is implemented in [`cmake/xpfunmac.cmake`](../xpfunmac.cmake).

At a high level it:

- generates a consumer "use" config (cmake script: `<repo>-config.cmake`)
- generates a per-release manifest (`<repo>-<tag>.manifest.cmake` or `<repo>-<tag>.manifest.json`)
- writes build metadata (`sysinfo.txt`)
- generates SBOM (Software Bill Of Materials) files
- generates CPS (Common Package Specification) files
- optionally generates dependency reports (`xprodeps.md` and `xprodeps.svg`) when dependency metadata is provided
- configures basic archive packaging (TXZ) for the produced artifacts

## Typical placement

Call `xpExternPackage()` from your top-level `CMakeLists.txt` after `project()`.

In repos using externpro, the provided CMakePresets automatically set up the dependency provider before `project()` (see [Dependency provider](dependency-provider.md)).

## Key named arguments

`xpExternPackage()` accepts a mix of "use script" parameters and "manifest" parameters.

### Use script parameters

- `REPO_NAME`
  - Use when `CMAKE_PROJECT_NAME` does not match the repository name.
  - This affects naming of generated files and the package identity used in the consumer config.

- `TARGETS_FILE`
  - A targets file name (without `.cmake`) to include from the consumer config.

- `EXPORT`
  - Export name used in `install(PACKAGE_INFO)` and `install(SBOM)` commands.
  - If not specified, defaults to `TARGETS_FILE` value.
  - Useful when the export name needs to be different from the targets file name.

- `LIBRARIES`
  - List of library target names that the consumer could link against.

- `DEFAULT_TARGETS`
  - List of default CMake targets passed to `install(PACKAGE_INFO)` for CPS generation.

- `EXE` / `EXE_PATH`
  - `EXE`: a CMake executable target name.
  - `EXE_PATH`: a relative executable path inside the package when the executable is not a CMake target.
  - Only one may be set.

- `DEPS`
  - **Consumer dependencies** (what downstream projects need). Automatically added to consumer config via `xpFindPkg(PKGS ...)` calls and included in the manifest.
  - If not specified, dependencies will be automatically inferred from `LIBRARIES` targets (PUBLIC + PRIVATE dependencies).
  - Use `NO_INFER_DEPS` option to disable automatic dependency inference.
  - When specified, inferred dependencies are audited against provided ones and differences are reported if the `XP_EXTERNPACKAGE_AUDIT_DEPS` option is enabled.

- `PVT_DEPS`
  - **Build dependencies** (what only the current project needs). Written to the manifest but NOT included in the consumer config.
  - These include build tools (e.g., yasm executable) and executable target dependencies.
  - If not specified, dependencies will be automatically inferred from `EXE` targets.

- `FIND_XPRO_CMAKE`
  - Creates a `findxpro.cmake` marker file that forces `find_package()` to use cmake script files instead of CPS files for this package.
  - Useful for packages that have CPS compatibility issues on specific platforms.
  - Can be used conditionally per platform (e.g., only on Windows).
  - Global `FIND_PACKAGE_CMAKE_SCRIPT` option can override this behavior for testing.

- `ALIAS_NAMESPACE`
  - Namespace to use for alias targets when `CREATE_ALIASES` option is specified.
  - If not provided, defaults to `xpro`.
  - Only has effect when `CREATE_ALIASES` option is enabled.

- `FIND_THREADS` (deprecated)
  - Previously emitted `find_package(Threads REQUIRED)` into the consumer config.
  - Add 'Threads' to `DEPS` parameter instead.

### Manifest metadata parameters

These fields are written into the generated manifest file (`.manifest.cmake` or `.manifest.json`):

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

- `<repo>-config.cmake`
  - Consumer entry point used by `xpFindPkg()` / `find_package(<repo>)`.

- `<REPO_NAME>-<VER>.manifest.cmake` or `<REPO_NAME>-<VER>.manifest.json`
  - Machine-readable metadata for the release.

- `sysinfo.txt`
  - Build machine details plus compiler prefix.

- `findxpro.cmake` (optional)
  - Marker file created when `FIND_XPRO_CMAKE` option is used.
  - Forces `find_package()` to use cmake script files instead of CPS files for this package.

- `xprodeps.md` and `xprodeps.svg` (optional)
  - Generated when `DEPS` or `PVT_DEPS` is provided.
  - Shows dependency relationships for both consumer and build dependencies.
  - The graph generation depends on Graphviz `dot` being available.

## Packaging behavior

`xpExternPackage()` configures a default archive package (TXZ) and sets:

- `CPACK_PACKAGE_NAME` to `REPO_NAME`
- `CPACK_PACKAGE_VERSION` to `<git-describe-version>-<compiler-prefix>`
- `CPACK_SYSTEM_NAME` based on OS and architecture

It then includes `CPack`.

For multi-generator / MSI / RPM packaging, use [`cmake/xpcpack.cmake`](../xpcpack.cmake) instead (see [Packaging](packaging.md)).
