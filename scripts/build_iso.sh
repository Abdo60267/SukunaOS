#!/bin/bash
set -e

# Limpeza total de builds anteriores
sudo lb clean --purge || true
mkdir -p live-build && cd live-build

# PASSO 1: Configuração Minimalista (apenas o que ele entende)
lb config \
    --binary-images iso-hybrid \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --security true

# PASSO 2: Cirurgia nos arquivos de configuração
# Como o lb config gera arquivos automáticos com caminhos errados para o Debian 12,
# nós vamos entrar em todos os arquivos gerados e consertar o texto na marra.
echo "🔧 Corrigindo repositórios do Debian 12..."
find config/ -type f -exec sed -i 's|bookworm/updates|bookworm-security|g' {} +
find config/ -type f -exec sed -i 's|security.debian.org/ |security.debian.org/debian-security |g' {} +
find config/ -type f -exec sed -i 's|security.debian.org\s|security.debian.org/debian-security |g' {} +

# PASSO 3: Rodar o build
sudo lb build
