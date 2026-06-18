#!/bin/bash
set -e

# 1. Limpeza Radical
lb clean --purge || true
rm -rf live-build config local chroot
mkdir -p live-build && cd live-build

# 2. lb config - MODO DEBIAN FORÇADO
# A flag --mode debian é o segredo para ele não procurar ubuntu-keyring
lb config \
    --mode debian \
    --binary-images iso-hybrid \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --security false \
    --apt-recommends false

# 3. Criar repositórios do Debian 12 sem erros de 404
mkdir -p config/archives
cat << 'EOT' > config/archives/sukuna.list.chroot
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOT
cp config/archives/sukuna.list.chroot config/archives/sukuna.list.binary

# 4. Criar lista básica de pacotes (evita conflitos de dependências)
mkdir -p config/package-lists
cat << 'EOT' > config/package-lists/sukuna.list.chroot
linux-image-amd64
live-boot
live-config
live-config-systemd
systemd-sysv
EOT

# 5. Executar o build direto
echo "🏹 Invocando Domínio: Criando a ISO..."
lb build
