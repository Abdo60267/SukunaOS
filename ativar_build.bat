@echo off
title SukunaOS - Ativador de Build Automático
cls

echo ====================================================
echo    🚀 SukunaOS - Configurando Build no GitHub
echo ====================================================

:: 1. Criar pastas do GitHub Actions
echo [*] Criando pastas do sistema (.github/workflows)...
if not exist .github\workflows mkdir .github\workflows

:: 2. Criar o arquivo YAML de build (as instruções para o GitHub)
echo [*] Gerando arquivo de configuracao (build-iso.yml)...

(
echo name: Build SukunaOS ISO
echo.
echo on:
echo   push:
echo     branches: [ main, master ]
echo   workflow_dispatch:
echo.
echo jobs:
echo   build:
echo     runs-on: ubuntu-latest
echo     steps:
echo       - name: Checkout code
echo         uses: actions/checkout@v3
echo.
echo       - name: Install dependencies
echo         run: ^|
echo           sudo apt update
echo           sudo apt install -y live-build squashfs-tools xorriso debootstrap rsync
echo.
echo       - name: Build ISO
echo         run: ^|
echo           if [ -f "scripts/build_iso.sh" ]; then
echo             chmod +x scripts/build_iso.sh
echo             sudo bash scripts/build_iso.sh
echo           else
echo             echo "ERRO: scripts/build_iso.sh nao encontrado!"
echo             exit 1
echo           fi
echo.
echo       - name: Upload ISO Artifact
echo         uses: actions/upload-artifact@v3
echo         with:
echo           name: sukunaos-iso
echo           path: out/*.iso
) > .github\workflows\build-iso.yml

:: 3. Sincronizar com o GitHub
echo [*] Enviando arquivos para o GitHub...
git add .
git commit -m "🚀 Ativando build automatico da ISO"
git push origin main

:: Se o push falhar na main, tenta na master
if %errorlevel% neq 0 (
    echo [!] Falha na branch main, tentando master...
    git push origin master
)

echo.
echo ====================================================
echo ✅ SUCESSO! O fluxo de trabalho foi instalado.
echo.
echo PRÓXIMOS PASSOS:
echo 1. Vá em seu navegador no GitHub.
echo 2. Clique na aba 'Actions'.
echo 3. Você verá 'Build SukunaOS ISO' lá!
echo 4. Aguarde cerca de 20-30 minutos para terminar.
echo ====================================================
pause