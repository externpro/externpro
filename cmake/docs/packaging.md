# Packaging (xpcpack)

externpro provides a shared CPack configuration via [`cmake/xpcpack.cmake`](../xpcpack.cmake).

It is designed to standardize packaging across projects while still allowing each project to supply its own `install()` rules and a small set of configuration variables.

## Entry points

- [`cmake/xpcpack.cmake`](../xpcpack.cmake)
  - the shared CPack configuration
- [`cmake/cpack/README.md`](../cpack/README.md)
  - detailed usage notes and troubleshooting (especially Windows MSI)

## What xpcpack.cmake configures

- Sets defaults such as:
  - `CPACK_PACKAGE_NAME` (defaults to `CMAKE_PROJECT_NAME`)
  - `CPACK_PACKAGE_VENDOR` (from `PACKAGE_VENDOR`)
  - `CPACK_PACKAGE_DESCRIPTION_SUMMARY`
  - `CPACK_THREADS=0` (use all cores)
- Enables component install (`CPACK_ARCHIVE_COMPONENT_INSTALL ON`).

### Generators by platform

- **Windows**
  - Always uses `ZIP`.
  - Adds `WIX` when building `client` and/or `server` components.
  - WiX configuration is delegated to [`cmake/xpmswwix.cmake`](../xpmswwix.cmake) and a template [`cmake/main.wxs.in`](../main.wxs.in).
- **Linux**
  - Always uses `TXZ`.
  - Adds `RPM` when building `client` and/or `server` components.

## Required inputs (typical)

- `CPACK_COMPONENTS_ALL`
  - component list (e.g. `server tool`)
- On Windows with WiX:
  - `CPACK_WIX_UPGRADE_GUID`

## Optional knobs (common)

- `XP_INSTALLDIR`
  - changes default install directory name.
- `XP_WIX_SHORTCUTS`
  - pairs of `executable "label"` used for Desktop/Start Menu shortcuts.
- RPM-related:
  - `XP_RPM_OWNER`, `XP_RPM_UMASK`, `XP_RPM_UNIT_FILE`, `XP_RPM_STOP_EXECUTABLE`

## Required project behavior

Your project should:

- install files using `install(... COMPONENT <name>)`
- include xpcpack after your install rules and after the project version is known:

```cmake
include(xpcpack)
```

## Related

- [`cmake/xpcpack.cmake`](../xpcpack.cmake)
- [`cmake/cpack/README.md`](../cpack/README.md)
- [`cmake/xpmswwix.cmake`](../xpmswwix.cmake)
