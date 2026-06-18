#!/usr/bin/env python3
"""
sukuna_dcl_wrapper.py - POC wrapper to install/run Windows .exe via Wine/Proton

Usage:
  sukuna_dcl_wrapper.py install /path/to/file.exe
  sukuna_dcl_wrapper.py run prefix_id path/to/exe

This POC tries to find `wine` or `proton` and execute the installer in an isolated prefix.
"""

import os
import subprocess
import sys
import uuid

PREFIX_BASE = '/var/lib/sukuna/dcl/prefixes'


def ensure_dirs():
    os.makedirs(PREFIX_BASE, exist_ok=True)


def find_runner():
    for cmd in ['proton', 'wine', 'wine64']:
        path = shutil.which(cmd) if 'shutil' in globals() else None
        if path:
            return cmd
    return None


def create_prefix():
    pid = str(uuid.uuid4())
    p = os.path.join(PREFIX_BASE, pid)
    os.makedirs(p, exist_ok=True)
    return pid, p


def install(path):
    ensure_dirs()
    if not os.path.exists(path):
        print('file not found', path)
        return 2
    pid, p = create_prefix()
    print('creating prefix', pid)
    # For POC: use wine to run installer inside prefix WINEPREFIX
    runner = os.environ.get('SUKUNA_DCL_RUNNER','wine')
    env = os.environ.copy()
    env['WINEPREFIX'] = p
    env['WINEDEBUG'] = '-all'
    try:
        subprocess.check_call([runner, path], env=env)
    except subprocess.CalledProcessError as e:
        print('installer failed', e)
        return 3
    print('installed to prefix', pid)
    # TODO: detect installed exe and create .desktop shortcut
    return 0


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == 'install':
        sys.exit(install(sys.argv[2]))
    else:
        print('unknown command')
        sys.exit(1)


if __name__ == '__main__':
    main()
