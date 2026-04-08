# Downloading and extracting xpro packages (xpFindPkg)

This page describes the "other half" of the dependency-provider story: what happens after externpro decides it can satisfy a `find_package(<dep>)` call.

The core flow is:

- `find_package(<dep>)`
- dependency provider calls `xpFindPkg(PKGS <dep>)`
- `xpFindPkg()` calls `ipGetProPath()` to obtain a `PATHS` entry
- `ipGetProPath()` downloads a release manifest (or uses a local artifact)
- `ipDownloadExtract()` downloads the `.tar.xz` package and extracts it under `XPRO_DIR`
- `find_package(xpuse-<dep> ... PATHS <share/cmake> NO_DEFAULT_PATH)` loads the generated use config from the extracted package

All of this is implemented in [`cmake/xpfunmac.cmake`](../xpfunmac.cmake).

## Working directory layout (`XPRO_DIR`)

`XPRO_DIR` is set (and cached) by [`cmake/xproinc.cmake`](../xproinc.cmake) and defaults to:

- `${CMAKE_BINARY_DIR}/_xpro`

Two important subdirectories are used:

- `xpd/`
  - downloaded files (manifests and package archives)
- `xpx/`
  - extracted package contents

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
  - Downloads the release manifest first.

For the common case (REPO + TAG + manifest hash), `ipGetProPath()`:
1. Calls `ipDownloadManifestFromRepo()` to download the manifest file
2. Calls `ipGetPkgFromManifest()` to select the correct artifact
3. Calls `ipDownloadExtract()` to download and extract the package

## Step 3: ipDownloadManifestFromRepo() downloads the manifest

`ipDownloadManifestFromRepo()` handles both `.manifest.cmake` and `.manifest.json` formats:

- Determines the manifest format based on whether `MANIFEST_SHA256` or `MANIFEST_HASH` is provided
- Downloads to `${XPRO_DIR}/xpd/manifests/<repo>-<tag>.manifest.<ext>`
- Performs integrity checking with the provided SHA256

## Step 4: ipGetPkgFromManifest() selects the right artifact

`ipGetPkgFromManifest()` reads the manifest and selects the appropriate artifact:

- Matches artifacts based on compiler prefix and platform
- First tries `<prefix>-<platform>...tar.xz`, falls back to `<platform>...tar.xz`
- Returns the artifact filename and its SHA256
- Works with both CMake and JSON manifest formats

## Step 5: ipDownloadExtract() downloads and extracts

`ipDownloadExtract(url, sha, outPathVar)`:
- downloads the `.tar.xz` into `${XPRO_DIR}/xpd/pkgs/<filename>.tar.xz`
- extracts into `${XPRO_DIR}/xpx/`
- uses a timestamp file to determine whether to re-extract when a newer archive is downloaded
- determines the CMake entry point path by probing for `${XPRO_DIR}/xpx/<pkgbase>-xpro/share/cmake` or `${XPRO_DIR}/xpx/<pkgbase>/share/cmake`

## Step 6: find_package(xpuse-<dep>) loads the consumer config

The extracted package contains a generated use config named `xpuse-<dep>-config.cmake`.

`xpFindPkg()` calls:
```cmake
find_package(xpuse-<dep> BYPASS_PROVIDER REQUIRED PATHS <pth> NO_DEFAULT_PATH)
```

This is how the package's imported targets/variables become available to the consuming project.

## Related

- [Dependency provider](dependency-provider.md)
- [Extern package](extern-package.md)
- [`cmake/xproinc.cmake`](../xproinc.cmake)
- [`cmake/xpfunmac.cmake`](../xpfunmac.cmake) (`xpFindPkg`, `ipGetProPath`, `ipDownloadExtract`, `ipGetPkgFromManifest`)
