#!/usr/bin/env bash
set -euo pipefail

# SukunaOS Dev Kit Installer - Ubuntu 24.04 LTS Edition
# Instala toolchains e SDKs completos

echo "🔴 ════════════════════════════════════════════════════════"
echo "🔴 SUKUNA DEV KIT INSTALLER - UBUNTU 24.04 LTS"
echo "🔴 ════════════════════════════════════════════════════════"
echo ""

if [ "$EUID" -ne 0 ]; then
  echo "❌ Execute como root: sudo $0"
  exit 1
fi

# Update package lists
echo "🔴 Atualizando repositórios APT..."
apt update
apt upgrade -y

# Core dependencies
DEPS=(
    build-essential git cmake ninja-build pkg-config
    curl wget unzip zip tar
    python3 python3-venv python3-pip python3-dev
    openjdk-17-jdk maven gradle
    docker.io docker-compose
    git-lfs imagemagick
    libssl-dev libffi-dev zlib1g-dev
    libbz2-dev libreadline-dev libsqlite3-dev
)

echo "🔴 Instalando pacotes base..."
apt install -y "${DEPS[@]}"

# Rust (via rustup)
if ! command -v rustc >/dev/null 2>&1; then
  echo "🔴 Instalando Rust (via rustup)..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
  export PATH="$PATH:$HOME/.cargo/bin"
  rustup component add clippy rustfmt
  echo "✅ Rust instalado"
else
  echo "✅ Rust já instalado"
fi

# Go
if ! command -v go >/dev/null 2>&1; then
  echo "🔴 Instalando Go 1.22..."
  GO_VER="1.22.3"
  wget -q https://go.dev/dl/go${GO_VER}.linux-amd64.tar.gz -O /tmp/go.tar.gz
  rm -rf /usr/local/go
  tar -C /usr/local -xzf /tmp/go.tar.gz
  echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile.d/go.sh
  source /etc/profile.d/go.sh
  rm /tmp/go.tar.gz
  echo "✅ Go instalado"
else
  echo "✅ Go já instalado"
fi

# Node.js LTS (via NodeSource)
if ! command -v node >/dev/null 2>&1; then
  echo "🔴 Instalando Node.js LTS..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
  apt install -y nodejs
  npm install -g npm @yarn/yarn pnpm
  echo "✅ Node.js instalado"
else
  echo "✅ Node.js já instalado"
fi

# .NET SDK (Microsoft official)
if ! command -v dotnet >/dev/null 2>&1; then
  echo "🔴 Instalando .NET SDK..."
  wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
  dpkg -i /tmp/packages-microsoft-prod.deb || true
  apt update
  apt install -y dotnet-sdk-8.0 dotnet-runtime-8.0
  rm /tmp/packages-microsoft-prod.deb
  echo "✅ .NET instalado"
else
  echo "✅ .NET já instalado"
fi

# C# / Mono support
echo "🔴 Instalando Mono (C# alternativo)..."
apt install -y mono-devel mono-complete

# Lua
echo "🔴 Instalando Lua..."
apt install -y lua5.4 lua5.4-dev luarocks

# Ruby (opcional, popular)
echo "🔴 Instalando Ruby..."
apt install -y ruby ruby-dev ruby-bundler

# PHP (opcional)
echo "🔴 Instalando PHP..."
apt install -y php php-cli php-dev php-composer

# Development tools
echo "🔴 Instalando ferramentas de desenvolvimento..."
apt install -y \
    vim nano emacs \
    htop btop tmux screen \
    git-flow gitk meld \
    valgrind gdb lldb \
    clang clang-tools \
    llvm llvm-dev \
    sqlitebrowser postgresql postgresql-contrib \
    redis-server \
    doxygen graphviz

# Create Sukuna Dev Kit profile
cat > /etc/profile.d/sukuna-devkit.sh << 'EOF'
# SukunaOS Dev Kit Environment
export SUKUNA_DEVKIT_HOME="/opt/sukuna/devkit"
export SUKUNA_SDK_PATH="/opt/sukuna/sdk"

# Add all toolchains to PATH
export PATH="$PATH:/usr/local/go/bin:$HOME/.cargo/bin:/opt/sukuna/bin"

# Development mode
export SUKUNA_DEV_MODE=1

# Python venv helper
sukuna-venv() {
    python3 -m venv "$1" || python3.11 -m venv "$1"
    source "$1/bin/activate"
}

# Build helper
sukuna-build() {
    if [ -f "CMakeLists.txt" ]; then
        cmake -B build -DCMAKE_BUILD_TYPE=Release . && cmake --build build --config Release
    elif [ -f "Makefile" ]; then
        make
    elif [ -f "cargo.toml" ]; then
        cargo build --release
    elif [ -f "go.mod" ]; then
        go build ./...
    else
        echo "Unknown build system"
        return 1
    fi
}

alias ll='ls -la'
alias grep='grep --color=auto'
EOF

chmod +x /etc/profile.d/sukuna-devkit.sh

# Create SDK directory structure
mkdir -p /opt/sukuna/{bin,sdk,devkit,lib}

# Summary
echo ""
echo "🔴 ════════════════════════════════════════════════════════"
echo "✅ SUKUNA DEV KIT INSTALLATION COMPLETE!"
echo "🔴 ════════════════════════════════════════════════════════"
echo ""
echo "📦 Installed Toolchains:"
echo "   ✅ C/C++        (GCC, Clang, CMake)"
echo "   ✅ Python       (3.12, pip, venv)"
echo "   ✅ Rust         (Latest stable)"
echo "   ✅ Go           (1.22)"
echo "   ✅ Node.js      (LTS + npm/yarn/pnpm)"
echo "   ✅ Java         (OpenJDK 17 + Maven)"
echo "   ✅ C#/.NET      (SDK 8.0)"
echo "   ✅ Lua          (5.4 + luarocks)"
echo "   ✅ Ruby         (Latest)"
echo "   ✅ PHP          (Latest + Composer)"
echo ""
echo "🛠️  Additional Tools:"
echo "   ✅ Docker       (containers)"
echo "   ✅ Git LFS      (large files)"
echo "   ✅ Debuggers    (GDB, LLDB, Valgrind)"
echo "   ✅ Databases    (PostgreSQL, SQLite, Redis)"
echo "   ✅ Build tools  (Make, CMake, Ninja, Doxygen)"
echo ""
echo "🔴 Next Steps:"
echo "   1. Log out and back in to refresh environment"
echo "   2. Test: 'rustc --version', 'go version', 'node -v'"
echo "   3. Create venv: 'sukuna-venv myproject'"
echo "   4. Start building! 🚀"
echo ""
echo "📖 Documentation: /opt/sukuna/devkit/"
echo "🔴 Happy cursing! 🔴"
