#!/bin/bash
set -e

echo "Iniciando Build do SukunaOS (Base Debian Bookworm)..."

# Limpar configurações antigas que podem estar travando o build
lb clean --purge

# Configurar o build para Debian Bookworm (Versão 12)
# Adicionamos non-free-firmware para drivers modernos
lb config -d bookworm \
    --debian-installer-distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --image-name "sukunaos-20260617" \
    --memtest memtest86+ \
    --apt-indices false \
    --backports true \
    --updates true

# Criar a pasta de saída se não existir
mkdir -p out

# Rodar o build
sudo lb build

# Mover a ISO gerada para a pasta 'out' para o GitHub encontrar
mv *.iso out/ 2>/dev/null || echo "ISO já está no lugar certo ou nome diferente."
