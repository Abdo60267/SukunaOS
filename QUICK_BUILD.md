# 🚀 BUILD ISO - 3 PASSOS SUPER SIMPLES

## ⚡ Modo Automático (RECOMENDADO)

### Passo 1: Abre PowerShell aqui
- `Win + X` → PowerShell ou CMD
- Ou dentro do VS Code: `Ctrl + ~`

### Passo 2: Cola isso:
```powershell
cd C:\Users\Abdul\Desktop\SukunaOS
.\build_iso_auto.bat
```

### Passo 3: Aguarda 20-30 minutos

Pronto! O GitHub vai:
1. ✅ Fazer commit automático
2. ✅ Fazer push
3. ✅ Gerar a ISO
4. ✅ Deixar pronta para baixar

---

## 📥 Como baixar quando estiver pronto?

1. Vai em: https://github.com/SEU_USER/SukunaOS
2. Clica em **Actions** (lá em cima)
3. Procura **"Build SukunaOS ISO"** (o mais recente)
4. Se tiver verde ✅, entra nele
5. Desce até **"Artifacts"**
6. Clica em **"sukunaos-iso"**
7. Download!

---

## 🤔 E se der erro?

**"Git não reconhecido"**
```powershell
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

**"Não acha o arquivo .bat"**
- Abre File Explorer
- Vai em: `C:\Users\Abdul\Desktop\SukunaOS`
- Procura `build_iso_auto.bat`
- Clica 2x

**"GitHub Actions não roda"**
- Settings do seu repositório
- Vai em "Actions"
- Clica "Enable GitHub Actions"

---

## 💡 Resumo

```
1. Abre PowerShell
2. cd C:\Users\Abdul\Desktop\SukunaOS
3. .\build_iso_auto.bat
4. Espera 20 min
5. Baixa em GitHub → Actions → Artifacts
6. Pronto!
```

---

## 🎁 Alternativa: Se quiser rodar tudo localmente

Se tiver **Docker Desktop**:

```powershell
cd C:\Users\Abdul\Desktop\SukunaOS
docker run --privileged -v ${PWD}:/workspace debian:bookworm bash -c "apt update && apt install -y live-build squashfs-tools xorriso debootstrap rsync && bash /workspace/scripts/build_iso.sh"
```

Demora uns 30 min, mas faz tudo offline.

---

**Qual você quer? GitHub Actions (nuvem) ou Docker (seu PC)? 🤔**
