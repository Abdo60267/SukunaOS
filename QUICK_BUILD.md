# 🔴 BUILD ISO SUKUNAOS - UBUNTU 24.04 LTS 🔴

## ✅ Antes de Começar - IMPORTANTE

### Passo 0: Validar Ambiente
```bash
cd SukunaOS
bash scripts/validate_build.sh   # Valida tudo antes de compilar
```

**⚠️ ATENÇÃO**: Se validação falhar, instale dependências:
```bash
sudo apt update
sudo apt install -y \
  live-build squashfs-tools xorriso \
  debootstrap rsync ubuntu-archive-keyring \
  live-config git make gettext \
  grub-common grub2-common grub-efi-amd64 \
  grub-efi-amd64-bin efibootmgr
```

---

## 🌐 Modo Automático com GitHub Actions (RECOMENDADO)

### Passo 1: Configure o Git
```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

### Passo 2: Push para GitHub
```bash
cd SukunaOS
git add -A
git commit -m "🔴 Build trigger"
git push origin main
```

### Passo 3: Acompanhe o Build
1. Vai em: https://github.com/SEU_USER/SukunaOS
2. Clica em **Actions** (lá em cima)
3. Procura **"Build SukunaOS ISO"** (mais recente)
4. Acompanha o progresso ✅
5. Se tiver ✅ verde → Artifact pronto!

### Passo 4: Download
1. Entra na workflow que passou
2. Desce até **"Artifacts"**
3. Clica em **"sukunaos-iso"** → Download
4. Você tem a ISO! 🎉

**Tempo**: ~30-40 minutos no GitHub  
**Vantagem**: Não usa seu PC

---

## 🖥️ Modo Local com Build Script

### Passo 1: Validar Ambiente
```bash
cd SukunaOS
bash scripts/validate_build.sh
```

### Passo 2: Executar Build
```bash
bash scripts/build_iso.sh
```

**Outputs**:
- `live-build/live-image-amd64.iso` → ISO final ✅
- `live-build/config_output.log` → Log de config
- `live-build/build_output.log` → Log de build

**Tempo**: 30-40 minutos (varia com internet)  
**Espaço**: Precisa de ~5-8 GB livre

---

## 🐳 Modo Local com Docker (Se não tiver live-build)

Se não conseguir instalar live-build:

```bash
docker run --privileged \
  -v ${PWD}:/workspace \
  ubuntu:24.04 \
  bash -c "
    apt update && \
    apt install -y live-build squashfs-tools xorriso debootstrap rsync ubuntu-archive-keyring live-config && \
    cd /workspace && \
    bash scripts/build_iso.sh
  "
```

**Requisito**: Docker Desktop instalado  
**Tempo**: 40-50 minutos

---

## 💾 Flash para USB

Depois de ter a ISO: `live-image-amd64.iso`

### Windows (PowerShell)
```powershell
# Use ferramentas gráficas (mais seguro):
# 1. Rufus: https://rufus.ie/
# 2. Balena Etcher: https://www.balena.io/etcher/
# 3. Ventoy: https://www.ventoy.net/
```

### Linux/Mac
```bash
# 1. Identifique o device
lsblk

# 2. Flash (ATENÇÃO: Verifique /dev/sdX correto!)
sudo dd if=live-image-amd64.iso of=/dev/sdX bs=4M && sync

# 3. Ou use Etcher (recomendado)
# https://www.balena.io/etcher/
```

**⚠️ AVISO**: `dd` sobrescreve o device! Verifique 2x antes de executar!

---

## 🧪 Teste em VM

### VirtualBox
```
Configuração recomendada:
  • RAM: 4 GB mínimo
  • Disk: 30 GB (dinâmico)
  • Boot: UEFI + Legacy BIOS hybrid
  • Network: NAT ou Bridge
```

### QEMU
```bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 4096 \
  -smp 4 \
  -cdrom live-image-amd64.iso \
  -drive file=disk.img,format=qcow2 \
  -net nic,model=virtio \
  -net user
```

---

## 🐛 Troubleshooting

### "lb: command not found"
```bash
sudo apt install live-build
```

### "ISO não encontrada"
```bash
# Procurar ISO
find . -name "*.iso" -o -name "live-image*"

# Se estiver em outro lugar:
ls -la live-build/
ls -la ./
```

### "Espaço insuficiente"
```bash
# Limpar cache
sudo apt clean
rm -rf live-build

# Verificar espaço
df -h
# Precisa de ~5 GB livre
```

### "GitHub Actions falha"
- Verifique log em **Actions → Workflow → Job**
- Erros comuns:
  - ❌ `ubuntu-archive-keyring` não encontrado → Adicionar à apt install
  - ❌ `lb: command not found` → live-build não foi instalado
  - ❌ Permission denied → Usar `sudo`

### "Build freezes/demora muito"
```bash
# Verificar progresso
tail -f live-build/build_output.log

# Se realmente está travado (30+ min sem atividade):
Ctrl+C para cancelar
rm -rf live-build
bash scripts/build_iso.sh  # Tentar novamente
```

---

## 📊 Especificações da ISO

| Aspecto | Valor |
|---------|-------|
| **Base OS** | Ubuntu 24.04 LTS (Noble) |
| **Kernel** | linux-image-generic |
| **Desktop** | GNOME Shell + Flashback |
| **Boot** | UEFI + BIOS hybrid |
| **Tamanho** | ~2-3 GB (ISO) |
| **Tema** | Carmesim + Mac-inspired |
| **Persistência** | Suportada |

---

## ✅ Checklist de Build

- [ ] Dependências instaladas (`validate_build.sh` passou)
- [ ] ISO criada (`live-image-amd64.iso` existe)
- [ ] Tamanho > 1 GB (não vazio)
- [ ] Boot testa em VM ou hardware
- [ ] Tema visual carrega (carmesim)
- [ ] Installer GUI aparece
- [ ] Network funciona no live
- [ ] Dev Kit instala corretamente

---

## 📚 Próximos Passos

### Se build OK:
1. ✅ Flash para USB
2. ✅ Boot em hardware
3. ✅ Teste installer
4. ✅ Instale Dev Kit

### Se build falhar:
1. ✅ Rode `validate_build.sh`
2. ✅ Verifique logs
3. ✅ Instale packages faltando
4. ✅ Tente novamente

---

## 🔴 Resumo Rápido

```bash
# 1. Validar
bash scripts/validate_build.sh

# 2. Build (escolha uma opção)
bash scripts/build_iso.sh              # Local (Ubuntu/Debian)
# OU
docker run --privileged ... (veja acima)  # Docker
# OU
git push → GitHub Actions             # GitHub (fácil)

# 3. Resultado
# live-image-amd64.iso

# 4. Flash
sudo dd if=live-image-amd64.iso of=/dev/sdX bs=4M

# 5. Boot!
```

---

**Última atualização**: 2026-06-19  
**Status**: ✅ Fully tested and corrected  
**Base**: Ubuntu 24.04 LTS


