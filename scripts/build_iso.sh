#!/bin/bash
set -e

# Limpar vestígios de maldições passadas
sudo lb clean --purge || true
rm -rf live-build
mkdir -p live-build && cd live-build

# PASSO 1: lb config - Sem frescuras, focado apenas no Debian 12
lb config \
    --binary-images iso-hybrid \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --security false

# PASSO 2: Injetar repositórios corretos SEM DUPLICIDADE
mkdir -p config/archives
cat << 'EOT' > config/archives/sukuna.list.chroot
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOT

cp config/archives/sukuna.list.chroot config/archives/sukuna.list.binary

# PASSO 3: Certificar que o ubuntu-keyring NÃO existe em listas geradas agora
if [ -d config/package-lists ]; then
    find config/package-lists/ -type f -exec sed -i 's/ubuntu-keyring//g' {} + || true
fi

# PASSO 4: Iniciar build
echo "👺 Domínio Malevolente: Iniciando criação da ISO..."
sudo lb build
