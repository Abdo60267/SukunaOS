# SukunaOS - Kernel build notes

This folder contains helper scripts and CI configuration for the `linux-sukuna` kernel.

Quick local build:

1. Ensure kernel sources are placed at `/usr/src/linux-sukuna` (git repo).
2. Install build deps:

```bash
sudo apt update
sudo apt install build-essential libncurses-dev bison flex libssl-dev libelf-dev bc dwarves
```

3. Run build script (example):

```bash
./scripts/build_kernel.sh SRCDIR=/usr/src/linux-sukuna OUTDIR=/tmp/kernel-build ARCH=x86_64
```

4. Package with bindeb-pkg (if available):

```bash
./ci/debian-package.sh /tmp/kernel-build x86_64
```

CI:
- See `.github/workflows/build.yml` for GitHub Actions workflow that builds and uploads artifacts for `x86_64` and `arm64`.
