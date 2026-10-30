# Download cache (`XPD_DIR`)

externpro keeps downloaded release manifests and `.xpro.tar.xz` package archives in a shared, per-user cache instead of inside the build directory. This page describes where the cache lives, how to override it, and how it interacts with containers, offline use, and CI.

This is implemented in [`cmake/xproinc.cmake`](../xproinc.cmake) (which sets `XPD_DIR`) and [`cmake/xpfunmac.cmake`](../xpfunmac.cmake) (`ipDownload*`, `ipDownloadExtract`).

## Location and `XPD_DIR`

`XPD_DIR` is a cached CMake variable. Resolution order:

1. `-DXPD_DIR=<path>` on the cmake command line
2. `ENV{XPD_DIR}` environment variable
3. A `cacheVariables` entry in a project's presets — for externpro-based projects that's `xpPresetsBase.json` at the repo root (copied at adoption, project-owned — externpro never edits it; the externpro platform preset files include it)
4. Platform default, computed in `xproinc.cmake`:
   - Windows: `$ENV{LOCALAPPDATA}/externpro`
   - Unix with `XDG_CACHE_HOME` set: `$ENV{XDG_CACHE_HOME}/externpro`
   - Unix otherwise: `$ENV{HOME}/.cache/externpro`
   - Fallback when no home is determinable: `${CMAKE_BINARY_DIR}/_xpd` (with a `message(WARNING)`)

The env-var level is handy for CI and containerized builds where editing presets or passing `-D` flags is awkward. Note that the *default* can only be computed in cmake code: preset `$env{VAR}` macros expand to an empty string when unset, so the `XDG_CACHE_HOME` -> `HOME` fallback chain isn't expressible in presets.

Extracted package contents are a separate, per-build location: `XPX_DIR`, defined at file scope just above `ipDownloadExtract()` in [`xpfunmac.cmake`](../xpfunmac.cmake) as `${CMAKE_BINARY_DIR}/_xpx`. It is intentionally not a cache var (though `-DXPX_DIR=` still overrides for edge cases).

## Cache layout

```
~/.cache/externpro/
  manifests/<pkg>-<tag>.manifest.json         # platform-agnostic; one per pkg+tag
  pkgs/<repo>-<tag>-<cpfx>-<plat>-xpro.tar.xz # flat; names embed toolchain signature
```

`pkgs/` is flat because archive filenames already embed the full toolchain signature (`<repo>-<tag>-<compiler_prefix>-<platform>[-xpro].tar.xz`) — no collisions, so per-toolchain subdirectories would add complexity for little gain.

Every file in the cache is SHA256-verified on use: a stale, corrupt, or tampered entry is detected and re-downloaded automatically, so `rm -rf ~/.cache/externpro` is always safe (it just costs a re-download).

## Why a user-level cache

The [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/) defines `$XDG_CACHE_HOME` (default `~/.cache`) as the home for non-essential data that can be regenerated — exactly what a download cache is. The closest analog in the C++ ecosystem already follows it: `vcpkg`'s default binary cache is `~/.cache/vcpkg/archives` on all non-Windows and `%LOCALAPPDATA%\vcpkg\archives` on Windows.

Compared to the alternatives:

- **vs. inside the build dir** (the old `_xpro/xpd/`): the cache survives `git clean -xdf`, `rm -rf _bld*`, and new worktrees — previously the only way to keep downloads across a clean was to script a stash in `/tmp` first.
- **vs. a sibling directory**: sharing isn't layout-dependent. `~/.cache/externpro` is shared by every checkout on the machine — sibling repos, git worktrees, one-off clones in `/tmp`, CI workspaces. A sibling dir only shares repos that happen to live under the same parent, and requires the container to mount the source dir's parent.

Anyone who prefers a different location (a shared NFS/team location, a project-local dir) can set `XPD_DIR`.

## Containers

The dev build containers bind-mount the host-side cache at the container-side default path:

```yaml
- ${XDG_CACHE_HOME:-${HOME}/.cache}/externpro:/home/${USER}/.cache/externpro
```

(in the `x-bld` volumes anchor of `compose.bld.yml` / `compose.gpu.yml`). The mount *source* follows `XDG_CACHE_HOME` so it resolves to the same directory `XPD_DIR` computes for host-native builds; the *target* is always `/home/${USER}/.cache/externpro`, matching `XPD_DIR`'s in-container default (`XDG_CACHE_HOME` isn't set inside the container, so CMake falls back to `$ENV{HOME}/.cache/externpro`). Because `local.dockerfile` creates the user home via `useradd --create-home` and the container runs as the host UID/GID, cache files get correct ownership and host and container builds share one cache — no container detection in CMake.

The compose entry-point scripts (`docker-compose.sh`, `compose.bld.sh`, `compose.gpu.sh` — via `funcs.sh`'s `buildreq`) run `mkdir -p` on the cache dir before `docker compose`. This matters because Docker auto-creates missing bind-mount sources as `root:root` — invisible on macOS/Windows-host paths where Desktop's file sharing virtualizes ownership, but a real failure on WSL2: the distro's filesystem enforces ownership, the non-root container user can't write into the auto-created dir, and the leftover needs `sudo` to remove.

### Cache domains are per filesystem environment, not per machine

On Windows + WSL2, native MSVC builds use `%LOCALAPPDATA%\externpro` while containers launched from WSL use the distro's own `~/.cache/externpro` — two domains. That's fine: `pkgs/` archives are toolchain-scoped (`vc*-Windows-*` vs `gcc*-Linux-*` never overlap), and only the small `manifests/` files are fetched once per domain. Bridging via `/mnt/c` or `\\wsl$` would route cache I/O through the slow 9P filesystem. The same reasoning covers remote docker hosts and VMs. To unify anyway, set `XPD_DIR` to a shared path in both environments.

## Offline use

A warm cache is a complete offline story: `ipDownload()` returns early when the destination file exists and its SHA256 matches, so once manifests and archives are cached, configure/build works with no network — no script, no flags.

## Concurrent access

`ipDownload()` writes to a unique temp file (`<dst>.part-<random>`), verifies the SHA256, then `file(RENAME)`s into place — atomic on the same filesystem, so readers never see a partial download. Stale `.part-*` files older than a day are cleaned up on the next download of the same file (fresh ones are left alone — they may belong to a concurrent process).

## Migrating an existing cache

Old per-build caches (`_bld*/_xpro/xpd`) are not imported automatically — missing archives re-download lazily. To seed the new cache manually:

```bash
mkdir -p ~/.cache/externpro
cp -rn _bld-*/_xpro/xpd/* ~/.cache/externpro/ 2>/dev/null
```

## CI caching

`XPD_DIR` is a natural `actions/cache` target — everything is SHA256-verified, so a warm or stale cache is always safe.

For Linux builds running in a `container:` job, the job container's filesystem is discarded at job end: `~/.cache/externpro` inside it persists between steps within a job but not across runs. Options:

- `actions/cache` on `~/.cache/externpro` directly — the action's restore/save runs inside the job container, and `~`/absolute paths are supported; a loose key (OS/arch) is fine since artifact names are content-addressed.
- Point `ENV{XPD_DIR}` at a path under `$GITHUB_WORKSPACE` (mounted into the job container) and cache that — more explicit, easier to inspect.
- Nothing at all — the per-job cache still helps repeated configures within one run; no worse than before.

## Related

- [Download and extract](download-and-extract.md)
- [Dependency provider](dependency-provider.md)
- [`cmake/xproinc.cmake`](../xproinc.cmake)
- [`cmake/xpfunmac.cmake`](../xpfunmac.cmake)
