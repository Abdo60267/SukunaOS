#!/usr/bin/env python3
"""
sukuna-securityctl - CLI for sukuna-securityd

Usage:
  sukuna-securityctl check /path/to/file
  sukuna-securityctl add /path/to/file [verdict]
  sukuna-securityctl list
  sukuna-securityctl status
"""

import json
import socket
import sys

SOCKET = '/run/sukuna-securityd.sock'


def send(req):
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    try:
        s.connect(SOCKET)
    except Exception as e:
        print('Error connecting to daemon:', e)
        sys.exit(2)
    s.sendall((json.dumps(req) + '\n').encode())
    resp = s.recv(65536).decode()
    print(resp.strip())
    s.close()


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == 'check' and len(sys.argv) >= 3:
        path = sys.argv[2]
        send({'cmd': 'check', 'path': path})
    elif cmd == 'add' and len(sys.argv) >= 3:
        path = sys.argv[2]
        verdict = sys.argv[3] if len(sys.argv) >= 4 else 'safe'
        send({'cmd': 'add', 'path': path, 'verdict': verdict})
    elif cmd == 'list':
        send({'cmd': 'list'})
    elif cmd == 'status':
        send({'cmd': 'status'})
    else:
        print(__doc__)


if __name__ == '__main__':
    main()
