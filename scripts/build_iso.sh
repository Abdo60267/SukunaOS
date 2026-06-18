#!/bin/bash
set -e
echo '----------------------------------------------------'
echo '🚀 Build SukunaOS - Corrigindo Mirrors de Segurança'
echo '----------------------------------------------------'

# Limpeza total
sudo lb clean --purge

# Configurar o build
# --security false: Resolve o erro 404 do mirror de segurança antigo
lb config --mode debian \
    -d bookworm \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-chroot "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --security false \
    --archive-areas "main contrib non-free non-free-firmware" \
    --apt-indices false

# Criar pasta de saida
mkdir -p out

# Rodar o build real
sudo lb build

# Localizar a ISO e mover
ISO_FILE=$(ls *.iso 2>/dev/null | head -n 1)
if [ -f "$ISO_FILE" ]; then
    mv "$ISO_FILE" out/sukunaos-build.iso
    echo "✅ ISO criada com sucesso: out/sukunaos-build.iso"
else
    echo "❌ Erro: ISO nao encontrada após o build."
    exit 1
fi