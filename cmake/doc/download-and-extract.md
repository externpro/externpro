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

## Working directories (`XPRO_DIR`)

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
- `REPO` + `TAG` + `MANIFEST_SHA256` (the common case)
  - Downloads the release manifest first.

In the common case, it does:

1. Compute a manifest destination path:

- `${XPRO_DIR}/xpd/manifests/<repoName>-<tag>.manifest.cmake`

2. Download the manifest with integrity checking:

- `ipDownload(https://<REPO>/releases/download/<TAG>/<repoName>-<TAG>.manifest.cmake <MANIFEST_SHA256> <dst>)`

3. Select the correct artifact filename + its SHA from the manifest:

- `ipGetPkgFromManifest(<dst> pkg sha)`

4. Build the final artifact URL:

- `https://<REPO>/releases/download/<TAG>/<pkg>`

5. Download+extract:

- `ipDownloadExtract(<url> <sha> pth)`

## Step 3: ipGetPkgFromManifest() selects the right artifact for your platform

A manifest defines `XP_MANIFEST_ARTIFACTS` and per-artifact SHA256 variables.

`ipGetPkgFromManifest()` matches an artifact name based on:

- compiler prefix (from `xpGetCompilerPrefix(pfx VER_ONE)`)
- platform string derived from:
  - `CMAKE_SYSTEM_NAME` and
  - `CMAKE_SYSTEM_PROCESSOR` (arm64 vs amd64)

It first tries to find an artifact matching:

- `<pfx>-<platform>...tar.xz`

and falls back to:

- `<platform>...tar.xz`

It then normalizes the artifact filename into a manifest variable name and reads:

- `XP_ARTIFACT_SHA256__<normalized-filename>`

If no matching artifact exists, or the SHA variable is missing/invalid, it fails with a clear `FATAL_ERROR`.

## Step 4: ipDownloadExtract() downloads and extracts

`ipDownloadExtract(url, sha, outPathVar)`:

- downloads the `.tar.xz` into:
  - `${XPRO_DIR}/xpd/pkgs/<filename>.tar.xz`
- extracts into:
  - `${XPRO_DIR}/xpx/`

It uses a timestamp file (`${XPRO_DIR}/xpx`) to determine whether to re-extract when a newer archive is downloaded.

Then it determines the "CMake entry point" path to return by probing for:

- `${XPRO_DIR}/xpx/<pkgbase>-xpro/share/cmake`
- `${XPRO_DIR}/xpx/<pkgbase>/share/cmake` (fallback)

That returned path is what `xpFindPkg()` passes to `find_package(... PATHS ... NO_DEFAULT_PATH)`.

## Step 5: find_package(xpuse-<dep>) loads the consumer config

The extracted package contains a generated use config named:

- `xpuse-<dep>-config.cmake`

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
