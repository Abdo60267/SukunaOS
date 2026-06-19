@echo off
title SukunaOS - ISO Build Launcher Auto
chcp 65001 >nul
cls

echo.
echo ====================================================
echo      SukunaOS ISO Build - Launcher Auto (Win)
echo ====================================================
echo.

:: Verificar se o Git esta instalado
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git nao encontrado! Por favor, instale o Git e adicione-o ao PATH.
    pause
    exit /b 1
)

:: Verificar se estamos em um repositorio Git
git rev-parse --is-inside-work-tree >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Este diretorio nao e um repositorio Git!
    echo Rode: git init e adicione o remote origin.
    pause
    exit /b 1
)

:: Obter data formatada via PowerShell
for /f "usebackq tokens=*" %%i in (`powershell -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"`) do set "timestamp=%%i"

echo [*] Adicionando modificacoes ao Git...
git add -A

echo [*] Criando commit...
git commit -m "Build ISO automatico - %timestamp%"
if %errorlevel% neq 0 (
    echo [AVISO] Nada novo para fazer commit (pode ser normal).
)

echo.
echo [*] Enviando para o repositorio remoto no GitHub (branch main)...
git push -u origin main
if %errorlevel% neq 0 (
    echo [ERROR] Erro ao fazer push! Verifique:
    echo   - Voce configurou o seu Git (git config --global user.name / email)?
    echo   - Voce tem permissao de escrita neste repositorio?
    echo   - A branch padrao e realmente 'main'?
    pause
    exit /b 1
)

:: Obter a URL do repositorio remoto
for /f "usebackq tokens=*" %%i in (`git config --get remote.origin.url`) do set "repo_url=%%i"

:: Limpar a URL
set "repo_url=%repo_url:.git=%"

echo.
echo ====================================================
echo  O Build da ISO foi ativado no GitHub Actions!
echo.
echo  Tempo de espera: -20 minutos
echo.
echo  Para acompanhar e baixar:
echo   1. Acesse: %repo_url%/actions
echo   2. Clique em "Build SukunaOS ISO" (o mais recente)
echo   3. Quando o build concluir, clique nele
echo   4. Desca ate "Artifacts" no final da pagina
echo   5. Baixe o arquivo "sukunaos-iso"
echo ====================================================
echo.
pause
