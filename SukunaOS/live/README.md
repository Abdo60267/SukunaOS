# SukunaOS Live Build

This directory is used by `live-build` to create a bootable ISO for SukunaOS.

## Build steps

1. Install dependencies:

```bash
sudo apt update
sudo apt install live-build squashfs-tools xorriso debootstrap
```

2. Run the ISO build script:

```bash
sudo bash scripts/build_iso.sh
```

3. The resulting ISO will be available at `live/sukunaos.iso`.

4. To create a persistent live USB, run:

```bash
sudo bash scripts/create_persistent_usb.sh live/sukunaos.iso /dev/sdX
```

5. In the live environment, test the installer frontend and backend:

```bash
python3 /opt/sukuna/src/sukuna_installer_gui.py
python3 /opt/sukuna/src/sukuna_installer_backend.py list-disks
```

## Notes

- This is a prototypical live build based on Debian.
- The script copies the repository into `/opt/sukuna` inside the live image.
- Customization should be done by editing `live/config/package-lists/sukuna.list.chroot`.
