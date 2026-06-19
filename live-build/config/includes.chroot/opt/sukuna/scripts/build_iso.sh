#!/bin/bash 
set -e 

echo "🔴 [Sukuna] Iniciando Ritual de Criação da ISO do SukunaOS..."
echo "🔴 [Sukuna] Base: Ubuntu 24.04 LTS | Tema: Crimson Carmesim"

# Limpeza 
lb clean --purge || true 
rm -rf live-build 

# Criar pasta de build 
mkdir -p live-build 

# Copiar a configuração base de live/ para live-build/ 
if [ -d "live/config" ]; then 
    echo "🔴 [Sukuna] Copiando configurações da pasta live/..." 
    cp -r live/config live-build/ 
else 
    echo "❌ ERRO: Pasta live/config não encontrada!" 
    exit 1 
fi 

# Entrar no diretório de build 
cd live-build 

# Criar pasta chroot para copiar o repositório 
mkdir -p config/includes.chroot/opt/sukuna 

echo "🔴 [Sukuna] Copiando arquivos do repositório para /opt/sukuna..." 
cp -r ../src ../scripts ../systemd ../assets ../devkit ../tools config/includes.chroot/opt/sukuna/ 

# Rodar a configuração e o build 
echo "🔴 [Sukuna] Rodando lb config..." 
lb config 

echo "🔴 [Sukuna] Rodando lb build (isso pode demorar 20-40 minutos)..." 
lb build 

echo "🔴🔴🔴 RITUAL CONCLUÍDO COM SUCESSO! 🔴🔴🔴"
echo ""
echo "ISO criada em: $(pwd)/live-image-amd64.iso"
echo "Tamanho: $(du -h live-image-amd64.iso | cut -f1)"
echo ""
echo "🔴 Próximos passos:"
echo "   • Flash para USB: dd if=live-image-amd64.iso of=/dev/sdX bs=4M"
echo "   • Ou use uma ferramenta como Etcher, Ventoy ou Rufus"
echo "   • Boot da ISO em VM ou hardware real"
echo "   • O instalador gráfico aparecerá automaticamente"