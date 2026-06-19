#!/usr/bin/env python3
"""SukunaOS Installer Backend - Ubuntu 24.04 LTS Edition

This module provides installer backend for the live image.
It bootstraps Ubuntu base system, creates user, and installs GRUB.

Supports:
  - UEFI + BIOS (hybrid)
  - Disk partitioning
  - User creation
  - GRUB bootloader installation
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

MIRROR = os.environ.get('SUKUNA_BOOTSTRAP_MIRROR', 'http://archive.ubuntu.com/ubuntu')
SUITE = os.environ.get('SUKUNA_BOOTSTRAP_SUITE', 'noble')  # Ubuntu 24.04 LTS


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
    print(f"🔴 Formatando partição {partition} como ext4...")
    run(['mkfs.ext4', '-F', partition])
    print("✅ Formatação concluída.")


def mount_root(target_partition, mount_base='/mnt/sukuna'):  # pragma: no cover
    target = Path(mount_base).resolve()
    target.mkdir(parents=True, exist_ok=True)
    print(f"🔴 Montando {target_partition} em {target}...")
    run(['mount', target_partition, str(target)])
    return target


def unmount_root(mount_path):
    print(f"🔴 Desmontando {mount_path}...")
    run(['umount', str(mount_path)])


def bootstrap_system(root_path):
    print(f"🔴 Bootstrapping do sistema Ubuntu para {root_path}...")
    run([
        'debootstrap',
        '--include=ubuntu-standard,ubuntu-minimal,python3,python3-pip,python3-pyside6,live-boot,systemd-sysv,network-manager,network-manager-gnome,gnome-shell,gnome-flashback,xorg,grub-pc,grub-efi-amd64,sudo,fonts-ubuntu,fonts-inter,zsh',
        SUITE,
        str(root_path),
        MIRROR,
    ])
    print("✅ Debootstrap concluído.")


def configure_target(root_path, username, password, hostname='sukunaos'):
    print('🔴 Configurando sistema alvo...')
    etc = root_path / 'etc'
    (etc / 'hostname').write_text(hostname + '\n')
    (etc / 'hosts').write_text('127.0.0.1 localhost\n127.0.1.1 ' + hostname + '\n')

    env = os.environ.copy()
    env['HOME'] = '/root'
    env['DEBIAN_FRONTEND'] = 'noninteractive'

    print('🔴 Criando conta de usuário...')
    run(['chroot', str(root_path), 'useradd', '-m', '-s', '/bin/bash', '-G', 'sudo', username])
    run(['chroot', str(root_path), 'bash', '-lc', f"echo '{username}:{password}' | chpasswd"], check=True)
    print(f"✅ Usuário {username} criado.")


def install_bootloader(root_path, target_device):
    print(f'🔴 Instalando GRUB em {target_device}...')
    run(['chroot', str(root_path), 'grub-install', '--target=x86_64-efi', '--efi-directory=/boot/efi', '--bootloader-id=SukunaOS', target_device], check=False)
    run(['chroot', str(root_path), 'grub-install', '--target=i386-pc', target_device], check=False)
    run(['chroot', str(root_path), 'update-grub'])
    print("✅ GRUB instalado.")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='SukunaOS Installer Backend (Ubuntu)')
    subparsers = parser.add_subparsers(dest='command')
    
    list_cmd = subparsers.add_parser('list', help='List disks')
    
    prep_cmd = subparsers.add_parser('prepare', help='Format partition')
    prep_cmd.add_argument('partition', help='Device path (e.g., /dev/sda1)')
    
    boot_cmd = subparsers.add_parser('bootstrap', help='Bootstrap system')
    boot_cmd.add_argument('--root', default='/mnt/sukuna', help='Root path')
    boot_cmd.add_argument('--user', required=True, help='Username')
    boot_cmd.add_argument('--password', required=True, help='Password')
    boot_cmd.add_argument('--hostname', default='sukunaos', help='Hostname')
    boot_cmd.add_argument('--device', required=True, help='Target device for GRUB')
    
    args = parser.parse_args()
    
    if args.command == 'list':
        list_disks()
    elif args.command == 'prepare':
        prepare_partition(args.partition)
    elif args.command == 'bootstrap':
        root = Path(args.root)
        root.mkdir(parents=True, exist_ok=True)
        bootstrap_system(root)
        configure_target(root, args.user, args.password, args.hostname)
        install_bootloader(root, args.device)
        print("\n✅ 🔴 SISTEMA PRONTO! 🔴 ✅")
    else:
        parser.print_help()
    run(['chroot', str(root_path), 'bash', '-lc', "echo 'root:sukuna' | chpasswd"], check=True)
    run(['chroot', str(root_path), 'bash', '-lc', "echo 'deb http://deb.debian.org/debian bookworm main contrib non-free' > /etc/apt/sources.list"])
    run(['chroot', str(root_path), 'apt-get', 'update'])

    opt_sukuna = root_path / 'opt' / 'sukuna'
    if opt_sukuna.exists():
        print('Preserving Sukuna assets inside target image...')
    else:
        print('Warning: /opt/sukuna was not found inside target system.')


def partition_to_disk(partition):
    """Derive disk device from partition path, e.g. /dev/sda1 -> /dev/sda."""
    base = os.path.basename(partition)
    disk = re.sub(r'p?\d+$', '', base)
    return os.path.join('/dev', disk)


def install_grub(root_path, partition):
    device = partition_to_disk(partition)
    print(f"Installing GRUB to {device} (from partition {partition})...")

    # Ensure EFI directory exists inside target
    efi_dir = root_path / 'boot' / 'efi'
    efi_dir.mkdir(parents=True, exist_ok=True)

    run(['mount', '--bind', '/dev', str(root_path / 'dev')])
    run(['mount', '--bind', '/proc', str(root_path / 'proc')])
    run(['mount', '--bind', '/sys', str(root_path / 'sys')])
    try:
        # Try EFI install first, fall back to BIOS/legacy
        efi_ret = subprocess.run(
            ['chroot', str(root_path), 'grub-install',
             '--target=x86_64-efi', '--efi-directory=/boot/efi',
             '--bootloader-id=SukunaOS', '--no-nvram', device],
            check=False
        )
        if efi_ret.returncode != 0:
            print('EFI install failed, trying BIOS/legacy...')
            run(['chroot', str(root_path), 'grub-install', '--target=i386-pc', device])
        run(['chroot', str(root_path), 'update-grub'])
    finally:
        run(['umount', str(root_path / 'sys')], check=False)
        run(['umount', str(root_path / 'proc')], check=False)
        run(['umount', str(root_path / 'dev')], check=False)


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
        prepare_partition(args.partition)
        target_mount = mount_root(args.partition)
        try:
            bootstrap_system(target_mount)
            configure_target(target_mount, args.username, args.password, args.hostname)
            install_grub(target_mount, args.partition)
        finally:
            unmount_root(target_mount)
        print('Installation process completed. Reboot and remove the live media.')

if __name__ == '__main__':
    main()
