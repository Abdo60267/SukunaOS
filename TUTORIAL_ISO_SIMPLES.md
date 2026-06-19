# 🔴 Como Montar a ISO do SukunaOS - Tutorial Simples

**Para qualquer pessoa com internet e paciência!** 😎

---

## 🎯 O que é ISO?

Pense em ISO como um **arquivo especial** que contém todo um sistema operacional dentro dele. É como uma cópia exata do Windows ou Ubuntu, mas em um único arquivo que você pode colocar em um pen drive.

---

## 📋 Você vai Precisar de:

1. **Um computador** (Windows, Mac ou Linux - qualquer um vale!)
2. **Internet** (para baixar os arquivos)
3. **Um pen drive** de 4 GB ou mais (vai ser apagado!)
4. **~15-40 minutos** de paciência
5. **Conhecimentos**: Saber clicar em botões 😄

---

## 🚀 Opção 1: Jeito MÁS FÁCIL (GitHub Actions) ⭐ RECOMENDADO

**Você NÃO precisa de nada no seu PC, o GitHub faz tudo!**

### Passo 1️⃣: Fazer Login no GitHub
1. Abra: https://github.com
2. Se não tem conta, crie uma (grátis!)
3. Faça login

### Passo 2️⃣: Ir para o Repositório
1. Acesse: https://github.com/Abdo60267/SukunaOS
2. Clique no botão verde **"Code"** (no topo à direita)

### Passo 3️⃣: Ativar o Build Automático
1. Clique na aba **"Actions"** (lá em cima, perto de "Pull requests")
2. Procure por **"Build SukunaOS ISO"**
3. Se não conseguir ativar, peça ajuda no repositório
4. Isso vai **compilar automaticamente** (15-40 minutos)

### Passo 4️⃣: Baixar a ISO
1. Aguarde terminar (você vê um ✅ verde quando acabar)
2. Entra novamente na workflow que passou
3. Desce até **"Artifacts"** (final da página)
4. Clica em **"sukunaos-iso"** 📥 **Download**
5. Parabéns! Você tem a ISO! 🎉

---

## 🖥️ Opção 2: Build no Seu PC (Um Pouco Mais Difícil)

**Use esta opção se**:
- Quiser fazer tudo no seu PC
- Tiver paciência com instalações
- Estiver em Linux ou WSL2 no Windows

### Passo 1️⃣: Abrir Terminal/Prompt

**Windows:**
1. Pressione `Win + X`
2. Clique em **"Terminal do Windows"** ou **"PowerShell"**

**Linux/Mac:**
1. Pressione `Ctrl + Alt + T` ou abra o aplicativo "Terminal"

### Passo 2️⃣: Entrar na Pasta do SukunaOS

```bash
cd Desktop/SukunaOS
```

**Se não estiver lá:**
```bash
cd C:\Users\SEU_USUARIO\Desktop\SukunaOS
```

### Passo 3️⃣: Executar o Validador

Isso verifica se seu PC tem tudo:

```bash
bash scripts/validate_build.sh
```

**Se falhar**, instale as dependências:

```bash
sudo apt update
sudo apt install -y live-build squashfs-tools xorriso debootstrap rsync ubuntu-archive-keyring live-config
```

### Passo 4️⃣: Fazer o Build

```bash
bash scripts/build_iso.sh
```

**Agora é só esperar!** ⏳
- Vai demorar **30-40 minutos**
- Seu PC vai fazer muito barulho (normal!)
- Não desligue nada

**Quando terminar**, você encontra o arquivo em:
```
live-build/live-image-amd64.iso
```

---

## 📀 Opção 3: Build com Docker (Se Não Tiver Live-Build)

**Se você instalou Docker Desktop:**

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

---

## 💾 Agora você tem a ISO! O que fazer?

Você tem um arquivo chamado `live-image-amd64.iso` (ou parecido).

### Opção A: Testar em Máquina Virtual (Mais Seguro ✅)

**VirtualBox** (grátis):
1. Baixe e instale: https://www.virtualbox.org
2. Crie uma máquina nova:
   - RAM: **4 GB**
   - Disco: **30 GB**
   - UEFI boot: ✅ ligado
3. Clique em **"Carregar"** e escolha seu ISO
4. Clique em **"Start"**
5. Aproveite! 🎉

### Opção B: Colocar em Pen Drive (Para Hardware Real)

**Windows ou Mac (Mais Fácil):**
1. Baixe **Balena Etcher**: https://www.balena.io/etcher/
2. Abra Etcher
3. Clique em **"Select Image"** → Escolha seu ISO
4. Clique em **"Select Drive"** → Escolha seu pen drive ⚠️
5. Clique em **"Flash"** e espera terminar
6. Pronto! Seu pen drive agora é um bootável do SukunaOS 🚀

**Linux (Linha de Comando):**
```bash
# Achar seu pen drive
lsblk

# ⚠️ TENHA CERTEZA DO NOME ANTES (ex: /dev/sdb)
sudo dd if=live-image-amd64.iso of=/dev/sdX bs=4M && sync
```

---

## 🆘 Deu Problema? Aqui Estão as Soluções

### "Command not found: bash"
- Você está no Windows Command Prompt (errado)
- Use **PowerShell** ou **WSL2** em vez disso

### "Permission denied"
- Tente colocar `sudo` na frente:
```bash
sudo bash scripts/build_iso.sh
```

### "ISO não encontrada"
- Procure em:
```bash
find . -name "*.iso"
```

### "Espaço insuficiente"
- Seu disco está muito cheio
- Você precisa de **5-8 GB livres**
- Limpe downloads antigos

### "Build congelou"
- Aguarde 30+ minutos (pode ser lento)
- Se realmente travou, pressione `Ctrl+C` e tente novamente

---

## ✅ Checklist Final

Antes de usar o pen drive, verifique:

- [ ] Você tem o arquivo `live-image-amd64.iso`
- [ ] O arquivo é **maior que 1 GB**
- [ ] Você já fez o flash com Etcher ou dd
- [ ] O pen drive foi reconhecido corretamente
- [ ] Você fez backup do que estava no pen drive (vai ser apagado!)

---

## 🎮 Pronto para Botar para Rodar!

### No seu PC/Laptop:

1. **Plug** o pen drive
2. **Reinicie** o PC
3. **Pressione** `F12` ou `Del` (depende do PC)
4. **Escolha** boot do pen drive
5. **Aguarde** o SukunaOS iniciar
6. Aproveite o sistema com tema **Carmesim e Mac-inspired** 🔴✨

---

## 📞 Algo Deu Errado?

1. Leia novamente a seção **"Deu Problema?"**
2. Veja os logs em: `live-build/build_output.log`
3. Abra uma **Issue** no GitHub: https://github.com/Abdo60267/SukunaOS/issues
4. Papeei no Discord (se tiver servidor)

---

## 🎓 Resumão Rápido para Lembrar:

```
1. GitHub Actions = Mais fácil (recomendado)
2. Build Local = Mais controle
3. Docker = Se não tiver dependências
4. Etcher = Pen drive (mais seguro)
5. VirtualBox = Teste antes
```

---

**Última atualização**: 2026-06-19
**Status**: ✅ Super simples para qualquer pessoa
**Dúvida?** Leia tudo novamente! 😄

Boa compilação! 🔴🎉
