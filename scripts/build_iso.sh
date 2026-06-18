#!/bin/bash
set -e

# Limpeza total
sudo lb clean --purge || true
mkdir -p live-build && cd live-build

# PASSO 1: Configuração Básica (Desativamos o --security automático para evitar o erro do Ubuntu)
lb config \
    --binary-images iso-hybrid \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --security false

# PASSO 2: Criar manualmente o arquivo de repositórios (Source List)
# Isso garante que ele NUNCA tente usar o repositório da Ubuntu
mkdir -p config/archives
cat << 'EOT' > config/archives/sukuna_repos.list.chroot
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOT

# Também para a ISO final
cp config/archives/sukuna_repos.list.chroot config/archives/sukuna_repos.list.binary

# PASSO 3: Rodar o build
echo "🏹 Disparando Build Final com repositórios corrigidos..."
sudo lb build
