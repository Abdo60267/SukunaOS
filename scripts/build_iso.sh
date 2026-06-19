#!/bin/bash 
set -e

echo "🔴🔴🔴 SUKUNA RITUAL DE CRIAÇÃO DE ISO 🔴🔴🔴"
echo "Base: Ubuntu 24.04 LTS | Tema: Crimson Carmesim"
echo ""

# Validar pré-requisitos (VERIFICAÇÃO 1, 2, 3)
echo "🔴 [VALIDAÇÃO] Verificando dependências..."
for cmd in lb xorriso debootstrap rsync; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ Erro: comando '$cmd' não encontrado"
        echo "   Instale: sudo apt install live-build squashfs-tools xorriso debootstrap rsync"
        exit 1
    fi
done
echo "✅ Todas as dependências encontradas"
echo ""

# Validar estrutura do repositório (VERIFICAÇÃO 1, 2, 3)
echo "🔴 [VALIDAÇÃO] Verificando estrutura do projeto..."
if [ ! -d "live/config" ]; then
    echo "❌ Erro: Pasta 'live/config' não encontrada!"
    echo "   Locação esperada: $(pwd)/live/config"
    exit 1
fi

if [ ! -f "live/config/auto/config" ]; then
    echo "❌ Erro: Arquivo 'live/config/auto/config' não encontrada!"
    echo "   Locação esperada: $(pwd)/live/config/auto/config"
    exit 1
fi

if [ ! -d "src" ] || [ ! -d "scripts" ] || [ ! -d "assets" ]; then
    echo "❌ Erro: Faltam pastas do projeto (src, scripts, assets)"
    exit 1
fi
echo "✅ Estrutura do projeto validada"
echo ""

# Guardar diretório de trabalho (VERIFICAÇÃO 1, 2, 3)
WORK_DIR="$(pwd)"
REPO_DIR="$WORK_DIR"

# Limpeza de builds anteriores (VERIFICAÇÃO 1, 2, 3)
echo "🔴 [LIMPEZA] Removendo builds anteriores..."
if [ -d "live-build" ]; then
    rm -rf live-build
    echo "✅ Pasta live-build removida"
fi

# Tentar limpar config live-build se existir
if command -v lb &> /dev/null; then
    lb clean --purge 2>/dev/null || true
fi

# Criar pasta de build
mkdir -p live-build
cd live-build

echo "✅ Pasta live-build criada em: $(pwd)"
echo ""

# Copiar configuração (VERIFICAÇÃO 1, 2, 3)
echo "🔴 [CONFIG] Copiando configurações live-build..."
if [ ! -d "$REPO_DIR/live/config" ]; then
    echo "❌ Erro: live/config não encontrado em $REPO_DIR"
    exit 1
fi

cp -r "$REPO_DIR/live/config" . || {
    echo "❌ Erro ao copiar live/config"
    exit 1
}
echo "✅ Configurações copiadas"
echo ""

# Criar estrutura chroot (VERIFICAÇÃO 1, 2, 3)
echo "🔴 [CHROOT] Preparando ambiente chroot..."
CHROOT_PATH="config/includes.chroot/opt/sukuna"
mkdir -p "$CHROOT_PATH"

# Copiar assets do repositório (com validação de paths)
echo "   • Copiando src, scripts, systemd, assets, devkit, tools..."
for item in src scripts systemd assets devkit tools; do
    if [ -e "$REPO_DIR/$item" ]; then
        cp -r "$REPO_DIR/$item" "$CHROOT_PATH/" || {
            echo "❌ Erro ao copiar $item"
            exit 1
        }
        echo "     ✅ $item copiado"
    else
        echo "     ⚠️  $item não encontrado (opcional)"
    fi
done
echo "✅ Estrutura chroot pronta"
echo ""

