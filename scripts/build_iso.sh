#!/bin/bash
set -e

# Criar pasta de trabalho se não existir
mkdir -p live-build && cd live-build

# Configurar o live-build com os mirrors corretos para o Debian 12 Bookworm
lb config \
    --binary-images iso-hybrid \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --mirror-debian-installer "http://deb.debian.org/debian/" \
    --parent-mirror-binary-security "http://security.debian.org/debian-security" \
    --parent-mirror-bootstrap-security "http://security.debian.org/debian-security" \
    --security true

# Se houver customizações, copiar para dentro (opcional)
# rsync -av ../config/ .

# Rodar o build
sudo lb build
