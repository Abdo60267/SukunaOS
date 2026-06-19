#!/usr/bin/env python3
"""
SukunaOS Security Daemon - King of Curses Edition
Userspace security daemon for POC LSM integration

API (JSON lines over UNIX socket /run/sukuna-securityd.sock):
  - {"cmd":"check","path":"/path/to/file"}
  - {"cmd":"add","path":"/path/to/file","verdict":"safe|suspicious|malicious"}
  - {"cmd":"list"}
  - {"cmd":"status"}

Features:
  - SQLite cache (/var/lib/sukuna/security.db)
  - Netlink listener for kernel exec_check events
  - Async file analysis (malevolent-runner.py)
  - JSON-RPC over UNIX socket
  - Thread-safe database operations

Status: POC - Production version in Sprint 1.2
"""

import json
import logging
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

# Logging setup
logging.basicConfig(
    level=logging.INFO,
    format='🔴 [%(asctime)s] %(levelname)s: %(message)s',
    handlers=[
        logging.FileHandler('/var/log/sukuna-securityd.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger('sukuna-securityd')

# Configuration
DB_PATH = '/var/lib/sukuna/security.db'
SOCKET_PATH = '/run/sukuna-securityd.sock'
ANALYZER_SCRIPT = '/opt/sukuna/malevolent_runner.py'

# Netlink constants
NETLINK_USERSOCK = 2
NLMSG_HDRLEN = 16


def init_db(conn):
    """Initialize security database schema"""
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS verdicts (
        path TEXT PRIMARY KEY,
        verdict TEXT,
        score REAL,
        timestamp INTEGER,
        metadata TEXT
    )''')
    c.execute('''CREATE TABLE IF NOT EXISTS events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER,
        event_type TEXT,
        path TEXT,
        result TEXT
    )''')
    conn.commit()


def _connect_db():
    """Create thread-local SQLite connection (thread-safe)"""
    conn = sqlite3.connect(DB_PATH, check_same_thread=False, timeout=10)
    conn.row_factory = sqlite3.Row
    init_db(conn)
    return conn


def analyze_file(path):
    """Analyze file using malevolent-runner.py
    
    Returns: {"verdict": "safe|suspicious|malicious", "score": 0.0-1.0, ...}
    """
    try:
        if not os.path.exists(path):
            logger.warning(f"File not found: {path}")
            return {"verdict": "unknown", "score": 0, "reason": "file_not_found"}
        
        logger.info(f"Analyzing: {path}")
        
        # Call analyzer script
        result = subprocess.run(
            [sys.executable, ANALYZER_SCRIPT, "analyze", path],
            capture_output=True,
            timeout=30,
            text=True
        )
        
        if result.returncode == 0:
            try:
                return json.loads(result.stdout)
            except json.JSONDecodeError:
                logger.error(f"Invalid JSON from analyzer: {result.stdout}")
                return {"verdict": "unknown", "score": 0.5}
        else:
            logger.error(f"Analyzer failed: {result.stderr}")
            return {"verdict": "suspicious", "score": 0.5, "reason": "analysis_failed"}
    
    except subprocess.TimeoutExpired:
        logger.error(f"Analysis timeout: {path}")
        return {"verdict": "suspicious", "score": 0.7, "reason": "timeout"}
    except Exception as e:
        logger.error(f"Analysis error: {e}")
        return {"verdict": "unknown", "score": 0, "error": str(e)}


def store_verdict(conn, path, verdict, score, metadata=None):
    """Store verdict in cache"""
    c = conn.cursor()
    c.execute('''INSERT OR REPLACE INTO verdicts 
                 (path, verdict, score, timestamp, metadata)
                 VALUES (?, ?, ?, ?, ?)''',
              (path, verdict, score, int(time.time()), 
               json.dumps(metadata or {})))
    conn.commit()
    logger.info(f"Stored verdict: {path} → {verdict}")


def get_verdict(conn, path):
    """Retrieve cached verdict"""
    c = conn.cursor()
    c.execute('SELECT * FROM verdicts WHERE path = ?', (path,))
    row = c.fetchone()
    if row:
        return dict(row)
    return None


def analyze_and_store(path):
    """Analyze file and store result (async)"""
    conn = _connect_db()
    try:
        result = analyze_file(path)
        verdict = result.get('verdict', 'unknown')
        score = result.get('score', 0.0)
        store_verdict(conn, path, verdict, score, result)
        
        # Log event
        c = conn.cursor()
        c.execute('INSERT INTO events (timestamp, event_type, path, result) VALUES (?, ?, ?, ?)',
                  (int(time.time()), 'analyze', path, json.dumps(result)))
        conn.commit()
    except Exception as e:
        logger.error(f"Store error: {e}")
    finally:
        conn.close()


def nl_recv_loop():
    """Listen to kernel netlink broadcasts for exec_check events"""
    try:
        s = socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, NETLINK_USERSOCK)
        s.bind((os.getpid(), 0))
        logger.info(f"🔴 Netlink listener bound (PID={os.getpid()})")
        
        while True:
            try:
                data = s.recv(65536)
                if not data:
                    continue
                
                # Skip netlink header
                if len(data) <= NLMSG_HDRLEN:
                    continue
                
                payload = data[NLMSG_HDRLEN:]
                msg = payload.decode('utf-8', errors='ignore')
                
                # Expect JSON payload: {"event":"exec_check","path":"..."}
                if 'exec_check' in msg:
                    try:
                        j = json.loads(msg)
                        if 'path' in j:
                            path = j['path']
                            logger.info(f"🔴 Exec check event: {path}")
                            # Analyze async
                            t = threading.Thread(target=analyze_and_store, args=(path,), daemon=True)
                            t.start()
                    except json.JSONDecodeError:
                        logger.warning(f"Invalid JSON from kernel: {msg[:100]}")
            except Exception as e:
                logger.error(f"Netlink parse error: {e}")
    except Exception as e:
        logger.error(f"Netlink socket error: {e}")
        logger.warning("Netlink listener disabled - kernel LSM integration not available")


class SecurityRequestHandler(StreamRequestHandler):
    """Handle socket API requests"""
    
    def handle(self):
        """Process JSON-RPC requests"""
        try:
            # Read JSON request (ends with newline)
            data = self.rfile.readline().decode('utf-8').strip()
            if not data:
                return
            
            req = json.loads(data)
            cmd = req.get('cmd')
            
            logger.info(f"Command: {cmd}")
            
            conn = _connect_db()
            resp = {"error": "unknown command"}
            
            try:
                if cmd == 'check':
                    path = req.get('path')
                    if not path:
                        resp = {"error": "missing path"}
                    else:
                        # Check cache first
                        cached = get_verdict(conn, path)
                        if cached:
                            resp = {
                                "verdict": cached['verdict'],
                                "score": cached['score'],
                                "cached": True,
                                "timestamp": cached['timestamp']
                            }
                        else:
                            # Analyze now
                            result = analyze_file(path)
                            verdict = result.get('verdict', 'unknown')
                            score = result.get('score', 0)
                            store_verdict(conn, path, verdict, score, result)
                            resp = {
                                "verdict": verdict,
                                "score": score,
                                "cached": False,
                                "analysis": result
                            }
                
                elif cmd == 'add':
                    path = req.get('path')
                    verdict = req.get('verdict', 'unknown')
                    if path:
                        store_verdict(conn, path, verdict, 1.0 if verdict == 'safe' else 0.0)
                        resp = {"ok": True, "path": path, "verdict": verdict}
                    else:
                        resp = {"error": "missing path"}
                
                elif cmd == 'list':
                    c = conn.cursor()
                    c.execute('SELECT path, verdict, score, timestamp FROM verdicts LIMIT 100')
                    rows = [dict(row) for row in c.fetchall()]
                    resp = {"verdicts": rows, "count": len(rows)}
                
                elif cmd == 'status':
                    c = conn.cursor()
                    c.execute('SELECT COUNT(*) FROM verdicts')
                    total = c.fetchone()[0]
                    c.execute('SELECT COUNT(*) FROM events')
                    events = c.fetchone()[0]
                    resp = {
                        "status": "running",
                        "version": "1.0.0-poc",
                        "cached_verdicts": total,
                        "events": events,
                        "db": DB_PATH
                    }
                
                else:
                    resp = {"error": f"unknown command: {cmd}"}
            
            finally:
                conn.close()
            
            # Send response
            self.wfile.write((json.dumps(resp) + '\n').encode())
            logger.info(f"Response: {cmd} → {resp.get('verdict', resp.get('status', 'error'))}")
        
        except json.JSONDecodeError as e:
            logger.error(f"JSON parse error: {e}")
            self.wfile.write(json.dumps({"error": "invalid json"}).encode() + b'\n')
        except Exception as e:
            logger.error(f"Handler error: {e}")
            self.wfile.write(json.dumps({"error": "internal error"}).encode() + b'\n')


def main():
    """Start security daemon"""
    # Setup directories
    os.makedirs('/var/lib/sukuna', exist_ok=True)
    os.makedirs('/var/log', exist_ok=True)
    
    logger.info("🔴 ════════════════════════════════════════")
    logger.info("🔴 SUKUNA SECURITY DAEMON (King of Curses)")
    logger.info("🔴 ════════════════════════════════════════")
    logger.info(f"Database: {DB_PATH}")
    logger.info(f"Socket: {SOCKET_PATH}")
    logger.info(f"Log: /var/log/sukuna-securityd.log")
    
    # Start netlink listener in background thread
    nl_thread = threading.Thread(target=nl_recv_loop, daemon=True)
    nl_thread.start()
    
    # Remove old socket
    if os.path.exists(SOCKET_PATH):
        os.remove(SOCKET_PATH)
    
    # Start socket server
    try:
        server = ThreadingUnixStreamServer(SOCKET_PATH, SecurityRequestHandler)
        os.chmod(SOCKET_PATH, 0o666)
        logger.info("🔴 Server listening on UNIX socket")
        logger.info("🔴 Ritual expanded - domain prepared")
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info("🔴 Ritual interrupted by user")
        sys.exit(0)
    except Exception as e:
        logger.error(f"Fatal error: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
        print('sukuna-securityd: stored verdict', verdict, 'for', path)
    finally:
        conn.close()

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

        # Each handler request gets its own DB connection (thread-safe)
        conn = _connect_db()
        try:
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
        finally:
            conn.close()


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

    # Initialize the DB schema once at startup
    conn = _connect_db()
    conn.close()

    # start netlink listener thread (no shared DB conn)
    t = threading.Thread(target=nl_recv_loop)
    t.daemon = True
    t.start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.shutdown()


if __name__ == '__main__':
    run_server()
