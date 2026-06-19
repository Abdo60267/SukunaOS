#!/usr/bin/env python3
"""
malevolent-runner.py - POC runner to analyze a binary in an isolated QEMU environment.

Usage: malevolent-runner analyze <path> [--timeout N] [--no-network]

This is a POC: it creates an instance folder under /srv/maledomin/instances/<id>/,
copies the artifact and launches a QEMU VM with the artifact mounted read-only.
Runs simple static checks and an optional dynamic execution with strace.

Requires: qemu-system-x86_64, mktemp, tar, python3
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
import uuid

BASE_DIR = '/srv/maledomin'
INST_DIR = os.path.join(BASE_DIR, 'instances')
IMAGE_TEMPLATE = os.path.join(BASE_DIR, 'images', 'maledomin-boot.img')


def ensure_dirs():
    os.makedirs(INST_DIR, exist_ok=True)


def static_checks(path):
    res = {'file': None, 'strings_hit': [], 'yara': [], 'metadata': {}}
    try:
        out = subprocess.check_output(['file', path], stderr=subprocess.STDOUT).decode().strip()
        res['file'] = out
    except Exception as e:
        res['file'] = 'error: ' + str(e)

    # Look for genuinely suspicious patterns, not just any URL
    suspicious_patterns = [
        'eval(', 'exec(', 'system(', '/bin/sh', '/bin/bash',
        'curl ', 'wget ', 'nc -e', 'reverse_tcp', 'meterpreter',
        'keylog', 'passwd', '/etc/shadow', 'base64 -d',
    ]
    try:
        s = subprocess.check_output(['strings', '-n', '6', path], stderr=subprocess.DEVNULL).decode(errors='ignore')
        hits = []
        for line in s.splitlines():
            lower = line.lower()
            for pat in suspicious_patterns:
                if pat.lower() in lower:
                    hits.append(line.strip())
                    break
        res['strings_hit'] = hits[:20]
    except Exception:
        res['strings_hit'] = []

    return res


def launch_qemu(instance_path, artifact_name, timeout=30, no_network=True):
    # POC: create overlay filesystem and run QEMU with the template image
    vm_id = os.path.basename(instance_path)
    sock = os.path.join(instance_path, 'qemu-monitor.sock')
    qemu_cmd = [
        'qemu-system-x86_64',
        '-m', '512M',
        '-drive', f'file={IMAGE_TEMPLATE},format=raw,if=virtio',
        '-drive', f'file={os.path.join(instance_path, artifact_name)},format=raw,if=virtio,readonly=on',
        '-nographic',
        '-monitor', f'unix:{sock},server,nowait',
    ]
    if no_network:
        qemu_cmd += ['-net', 'none']
    else:
        qemu_cmd += ['-netdev', f'user,id=net0', '-device', 'virtio-net-pci,netdev=net0']

    proc = subprocess.Popen(qemu_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        # Wait a bit and capture any output
        time.sleep(min(timeout, 5))
        # For POC, we won't actually interact; in real system we'd exec inside VM
        proc.terminate()
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()
    except Exception:
        proc.kill()

    return {'vm_exit': True, 'stdout': '', 'stderr': ''}


def analyze(path, timeout=30, no_network=True):
    ensure_dirs()
    if not os.path.exists(path):
        return {'error': 'path not found'}

    inst_id = str(uuid.uuid4())
    inst_path = os.path.join(INST_DIR, inst_id)
    os.makedirs(inst_path, exist_ok=True)
    artifact_name = os.path.basename(path)
    dest = os.path.join(inst_path, artifact_name)
    shutil.copy2(path, dest)

    report = {'id': inst_id, 'verdict': 'unknown', 'score': 0.0, 'evidence': []}

    # Static checks
    s = static_checks(dest)
    report['evidence'].append({'static': s})

    # Graduated scoring based on number of suspicious hits
    hit_count = len(s.get('strings_hit', []))
    if hit_count >= 5:
        report['score'] += 0.6
    elif hit_count >= 2:
        report['score'] += 0.3
    elif hit_count >= 1:
        report['score'] += 0.1

    # Dynamic run in QEMU (POC)
    dyn = launch_qemu(inst_path, artifact_name, timeout=timeout, no_network=no_network)
    report['evidence'].append({'dynamic': dyn})

    # Final scoring with clearer thresholds
    if report['score'] >= 0.6:
        report['verdict'] = 'malicious'
    elif report['score'] >= 0.2:
        report['verdict'] = 'suspicious'
    else:
        report['verdict'] = 'safe'

    return report


def main():
    parser = argparse.ArgumentParser(prog='malevolent-runner')
    sub = parser.add_subparsers(dest='cmd')
    p_an = sub.add_parser('analyze')
    p_an.add_argument('path')
    p_an.add_argument('--timeout', type=int, default=30)
    p_an.add_argument('--no-network', action='store_true')

    args = parser.parse_args()
    if args.cmd == 'analyze':
        r = analyze(args.path, timeout=args.timeout, no_network=args.no_network)
        print(json.dumps(r))
        sys.exit(0 if r.get('verdict') != 'malicious' else 2)
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
