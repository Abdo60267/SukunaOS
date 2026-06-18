#!/usr/bin/env python3
"""
sukuna_securityd.py - simple userspace security daemon for King of Curses POC

API (JSON lines over UNIX socket /run/sukuna-securityd.sock):
 - {"cmd":"check","path":"/path/to/file"}
 - {"cmd":"add","path":"/path/to/file","verdict":"safe"}
 - {"cmd":"list"}
 - {"cmd":"status"}

Behavior:
 - checks SQLite cache (/var/lib/sukuna/security.db)
 - on cache miss, calls /opt/sukuna/malevolent-runner.py analyze
 - stores verdict and returns JSON
"""

import json
import os
import shutil
import socket
import sqlite3
import subprocess
import sys
import threading
import time
from socketserver import ThreadingUnixStreamServer, StreamRequestHandler
import struct

# Netlink constants
NETLINK_USERSOCK = 2
NLMSG_HDRLEN = 16


def nl_recv_loop(db_conn):
    # Listen to kernel netlink broadcasts for exec_check events
    s = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, NETLINK_USERSOCK)
    s.bind((os.getpid(), 0))
    print('sukuna-securityd: netlink listener bound, pid=%d' % os.getpid())
    while True:
        data = s.recv(65536)
        if not data:
            continue
        # skip nl header
        if len(data) <= NLMSG_HDRLEN:
            continue
        payload = data[NLMSG_HDRLEN:]
        try:
            msg = payload.decode('utf-8', errors='ignore')
            # Expect JSON-like payload {"event":"exec_check","path":"..."}
            if 'exec_check' in msg:
                try:
                    j = json.loads(msg)
                except Exception:
                    j = None
                if j and 'path' in j:
                    path = j['path']
                    print('sukuna-securityd: received exec_check for', path)
                    # analyze asynchronously and store result in DB
                    t = threading.Thread(target=analyze_and_store, args=(db_conn, path))
                    t.daemon = True
                    t.start()
        except Exception as e:
            print('netlink parse error', e)


def analyze_and_store(conn, path):
    res = analyze_file(path)
    verdict = res.get('verdict', 'unknown')
    score = res.get('score', 0.0)
    store_cache(conn, path, verdict, score, res)
    print('sukuna-securityd: stored verdict', verdict, 'for', path)

SOCKET_PATH = '/run/sukuna-securityd.sock'
DB_PATH = '/var/lib/sukuna/security.db'
MALEVOLENT_RUNNER = '/opt/sukuna/malevolent-runner.py'


def ensure_dirs():
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    os.makedirs(os.path.dirname(SOCKET_PATH), exist_ok=True)


def init_db(conn):
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS verdicts (
                 id INTEGER PRIMARY KEY,
                 path TEXT UNIQUE,
                 verdict TEXT,
                 score REAL,
                 info TEXT,
                 updated INTEGER
                 )''')
    conn.commit()


def query_cache(conn, path):
    c = conn.cursor()
    c.execute('SELECT verdict,score,info,updated FROM verdicts WHERE path=?', (path,))
    row = c.fetchone()
    return row


def store_cache(conn, path, verdict, score, info):
    c = conn.cursor()
    now = int(time.time())
    c.execute('INSERT OR REPLACE INTO verdicts (path,verdict,score,info,updated) VALUES (?,?,?,?,?)',
              (path, verdict, score, json.dumps(info), now))
    conn.commit()


def analyze_file(path, timeout=30):
    if not os.path.exists(MALEVOLENT_RUNNER):
        return {'error': 'malevolent-runner not found', 'verdict': 'unknown'}
    try:
        proc = subprocess.run([MALEVOLENT_RUNNER, 'analyze', path, '--timeout', str(timeout), '--no-network'],
                              capture_output=True, text=True, check=False)
        out = proc.stdout.strip()
        try:
            j = json.loads(out)
        except Exception:
            j = {'error': 'invalid runner output', 'stdout': out, 'stderr': proc.stderr}
        return j
    except Exception as e:
        return {'error': str(e), 'verdict': 'unknown'}


class Handler(StreamRequestHandler):
    def handle(self):
        data = self.rfile.readline().decode().strip()
        if not data:
            return
        try:
            req = json.loads(data)
        except Exception:
            self.wfile.write(b'{"error":"invalid json"}\n')
            return

        cmd = req.get('cmd')
        path = req.get('path')

        conn = sqlite3.connect(DB_PATH)
        init_db(conn)

        if cmd == 'check' and path:
            row = query_cache(conn, path)
            if row:
                verdict, score, info, updated = row
                resp = {'path': path, 'verdict': verdict, 'score': score, 'info': json.loads(info) if info else None, 'cached': True}
                self.wfile.write((json.dumps(resp) + '\n').encode())
            else:
                # analyze
                res = analyze_file(path)
                verdict = res.get('verdict', 'unknown')
                score = res.get('score', 0.0)
                store_cache(conn, path, verdict, score, res)
                resp = {'path': path, 'verdict': verdict, 'score': score, 'info': res, 'cached': False}
                self.wfile.write((json.dumps(resp) + '\n').encode())

        elif cmd == 'add' and path:
            verdict = req.get('verdict', 'safe')
            store_cache(conn, path, verdict, 1.0, {'manual': True})
            self.wfile.write((json.dumps({'ok': True, 'path': path, 'verdict': verdict}) + '\n').encode())

        elif cmd == 'list':
            c = conn.cursor()
            c.execute('SELECT path,verdict,score,updated FROM verdicts ORDER BY updated DESC LIMIT 200')
            rows = [{'path': r[0], 'verdict': r[1], 'score': r[2], 'updated': r[3]} for r in c.fetchall()]
            self.wfile.write((json.dumps({'rows': rows}) + '\n').encode())

        elif cmd == 'status':
            self.wfile.write((json.dumps({'status': 'ok'}) + '\n').encode())

        else:
            self.wfile.write(b'{"error":"unknown command"}\n')


def run_server():
    ensure_dirs()
    if os.path.exists(SOCKET_PATH):
        try:
            os.remove(SOCKET_PATH)
        except Exception:
            pass
    server = ThreadingUnixStreamServer(SOCKET_PATH, Handler)
    os.chmod(SOCKET_PATH, 0o660)
    print('sukuna-securityd: listening on', SOCKET_PATH)
    conn = sqlite3.connect(DB_PATH)
    init_db(conn)
    # start netlink listener thread
    t = threading.Thread(target=nl_recv_loop, args=(conn,))
    t.daemon = True
    t.start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.shutdown()


if __name__ == '__main__':
    run_server()
