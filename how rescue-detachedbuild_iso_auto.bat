@echo off
REM SukunaOS ISO Build Launcher para Windows
REM Este script faz commit das mudanças, faz push para GitHub e ativa o build automático

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║     🚀 SukunaOS ISO Build - Launcher Automático            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Verifica se tem mudanças
git status --porcelain >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git não está configurado ou você não está em um repo Git
    echo Solução: git init ^&^& git remote add origin ^<seu-repo-url^>
    pause
    exit /b 1
)

echo 📝 Fazendo commit das mudanças...
git add -A
git commit -m "🔨 Build ISO automático - %date%"

if %errorlevel% neq 0 (
    echo ⚠️ Nada novo para fazer commit (pode ser normal)
) else (
    echo ✅ Commit realizado
)

echo.
echo 📤 Fazendo push para GitHub (branch main)...
git push -u origin main

if %errorlevel% neq 0 (
    echo ❌ Erro no push. Verifique:
    echo   - Tem acesso ao repositório?
    echo   - Rodou: git config --global user.name "Abdo60267"
    echo   - Rodou: git config --global user.email "abdocatnoir@gmail.com"
    pause
    exit /b 1
)

echo ✅ Push realizado!
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║ 🎉 ISO Build foi ativado no GitHub Actions!               ║
echo ║                                                            ║
echo ║ ⏱️  Tempo de espera: ~20 minutos                            ║
echo ║                                                            ║
echo ║ 📍 Para acompanhar:                                        ║
echo ║    1. Vai em: https://github.com/SEU_USER/SukunaOS        ║
echo ║    2. Clica em "Actions"                                  ║
echo ║    3. Procura "Build SukunaOS ISO"                        ║
echo ║    4. Quando ficar verde ✅, clica e vai em "Artifacts"  ║
echo ║                                                            ║
echo ║ 📥 Baixa o arquivo "sukunaos-iso"                         ║
echo ║                                                            ║
echo ║ Seu repositório é:                                         ║
for /f "tokens=*" %%i in ('git config --get remote.origin.url') do set "REPO=%%i"
echo ║    %REPO%                      ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

pause
