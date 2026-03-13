# Dependency provider (xproinc)

externpro integrates with CMake's dependency provider mechanism so that `find_package(<dep>)` can be satisfied by externpro-managed packages ("xpro" packages) when a corresponding `xp_<dep>` variable is defined.

## How it works

- [`cmake/xproinc.cmake`](../xproinc.cmake) is intended to be injected via `CMAKE_PROJECT_TOP_LEVEL_INCLUDES` so it runs before your top-level `project()` call.
- It sets a few key variables early (notably `CMAKE_INSTALL_PREFIX` and `XPRO_DIR`).
- It adds externpro's `cmake/` directory to `CMAKE_MODULE_PATH`.
- It includes [`cmake/pros.cmake`](../pros.cmake), which defines the default externpro dependency variables (`xp_<project>`).
- It installs a dependency provider via:

```cmake
cmake_language(
  SET_DEPENDENCY_PROVIDER externpro_provide_dependency
  SUPPORTED_METHODS FIND_PACKAGE
  )
```

The provider implementation is `externpro_provide_dependency(method, depName)`.

For `method == FIND_PACKAGE` it:

- Calls `xpFindPkg(PKGS ${depName})`.
- If `${depName}_FOUND` is still false, it falls back to the normal behavior using:

```cmake
find_package(${depName} BYPASS_PROVIDER ...)
```

## Working directory layout (`XPRO_DIR`)

`XPRO_DIR` defaults to `${CMAKE_BINARY_DIR}/_xpro`.

It is used by internals (e.g., `ipGetProPath()` / download+extract) to store:

- downloaded manifests
- downloaded packages
- extracted package contents (for `find_package(xpuse-<pkg>)`)

## Common usage

In a consuming repo, set:

- `CMAKE_PROJECT_TOP_LEVEL_INCLUDES` to point to externpro's [`cmake/xproinc.cmake`](../xproinc.cmake)

Then in your CMakeLists you can keep using normal `find_package()` calls; externpro will intercept them when it can.

## Related

- [`cmake/xproinc.cmake`](../xproinc.cmake)
- `xpFindPkg()` and `ipGetProPath()` in [`cmake/xpfunmac.cmake`](../xpfunmac.cmake)
