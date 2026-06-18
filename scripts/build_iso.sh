#!/bin/bash
set -e

# 1. LIMPEZA TOTAL (Purger todas as maldições anteriores)
lb clean --purge || true
rm -rf live-build config local
mkdir -p live-build && cd live-build

# 2. CONFIGURAÇÃO MESTRE (Focada 100% em Debian Puro)
# Usamos o mirror oficial e desativamos pacotes recomendados que puxam lixo
lb config \
    --binary-images iso-hybrid \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --apt-recommends false \
    --security false

# 3. CONSTRUÇÃO MANUAL DOS REPOSITÓRIOS (Sem duplicidade)
# Criamos a pasta e o arquivo do ZERO para evitar o erro de "multiple times"
mkdir -p config/archives
cat << 'EOT' > config/archives/sukuna.list.chroot
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOT

# Copiamos para o ambiente binário também
cp config/archives/sukuna.list.chroot config/archives/sukuna.list.binary

# 4. EXTERMÍNIO DO UBUNTU-KEYRING
# Se houver qualquer lista de pacotes pedindo o chaveiro do ubuntu, nós deletamos a linha
if [ -d config/package-lists ]; then
    find config/package-lists/ -type f -exec sed -i '/ubuntu-keyring/d' {} + || true
fi

# 5. LISTA DE PACOTES BÁSICA DO SUKUNAOS
# Vamos definir os pacotes essenciais aqui para garantir que o build não puxe nada estranho
mkdir -p config/package-lists
echo "linux-image-amd64 live-boot live-config live-config-systemd systemd-sysv iproute2 curl" > config/package-lists/core.list.chroot

# 6. INICIAR EXPANSÃO DE DOMÍNIO (Build)
echo "⛩️ Iniciando Build da ISO SukunaOS (Fase 1)..."
lb build
