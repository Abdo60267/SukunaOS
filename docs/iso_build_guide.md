# Como gerar e usar a ISO do SukunaOS

## ⚡ Opção rápida para Windows: GitHub Actions

Se seu repositório está no GitHub:
1. Faça push das mudanças para `main`
2. Abra a aba **Actions** → **Build SukunaOS ISO**
3. Aguarde o build terminar (~15-20 min)
4. Baixe a ISO em **Artifacts** → `sukunaos-iso`

Sem precisar de Linux instalado localmente!

---

## Local Build - Windows com WSL2

### Pré-requisitos
- Windows 10/11 com WSL2 instalado
- Ubuntu 22.04+ no WSL2
- 20GB de espaço em disco livre

### Passo 1: Instalar WSL2
```powershell
# PowerShell como Admin
wsl --install
# Reinicie o computador
```

### Passo 2: No terminal WSL2
```bash
# Dentro do WSL2
sudo apt update
sudo apt install -y live-build squashfs-tools xorriso debootstrap rsync
cd /mnt/c/Users/Abdul/Desktop/SukunaOS
sudo bash scripts/build_iso.sh
```

A ISO será criada em: `live/sukunaos.iso` (~1.5-2GB)

---

## Local Build - Windows com Docker Desktop

### Pré-requisitos
- Docker Desktop instalado

### Build da ISO
```powershell
cd C:\Users\Abdul\Desktop\SukunaOS
docker run --privileged -v ${PWD}:/workspace debian:bookworm bash -c "
  cd /workspace
  apt update && apt install -y live-build squashfs-tools xorriso debootstrap rsync
  sudo bash scripts/build_iso.sh
"
```

---

## VM Linux Local

Se preferir isolar tudo, crie uma VM Linux (VirtualBox/Hyper-V/VMware) com:
- Debian/Ubuntu
- 4GB RAM, 40GB disco
- Clone o repositório dentro
- Execute: `sudo bash scripts/build_iso.sh`

---

#### VirtualBox
1. Crie uma nova VM com pelo menos 4GB RAM e 20GB disco.
2. Configure boot order para ISO.
3. Inicie e escolha "live" ou "live persistence" no menu de boot.
4. Para instalar no disco, execute: `python3 /opt/sukuna/src/sukuna_installer_gui.py`

#### QEMU/KVM
```bash
sudo qemu-system-x86_64 \
  -m 4096 \
  -hda /tmp/sukuna-test.img \
  -cdrom live/sukunaos.iso \
  -boot d
```

#### VMware
1. Crie nova VM.
2. Aponte para `live/sukunaos.iso`.
3. Inicie.

#### VirtualBox

Após gerar a ISO:

```bash
sudo bash scripts/create_persistent_usb.sh live/sukunaos.iso /dev/sdX
```

Substitua `/dev/sdX` pelo seu dispositivo USB (ex: `/dev/sdb`)

## Instalação no disco

### No live environment:
```bash
# Listar discos
sudo python3 /opt/sukuna/src/sukuna_installer_backend.py list-disks

# Iniciar instalador GUI
sudo python3 /opt/sukuna/src/sukuna_installer_gui.py
```

### Siga os passos do instalador:
1. Defina nome de usuário e senha
2. Escolha partição de destino
3. Confirme e aguarde a instalação
4. Reinicie

## Troubleshooting

### Live boot parado em dracut
- Adicione `debug` ao kernel: `boot=live components debug`

### Installer não encontra discos
- Verifique se rodou como `sudo`
- Tente manualmente: `lsblk`

### Sem saída gráfica
- Verifique VRAM da VM (mínimo 512MB)
- Adicione mais CPUs/RAM

## Status atual (POC)
- ✅ ISO bootável com live-build
- ✅ Instalador GUI em PySide6
- ✅ Backend de instalação básico
- ✅ Suporte a persistence
- ⚠️ MDE ainda é mockup/não integrado
- ⚠️ Drivers e temas em desenvolvimento
