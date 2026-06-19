# 🔴 BUILD ISO SUKUNAOS - UBUNTU 24.04 LTS 🔴

## Modo Automático com GitHub Actions (RECOMENDADO)

### Passo 1: Configure o Git
```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

### Passo 2: Execute no terminal
```bash
cd C:\Users\Abdul\Desktop\SukunaOS
.\build_iso_auto.bat
```

### Passo 3: Aguarde 20-40 minutos
O GitHub Actions irá:
1. ✅ Fazer commit automático
2. ✅ Fazer push
3. ✅ Gerar a ISO (Ubuntu 24.04 LTS)
4. ✅ Deixar pronta para download

### Download da ISO
1. Vai em: https://github.com/SEU_USER/SukunaOS
2. Clica em **Actions** (lá em cima)
3. Procura **"Build SukunaOS ISO"** (mais recente)
4. Se tiver ✅ verde, entra nele
5. Desce até **"Artifacts"**
6. Clica em **"sukunaos-iso"** → Download

---

## 🐧 Modo Local com Docker (Alternativa)

Se tiver **Docker Desktop** instalado:

```bash
cd C:\Users\Abdul\Desktop\SukunaOS

docker run --privileged \
  -v ${PWD}:/workspace \
  ubuntu:24.04 \
  bash -c "apt update && apt install -y live-build squashfs-tools xorriso debootstrap rsync && bash /workspace/scripts/build_iso.sh"
```

**Tempo**: ~30-40 minutos  
**Espaço disco**: ~5-8 GB

---

## 🖥️ Modo Local Nativo (Ubuntu/Debian)

Se estiver rodando em Ubuntu/Debian nativo:

```bash
cd SukunaOS

# Instalar dependências
sudo apt update
sudo apt install -y live-build squashfs-tools xorriso debootstrap rsync

# Executar build
bash scripts/build_iso.sh
```

**Resultado**: `live-build/live-image-amd64.iso`

---

## 💾 Flash para USB

Depois de ter a ISO:

### Windows (PowerShell)
```powershell
# Encontre seu USB em Device Manager (ex: \\.\PHYSICALDRIVE1)
$IsoPath = "C:\path\to\sukunaos-iso.iso"
$UsbDrive = "\\.\PHYSICALDRIVE1"  # ATENÇÃO: Verifique o número correto!

# Use Rufus, Etcher ou:
dd.exe if=$IsoPath of=$UsbDrive bs=4M
```

### Linux/Mac
```bash
# Identifique o device
lsblk

# Flash (ATENÇÃO: Verifique /dev/sdX)
sudo dd if=sukunaos-iso.iso of=/dev/sdX bs=4M && sync

# Ou use Etcher (recomendado)
# https://www.balena.io/etcher/
```

### Ferramentas Recomendadas
- **Ventoy** - Múltiplas ISOs em um USB
- **Rufus** - Windows, simples e rápido
- **Balena Etcher** - Multiplataforma
- **dd** - Linha de comando (Linux/Mac)

---

## 🧪 Teste em VM

### VirtualBox
```bash
VirtualBoxVM:
  - RAM: 4 GB mínimo
  - Disk: 30 GB (dinâmico)
  - Boot: UEFI + Legacy BIOS hybrid
  - Network: NAT ou Bridge
```

### QEMU
```bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 4096 \
  -smp 4 \
  -cdrom sukunaos-iso.iso \
  -drive file=disk.img,format=qcow2 \
  -net nic,model=virtio \
  -net user
```

### VMware
- ISO funciona nativamente
- Recomenda 4GB RAM, 30GB disk

---

## 🐛 Troubleshooting

### "Git não reconhecido"
```powershell
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

### "Arquivo .bat não encontrado"
- Certifique que está no diretório correto: `C:\Users\Abdul\Desktop\SukunaOS`
- Verifique se tem permissão de leitura

### "GitHub Actions não executa"
- Vá em Settings → Actions → Enable GitHub Actions
- Verifique se o repositório é público (ou actions está ativo)

### "Docker não encontrado"
- Instale Docker Desktop: https://www.docker.com/products/docker-desktop
- Reinicie após instalação
- Execute `docker --version` para confirmar

### "Erro ao fazer flash para USB"
- Verifique o device correto com `lsblk` ou Device Manager
- Certifique que o USB não está em uso
- Use ferramentas como Etcher (mais seguro)

### "ISO não inicia"
- Tente em UEFI mode primeiro
- Depois tente Legacy BIOS
- Verifique se o USB foi flashado corretamente

---

## 📊 Especificações da ISO

| Item | Valor |
|------|-------|
| **Base OS** | Ubuntu 24.04 LTS (Noble Numbat) |
| **Kernel** | linux-image-generic |
| **DE** | GNOME Shell + Flashback |
| **Instalador** | Python + PySide6 (GUI) |
| **Tema** | SukunaOS Crimson + macOS inspired |
| **Tamanho** | ~2-3 GB (live ISO) |
| **Boot** | UEFI + BIOS hybrid |
| **Format** | ISO 9660 Hybrid |

---

## 🎯 Próximos Passos

1. **Build**: Execute o script acima
2. **Flash**: Gravar em USB
3. **Boot**: Reinicie com USB
4. **Installer**: Siga o instalador gráfico
5. **Setup**: Configure usuário e partições
6. **Pronto**: SukunaOS rodando! 🔴

---

## 📚 Documentação Completa

- **README.md** - Overview geral
- **docs/visual_identity_macos_carmesim.md** - Tema & cores
- **README_KERNEL.md** - Build de kernel customizado
- **docs/iso_build_guide.md** - Guia detalhado de build

---

## 🔴 Status

- **Base**: Ubuntu 24.04 LTS ✅
- **Tema Visual**: Mac Carmesim ✅
- **Installer GUI**: Python/PySide6 ✅
- **Store POC**: Flask backend ✅
- **Security**: LSM templates ✅

**Pronto para build e teste!** 🔴

---

**Last updated**: June 2026  
**Maintainer**: SukunaOS Team 🔴

