#!/bin/bash
set -e

# Limpar qualquer tentativa anterior que falhou
sudo lb clean --purge || true
mkdir -p live-build && cd live-build

# lb config: Versão compatível com o Runner do GitHub (3.x)
# Note que removemos o prefixo "--parent"
lb config \
    --binary-images iso-hybrid \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --security true \
    --mirror-binary-security "http://security.debian.org/debian-security" \
    --mirror-bootstrap-security "http://security.debian.org/debian-security"

# TRUQUE MESTRE PARA BOOKWORM:
# Como o live-build antigo tenta colocar "/updates", vamos trocar para "-security" manualmente
# Isso corrige o erro 404 que deu no seu primeiro build
if [ -d config ]; then
    grep -rl "bookworm/updates" config/ | xargs sed -i 's|bookworm/updates|bookworm-security|g' 2>/dev/null || true
fi

# Inicia o build
sudo lb build
