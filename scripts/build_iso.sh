#!/usr/bin/env bash
set -euo pipefail

# scripts/build_iso.sh
# Build a bootable SukunaOS ISO using Debian live-build.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIVE_DIR="$ROOT/live"
CONFIG_DIR="$LIVE_DIR/config"
INCLUDE_DIR="$CONFIG_DIR/includes.chroot"
PACKAGE_LIST="$CONFIG_DIR/package-lists/sukuna.list.chroot"
ISO_OUTPUT="$LIVE_DIR/sukunaos.iso"

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo."
  exit 1
fi

command -v lb >/dev/null 2>&1 || {
  echo "live-build is required. Install with: sudo apt install live-build"
  exit 1
}

mkdir -p "$INCLUDE_DIR/opt/sukuna"
mkdir -p "$CONFIG_DIR/package-lists"

cat > "$PACKAGE_LIST" <<'EOF'
live-boot
live-config
systemd-sysv
grub-pc
grub-efi-amd64
linux-image-amd64
xorg
xinit
openbox
python3
python3-pip
python3-venv
git
curl
wget
sudo
xfce4
network-manager
network-manager-gnome
bash-completion
EOF

cd "$LIVE_DIR"

if [ ! -d "$CONFIG_DIR/auto" ]; then
  lb config --distribution bookworm --architectures amd64 \
    --archive-areas "main contrib non-free" \
    --binary-images iso-hybrid \
    --bootappend-live "boot=live components hostname=sukunaos locales=en_US.UTF-8" \
    --debian-installer false
fi

rm -rf "$INCLUDE_DIR/opt/sukuna"/*
rsync -a --delete --exclude '/live' --exclude '/.git' --exclude '/.cache' "$ROOT/" "$INCLUDE_DIR/opt/sukuna/"

echo "Building SukunaOS ISO..."
lb build

if [ -f "sukunaos-amd64.hybrid.iso" ]; then
  mv sukunaos-amd64.hybrid.iso "$ISO_OUTPUT"
  echo "ISO created at: $ISO_OUTPUT"
else
  echo "ISO build failed: output file not found"
  exit 1
fi
