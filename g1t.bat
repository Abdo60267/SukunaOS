@echo off
setlocal EnableDelayedExpansion

:: ============================
:: SukunaOS ISO Build Launcher
:: ============================

:: Sempre executar na pasta do script
cd /d "%~dp0"

set "LOGFILE=%~dp0sukunaos_build.log"

echo =========================================== > "%LOGFILE%"
echo SukunaOS Build Log >> "%LOGFILE%"
echo Data: %date% %time% >> "%LOGFILE%"
echo =========================================== >> "%LOGFILE%"

echo.
echo ===========================================
echo  SukunaOS ISO Build Launcher
echo ===========================================
echo.

echo Script: %~dp0
echo Executando em: %CD%
echo.

call :log "Inicio"

:: Segurança contra System32
if /I "%CD%"=="C:\Windows\System32" (
    call :log "ERRO: Executando dentro do System32"
    echo ERRO: Nao execute dentro do System32.
    pause
    exit /b 1
)

:: Verificar Git
call :log "Verificando Git"

git --version >> "%LOGFILE%" 2>&1

if errorlevel 1 (
    call :log "Git nao encontrado"
    echo ERRO: Git nao encontrado.
    echo Instale em:
    echo https://git-scm.com/download/win
    pause
    exit /b 1
)

call :log "Git encontrado"

:: Criar repo se nao existir
if not exist ".git" (
    call :log "Inicializando repositorio Git"
    git init >> "%LOGFILE%" 2>&1
)

:: Branch
call :log "Detectando branch"

for /f "delims=" %%a in ('git branch --show-current 2^>nul') do set "BRANCH=%%a"

if not defined BRANCH set "BRANCH=main"

echo Branch: !BRANCH!
call :log "Branch detectada: !BRANCH!"

:: Remote
call :log "Buscando remote"

for /f "delims=" %%a in ('git remote get-url origin 2^>nul') do set "REMOTE_URL=%%a"

if not defined REMOTE_URL (

    call :log "Nenhum remote encontrado"

    set /p GITHUB_USER=Usuario GitHub [Abdo60267]:
    if "!GITHUB_USER!"=="" set "GITHUB_USER=Abdo60267"

    set /p GITHUB_REPO=Repositorio [SukunaOS]:
    if "!GITHUB_REPO!"=="" set "GITHUB_REPO=SukunaOS"

    set "REMOTE_URL=https://github.com/!GITHUB_USER!/!GITHUB_REPO!.git"

    git remote add origin "!REMOTE_URL!" >> "%LOGFILE%" 2>&1

    call :log "Remote criado: !REMOTE_URL!"
)

echo Remote: !REMOTE_URL!

:: Status
call :log "Executando git status"

git status >> "%LOGFILE%" 2>&1

if errorlevel 1 (
    call :log "Falha no git status"
    echo ERRO ao executar git status.
    pause
    exit /b 1
)

:: Adicionar arquivos
call :log "Adicionando arquivos"

git add -A >> "%LOGFILE%" 2>&1

:: Commit
call :log "Criando commit"

git commit -m "SukunaOS Build %date% %time%" >> "%LOGFILE%" 2>&1

:: Renomear branch para main
git branch -M main >> "%LOGFILE%" 2>&1
set "BRANCH=main"

:: Push
call :log "Executando push"

git push -u origin !BRANCH! >> "%LOGFILE%" 2>&1

if errorlevel 1 (
    call :log "Push falhou"

    echo.
    echo ===========================================
    echo ERRO NO PUSH
    echo ===========================================
    echo.
    echo Verifique:
    echo 1. O repositorio existe no GitHub
    echo 2. Voce esta logado no GitHub
    echo 3. Possui permissao de escrita
    echo.
    echo Log:
    echo %LOGFILE%
    echo.

    pause
    exit /b 1
)

call :log "Push concluido"

echo.
echo ===========================================
echo PUSH REALIZADO COM SUCESSO!
echo ===========================================
echo.
echo Repositorio:
echo !REMOTE_URL!
echo.
echo Log salvo em:
echo %LOGFILE%
echo.

pause
exit /b

:log
echo [%time%] %~1
echo [%time%] %~1 >> "%LOGFILE%"
exit /b