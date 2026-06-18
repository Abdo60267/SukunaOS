#!/usr/bin/env bash
set -euo pipefail

# scripts/build_kernel.sh
# Build script for linux-sukuna (local build). Expects sources in /usr/src/linux-sukuna

SRCDIR=${SRCDIR:-/usr/src/linux-sukuna}
OUTDIR=${OUTDIR:-/tmp/kernel-build}
ARCH=${ARCH:-x86_64}
JOBS=${JOBS:-$(nproc)}

echo "SRCDIR=$SRCDIR"
echo "OUTDIR=$OUTDIR"
echo "ARCH=$ARCH"

if [ ! -d "$SRCDIR" ]; then
  echo "Kernel source not found at $SRCDIR"
  exit 1
fi

mkdir -p "$OUTDIR"
cd "$SRCDIR"

# Ensure scripts are executable
if [ -f "scripts/apply_patches.sh" ]; then
  bash scripts/apply_patches.sh
fi

# Use provided defconfig if exists
if [ -f "configs/${ARCH}-defconfig" ]; then
  echo "Using configs/${ARCH}-defconfig"
  make O="$OUTDIR" ARCH=$ARCH defconfig KCONFIG_ALLCONFIG=configs/${ARCH}-defconfig
else
  make O="$OUTDIR" ARCH=$ARCH olddefconfig || make O="$OUTDIR" ARCH=$ARCH defconfig
fi

echo "Building kernel..."
make -j"$JOBS" O="$OUTDIR" ARCH=$ARCH

echo "Installing modules to staging dir..."
make modules_install INSTALL_MOD_PATH="$OUTDIR/modules" O="$OUTDIR" ARCH=$ARCH

echo "Packaging using bindeb-pkg (if available)..."
if make -n bindeb-pkg >/dev/null 2>&1; then
  make -j"$JOBS" bindeb-pkg O="$OUTDIR" ARCH=$ARCH LOCALVERSION=-sukuna
  echo "Deb packages created in parent directory"
else
  echo "bindeb-pkg unavailable; creating tarball"
  mkdir -p build-artifacts
  tar czf build-artifacts/linux-sukuna-${ARCH}-$(date +%s).tar.gz -C "$OUTDIR" .
fi

echo "Build complete. Artifacts in build-artifacts/ or parent dir."
