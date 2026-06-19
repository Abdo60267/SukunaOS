#!/bin/bash
set -e

# Limpeza
lb clean --purge || true
rm -rf live-build
mkdir -p live-build && cd live-build

# Configuração Moderna para Debian 12
lb config \
    --mode debian \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --binary-images iso-hybrid \
    --linux-flavours amd64

# Pacotes essenciais do SukunaOS
mkdir -p config/package-lists
cat << 'EOT' > config/package-lists/sukuna.list.chroot
linux-image-amd64
live-boot
live-config
live-config-systemd
systemd-sysv
EOT

echo "👹 Iniciando Ritual de Criação: lb build"
lb build
