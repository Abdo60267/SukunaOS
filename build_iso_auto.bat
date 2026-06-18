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

:: Verificar configuracao Git (nome e email)
set "GIT_OK=1"
git config user.name >nul 2>&1
if errorlevel 1 set "GIT_OK=0"
git config user.email >nul 2>&1
if errorlevel 1 set "GIT_OK=0"

if "!GIT_OK!"=="0" (
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

set "BRANCH="
for /f "delims=" %%a in ('git branch --show-current 2^>nul') do set "BRANCH=%%a"

if not defined BRANCH set "BRANCH=main"

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

:: URL do GitHub para exibir (sem o .git no final)
set "WEB_URL=!REMOTE_URL!"
if "!WEB_URL:~-4!"==".git" set "WEB_URL=!WEB_URL:~0,-4!"

:: Criar .gitignore automaticamente (se nao existir)
if not exist ".gitignore" (

    call :log "Criando .gitignore"

    (
    echo *.exe
    echo *.zip
    echo *.iso
    echo *.db
    echo *.db-shm
    echo *.db-wal
    echo .env
    echo *.log
    echo node_modules/
    echo __pycache__/
    ) > .gitignore
)

:: Garantir que log e ISO nunca sejam commitados, mesmo num .gitignore ja existente
findstr /x "*.log" .gitignore >nul 2>&1
if errorlevel 1 echo *.log >> .gitignore

findstr /x "*.iso" .gitignore >nul 2>&1
if errorlevel 1 echo *.iso >> .gitignore

:: Se o log de builds antigo ja estava versionado, parar de rastrea-lo (mantendo o arquivo local)
git ls-files --error-unmatch "sukunaos_build.log" >nul 2>&1
if not errorlevel 1 (
    call :log "Removendo sukunaos_build.log do controle de versao"
    git rm --cached "sukunaos_build.log" >> "%LOGFILE%" 2>&1
)

:: Buscar atualizacoes do remoto antes de qualquer coisa
call :log "Executando fetch"
git fetch origin >> "%LOGFILE%" 2>&1

:: Adicionar e commitar alteracoes locais, se houver
call :log "Adicionando arquivos"
git add -A >> "%LOGFILE%" 2>&1

git diff --cached --quiet
if errorlevel 1 (
    call :log "Criando commit"
    git commit -m "SukunaOS Build %date% %time%" >> "%LOGFILE%" 2>&1
    call :log "Commit criado"
) else (
    call :log "Nenhuma alteracao nova para commitar"
)

:: Verificar se a branch ja existe no remoto (define se e o primeiro push)
set "FIRST_PUSH=0"
git rev-parse --verify origin/!BRANCH! >nul 2>&1
if errorlevel 1 set "FIRST_PUSH=1"

if "!FIRST_PUSH!"=="1" call :log "Branch nao existe no remoto - sera o primeiro push"
if "!FIRST_PUSH!"=="1" goto :do_push

call :log "Verificando divergencia com o remoto"

set "BEHIND=0"
set "AHEAD=0"
for /f "tokens=1,2" %%a in ('git rev-list --left-right --count origin/!BRANCH!...!BRANCH! 2^>nul') do (
    set "BEHIND=%%a"
    set "AHEAD=%%b"
)

if "!BEHIND!"=="0" goto :check_ahead

echo.
echo O repositorio remoto tem commits que voce nao tem localmente.
echo Sincronizando automaticamente com pull --rebase...
call :log "Branch atras do remoto - tentando pull --rebase"

git pull --rebase origin !BRANCH! >> "%LOGFILE%" 2>&1

if errorlevel 1 (
    call :log "Pull --rebase falhou (provavel conflito)"
    echo.
    echo ===========================================
    echo CONFLITO DETECTADO
    echo ===========================================
    echo.
    echo O rebase automatico falhou, provavelmente por conflito de merge.
    echo Resolva manualmente antes de rodar o script de novo:
    echo   1. git status
    echo   2. Edite os arquivos listados como conflito
    echo   3. git add [arquivo]
    echo   4. git rebase --continue
    echo   5. git push origin !BRANCH!
    echo.
    echo Log completo em: %LOGFILE%
    echo.
    pause
    exit /b 1
)

call :log "Pull --rebase concluido com sucesso"

set "BEHIND=0"
set "AHEAD=0"
for /f "tokens=1,2" %%a in ('git rev-list --left-right --count origin/!BRANCH!...!BRANCH! 2^>nul') do (
    set "BEHIND=%%a"
    set "AHEAD=%%b"
)

:check_ahead
if "!AHEAD!"=="0" (
    call :log "Nada para enviar"
    echo.
    echo ===========================================
    echo NADA PARA ENVIAR
    echo ===========================================
    echo.
    echo O repositorio remoto ja esta atualizado.
    echo.
    pause
    exit /b 0
)

:do_push
call :log "Executando push"

if "!FIRST_PUSH!"=="1" (
    git push -u origin !BRANCH! >> "%LOGFILE%" 2>&1
) else (
    git push origin !BRANCH! >> "%LOGFILE%" 2>&1
)

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
echo !WEB_URL!
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