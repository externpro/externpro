# "diff" types (how externpro changes upstream projects)

Many externpro projects start from an upstream source release and then apply a set of changes to make it build and package consistently under externpro.

This document names the common CMake-focused change patterns ("diffs") used across externpro projects.

These "diff" types describe what happened to the project’s CMake (patched, introduced, replaced, etc.). They do not try to categorize other non-CMake changes a project may carry.

## Why a project may carry patches (not a diff type)

Independently of the CMake diff type, a project may still carry other patches to:

- carry fixes not yet accepted upstream
- address static analysis findings
- backport a fix while staying on an older upstream version
- fix issues exposed by newer/older compilers

## `patch`

- Applies targeted modifications to an existing CMake build.

## `intro`

- Introduces a new CMake build system where none existed (or where it was incomplete).

## `auto`

- Adds a CMake build to replace autotools-style builds (e.g., `configure`/`make`).

## `native`

- Adds a CMake build but still uses the upstream/native build system for the actual build steps.

## `bin`

- Adds CMake packaging logic to repackage binaries built elsewhere.

## `fetch`

- Adds a CMake build and uses CMake `FetchContent` for sources/dependencies.
