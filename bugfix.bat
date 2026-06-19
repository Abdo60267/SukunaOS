@echo off
chcp 65001 >nul
setlocal

echo.
echo  ==========================================
echo   SukunaOS - Corrigir GitHub Actions
echo  ==========================================
echo.

:: Verificar se esta na pasta certa
if not exist ".github\workflows" (
    echo  [ERRO] Pasta .github\workflows nao encontrada.
    echo  Execute esse .bat na pasta raiz do SukunaOS.
    echo.
    pause
    exit /b 1
)

set "WORKFLOW=.github\workflows\build.yml"

if not exist "%WORKFLOW%" (
    echo  [ERRO] Arquivo build.yml nao encontrado em:
    echo  %WORKFLOW%
    echo.
    pause
    exit /b 1
)

:: Verificar git
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERRO] Git nao encontrado. Instale o Git e tente novamente.
    pause
    exit /b 1
)

:: Verificar PowerShell
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERRO] PowerShell nao encontrado.
    pause
    exit /b 1
)

set "PSFILE=%TEMP%\fix_sukuna_workflow.ps1"

:: -----------------------------------------------
:: Gerar o script PowerShell no disco
:: -----------------------------------------------
echo  [1/4] Preparando correcoes...

(
echo $wf = '.github/workflows/build.yml'
echo $c  = [IO.File]::ReadAllText^($wf^)
echo $changed = $false
echo.
echo # Pacotes que precisam estar no apt-get install
echo $deps = @^(
echo     'gettext',
echo     'squashfs-tools',
echo     'isolinux',
echo     'syslinux-common',
echo     'mtools',
echo     'dosfstools',
echo     'grub-pc-bin',
echo     'grub-efi-amd64-bin',
echo     'live-boot'
echo ^)
echo.
echo Write-Host "  Verificando dependencias..."
echo $added = @^(^)
echo foreach ^($d in $deps^) {
echo     if ^($c -notmatch [regex]::Escape^($d^)^) {
echo         $c = $c -replace '^(apt-get install -y [^^\n]+^)', ^("`$1 " + $d^)
echo         $added += $d
echo         $changed = $true
echo     }
echo }
echo if ^($added^) { Write-Host ^("  [+] Adicionado: " + ^($added -join ', '^)^) }
echo else { Write-Host "  [OK] Todas as dependencias ja estao no workflow." }
echo.
echo # Corrigir live-build make install - evita erro de manpages ^(gettext/msgfmt^)
echo Write-Host "  Verificando make install do live-build..."
echo if ^($c -match 'make install' -and $c -notmatch 'MANPAGES=false'^) {
echo     $c = $c -replace 'make install', 'make install MANPAGES=false'
echo     Write-Host "  [+] MANPAGES=false adicionado ao make install"
echo     $changed = $true
echo } else {
echo     Write-Host "  [OK] make install ja esta correto."
echo }
echo.
echo # Salvar se houve mudancas
echo if ^($changed^) {
echo     [IO.File]::WriteAllText^($wf, $c^)
echo     Write-Host "  [OK] Workflow salvo com sucesso."
echo } else {
echo     Write-Host "  [OK] Nenhuma alteracao foi necessaria."
echo }
) > "%PSFILE%"

:: -----------------------------------------------
:: Executar o script
:: -----------------------------------------------
echo  [2/4] Aplicando correcoes no build.yml...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"

if %errorlevel% neq 0 (
    echo.
    echo  [ERRO] O script de correcao falhou.
    echo  Verifique o build.yml manualmente.
    del "%PSFILE%" 2>nul
    pause
    exit /b 1
)

:: -----------------------------------------------
:: Git commit
:: -----------------------------------------------
echo.
echo  [3/4] Fazendo commit...
git add "%WORKFLOW%"
git commit -m "fix: adiciona dependencias e corrige live-build no GitHub Actions"

if %errorlevel% neq 0 (
    echo  [AVISO] Nada novo para commitar ^(workflow ja pode estar atualizado^).
)

:: -----------------------------------------------
:: Git push
:: -----------------------------------------------
echo.
echo  [4/4] Enviando para o GitHub...
git push

if %errorlevel% neq 0 (
    echo.
    echo  [ERRO] git push falhou.
    echo  Verifique sua conexao com a internet e permissoes do repositorio.
    del "%PSFILE%" 2>nul
    pause
    exit /b 1
)

del "%PSFILE%" 2>nul

echo.
echo  ==========================================
echo   [OK] Correcoes aplicadas com sucesso!
echo.
echo   Acompanhe o build em:
echo   https://github.com/Abdo60267/SukunaOS/actions
echo  ==========================================
echo.
pause