@echo off
title SukunaOS - Fixador de Build
cls

echo ====================================================
echo    🔥 SukunaOS - Reset e Correcao de Script
echo ====================================================

:: 1. Criar pastas se nao existirem
if not exist .github\workflows mkdir .github\workflows
if not exist scripts mkdir scripts

:: 2. Usar PowerShell para criar os arquivos SEM a assinatura invisivel (BOM)
echo [*] Gerando scripts com codificacao correta...

powershell -Command "$utf8 = New-Object System.Text.UTF8Encoding $false; $iso_script = @'
#!/bin/bash
set -e
echo '----------------------------------------------------'
echo '🚀 Iniciando Build do SukunaOS (Base Debian)'
echo '----------------------------------------------------'

# Limpeza total
sudo lb clean --purge

# Configurar o build (Versao compativel com Live-Build 3.x)
lb config -d bookworm \
    --archive-areas 'main contrib non-free non-free-firmware' \
    --apt-indices false

# Criar pasta de saida
mkdir -p out

# Rodar o build real
sudo lb build

# Localizar a ISO e mover para a pasta out
ISO_FILE=$(ls *.iso 2>/dev/null | head -n 1)
if [ -f \"$ISO_FILE\" ]; then
    mv \"$ISO_FILE\" out/sukunaos-build.iso
    echo '✅ ISO gerada com sucesso em: out/'
else
    echo '❌ Erro: ISO nao encontrada.'
    exit 1
fi
'@; [System.IO.File]::WriteAllText('scripts/build_iso.sh', $iso_script, $utf8)"

echo [*] Gerando arquivo de workflow v4...

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
          sudo apt install -y live-build squashfs-tools xorriso debootstrap rsync
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

:: 3. Enviar para o GitHub
echo [*] Enviando correcoes para o GitHub...
git add .
git commit -m "🔧 FIX: Removendo BOM e corrigindo comandos lb config"
git push origin main --force

echo.
echo ====================================================
echo ✅ TUDO PRONTO!
echo.
echo O GitHub Actions vai reiniciar o build automaticamente.
echo Acesse: https://github.com/Abdo60267/SukunaOS/actions
echo ====================================================
pause