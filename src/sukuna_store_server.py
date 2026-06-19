#!/usr/bin/env python3
"""
Sukuna Store Backend - Ubuntu 24.04 LTS Edition
REST API for package management (Flatpak, Snap, Deb, DCL)

Endpoints:
  - GET /api/apps?q=...  (search)
  - GET /api/apps/<id>
  - POST /api/apps/<id>/install  (triggers installer)
  - GET /api/health (status check)

Local development: python3 sukuna_store_server.py
"""

from flask import Flask, request, jsonify
import sqlite3
import os
import subprocess
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('SukunaStore')

DB = '/var/lib/sukuna/store.db'
app = Flask(__name__)


def init_db():
    """Initialize store database with sample apps"""
    os.makedirs(os.path.dirname(DB), exist_ok=True)
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS apps 
        (id TEXT PRIMARY KEY, name TEXT, desc TEXT, format TEXT, category TEXT)''')
    
    # Sample apps with Sukuna theme
    sample_apps = [
        ('firefox', 'Firefox', 'Navegador web rápido e seguro', 'flatpak', 'Internet'),
        ('blender', 'Blender', '3D modeling e animação profissional', 'flatpak', 'Graphics'),
        ('vscode', 'VS Code', 'Editor de código poderoso', 'flatpak', 'Development'),
        ('audacity', 'Audacity', 'Editor de áudio profissional', 'flatpak', 'Multimedia'),
        ('gimp', 'GIMP', 'Editor de imagens avançado', 'flatpak', 'Graphics'),
        ('vlc', 'VLC', 'Reprodutor multimídia versátil', 'flatpak', 'Multimedia'),
    ]
    
    for app_id, name, desc, fmt, cat in sample_apps:
        try:
            c.execute('INSERT INTO apps VALUES (?, ?, ?, ?, ?)', (app_id, name, desc, fmt, cat))
        except sqlite3.IntegrityError:
            pass  # App already exists
    
    conn.commit()
    conn.close()
    logger.info("🔴 Store database initialized")


@app.route('/api/health')
def health():
    """Health check endpoint"""
    return jsonify({'status': 'ok', 'version': '1.0.0', 'os': 'SukunaOS Ubuntu'})


@app.route('/api/apps')
def list_apps():
    """List or search apps"""
    q = request.args.get('q', '').strip()
    category = request.args.get('category', '').strip()
    
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    
    if q:
        c.execute(
            "SELECT id, name, desc, format, category FROM apps WHERE name LIKE ? OR desc LIKE ? LIMIT 50",
            (f'%{q}%', f'%{q}%')
        )
    elif category:
        c.execute(
            "SELECT id, name, desc, format, category FROM apps WHERE category = ? LIMIT 50",
            (category,)
        )
    else:
        c.execute("SELECT id, name, desc, format, category FROM apps LIMIT 200")
    
    rows = [{'id': r[0], 'name': r[1], 'desc': r[2], 'format': r[3], 'category': r[4]} 
            for r in c.fetchall()]
    conn.close()
    
    logger.info(f"🔴 Listed {len(rows)} apps (query: {q or 'all'})")
    return jsonify({'apps': rows, 'total': len(rows)})


@app.route('/api/apps/<app_id>')
def get_app(app_id):
    """Get app details"""
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    c.execute('SELECT id, name, desc, format, category FROM apps WHERE id=?', (app_id,))
    r = c.fetchone()
    conn.close()
    
    if not r:
        return jsonify({'error': 'app not found'}), 404
    
    return jsonify({
        'id': r[0],
        'name': r[1],
        'desc': r[2],
        'format': r[3],
        'category': r[4]
    })


@app.route('/api/apps/<app_id>/install', methods=['POST'])
def install_app(app_id):
    """Install an app"""
    data = request.json or {}
    fmt = data.get('format', 'flatpak')
    
    logger.info(f"🔴 Installing {app_id} ({fmt})")
    
    try:
        if fmt == 'flatpak':
            subprocess.check_call(['flatpak', 'install', '-y', f'flathub {app_id}'])
        elif fmt == 'dcl':
            # Domain Compatibility Layer
            subprocess.check_call(['/usr/bin/env', 'python3', '/opt/sukuna/sukuna_dcl_wrapper.py', 
                                   'install', data.get('path')])
        else:
            return jsonify({'error': f'format {fmt} not implemented'}), 501
        
        logger.info(f"✅ Installed {app_id} successfully")
        return jsonify({'status': 'ok', 'installed': True, 'app_id': app_id})
    
    except subprocess.CalledProcessError as e:
        logger.error(f"❌ Install failed for {app_id}: {e}")
        return jsonify({'error': 'install failed', 'detail': str(e)}), 500
    except Exception as e:
        logger.error(f"❌ Unexpected error: {e}")
        return jsonify({'error': 'unexpected error', 'detail': str(e)}), 500


if __name__ == '__main__':
    init_db()
    print("\n🔴🔴🔴 SUKUNA STORE - UBUNTU EDITION 🔴🔴🔴")
    print("🔴 Starting on http://127.0.0.1:8080")
    print("🔴 Local development mode only\n")
    app.run(host='127.0.0.1', port=8080, debug=True)
