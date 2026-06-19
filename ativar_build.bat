@echo off
title SukunaOS - Ajuste e Ativacao do Build
chcp 65001 >nul
cls

echo ====================================================
echo    SukunaOS - Ajustando e Ativando o Build
echo ====================================================

:: Criar pastas se nao existirem
if not exist .github\workflows mkdir .github\workflows
if not exist scripts mkdir scripts

:: Criar um arquivo ps1 temporario para escrever os scripts com seguranca
set "TEMP_PS1=%TEMP%\sukuna_write.ps1"

echo $utf8 = New-Object System.Text.UTF8Encoding $false > "%TEMP_PS1%"
echo $iso_script = @' >> "%TEMP_PS1%"
echo #!/bin/bash >> "%TEMP_PS1%"
echo set -e >> "%TEMP_PS1%"
echo echo "Iniciando Ritual de Criacao da ISO do SukunaOS..." >> "%TEMP_PS1%"
echo. >> "%TEMP_PS1%"
echo # Limpeza >> "%TEMP_PS1%"
echo lb clean --purge ^|^| true >> "%TEMP_PS1%"
echo rm -rf live-build >> "%TEMP_PS1%"
echo. >> "%TEMP_PS1%"
echo # Criar pasta de build >> "%TEMP_PS1%"
echo mkdir -p live-build >> "%TEMP_PS1%"
echo. >> "%TEMP_PS1%"
echo # Copiar a configuracao base de live/ para live-build/ >> "%TEMP_PS1%"
echo if [ -d "live/config" ]; then >> "%TEMP_PS1%"
echo     echo "[*] Copiando configuracoes da pasta live/..." >> "%TEMP_PS1%"
echo     cp -r live/config live-build/ >> "%TEMP_PS1%"
echo else >> "%TEMP_PS1%"
echo     echo "Erro: Pasta live/config nao encontrada!" >> "%TEMP_PS1%"
echo     exit 1 >> "%TEMP_PS1%"
echo fi >> "%TEMP_PS1%"
echo. >> "%TEMP_PS1%"
echo # Entrar no diretorio de build >> "%TEMP_PS1%"
echo cd live-build >> "%TEMP_PS1%"
echo. >> "%TEMP_PS1%"
echo # Criar pasta chroot para copiar o repositorio >> "%TEMP_PS1%"
echo mkdir -p config/includes.chroot/opt/sukuna >> "%TEMP_PS1%"
echo. >> "%TEMP_PS1%"
echo echo "[*] Copiando arquivos do repositorio para /opt/sukuna..." >> "%TEMP_PS1%"
echo cp -r ../src ../scripts ../systemd ../assets ../devkit ../tools config/includes.chroot/opt/sukuna/ >> "%TEMP_PS1%"
echo. >> "%TEMP_PS1%"
echo # Rodar a configuracao e o build >> "%TEMP_PS1%"
echo echo "[*] Rodando lb config..." >> "%TEMP_PS1%"
echo lb config >> "%TEMP_PS1%"
echo. >> "%TEMP_PS1%"
echo echo "[*] Rodando lb build..." >> "%TEMP_PS1%"
echo lb build >> "%TEMP_PS1%"
echo. >> "%TEMP_PS1%"
echo echo "Ritual de Criacao Concluido com Sucesso!" >> "%TEMP_PS1%"
echo '@ >> "%TEMP_PS1%"
echo [System.IO.File]::WriteAllText('scripts/build_iso.sh', $iso_script, $utf8) >> "%TEMP_PS1%"
echo. >> "%TEMP_PS1%"
echo $workflow = @' >> "%TEMP_PS1%"
echo name: Build SukunaOS ISO >> "%TEMP_PS1%"
echo on: >> "%TEMP_PS1%"
echo   push: >> "%TEMP_PS1%"
echo     branches: [ main, master ] >> "%TEMP_PS1%"
echo   workflow_dispatch: >> "%TEMP_PS1%"
echo jobs: >> "%TEMP_PS1%"
echo   build: >> "%TEMP_PS1%"
echo     runs-on: ubuntu-latest >> "%TEMP_PS1%"
echo     steps: >> "%TEMP_PS1%"
echo       - name: Checkout code >> "%TEMP_PS1%"
echo         uses: actions/checkout@v4 >> "%TEMP_PS1%"
echo       - name: Install dependencies >> "%TEMP_PS1%"
echo         run: ^| >> "%TEMP_PS1%"
echo           sudo apt update >> "%TEMP_PS1%"
echo           sudo apt install -y live-build squashfs-tools xorriso debootstrap rsync debian-archive-keyring git make gettext isolinux syslinux-common mtools dosfstools grub-pc-bin grub-efi-amd64-bin live-boot po4a >> "%TEMP_PS1%"
echo       - name: Build ISO >> "%TEMP_PS1%"
echo         run: ^| >> "%TEMP_PS1%"
echo           chmod +x scripts/*.sh ^|^| true >> "%TEMP_PS1%"
echo           sudo bash scripts/build_iso.sh >> "%TEMP_PS1%"
echo       - name: Upload ISO Artifact >> "%TEMP_PS1%"
echo         uses: actions/upload-artifact@v4 >> "%TEMP_PS1%"
echo         with: >> "%TEMP_PS1%"
echo           name: sukunaos-iso >> "%TEMP_PS1%"
echo           path: live-build/*.iso >> "%TEMP_PS1%"
echo '@ >> "%TEMP_PS1%"
echo [System.IO.File]::WriteAllText('.github/workflows/build.yml', $workflow, $utf8) >> "%TEMP_PS1%"

:: Executar o PowerShell para escrever os arquivos com LF e UTF8 correto
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP_PS1%"
del "%TEMP_PS1%" 2>nul

echo [*] Arquivos atualizados com sucesso!
echo.
echo [*] Enviando para o GitHub...
git add .
git commit -m "Ajuste nos scripts de build e workflow da ISO"
git push origin main --force

echo.
echo ====================================================
echo CORRECAO ENVIADA COM FORCA!
echo.
echo Verifique o novo build:
echo https://github.com/Abdo60267/SukunaOS/actions
echo ====================================================
pause