#!/usr/bin/env bash
# SukunaOS ISO Build Launcher para Linux/WSL
# Este script faz commit das mudanças, faz push para GitHub e ativa o build automático

set -e

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     🚀 SukunaOS ISO Build - Launcher Automático            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

if ! git status >/dev/null 2>&1; then
    echo "❌ Git não está configurado ou você não está em um repo Git"
    echo "Solução: git init && git remote add origin <seu-repo-url>"
    exit 1
fi

echo "📝 Fazendo commit das mudanças..."
git add -A
git commit -m "🔨 Build ISO automático - $(date '+%Y-%m-%d %H:%M:%S')" || echo "⚠️  Nada novo para fazer commit (pode ser normal)"

echo ""
echo "📤 Fazendo push para GitHub (branch main)..."
git push -u origin main

if [ $? -ne 0 ]; then
    echo "❌ Erro no push. Verifique:"
    echo "   - Tem acesso ao repositório?"
    echo "   - Rodou: git config --global user.name 'Seu Nome'"
    echo "   - Rodou: git config --global user.email 'seu@email.com'"
    exit 1
fi

echo "✅ Push realizado!"
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║ 🎉 ISO Build foi ativado no GitHub Actions!               ║"
echo "║                                                            ║"
echo "║ ⏱️  Tempo de espera: ~20 minutos                            ║"
echo "║                                                            ║"
echo "║ 📍 Para acompanhar:                                        ║"
echo "║    1. Vai em: https://github.com/SEU_USER/SukunaOS        ║"
echo "║    2. Clica em \"Actions\"                                  ║"
echo "║    3. Procura \"Build SukunaOS ISO\"                        ║"
echo "║    4. Quando ficar verde ✅, clica e vai em \"Artifacts\"  ║"
echo "║                                                            ║"
echo "║ 📥 Baixa o arquivo \"sukunaos-iso\"                         ║"
echo "║                                                            ║"
echo "║ Seu repositório é:                                         ║"
REPO=$(git config --get remote.origin.url)
echo "║    $REPO"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
