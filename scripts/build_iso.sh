#!/bin/bash 
set -e 
echo "Iniciando Ritual de Criacao da ISO do SukunaOS..." 
 
# Limpeza 
lb clean --purge || true 
rm -rf live-build 
 
# Criar pasta de build 
mkdir -p live-build 
 
# Copiar a configuracao base de live/ para live-build/ 
if [ -d "live/config" ]; then 
    echo "[*] Copiando configuracoes da pasta live/..." 
    cp -r live/config live-build/ 
else 
    echo "Erro: Pasta live/config nao encontrada!" 
    exit 1 
fi 
 
# Entrar no diretorio de build 
cd live-build 
 
# Criar pasta chroot para copiar o repositorio 
mkdir -p config/includes.chroot/opt/sukuna 
 
echo "[*] Copiando arquivos do repositorio para /opt/sukuna..." 
cp -r ../src ../scripts ../systemd ../assets ../devkit ../tools config/includes.chroot/opt/sukuna/ 
 
# Rodar a configuracao e o build 
echo "[*] Rodando lb config..." 
lb config 
 
echo "[*] Rodando lb build..." 
lb build 
 
echo "Ritual de Criacao Concluido com Sucesso!" 