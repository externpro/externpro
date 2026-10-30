# Architecture overview

This page gives a quick mental model of how externpro's CMake dependency provider and GitHub Actions workflows fit together.

## CMake dependency provider (consuming packages)

```text
CMakeLists.txt
  find_package(dep)
    -> dependency provider (xproinc.cmake)
      -> xpFindPkg(PKGS dep)
        -> ipGetProPath()
          -> download manifest (GitHub Release)
          -> select correct artifact (platform/compiler)
          -> download .tar.xz into shared cache (XPD_DIR), extract into _xpx/
        -> find_package(dep PATHS <extracted>/share/cmake NO_DEFAULT_PATH)
```

Relevant docs:
- [Dependency provider](../../cmake/docs/dependency-provider.md)
- [Download and extract](../../cmake/docs/download-and-extract.md)
- [Download cache](../../cmake/docs/download-cache.md)

## CI/release flow (producing packages)

```text
PR -> xpBuild
merge + label release:tag -> xpTag -> tag push -> xpBuild (tag)
xpRelease (on successful tag build) -> draft GitHub Release + assets + attestations
```

Relevant docs:
- [Caller workflows](caller-workflows.md)
- [Release flow](release-flow.md)
- [Supply chain](supply-chain.md)
