#!/bin/bash
set -e
echo "----------------------------------------------------"
echo "👺 SukunaOS - Integrando Visual e Mockups"
echo "----------------------------------------------------"

# Limpeza
lb clean --purge

# Configuração básica
lb config -d bookworm \
    --mode debian \
    --hostname "sukunaos" \
    --archive-areas "main contrib non-free non-free-firmware" \
    --apt-indices false

# --- 📂 PARTE NOVA: INJETANDO SEUS ARQUIVOS ---
# O live-build usa uma pasta chamada 'config/includes.chroot' 
# Tudo que estiver dentro dela vai parar direto na raiz (/) do seu sistema.

mkdir -p config/includes.chroot/usr/share/sukunaos/assets
mkdir -p config/includes.chroot/usr/share/sukunaos/mde
mkdir -p config/includes.chroot/etc/skel/Desktop

# 1. Copiar seus wallpapers e logos do repositório para dentro da ISO
cp -r assets/* config/includes.chroot/usr/share/sukunaos/assets/ 2>/dev/null || echo "Sem assets para copiar"

# 2. Copiar os mockups do MDE (aquela interface Python que você tem)
cp -r mde/* config/includes.chroot/usr/share/sukunaos/mde/ 2>/dev/null || echo "Sem MDE para copiar"

# 3. Criar um atalho na Área de Trabalho para o seu Mockup
cat <<EOF > config/includes.chroot/etc/skel/Desktop/Sukuna-MDE-Mockup.desktop
[Desktop Entry]
Name=Sukuna MDE Mockup
Exec=python3 /usr/share/sukunaos/mde/mockup/main.py
Icon=/usr/share/sukunaos/assets/sukunaos-logo.svg
Type=Application
Terminal=true
EOF

# 4. Lista de programas necessários para rodar o visual
mkdir -p config/package-lists
cat <<EOF > config/package-lists/sukuna_visual.list.chroot
task-xfce-desktop
python3-full
python3-pip
python3-tk
neofetch
firefox-esr
EOF

# Rodar o build
lb build

# Organizar a saída
mkdir -p out
mv *.iso out/sukunaos-custom-visual.iso || echo "ISO movida"