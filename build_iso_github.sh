#!/usr/bin/env bash
set -e
echo "🚀 Iniciando Launcher Automático SukunaOS..."
git add -A
git commit -m "🔨 Build ISO automático - $(date '+%Y-%m-%d %H:%M:%S')" || echo "⚠️ Nada novo para commit"
git push -u origin main
echo "✅ Pronto! Verifique a aba Actions no seu GitHub."
