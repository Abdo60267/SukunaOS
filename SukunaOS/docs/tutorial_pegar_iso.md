# 📥 Tutorial: Como pegar a ISO do SukunaOS para compartilhar

## ⚡ Opção 1: SUPER FÁCIL (GitHub Actions - Recomendado!)

Se você tem o projeto no GitHub, é LITERALMENTE clicar e baixar:

### Passo 1: Entra no seu repositório GitHub
- Abra: `https://github.com/SEU_USER/SukunaOS`
- Clique em **Actions** (no menu superior)

### Passo 2: Clica em "Build SukunaOS ISO"
- Vê uma lista de workflows
- Procura por **"Build SukunaOS ISO"**
- Clica nele

### Passo 3: Clica em "Run workflow"
- Botão verde no lado direito
- Escolha a branch `main` (já vem selecionada)
- Clica **"Run workflow"**

### Passo 4: Aguarda 15-20 minutos
- Aparece uma bolinha girando ⏳
- Quando ficar verde ✅, tá pronto

### Passo 5: Baixa a ISO
- Clica no workflow que ficou verde
- Abra a seção **"Artifacts"** (lá em cima)
- Clica em **"sukunaos-iso"**
- Baixa o arquivo `.iso`

**Pronto! Você tem a ISO!** 🎉

---

## 💻 Opção 2: No seu PC com Docker (um pouco mais técnico)

Se tiver **Docker Desktop** instalado:

### Passo 1: Abre o PowerShell
- `Win + X` → PowerShell
- Ou CMD mesmo

### Passo 2: Cola esse comando:
```powershell
cd C:\Users\Abdul\Desktop\SukunaOS
docker run --privileged -v ${PWD}:/workspace debian:bookworm bash -c "apt update && apt install -y live-build squashfs-tools xorriso debootstrap rsync && bash /workspace/scripts/build_iso.sh"
```

### Passo 3: Aperta Enter
- Vai dar um monte de mensagens
- Deixa rodando (leva ~20-30 min)

### Passo 4: Encontra a ISO
- Quando terminar, abre o File Explorer
- Vai em: `C:\Users\Abdul\Desktop\SukunaOS\live`
- Vê o arquivo `sukunaos.iso` (uns 1.5GB)

**Pronto! A ISO tá lá!** 🎉

---

## 📤 Passo 5: Compartilha no Discord

### Se a ISO é pequena (< 100MB):
1. Discord → seu servidor
2. Clica no ícone **+** (anexar arquivo)
3. Procura `sukunaos.iso`
4. Envia

### Se a ISO é grande (1-2GB):
**Opção A: Upload em um site**
- Vai em [files.fm](https://files.fm) ou [transfer.sh](https://transfer.sh)
- Arrasta a ISO para lá
- Copia o link
- Cola no Discord

**Opção B: Compartilha via Google Drive**
1. Abre Google Drive
2. Clica **"+ Novo"** → **"Upload de arquivo"**
3. Procura `sukunaos.iso`
4. Quando terminar, **clica direito** → **"Compartilhar"**
5. Muda para **"Qualquer um com o link"**
6. Copia o link
7. Cola no Discord

**Opção C: Torrent (se muita gente quer)**
- Use [file2torrent.com](https://file2torrent.com)
- Faz upload da ISO
- Recebe um arquivo `.torrent`
- Compartilha no Discord

---

## 🤔 Qual escolher?

| Método | Dificuldade | Tempo | Recomendado para |
|--------|-------------|-------|------------------|
| **GitHub Actions** | ⭐ Muito fácil | 20 min | Iniciantes, melhor qualidade |
| **Docker** | ⭐⭐ Fácil | 30 min | Quem quer no PC |
| **Google Drive** | ⭐ Muito fácil | 5 min upload | Compartilhar 1 GB |
| **Files.fm** | ⭐ Muito fácil | 3 min upload | Upload temporário |

---

## ✅ Checklist final

- [ ] Gerou a ISO (GitHub Actions OU Docker)
- [ ] Encontrou o arquivo `sukunaos.iso`
- [ ] Compartilhou no Discord (Drive, Files.fm ou direto)
- [ ] Mandou o link para os amigos
- [ ] Pediu feedback no servidor 😄

---

## 🆘 Se deu erro?

**"Docker não instalado"**
- Baixa em: https://www.docker.com/products/docker-desktop

**"GitHub não deixa rodar Actions"**
- Settings → Actions → Reativa "Actions"

**"ISO muito grande pra enviar"**
- Use Google Drive ou Files.fm

**"Não acha o arquivo .iso"**
- Abre o File Explorer
- Cola esse caminho: `C:\Users\Abdul\Desktop\SukunaOS\live`
- Procura por arquivo com ícone de disco

---

## 💡 Dica: Versione a ISO no Discord

Coloca uma descrição assim:

```
📦 SukunaOS ISO - Data: [data de hoje]
🔧 Build: Live+Installer POC
📏 Tamanho: 1.5 GB
🎮 Para: VirtualBox, Hyper-V, USB
🚀 Como usar: https://github.com/SEU_USER/SukunaOS/blob/main/docs/iso_build_guide.md
```

Pronto! 🎉
