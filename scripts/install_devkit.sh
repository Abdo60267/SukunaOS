#!/usr/bin/env bash
set -euo pipefail

# scripts/install_devkit.sh
# Instala toolchains e SDKs para Sukuna Dev Kit (Debian/Ubuntu/Kali based)

echo "Starting Sukuna Dev Kit installer..."

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo $0"
  exit 1
fi

apt update
DEPS=(build-essential git cmake ninja-build pkg-config curl wget unzip python3 python3-venv python3-pip openjdk-17-jdk maven docker.io)
echo "Installing apt packages: ${DEPS[*]}"
apt install -y "${DEPS[@]}"

# Install Rust via rustup for root or suggest for users
if ! command -v rustc >/dev/null 2>&1; then
  echo "Installing rustup (system-wide via curl)..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  export PATH="$PATH:$HOME/.cargo/bin"
fi

# Install Go
if ! command -v go >/dev/null 2>&1; then
  echo "Installing Go..."
  GO_VER="1.20.7"
  wget -q https://golang.org/dl/go${GO_VER}.linux-amd64.tar.gz -O /tmp/go.tar.gz
  tar -C /usr/local -xzf /tmp/go.tar.gz
  echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile.d/go.sh
fi

# Install Node.js (LTS) via NodeSource
if ! command -v node >/dev/null 2>&1; then
  echo "Installing Node.js LTS..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
  apt install -y nodejs
fi

# Install .NET SDK (Microsoft packages)
if ! command -v dotnet >/dev/null 2>&1; then
  echo "Installing .NET SDK..."
  wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
  dpkg -i /tmp/packages-microsoft-prod.deb || true
  apt update
  apt install -y dotnet-sdk-7.0
fi

echo "Sukuna Dev Kit installer finished. Please log out/in to refresh environment variables."
