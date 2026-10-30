# Downloading and extracting xpro packages (xpFindPkg)

This page describes the "other half" of the dependency-provider story: what happens after externpro decides it can satisfy a `find_package(<dep>)` call.

This includes downloading and extracting packages, with support for both Common Package Specification (CPS) files and traditional CMake script configurations.

The core flow is:

- `find_package(<dep>)`
- dependency provider calls `xpFindPkg(PKGS <dep>)`
- `xpFindPkg()` calls `ipGetProPath()` to obtain a `PATHS` entry
- `ipGetProPath()` downloads a release manifest (or uses a local artifact)
- `ipDownloadExtract()` downloads the `.tar.xz` package into the shared download cache (`XPD_DIR`) and extracts it into the build directory (`XPX_DIR`)
- `find_package(<dep> ... PATHS <search_paths> NO_DEFAULT_PATH)` loads either CPS files or the generated cmake script config from the extracted package

All of this is implemented in [`cmake/xpfunmac.cmake`](../xpfunmac.cmake).

## Working directories (`XPD_DIR` and `XPX_DIR`)

Two locations are used:

- `XPD_DIR`
  - the shared, per-user download cache: downloaded manifests and package archives
  - set (and cached) by [`cmake/xproinc.cmake`](../xproinc.cmake); defaults to `~/.cache/externpro` (`%LOCALAPPDATA%\externpro` on Windows)
  - see [Download cache](download-cache.md)
- `XPX_DIR`
  - extracted package contents
  - defined in [`xpfunmac.cmake`](../xpfunmac.cmake) as `${CMAKE_BINARY_DIR}/_xpx` (per-build)

## Step 1: xpFindPkg() decides whether externpro can handle the package

`xpFindPkg(PKGS ...)` only attempts to resolve a dependency if an `xp_<dep>` variable exists.

- If `xp_<dep>` is not defined, externpro does nothing and normal CMake behavior continues.
- If it is defined, `xpFindPkg()` calls:

```cmake
ipGetProPath(pth PKG <dep> ${xp_<dep>})
```

## Step 2: ipGetProPath() chooses a source for the package

`ipGetProPath()` supports a few ways to provide the package:

- `DIST_DIR`
  - Use a local directory of build artifacts.
  - This is most useful for local development/testing: you can build a dependency on your machine and point externpro at the resulting install/package layout to bypass package creation, publishing, downloading, and extracting.
  - Expects `<DIST_DIR>/share/cmake`.
- `XPRO_PATH`
  - Use a local `.tar.xz` archive file (typically a locally built package artifact).
  - This is most useful for local development/testing: you can build/package a dependency and validate the consumer flow without publishing a release.
  - It computes the archive SHA and treats it like a download URL (`file://...`).
- `REPO` + `TAG` + manifest hash (the common case)
  1. Calls `ipDownloadManifestFromRepo()` to download the manifest file — Step 3 below
  2. Calls `ipGetPkgFromManifest()` to select the correct artifact — Step 4
  3. Calls `ipDownloadExtract()` to download and extract the package — Step 5

## Step 3: ipDownloadManifestFromRepo() downloads the manifest

`ipDownloadManifestFromRepo()` handles both `.manifest.cmake` and `.manifest.json` formats:

- `.manifest.cmake` is deprecated — still read so that packages released before the JSON format continue to work, but current `xpExternPackage()` generates only `.manifest.json`
- Determines the manifest format based on whether `MANIFEST_SHA256` or `MANIFEST_HASH` is provided
- Downloads to `${XPD_DIR}/manifests/<repo>-<tag>.manifest.<ext>`
- Performs integrity checking with the provided SHA256

## Step 4: ipGetPkgFromManifest() selects the right artifact

`ipGetPkgFromManifest()` reads the manifest and selects the appropriate artifact:

- Matches artifacts based on compiler prefix and platform
- First tries `<prefix>-<platform>...tar.xz`, falls back to `<platform>...tar.xz`
- Returns the artifact filename and its SHA256
- Works with both CMake and JSON manifest formats

## Step 5: ipDownloadExtract() downloads and extracts

`ipDownloadExtract(url, sha, outPathVar)`:
- downloads the `.tar.xz` into `${XPD_DIR}/pkgs/<filename>.tar.xz`
- extracts into `${XPX_DIR}/`
- re-extracts only when a newer archive has been downloaded
- determines the CMake entry point path by probing for `${XPX_DIR}/<pkgbase>-xpro/share/cmake` or `${XPX_DIR}/<pkgbase>/share/cmake`

## Step 6: find_package(<dep>) loads the package config

The extracted package contains a generated use config named `<dep>-config.cmake` (cmake script). Many packages also include CPS files.

`xpFindPkg()` calls:
```cmake
find_package(<dep> [NAMES xpuse-<dep>] REQUIRED CONFIG GLOBAL
  BYPASS_PROVIDER PATHS <search_paths> NO_DEFAULT_PATH)
```

The optional `NAMES xpuse-<dep>` is emitted only when the extracted package still contains a legacy `xpuse-<dep>-config.cmake` — packages released before the `xpuse-` prefix was dropped. The prefix was dropped when CPS support was added: the generated cmake-script config needed to be found as `<dep>` alongside `<dep>`'s CPS files, so current packages are found directly as `<dep>`.

Where `<search_paths>` depends on the mode:
- **CPS mode**: `${pth} ${pth}/share/cmake` (searches both CPS and cmake script files)
- **CMake script mode**: `${pth}/share/cmake` (searches only cmake script files)

The mode is determined by:
1. Global `FIND_PACKAGE_CMAKE_SCRIPT` option
2. Per-package `findxpro.cmake` marker file
3. `.cps` files containing `"type" : "executable"` components (CMake < 4.5 cannot import them, so the package falls back to cmake script)
4. Default CPS behavior

This is how the package's imported targets/variables become available to the consuming project.

Packages that repackage binaries built elsewhere (declared via `xpPrebuiltComponent`) provide the same imported targets through either mode: the cmake script defines them directly, and the `.cps` file describes them as CPS components.

## Related

- [Download cache](download-cache.md)
- [Dependency provider](dependency-provider.md)
- [Extern package](extern-package.md)
- [`cmake/xproinc.cmake`](../xproinc.cmake)
- [`cmake/xpfunmac.cmake`](../xpfunmac.cmake) (`xpFindPkg`, `ipGetProPath`, `ipDownloadExtract`, `ipGetPkgFromManifest`)
