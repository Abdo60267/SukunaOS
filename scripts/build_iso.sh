#!/bin/bash
set -e

# Limpar vestígios
sudo lb clean --purge || true
rm -rf live-build
mkdir -p live-build && cd live-build

# PASSO 1: Configuração Básica (Desativamos o --security automático para evitar erro)
lb config \
    --binary-images iso-hybrid \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --security false

# PASSO 2: Criar manualmente os repositórios (Source List) corretos do Debian 12
mkdir -p config/archives
cat << 'EOT' > config/archives/sukuna_repos.list.chroot
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOT

cp config/archives/sukuna_repos.list.chroot config/archives/sukuna_repos.list.binary

# PASSO 3: Limpeza de pacotes fantasmagóricos (Ubuntu-keyring)
if [ -d config/package-lists ]; then
    find config/package-lists/ -type f -exec sed -i 's/ubuntu-keyring//g' {} + || true
fi

# PASSO 4: Rodar o build
echo "🏹 Disparando Build Final SukunaOS..."
sudo lb build
