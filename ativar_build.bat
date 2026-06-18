@echo off
title SukunaOS - Ultra Fix (Debian Mode)
cls

echo ====================================================
echo    🚀 SukunaOS - Ajustando Espelhamento Debian
echo ====================================================

:: 1. Criar pastas se nao existirem
if not exist .github\workflows mkdir .github\workflows
if not exist scripts mkdir scripts

:: 2. Gerar o script de build FORÇANDO o modo Debian e os mirrors oficiais
echo [*] Gerando script de build (Debian Mode)...

powershell -Command "$utf8 = New-Object System.Text.UTF8Encoding $false; $iso_script = @'
#!/bin/bash
set -e
echo '----------------------------------------------------'
echo '🚀 Build SukunaOS - Modo Nativo Debian'
echo '----------------------------------------------------'

# Limpeza total
sudo lb clean --purge

# Configurar o build FORÇANDO o modo debian e os mirrors corretos
# Isso evita que o live-build tente usar mirrors do Ubuntu
lb config --mode debian \
    -d bookworm \
    --mirror-bootstrap http://deb.debian.org/debian/ \
    --mirror-chroot http://deb.debian.org/debian/ \
    --mirror-binary http://deb.debian.org/debian/ \
    --archive-areas 'main contrib non-free non-free-firmware' \
    --apt-indices false

# Criar pasta de saida
mkdir -p out

# Rodar o build real
sudo lb build

# Localizar a ISO e mover
ISO_FILE=$(ls *.iso 2>/dev/null | head -n 1)
if [ -f \"$ISO_FILE\" ]; then
    mv \"$ISO_FILE\" out/sukunaos-build.iso
    echo '✅ ISO criada: out/sukunaos-build.iso'
else
    echo '❌ Erro: ISO nao gerada.'
    exit 1
fi
'@; [System.IO.File]::WriteAllText('scripts/build_iso.sh', $iso_script, $utf8)"

:: 3. Gerar o Workflow instalando a chave de segurança (keyring)
echo [*] Atualizando Workflow (Instalando Keyrings)...

powershell -Command "$utf8 = New-Object System.Text.UTF8Encoding $false; $yaml = @'
name: Build SukunaOS ISO
on:
  push:
    branches: [ main, master ]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          sudo apt update
          sudo apt install -y live-build squashfs-tools xorriso debootstrap rsync debian-archive-keyring
      - name: Build ISO
        run: |
          chmod +x scripts/build_iso.sh
          sudo bash scripts/build_iso.sh
      - name: Upload ISO Artifact
        uses: actions/upload-artifact@v4
        with:
          name: sukunaos-iso
          path: out/*.iso
'@; [System.IO.File]::WriteAllText('.github/workflows/build-iso.yml', $yaml, $utf8)"

:: 4. Enviar para o GitHub
echo [*] Enviando para o GitHub...
git add .
git commit -m "🔧 ULTRA FIX: Modo Debian nativo e Mirrors oficiais"
git push origin main --force

echo.
echo ====================================================
echo ✅ CORREÇÃO ENVIADA!
echo.
echo Verifique o novo build:
echo https://github.com/Abdo60267/SukunaOS/actions
echo ====================================================
pause