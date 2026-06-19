# 🔴 SukunaOS Build Scripts 🔴

Utilitários para construir, instalar e configurar SukunaOS baseado em Ubuntu 24.04 LTS.

## 📋 Scripts Disponíveis

### `build_iso.sh` - Build da ISO Live (Ubuntu)
**Propósito**: Criar a ISO bootável do SukunaOS

```bash
cd SukunaOS
bash scripts/build_iso.sh
```

**Requisitos**:
- live-build
- squashfs-tools
- xorriso
- debootstrap
- rsync

**Saída**: `live-build/live-image-amd64.iso` (~2-3 GB)

**Tempo**: 30-40 minutos

---

### `install_devkit.sh` - Instalar Sukuna Dev Kit
**Propósito**: Instalar toda a suite de development tools

```bash
sudo bash scripts/install_devkit.sh
```

**Instala**:
- ✅ C/C++: GCC, Clang, CMake, Ninja
- ✅ Python: Python 3.12, pip, venv
- ✅ Rust: Latest stable + clippy + rustfmt
- ✅ Go: 1.22
- ✅ Node.js: LTS + npm + yarn + pnpm
- ✅ Java: OpenJDK 17 + Maven + Gradle
- ✅ C#/.NET: SDK 8.0
- ✅ Lua: 5.4 + luarocks
- ✅ Ruby: Latest + bundler
- ✅ PHP: Latest + Composer
- ✅ Docker: docker + docker-compose
- ✅ Databases: PostgreSQL, SQLite, Redis
- ✅ Debuggers: GDB, LLDB, Valgrind
- ✅ Build tools: Make, CMake, Ninja, Doxygen

**Tempo**: 15-30 minutos (varia com velocidade de internet)

---

### `create_persistent_usb.sh` - Criar USB Persistente
**Propósito**: Criar mídia USB bootável com persistência de dados

```bash
sudo bash scripts/create_persistent_usb.sh /dev/sdX
```

**⚠️ ATENÇÃO**: Substitua `/dev/sdX` pelo device correto!

```bash
# Listar devices
lsblk

# Exemplo: /dev/sdb (não /dev/sdb1!)
sudo bash scripts/create_persistent_usb.sh /dev/sdb
```

**Requisitos**:
- USB drive > 4 GB
- Sem dados importantes (será formatado!)
- Plugin USB com permissão de escrita

**Saída**: USB bootável com 50% espaço live + 50% persistente

---

### `install_grub_theme.sh` - Instalar Tema GRUB Sukuna
**Propósito**: Aplicar tema visual Sukuna Crimson ao GRUB bootloader

```bash
sudo bash scripts/install_grub_theme.sh
```

**Instalações**:
- Copia assets de imagem (background crimson)
- Cria theme.txt personalizado
- Atualiza `/etc/default/grub`
- Regenera configuração GRUB

**Visível em**: Próxima inicialização (GRUB menu)

---

### `setup_dev_workspace.sh` - Setup Workspace de Desenvolvimento
**Propósito**: Preparar ambiente de dev local com SukunaOS

```bash
bash scripts/setup_dev_workspace.sh
```

**Configura**:
- Git configuration
- SSH keys setup
- Python venvs
- Docker daemon
- IDE integrations

---

### `build_kernel.sh` - Build Kernel Customizado (Futuro)
**Propósito**: Compilar linux-sukuna kernel customizado

```bash
bash scripts/build_kernel.sh
```

**Status**: Em desenvolvimento (Sprint 1.5)

---

### `apply_patches.sh` - Aplicar Patches ao Sistema
**Propósito**: Aplicar patches de segurança e features

```bash
bash scripts/apply_patches.sh [patch-file]
```

---

## 🚀 Quick Start

### Build ISO + Boot
```bash
# 1. Build ISO
cd SukunaOS
bash scripts/build_iso.sh

# 2. Flash para USB (Linux/Mac)
sudo dd if=live-build/live-image-amd64.iso of=/dev/sdX bs=4M

# 3. Boot do USB
# Reinicie máquina, selecione USB no boot menu
```

### Instalar Devkit
```bash
# Em qualquer máquina Ubuntu/Debian
sudo bash scripts/install_devkit.sh

# Depois
source /etc/profile.d/sukuna-devkit.sh
sukuna-venv myproject
```

### Setup Local Development
```bash
# Clone repo
git clone https://github.com/seu-user/SukunaOS.git
cd SukunaOS

# Setup workspace
bash scripts/setup_dev_workspace.sh

# Install devkit
sudo bash scripts/install_devkit.sh

# Pronto!
```

---

## 🔧 Configurações Importantes

### Build ISO
**Arquivo**: `live/config/auto/config`

```sh
# Base: Ubuntu 24.04 LTS (noble)
# Arquitetura: amd64
# Mirrors: archive.ubuntu.com
# Boot options: live, persistence, persistence-encryption=none
```

**Pacotes**: `live/config/package-lists/sukuna.list.chroot`

---

### Devkit
**Arquivo**: `/etc/profile.d/sukuna-devkit.sh` (criado por install_devkit.sh)

```bash
# Helpers disponíveis:
sukuna-venv <nome>        # Criar venv Python
sukuna-build              # Auto-detect e fazer build
sukuna-docker             # Docker helpers (futuro)
```

---

## 🐛 Troubleshooting

### ISO Build falha
```bash
# Limpar e reconstruir
rm -rf live-build
bash scripts/build_iso.sh
```

### Sem permissão em device USB
```bash
# Verificar ownership
ls -l /dev/sdX

# Adicionar user ao grupo disk
sudo usermod -aG disk $USER
# Depois logout/login
```

### Debootstrap timed out
```bash
# Usar mirror diferente
export SUKUNA_BOOTSTRAP_MIRROR="http://mirrors.aliyun.com/ubuntu"
bash scripts/install_devkit.sh
```

### GRUB theme não aparece
```bash
# Update GRUB manualmente
sudo update-grub
sudo reboot
```

---

## 📊 Tempo Estimado

| Script | Tempo | CPU | Rede |
|--------|-------|-----|------|
| `build_iso.sh` | 30-40 min | Alto | Alto |
| `install_devkit.sh` | 15-30 min | Médio | Alto |
| `create_persistent_usb.sh` | 5-10 min | Baixo | Não |
| `install_grub_theme.sh` | <1 min | Muito baixo | Não |
| `setup_dev_workspace.sh` | 5 min | Baixo | Baixo |

---

## 🔴 Automação (GitHub Actions)

Veja `.github/workflows/build-iso.yml` para CI/CD automático:

```yaml
# Gatilho: Push para main
# Saída: Artifact "sukunaos-iso" com ISO pronta
```

---

## 📚 Documentação Relacionada

- `README.md` - Overview geral
- `QUICK_BUILD.md` - Build rápido (para Windows users)
- `docs/visual_identity_macos_carmesim.md` - Tema visual
- `docs/iso_build_guide.md` - Guia detalhado
- `README_KERNEL.md` - Build do kernel

---

## 🤝 Contribuir

Para adicionar novo script:

1. Coloque em `scripts/`
2. Adicione sheban: `#!/usr/bin/env bash`
3. Set permissions: `chmod +x scripts/seu-script.sh`
4. Documente em `scripts/README.md`
5. Teste em Ubuntu 24.04 LTS
6. Submit PR

---

**Versão**: 1.0  
**Última atualização**: June 2026  
**Mantido por**: SukunaOS Team 🔴
