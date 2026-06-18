@echo off
setlocal EnableDelayedExpansion

:: ============================
:: SukunaOS ISO Build Launcher
:: ============================

cd /d "%~dp0"

set "LOGFILE=%~dp0sukunaos_build.log"

(
echo ===========================================
echo SukunaOS Build Log
echo Data: %date% %time%
echo ===========================================
) > "%LOGFILE%"

echo.
echo ===========================================
echo  SukunaOS ISO Build Launcher
echo ===========================================
echo.

echo Script: %~dp0
echo Executando em: %CD%
echo.

call :log "Inicio"

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

:: Verificar configuracao Git
git config user.name >nul 2>&1

if errorlevel 1 (
    echo.
    echo ===========================================
    echo CONFIGURE O GIT PRIMEIRO
    echo ===========================================
    echo.
    echo Execute:
    echo git config --global user.name "Abdo60267"
    echo git config --global user.email "seuemail@exemplo.com"
    echo.
    pause
    exit /b 1
)

:: Verificar repositorio
if not exist ".git" (
    call :log "Repositorio Git nao encontrado"

    echo.
    echo ERRO:
    echo Nenhum repositorio Git encontrado nesta pasta.
    echo.
    echo Pasta atual:
    echo %CD%
    echo.
    pause
    exit /b 1
)

:: Branch atual
call :log "Detectando branch"

for /f "delims=" %%a in ('git branch --show-current 2^>nul') do set "BRANCH=%%a"

if not defined BRANCH set "BRANCH=master"

echo Branch: !BRANCH!
call :log "Branch detectada: !BRANCH!"

:: Remote
call :log "Buscando remote"

set "REMOTE_URL="

for /f "delims=" %%a in ('git remote get-url origin 2^>nul') do set "REMOTE_URL=%%a"

if not defined REMOTE_URL (

    echo.
    echo Nenhum remote encontrado.
    echo.

    set /p GITHUB_USER=Usuario GitHub [Abdo60267]:
    if "!GITHUB_USER!"=="" set "GITHUB_USER=Abdo60267"

    set /p GITHUB_REPO=Repositorio [SukunaOS]:
    if "!GITHUB_REPO!"=="" set "GITHUB_REPO=SukunaOS"

    set "REMOTE_URL=https://github.com/!GITHUB_USER!/!GITHUB_REPO!.git"

    git remote add origin "!REMOTE_URL!" >> "%LOGFILE%" 2>&1

    call :log "Remote criado: !REMOTE_URL!"
)

echo Remote: !REMOTE_URL!

:: Criar .gitignore automaticamente
if not exist ".gitignore" (

    call :log "Criando .gitignore"

    (
    echo *.exe
    echo *.zip
    echo *.db
    echo *.db-shm
    echo *.db-wal
    echo .env
    echo node_modules/
    echo __pycache__/
    ) > .gitignore
)

:: Verificar alteracoes
call :log "Verificando alteracoes"

git status --porcelain > temp_git_status.txt

for %%A in (temp_git_status.txt) do set SIZE=%%~zA

del temp_git_status.txt

if "!SIZE!"=="0" (

    call :log "Nenhuma alteracao encontrada"

    echo.
    echo ===========================================
    echo NADA PARA ENVIAR
    echo ===========================================
    echo.
    echo O repositorio ja esta atualizado.
    echo.

    pause
    exit /b 0
)

:: Add
call :log "Adicionando arquivos"

git add -A >> "%LOGFILE%" 2>&1

:: Commit
call :log "Criando commit"

git commit -m "SukunaOS Build %date% %time%" >> "%LOGFILE%" 2>&1

if errorlevel 1 (

    call :log "Commit falhou"

    echo.
    echo Nenhuma alteracao para commitar.
    echo.

    pause
    exit /b 0
)

:: Push
call :log "Executando push"

git push origin !BRANCH! >> "%LOGFILE%" 2>&1

if errorlevel 1 (

    call :log "Push falhou"

    echo.
    echo ===========================================
    echo ERRO NO PUSH
    echo ===========================================
    echo.
    echo Verifique o log:
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
echo GitHub:
echo https://github.com/Abdo60267/SukunaOS
echo.
echo Log:
echo %LOGFILE%
echo.

pause
exit /b

:log
echo [%time%] %~1
echo [%time%] %~1 >> "%LOGFILE%"
exit /b