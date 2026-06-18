#!/usr/bin/env bash
set -euo pipefail

# ci/debian-package.sh
# Package a built kernel tree into deb packages using kernel's bindeb-pkg target

OUTDIR=${1:-/tmp/kernel-build}
ARCH=${2:-x86_64}

if [ ! -d "$OUTDIR" ]; then
  echo "Outdir $OUTDIR not found"
  exit 1
fi

cd "$OUTDIR"

# If a Debian packaging target exists in the build tree, attempt to run it
if make -n bindeb-pkg >/dev/null 2>&1; then
  echo "Packaging .deb via bindeb-pkg"
  make -j$(nproc) bindeb-pkg
  mkdir -p build-artifacts
  mv ../linux-*-sukuna_*_*.deb build-artifacts/ 2>/dev/null || true
  echo "Deb packages moved to build-artifacts/"
else
  echo "bindeb-pkg not supported here; creating tarball"
  mkdir -p build-artifacts
  tar czf build-artifacts/linux-sukuna-${ARCH}-$(date +%s).tar.gz .
fi
