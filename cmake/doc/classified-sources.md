# Classified/offline sources (xpClassified*)

The `xpClassified*` functions provide a way to build with an alternate, *classified/offline* source tree when it is available, while still allowing the same project to build in an unclassified/public environment.

This is implemented in [`cmake/xpfunmac.cmake`](../xpfunmac.cmake).

## Concepts

- **Unclassified source tree**
  - The normal checkout you are building.
- **Classified repository**
  - A separate repo mirror (local path or URL) that contains additional or replacement sources.
- **Working tree**
  - A local checkout path where externpro will checkout a specific commit/hash of the classified repo.

## xpClassifiedRepo()

Signature (named args):

- `REPO`
- `HASH`
- `WORKING_TREE`
- one of:
  - `PATH_URL` (checked via `curl`), or
  - `PATH_MSW` (Windows local filesystem), or
  - `PATH_UNIX` (non-Windows local filesystem)
- optional:
  - `VERBOSE`

Behavior:

- Determines if the classified repo is accessible.
- If accessible:
  - checks out the requested `HASH` into `WORKING_TREE`.
  - sets `XP_CLAS_REPO` in the parent scope.
- If not accessible:
  - build proceeds unclassified.

## xpClassifiedSrc()

`xpClassifiedSrc(<outVar> <srcList>)` selects between classified and unclassified source files on a per-file basis.

For each entry in `srcList`:

- If `XP_CLAS_REPO` is set and the corresponding file exists under the classified working tree, that classified path is appended.
- Otherwise, the original entry is appended.

It also populates `unclassifiedSrcList` (parent scope) with the unclassified counterparts for any file that was taken from the classified tree.

This is typically used to populate a source list for `add_library()` / `add_executable()` while remaining compatible with both environments.

## xpClassifiedSrcExc()

`xpClassifiedSrcExc(<outVar> <srcList>)` is *exclusive*:

- files are only appended if they exist in the classified repo
- missing files are reported (STATUS)

It also adds an include directory for the classified repo’s corresponding relative folder when present.

This is useful for sources that must never exist in the unclassified tree.

## Notes

- The functions emit `message(STATUS ...)` traces showing whether each file came from classified/unclassified.
- The intent is for the same build scripts to be usable in both contexts without a separate branch.

## Related

- [`cmake/xpfunmac.cmake`](../xpfunmac.cmake) (`xpGitCheckout`, `xpClassifiedRepo`, `xpClassifiedSrc`, `xpClassifiedSrcExc`)
