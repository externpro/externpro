# Build customization

This page documents the default build matrices (where applicable) used by the build workflows, along with the most common knobs you can change in the caller workflow (`xpbuild.yml`).

## Where this is configured

- Caller workflow template: `.github/wf-templates/xpbuild.yml`
- Reusable workflows:
  - `.github/workflows/build-linux.yml`
  - `.github/workflows/build-macos.yml`
  - `.github/workflows/build-windows.yml`

## Triggers (default `xpbuild.yml` template)

- **Pull requests** targeting `xpro`
- **Tag pushes** matching `xpv*`
- Manual `workflow_dispatch`

## Linux build matrix

Linux builds run inside buildpro-based Docker containers and use a matrix of:

- **Architectures** (`arch_list`)
  - default: `{"amd64","arm64"}`
- **Toolchain/container images** (`buildpro_images`)
  - default: `{"rocky8-gcc9","rocky9-gcc13","rocky10-gcc15"}`

### Customizing Linux

In your repo’s `xpbuild.yml`, override inputs to the `build-linux.yml` job.

Examples:

- Build only on `amd64`:

```yaml
with:
  arch_list: '["amd64"]'
```

- Build only with one toolchain:

```yaml
with:
  buildpro_images: '["rocky9-gcc13"]'
```

- Enable `tmate` on failure for CI debugging:

```yaml
with:
  enable_tmate: true
```

## macOS

macOS builds run on GitHub-hosted runners and use the `cmake-build` action with preset `Darwin`.

### Customizing macOS

The common knob is selecting a different workflow preset suffix via the shared input:

- `cmake_workflow_preset_suffix`

## Windows build matrix

Windows builds run on GitHub-hosted runners and use a matrix of Visual Studio toolchains:

- **Toolchains** (`vs_compilers`)
  - default: `{"Vs2022","Vs2026"}`

### Customizing Windows

In your repo’s `xpbuild.yml`, override `vs_compilers`:

```yaml
with:
  vs_compilers: '["Vs2022"]'
```

## Artifact naming

All build workflows accept:

- `artifact_pattern`

Default:

- `${{ github.event.repository.name }}-*-xpro.tar.xz`

Use this if your project produces a different package naming convention and/or a different artifact format (for example: `.zip`, `.tar.gz`, `.exe`, `.msi`, `.deb`, `.rpm`).
