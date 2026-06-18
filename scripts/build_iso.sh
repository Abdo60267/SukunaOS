#!/bin/bash
set -e
echo '----------------------------------------------------'
echo '🚀 Build SukunaOS - Modo Nativo Debian'
echo '----------------------------------------------------'

# Limpeza total
sudo lb clean --purge

# Configurar o build FORÇANDO o modo debian e os mirrors corretos
lb config --mode debian \
    -d bookworm \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-chroot "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --archive-areas "main contrib non-free non-free-firmware" \
    --apt-indices false

# Criar pasta de saida
mkdir -p out

# Rodar o build real
sudo lb build

# Localizar a ISO e mover
ISO_FILE=\
if [ -f "\" ]; then
    mv "\" out/sukunaos-build.iso
    echo "✅ ISO criada: out/sukunaos-build.iso"
else
    echo "❌ Erro: ISO nao gerada."
    exit 1
fi