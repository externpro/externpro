# Debugging Windows CI with tmate

Projects using externpro have access to the `externpro/.github/workflows/build-windows.yml` reusable workflow, which supports interactive `tmate` debugging sessions.

## Enabling tmate

Edit `.github/workflows/xpbuild.yml` and set `enable_tmate: true` under the Windows job `with:` block:

```yaml
  windows:
    uses: externpro/externpro/.github/workflows/build-windows.yml@26.01.5
    secrets: inherit
    with:
      enable_tmate: true
```

When the workflow reaches the Windows job, it will pause and print an SSH command such as:

```text
ssh abc123@nyc1.tmate.io
```

Run that command from your local shell to connect to the runner.

## Transferring files to/from the Windows runner with base64

The easiest way to move a file into or out of the `tmate` shell is to base64-encode it and copy the string through the terminal.

### Encode a file on macOS

```bash
base64 -i <file> | tr -d '\n' && echo
```

Example for `crypto/CMakeLists.txt`:

```bash
base64 -i crypto/CMakeLists.txt | tr -d '\n' && echo
```

Copy the printed base64 string.

### Decode on the Windows/tmate side

In the Windows `tmate` shell (Git for Windows / `bash`), paste the string using a heredoc:

```bash
base64 -d << 'B64' > <file>
PASTE_BASE64_STRING_HERE
B64
```

Example for `crypto/CMakeLists.txt`:

```bash
base64 -d << 'B64' > crypto/CMakeLists.txt
PASTE_BASE64_STRING_HERE
B64
```

- The heredoc delimiter is `B64`.
- Paste the entire one-line base64 string on the line between the two `B64` markers.

### If `base64` is not available

Use Python instead:

```bash
python - << 'PY'
import base64, sys
b64 = sys.stdin.read().split('B64')[0]
open('crypto/CMakeLists.txt','wb').write(base64.b64decode(b64))
PY
PASTE_BASE64_STRING_HERE
B64
```

### Note: macOS vs. Windows `base64` decode flags

- macOS uses `base64 -D` (uppercase) to decode.
- Git for Windows / GNU uses `base64 -d` (lowercase).

Use the correct flag for the system you are decoding on.

## Disabling tmate

Once debugging is complete, revert the `with:` block to an empty object and commit the change:

```yaml
  windows:
    uses: externpro/externpro/.github/workflows/build-windows.yml@26.01.5
    secrets: inherit
    with: {}
```
