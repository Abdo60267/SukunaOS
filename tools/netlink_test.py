#!/usr/bin/env python3
"""
netlink_test.py - Send a test Netlink exec_check message to userspace

Usage:
  python3 tools/netlink_test.py /path/to/binary

This script crafts a simple Netlink message similar to the kernel POC and
broadcasts it to the kernel netlink socket so the `sukuna-securityd` listener
can receive and process it.

Note: Requires root privileges to send raw netlink messages.
"""

import os
import socket
import struct
import sys

NETLINK_USERSOCK = 2
NLMSG_HDR_FMT = 'IHHII'  # len, type, flags, seq, pid
NLMSG_HDRLEN = struct.calcsize(NLMSG_HDR_FMT)


def build_nlmsg(payload_bytes, seq=1, nl_type=0, flags=0):
    plen = NLMSG_HDRLEN + len(payload_bytes)
    pid = os.getpid()
    hdr = struct.pack(NLMSG_HDR_FMT, plen, nl_type, flags, seq, pid)
    return hdr + payload_bytes


def send_exec_check(path):
    payload = ('{"event":"exec_check","path":"%s"}' % path).encode('utf-8')
    msg = build_nlmsg(payload)
    s = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, NETLINK_USERSOCK)
    try:
        # bind to pid and groups=0
        s.bind((os.getpid(), 0))
        # send to kernel (pid 0)
        s.sendto(msg, (0, 0))
        print('sent exec_check for', path)
    finally:
        s.close()


def main():
    if len(sys.argv) < 2:
        print('Usage: netlink_test.py /path/to/binary')
        sys.exit(1)
    path = sys.argv[1]
    if not os.path.exists(path):
        print('Path not found:', path)
        sys.exit(1)
    send_exec_check(path)


if __name__ == '__main__':
    main()
