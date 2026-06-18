@echo off
REM SukunaOS ISO Build Launcher para Windows
REM Este script configura o repo local, adiciona remote GitHub e faz push.

setlocal enabledelayedexpansion
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo.
echo ===========================================
echo  SukunaOS ISO Build Launcher
echo ===========================================
echo.
echo Script: %SCRIPT_DIR%
echo Executando em: %CD%

git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Git nao encontrado.
    echo Instale Git: https://git-scm.com/download/win
    pause
    exit /b 1
)

if not exist .git (
    echo Inicializando repositorio Git local...
    git init
)

for /f "delims=" %%b in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "BRANCH=%%b"
if "%BRANCH%"=="" set "BRANCH=master"
if "%BRANCH%"=="HEAD" set "BRANCH=master"

echo Branch atual: %BRANCH%

set "REMOTE_URL="
git remote get-url origin >nul 2>&1 && for /f "delims=" %%r in ('git remote get-url origin') do set "REMOTE_URL=%%r"
if "%REMOTE_URL%"=="" (
    echo Nao ha remote origin configurado.
    set /p GITHUB_USER=Digite seu usuario GitHub [Abdo60267]: 
    if "%GITHUB_USER%"=="" set "GITHUB_USER=Abdo60267"
    set /p GITHUB_REPO=Digite o nome do repositorio [SukunaOS]: 
    if "%GITHUB_REPO%"=="" set "GITHUB_REPO=SukunaOS"
    set "REMOTE_URL=https://github.com/%GITHUB_USER%/%GITHUB_REPO%.git"
    git remote add origin %REMOTE_URL%
) else (
    echo Remote origin ja configurado: %REMOTE_URL%
)

if not defined GITHUB_USER (
    for /f "tokens=4 delims=/" %%u in ("%REMOTE_URL%") do set "GITHUB_USER=%%u"
)
if not defined GITHUB_REPO (
    for /f "tokens=5 delims=/" %%r in ("%REMOTE_URL%") do set "GITHUB_REPO=%%r"
    set "GITHUB_REPO=%GITHUB_REPO:.git=%"
)

git status --porcelain >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Nao foi possivel executar git status.
    pause
    exit /b 1
)

set "CHANGES=0"
for /f %%c in ('git status --porcelain') do set "CHANGES=1"

if "%CHANGES%"=="1" (
    echo Preparando commit...
    git add -A
    git commit -m "🔨 Prepare repo and enable GitHub ISO build"
    if %errorlevel% neq 0 (
        echo Aviso: nenhuma mudanca nova para commitar.
    ) else (
        echo Commit realizado.
    )
) else (
    echo Nada novo para commitar.
)

echo.
echo Tentando push para %REMOTE_URL%...
git push -u origin %BRANCH%
if %errorlevel% neq 0 (
    echo ERRO: Push falhou.
    echo Verifique:
    echo   - O repositorio %REMOTE_URL% existe no GitHub
    echo   - Voce esta logado no GitHub no Windows
    echo   - Voce tem permissao para publicar no repo
    echo.
    echo Caso o repositorio nao exista, crie em:
    echo   https://github.com/%GITHUB_USER%/%GITHUB_REPO%
    echo.
    pause
    exit /b 1
)

echo ✅ Push realizado!
echo.
echo Agora abra no navegador:
echo   https://github.com/%GITHUB_USER%/%GITHUB_REPO%
echo.
echo Depois va em Actions e execute o workflow "Build SukunaOS ISO".
echo Quando terminar, baixe o arquivo em Artifacts -> sukunaos-iso.
echo.

pause
