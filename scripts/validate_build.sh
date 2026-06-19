#!/bin/bash
# SukunaOS Pre-Build Validation Script
# Executa validações antes de tentar build
# Uso: bash scripts/validate_build.sh

set -e

echo "🔴🔴🔴 SUKUNA BUILD VALIDATOR 🔴🔴🔴"
echo ""

ERRORS=0
WARNINGS=0

# 1. Validar diretório (REVISAR 3x)
echo "🔴 [1/8] Validando diretório atual..."
if [ ! -f "README.md" ] || [ ! -d "scripts" ]; then
    echo "❌ Erro: Execute de dentro do repositório SukunaOS"
    echo "   cd /caminho/para/SukunaOS"
    exit 1
fi
echo "✅ Diretório correto"
echo ""

# 2. Validar estrutura (REVISAR 3x)
echo "🔴 [2/8] Validando estrutura do projeto..."
REQUIRED_DIRS=("live/config" "src" "scripts" "assets" "systemd" "devkit" "tools")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "❌ Pasta ausente: $dir"
        ERRORS=$((ERRORS+1))
    else
        echo "✅ $dir"
    fi
done
echo ""

# 3. Validar arquivo de config (REVISAR 3x)
echo "🔴 [3/8] Validando configuração live-build..."
if [ ! -f "live/config/auto/config" ]; then
    echo "❌ Arquivo ausente: live/config/auto/config"
    ERRORS=$((ERRORS+1))
else
    if ! grep -q "lb config" "live/config/auto/config"; then
        echo "⚠️  Aviso: live/config/auto/config pode estar vazio"
        WARNINGS=$((WARNINGS+1))
    else
        echo "✅ live/config/auto/config válido"
    fi
fi
echo ""

# 4. Validar package list (REVISAR 3x)
echo "🔴 [4/8] Validando package list..."
if [ ! -f "live/config/package-lists/sukuna.list.chroot" ]; then
    echo "❌ Arquivo ausente: sukuna.list.chroot"
    ERRORS=$((ERRORS+1))
else
    PACKAGE_COUNT=$(wc -l < "live/config/package-lists/sukuna.list.chroot")
    if [ "$PACKAGE_COUNT" -lt 5 ]; then
        echo "⚠️  Aviso: Muito poucas packages ($PACKAGE_COUNT)"
        WARNINGS=$((WARNINGS+1))
    else
        echo "✅ sukuna.list.chroot com $PACKAGE_COUNT packages"
    fi
fi
echo ""

# 5. Validar dependências do sistema (REVISAR 3x)
echo "🔴 [5/8] Validando dependências do sistema..."
REQUIRED_CMDS=("live-build" "lb" "xorriso" "debootstrap" "rsync" "squashfs-tools")
for cmd in "${REQUIRED_CMDS[@]}"; do
    if command -v "$cmd" &> /dev/null; then
        VERSION=$(apt list --installed 2>/dev/null | grep "^$cmd/" | head -1 || echo "N/A")
        echo "✅ $cmd instalado"
    else
        echo "❌ $cmd NÃO INSTALADO"
        ERRORS=$((ERRORS+1))
    fi
done
echo ""

# 6. Validar espaço em disco (REVISAR 3x)
echo "🔴 [6/8] Validando espaço em disco..."
AVAILABLE=$(df . | tail -1 | awk '{print $4}')
NEEDED=$((5 * 1024 * 1024))  # 5 GB em KB
if [ "$AVAILABLE" -lt "$NEEDED" ]; then
    echo "❌ Espaço insuficiente!"
    echo "   Disponível: $(numfmt --to=iec-i --suffix=B $((AVAILABLE * 1024)) 2>/dev/null || echo "${AVAILABLE}KB")"
    echo "   Necessário: ~5 GB"
    ERRORS=$((ERRORS+1))
else
    AVAILABLE_GB=$((AVAILABLE / 1024 / 1024))
    echo "✅ Espaço disponível: ~${AVAILABLE_GB}GB"
fi
echo ""

# 7. Validar permissões (REVISAR 3x)
echo "🔴 [7/8] Validando permissões..."
if [ ! -r "scripts/build_iso.sh" ]; then
    echo "❌ scripts/build_iso.sh não legível"
    ERRORS=$((ERRORS+1))
else
    echo "✅ scripts/build_iso.sh legível"
fi

if [ ! -x "scripts/build_iso.sh" ]; then
    echo "⚠️  scripts/build_iso.sh não é executável"
    echo "   Corrigindo..."
    chmod +x scripts/build_iso.sh
    echo "✅ Permissões ajustadas"
fi
echo ""

# 8. Validar Ubuntu/Debian (REVISAR 3x)
echo "🔴 [8/8] Validando OS..."
if [ -f "/etc/os-release" ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian)
            echo "✅ OS: $PRETTY_NAME"
            ;;
        *)
            echo "⚠️  Aviso: Este script foi testado em Ubuntu/Debian"
            echo "   OS detectado: $PRETTY_NAME"
            WARNINGS=$((WARNINGS+1))
            ;;
    esac
else
    echo "⚠️  Aviso: Não foi possível detectar OS"
    WARNINGS=$((WARNINGS+1))
fi
echo ""

# Resumo final
echo "════════════════════════════════════════════════════════════"
echo "🔴 RELATÓRIO DE VALIDAÇÃO"
echo "════════════════════════════════════════════════════════════"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "✅ Erros: 0"
else
    echo "❌ Erros: $ERRORS (CRÍTICOS - Corrija antes de prosseguir)"
fi

if [ $WARNINGS -eq 0 ]; then
    echo "✅ Avisos: 0"
else
    echo "⚠️  Avisos: $WARNINGS (não-críticos)"
fi

echo ""
echo "════════════════════════════════════════════════════════════"

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo "❌ VALIDAÇÃO FALHOU"
    echo ""
    echo "Para instalar dependências em Ubuntu/Debian:"
    echo "  sudo apt update"
    echo "  sudo apt install live-build squashfs-tools xorriso debootstrap rsync"
    echo ""
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo ""
    echo "⚠️  VALIDAÇÃO PASSOU COM AVISOS"
    echo "O build pode funcionar, mas verifique os avisos acima"
    echo ""
else
    echo ""
    echo "✅ VALIDAÇÃO PASSOU"
    echo ""
    echo "🔴 Próximo passo: bash scripts/build_iso.sh"
    echo ""
fi
