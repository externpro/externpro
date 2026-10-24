# Packaging a project as an xpro package (xpExternPackage)

`xpExternPackage()` is the central externpro helper for turning a CMake project into an "xpro" package.

It is implemented in [`cmake/xpfunmac.cmake`](../xpfunmac.cmake).

At a high level it:

- generates a consumer "use" config (cmake script: `<repo>-config.cmake`)
- generates a per-release manifest (`<repo>-<tag>.manifest.json`)
- writes build metadata (`sysinfo.txt`)
- generates SBOM (Software Bill Of Materials) files
- generates CPS (Common Package Specification) files
- generates imported-target definitions and CPS components for pre-built binaries ([`xpPrebuiltComponent`](#pre-built-components-xpprebuiltcomponent))
- optionally generates dependency reports (`xprodeps.md` and `xprodeps.svg`) when dependency metadata is provided
- configures basic archive packaging (TXZ) for the produced artifacts

## Typical placement

Call `xpExternPackage()` from your top-level `CMakeLists.txt` after `project()`.

In repos using externpro, the provided cmake presets automatically set up the dependency provider before `project()` (see [Dependency provider](dependency-provider.md)).

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
  - List of default CMake targets passed to `install(PACKAGE_INFO)` for CPS generation; also names the `default_components` of the `.cps` generated for prebuilt components (when no `EXPORT` is set).

- `EXE` / `EXE_PATH`
  - `EXE`: a CMake executable target name — either a real target in this build or a prebuilt component declared via `xpPrebuiltComponent`. Sets `<PKG>_EXE` in the use script.
  - `EXE_PATH` (deprecated): a relative executable path inside the package. When combined with `EXE` it is translated to `xpPrebuiltComponent(<EXE> TYPE executable LOCATION <path>)`; without `EXE`, `<PKG>_EXE` is set to the path directly (legacy behavior).
  - Use `xpPrebuiltComponent` instead — see [Pre-built components](#pre-built-components-xpprebuiltcomponent).

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
  - Namespace to use for alias targets when `CREATE_ALIASES` is enabled.
  - If not provided, defaults to `xpro`.
  - Specifying `ALIAS_NAMESPACE` automatically enables `CREATE_ALIASES`.
  - Maps every `LIBRARIES`/`EXE` component uniformly into the given namespace; for explicit name-mapped aliases (e.g. `OpenSSL::Crypto`), use [`xpAlias`](#explicit-aliases-xpalias) — the two may coexist.

- `FIND_THREADS` (deprecated)
  - Previously emitted `find_package(Threads REQUIRED)` into the consumer config.
  - Add 'Threads' to `DEPS` parameter instead.

### Manifest metadata parameters

These fields are written into the generated manifest file (`.manifest.json`):

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

## Pre-built components (xpPrebuiltComponent)

For binaries built elsewhere — e.g. `XPDIFF "bin"` repackaging — there is no CMake `EXPORT` set, so `install(EXPORT)`/`install(PACKAGE_INFO)` cannot describe them. Declare them with `xpPrebuiltComponent()` **before** `xpExternPackage()` (accumulating, like `install(TARGETS ... EXPORT)`):

```cmake
xpPrebuiltComponent(<name>
  TYPE executable|archive|dylib|module|interface
  [LOCATION <path>]         # relative to package root; required unless
                            # TYPE interface; CMAKE_EXECUTABLE_SUFFIX
                            # appended for TYPE executable
  [IMPLIB_LOCATION <path>]  # import library path for TYPE dylib
  [INCLUDES <dir>...]       # include dirs relative to package root
  [LINK_LANGUAGES <l>...]   # e.g. c cxx
  [REQUIRES <comp>...]      # deps: bare name = this package, or ns::name
  )
```

Each spec generates both consumer representations:

- `if(NOT TARGET)`-guarded imported-target definitions in the generated use script (`<repo>-config.cmake`) and `-usext.cmake` (for CPS consumers). `archive`/`dylib`/`module` map to `STATIC`/`SHARED`/`MODULE` imported libraries; `INCLUDES`/`LINK_LANGUAGES`/`REQUIRES` become `INTERFACE_INCLUDE_DIRECTORIES`/`IMPORTED_LINK_INTERFACE_LANGUAGES`/`INTERFACE_LINK_LIBRARIES`.
- `"components"` entries in a generated `<repo>.cps`, installed alongside the manifest (only when no `EXPORT` is set — `install(PACKAGE_INFO)` cannot cover non-target components, so mixing real targets and prebuilt components emits an `AUTHOR_WARNING`).

`<PKG>_LIBRARIES` and `<PKG>_EXE` are driven by the `LIBRARIES` and `EXE` parameters — same as for real targets. List a prebuilt component in `LIBRARIES` to add it to `<PKG>_LIBRARIES` (and `reqVars`); `EXE` may name a prebuilt component to set `<PKG>_EXE` to the imported target. Likewise, `DEFAULT_TARGETS` names the components written to `default_components` in the generated `.cps`.

Consumers get the same targets either way: CMake < 4.5 falls back to the cmake-script path (executable components trigger this automatically); CMake ≥ 4.5 imports them from the `.cps`.

Example:

```cmake
if(WIN32)
  xpPrebuiltComponent(nodelib TYPE archive
    LOCATION "lib/node${CMAKE_STATIC_LIBRARY_SUFFIX}"
    LINK_LANGUAGES c cxx INCLUDES include include/node)
else()
  xpPrebuiltComponent(nodelib TYPE interface INCLUDES include include/node)
endif()
xpExternPackage(LIBRARIES nodelib ...)
```

## Explicit aliases (xpAlias)

Call `xpAlias(<alias> <component>)` before `xpExternPackage()` to emit `if(NOT TARGET)`-guarded `ALIAS` targets into the generated use scripts — for backwards-compatible target names expected by CMake's bundled find modules:

```cmake
xpAlias(OpenSSL::Crypto crypto)
xpAlias(OpenSSL::SSL ssl)
```

emits

```cmake
if(NOT TARGET OpenSSL::Crypto)
  add_library(OpenSSL::Crypto ALIAS openssl::crypto)
endif()
if(NOT TARGET OpenSSL::SSL)
  add_library(OpenSSL::SSL ALIAS openssl::ssl)
endif()
```

`<component>` may be a bare component name (resolved to `<repo>::<component>`) or a fully-qualified target name. `add_library` vs `add_executable` is inferred from the component: an existing fully-qualified target, then a bare build target, then a matching `xpPrebuiltComponent` spec's `TYPE`; defaults to `add_library`.

Coexists with `CREATE_ALIASES`/`ALIAS_NAMESPACE` — e.g. `ALIAS_NAMESPACE xpro` gives uniform `xpro::crypto` aliases while `xpAlias` provides the name-mapped `OpenSSL::Crypto` for the same target. Collisions are first-wins under the `if(NOT TARGET)` guards.

## Generated files (in the build directory)

- `<repo>-config.cmake`
  - Consumer entry point used by `xpFindPkg()` / `find_package(<repo>)`.

- `<REPO_NAME>-<VER>.manifest.json`
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
