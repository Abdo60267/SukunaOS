#!/bin/bash
set -e

echo "Iniciando Build do SukunaOS (Base Debian Bookworm)..."

# Limpar tudo antes de começar
lb clean --purge

# Configurar o build (Removidos comandos incompatíveis com a v3.0)
# O live-build 3.0 vai gerar um arquivo chamado 'live-image-amd64.hybrid.iso' por padrão
lb config -d bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --apt-indices false \
    --bootstrap-qemu-static true

# Criar a pasta de saída
mkdir -p out

# Rodar o build (Essa parte demora uns 20 min)
sudo lb build

# Renomear e mover a ISO final para a pasta 'out'
if [ -f *.iso ]; then
    mv *.iso out/sukunaos-$(date +%Y%m%d).iso
    echo "ISO criada com sucesso em out/"
else
    echo "ERRO: O arquivo ISO não foi encontrado após o build."
    exit 1
fi
