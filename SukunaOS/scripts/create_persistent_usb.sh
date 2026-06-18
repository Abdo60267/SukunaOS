#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <path-to-iso> <usb-device>"
  echo "Example: sudo $0 live/sukunaos.iso /dev/sdb"
  exit 1
fi

ISO_PATH="$1"
USB_DEVICE="$2"
MOUNT_DIR="/mnt/sukunaos-usb"
PERSISTENCE_SIZE="4G"

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo."
  exit 1
fi

if [ ! -f "$ISO_PATH" ]; then
  echo "ISO file not found: $ISO_PATH"
  exit 1
fi

read -p "This will erase $USB_DEVICE. Continue? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborting."
  exit 1
fi

umount "${USB_DEVICE}"* 2>/dev/null || true

parted -s "$USB_DEVICE" mklabel msdos
parted -s "$USB_DEVICE" mkpart primary fat32 1MiB 512MiB
parted -s "$USB_DEVICE" mkpart primary ext4 512MiB 100%
parted -s "$USB_DEVICE" set 1 boot on

mkfs.vfat -F 32 "${USB_DEVICE}1"
mkfs.ext4 -F "${USB_DEVICE}2"

mkdir -p "$MOUNT_DIR"
mount "${USB_DEVICE}1" "$MOUNT_DIR"
rsync -a "$ISO_PATH" "$MOUNT_DIR/" 

mkdir -p "$MOUNT_DIR/persistence"
umount "$MOUNT_DIR"

mount "${USB_DEVICE}2" "$MOUNT_DIR"
echo "persistent live" > "$MOUNT_DIR/persistence.conf"
umount "$MOUNT_DIR"

cat <<EOF
Persistent USB created successfully on $USB_DEVICE.
Use this media with a live boot option configured for persistence.
EOF
