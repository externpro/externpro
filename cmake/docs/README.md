# CMake toolkit docs

This directory contains short, developer-facing notes about the externpro CMake toolkit under [`cmake/`](../).

## Consuming packages

- [Dependency provider](dependency-provider.md)
  - How `xproinc.cmake` routes `find_package()` through externpro.

- [Download and extract](download-and-extract.md)
  - How `xpFindPkg()` resolves an externpro dependency from a release manifest.

## Producing packages

- [Extern package](extern-package.md)
  - How externpro turns a CMake project into an xpro package.

- [Packaging](packaging.md)
  - Shared CPack setup via [`xpcpack.cmake`](../xpcpack.cmake) for multi-generator packaging (msi/rpm/deb/etc).

- [Diff types](diff-types.md)
  - The CMake-focused "diff" taxonomy used in the `diff` column of the generated [cmake/README.md](../README.md) dependency table.

## Repo adoption

- [How-to: adopt externpro](how-to-adopt-externpro.md)
  - Practical steps to wire externpro into a repo.

## Advanced

- [Classified/offline sources](classified-sources.md)
  - How the `xpClassified*` functions let you substitute sources from an alternate repo.
