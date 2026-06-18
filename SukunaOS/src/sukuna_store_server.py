#!/usr/bin/env python3
"""
Simple POC Sukuna Store backend (Flask) - local development only

Endpoints:
 - GET /api/apps?q=...  (search)
 - GET /api/apps/<id>
 - POST /api/apps/<id>/install  (triggers installer: flatpak/deb/dcl)

This is a minimal skeleton for local testing and integration with the MDE.
"""

from flask import Flask, request, jsonify
import sqlite3
import os
import subprocess

DB = '/var/lib/sukuna/store.db'
app = Flask(__name__)


def init_db():
    os.makedirs(os.path.dirname(DB), exist_ok=True)
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS apps (id TEXT PRIMARY KEY, name TEXT, desc TEXT)''')
    conn.commit()
    conn.close()


@app.route('/api/apps')
def list_apps():
    q = request.args.get('q','')
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    if q:
        c.execute("SELECT id,name,desc FROM apps WHERE name LIKE ? OR desc LIKE ? LIMIT 50", (f'%{q}%', f'%{q}%'))
    else:
        c.execute("SELECT id,name,desc FROM apps LIMIT 200")
    rows = [{'id':r[0],'name':r[1],'desc':r[2]} for r in c.fetchall()]
    conn.close()
    return jsonify({'rows': rows})


@app.route('/api/apps/<app_id>')
def get_app(app_id):
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    c.execute('SELECT id,name,desc FROM apps WHERE id=?', (app_id,))
    r = c.fetchone()
    conn.close()
    if not r:
        return jsonify({'error':'not found'}), 404
    return jsonify({'id':r[0],'name':r[1],'desc':r[2]})


@app.route('/api/apps/<app_id>/install', methods=['POST'])
def install_app(app_id):
    data = request.json or {}
    fmt = data.get('format','dcl')
    user_scope = data.get('user_scope', True)
    # For POC, simply call dcl wrapper when format==dcl
    if fmt == 'dcl':
        # find package path in DB (POC: assume path provided)
        path = data.get('path')
        if not path or not os.path.exists(path):
            return jsonify({'error':'path missing or not exists'}), 400
        # call wrapper
        try:
            subprocess.check_call(['/usr/bin/env','python3','/opt/sukuna/sukuna_dcl_wrapper.py','install',path])
            return jsonify({'status':'ok','installed':True})
        except subprocess.CalledProcessError as e:
            return jsonify({'error':'install failed','detail':str(e)}), 500
    else:
        return jsonify({'error':'format not implemented in POC'}), 501


if __name__ == '__main__':
    init_db()
    app.run(host='127.0.0.1',port=8080)
