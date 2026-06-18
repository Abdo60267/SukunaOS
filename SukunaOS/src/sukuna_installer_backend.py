#!/usr/bin/env python3
"""SukunaOS installer backend prototype.

This module provides a minimal installer backend for the live image.
It is a proof-of-concept implementation to mount a target partition,
bootstrap a Debian base system, create an initial user, and install GRUB.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

MIRROR = os.environ.get('SUKUNA_DEBOOTSTRAP_MIRROR', 'http://deb.debian.org/debian')
SUITE = os.environ.get('SUKUNA_DEBOOTSTRAP_SUITE', 'bookworm')


def run(cmd, check=True, capture=False):
    if capture:
        result = subprocess.run(cmd, check=check, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        return result.stdout.strip()
    subprocess.run(cmd, check=check)


def list_disks():
    output = run(['lsblk', '-J', '-o', 'NAME,SIZE,TYPE,MOUNTPOINT,MODEL,ROTA'], capture=True)
    data = json.loads(output)
    print(json.dumps(data, indent=2))


def prepare_partition(partition):
    if not Path(partition).exists():
        raise FileNotFoundError(f"Partition path not found: {partition}")
    print(f"Formatting partition {partition} as ext4...")
    run(['mkfs.ext4', '-F', partition])
    print("Format completed.")


def mount_root(target_partition, mount_base='/mnt/sukuna'):  # pragma: no cover
    target = Path(mount_base).resolve()
    target.mkdir(parents=True, exist_ok=True)
    print(f"Mounting {target_partition} to {target}...")
    run(['mount', target_partition, str(target)])
    return target


def unmount_root(mount_path):
    print(f"Unmounting {mount_path}...")
    run(['umount', str(mount_path)])


def bootstrap_system(root_path):
    print(f"Bootstrapping base system into {root_path}...")
    run([
        'debootstrap',
        '--include=python3,python3-pip,python3-pyside6,live-boot,systemd-sysv,network-manager,network-manager-gnome,xfce4,xorg,grub-pc,grub-efi-amd64,sudo',
        SUITE,
        str(root_path),
        MIRROR,
    ])
    print("debootstrap finished.")


def configure_target(root_path, username, password, hostname='sukunaos'):
    print('Configuring target system...')
    etc = root_path / 'etc'
    (etc / 'hostname').write_text(hostname + '\n')
    (etc / 'hosts').write_text('127.0.0.1 localhost\n127.0.1.1 ' + hostname + '\n')

    env = os.environ.copy()
    env['HOME'] = '/root'
    env['DEBIAN_FRONTEND'] = 'noninteractive'

    print('Creating user account...')
    run(['chroot', str(root_path), 'useradd', '-m', '-s', '/bin/bash', '-G', 'sudo', username])
    run(['chroot', str(root_path), 'bash', '-lc', f"echo '{username}:{password}' | chpasswd"], check=True)
    run(['chroot', str(root_path), 'bash', '-lc', "echo 'root:sukuna' | chpasswd"], check=True)
    run(['chroot', str(root_path), 'bash', '-lc', "echo 'deb http://deb.debian.org/debian bookworm main contrib non-free' > /etc/apt/sources.list"])
    run(['chroot', str(root_path), 'apt-get', 'update'])

    opt_sukuna = root_path / 'opt' / 'sukuna'
    if opt_sukuna.exists():
        print('Preserving Sukuna assets inside target image...')
    else:
        print('Warning: /opt/sukuna was not found inside target system.')


def install_grub(root_path, device):
    print(f"Installing GRUB to {device}...")
    run(['mount', '--bind', '/dev', str(root_path / 'dev')])
    run(['mount', '--bind', '/proc', str(root_path / 'proc')])
    run(['mount', '--bind', '/sys', str(root_path / 'sys')])
    try:
        run(['chroot', str(root_path), 'grub-install', '--target=x86_64-efi', '--efi-directory=/boot/efi', '--bootloader-id=SukunaOS', device])
        run(['chroot', str(root_path), 'update-grub'])
    finally:
        run(['umount', str(root_path / 'sys')])
        run(['umount', str(root_path / 'proc')])
        run(['umount', str(root_path / 'dev')])


def main():
    parser = argparse.ArgumentParser(description='SukunaOS installer backend POC')
    subparsers = parser.add_subparsers(dest='command', required=True)

    parser_list = subparsers.add_parser('list-disks', help='List available disks and partitions')

    parser_prepare = subparsers.add_parser('prepare-partition', help='Format a partition for SukunaOS')
    parser_prepare.add_argument('--partition', required=True, help='Partition device path, e.g. /dev/sda1')

    parser_install = subparsers.add_parser('install', help='Install SukunaOS onto a prepared partition')
    parser_install.add_argument('--partition', required=True, help='Target root partition, e.g. /dev/sda1')
    parser_install.add_argument('--username', required=True, help='Initial username')
    parser_install.add_argument('--password', required=True, help='Initial user password')
    parser_install.add_argument('--hostname', default='sukunaos', help='Hostname for the installed system')

    args = parser.parse_args()

    if args.command == 'list-disks':
        list_disks()
    elif args.command == 'prepare-partition':
        prepare_partition(args.partition)
    elif args.command == 'install':
        target_mount = mount_root(args.partition)
        try:
            bootstrap_system(target_mount)
            configure_target(target_mount, args.username, args.password, args.hostname)
        finally:
            unmount_root(target_mount)
        print('Installation process completed. Reboot and remove the live media.')

if __name__ == '__main__':
    main()