# Executar lb config (VERIFICAÇÃO 1, 2, 3)
echo "🔴 [LIVE-BUILD] Configurando live-build..."
if [ ! -f "config/auto/config" ]; then
    echo "❌ Erro: config/auto/config não encontrado"
    echo "   Procurando em: $(pwd)/config/auto/"
    ls -la config/auto/ 2>/dev/null || echo "   Pasta auto/ não existe!"
    exit 1
fi

# Executar configuração
if ! bash config/auto/config 2>&1 | tee config_output.log; then
    echo "❌ Erro ao executar lb config"
    echo "   Log: $(pwd)/config_output.log"
    tail -20 config_output.log
    exit 1
fi
echo "✅ Configuração live-build concluída"
echo ""

# Executar build (VERIFICAÇÃO 1, 2, 3)
echo "🔴 [BUILD] Iniciando build ISO (pode demorar 30-40 minutos)..."
if ! lb build 2>&1 | tee build_output.log; then
    echo "❌ Erro durante lb build!"
    echo "   Log: $(pwd)/build_output.log"
    echo "   Últimas linhas:"
    tail -50 build_output.log
    exit 1
fi
echo "✅ Build concluído"
echo ""

# Verificar resultado (VERIFICAÇÃO 1, 2, 3)
echo "🔴 [VERIFICAÇÃO] Procurando arquivo ISO..."
ISO_FILE=""
if [ -f "live-image-amd64.iso" ]; then
    ISO_FILE="$(pwd)/live-image-amd64.iso"
    echo "✅ Encontrado: live-image-amd64.iso"
elif [ -f "../live-image-amd64.iso" ]; then
    ISO_FILE="$REPO_DIR/live-image-amd64.iso"
    echo "✅ Encontrado: ../live-image-amd64.iso"
    echo "   Movendo para live-build/..."
    mv "../live-image-amd64.iso" "live-image-amd64.iso"
else
    echo "❌ ISO não encontrada!"
    echo "   Procurando em toda a estrutura..."
    find . -name "*.iso" -o -name "live-image*" 2>/dev/null || echo "   Nenhum arquivo encontrado"
    exit 1
fi

# Validar tamanho (VERIFICAÇÃO 1, 2, 3)
if [ -f "live-image-amd64.iso" ]; then
    ISO_SIZE=$(du -h live-image-amd64.iso | cut -f1)
    ISO_BYTES=$(stat -c%s "live-image-amd64.iso" 2>/dev/null || stat -f%z "live-image-amd64.iso" 2>/dev/null || echo "0")
    
    if [ "$ISO_BYTES" -lt 1000000000 ]; then
        echo "⚠️  Aviso: ISO é menor que 1GB ($ISO_SIZE)"
        echo "   Isso pode indicar build incompleto"
    else
        echo "✅ Tamanho da ISO: $ISO_SIZE (${ISO_BYTES} bytes)"
    fi
fi

echo ""
echo "🔴🔴🔴 RITUAL CONCLUÍDO COM SUCESSO! 🔴🔴🔴"
echo ""
echo "ISO criada: $(pwd)/live-image-amd64.iso"
echo "Tamanho: $ISO_SIZE"
echo ""
echo "🔴 Próximos passos:"
echo "   1. Flash para USB:"
echo "      sudo dd if=live-image-amd64.iso of=/dev/sdX bs=4M"
echo "   2. Ou use ferramenta gráfica:"
echo "      • Etcher: https://www.balena.io/etcher/"
echo "      • Ventoy: https://www.ventoy.net/"
echo "      • Rufus (Windows): https://rufus.ie/"
echo "   3. Boot da ISO em VM ou hardware"
echo "   4. Instalador gráfico aparecerá automaticamente"
echo ""
echo "🔴 Informações técnicas:"
echo "   • Base: Ubuntu 24.04 LTS (noble)"
echo "   • Boot: UEFI + BIOS (hybrid)"
echo "   • Tema: Carmesim + Mac-inspired"
echo "   • Arquitetura: amd64 (x86_64)"
echo ""