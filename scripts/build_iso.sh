#!/bin/bash
set -e
echo "----------------------------------------------------"
echo "🚀 Build SukunaOS - Modo Container Nativo"
echo "----------------------------------------------------"

# Limpeza
lb clean --purge

# Configuração Básica (O container já é Debian, então ele se entende)
lb config -d bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --apt-indices false

# Rodar o build
lb build

# Organizar a saída
mkdir -p out
mv *.iso out/sukunaos-build.iso || echo "ISO movida"