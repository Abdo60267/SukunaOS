#!/bin/bash
set -e
echo "----------------------------------------------------"
echo "👹 SukunaOS - Injetando Alma e Visual no Sistema"
echo "----------------------------------------------------"

# Limpeza total
lb clean --purge

# Configuração minimalista (Compatível com v3.0)
lb config -d bookworm \
    --mode debian \
    --archive-areas "main contrib non-free non-free-firmware" \
    --apt-indices false

# --- 📂 INJEÇÃO DE ARQUIVOS (O SEU VISUAL) ---
# Criando a estrutura de pastas do Linux dentro da ISO
mkdir -p config/includes.chroot/etc
mkdir -p config/includes.chroot/usr/share/sukunaos/assets
mkdir -p config/includes.chroot/usr/share/sukunaos/mde
mkdir -p config/includes.chroot/etc/skel/Desktop

# 1. Definindo o nome do sistema (Hostname) manualmente
echo "sukunaos" > config/includes.chroot/etc/hostname
echo "127.0.0.1 localhost" > config/includes.chroot/etc/hosts
echo "127.0.1.1 sukunaos" >> config/includes.chroot/etc/hosts

# 2. Copiando SEUS arquivos do repositório para dentro da ISO
echo "[*] Copiando assets e mde..."
cp -r assets/* config/includes.chroot/usr/share/sukunaos/assets/ 2>/dev/null || true
cp -r mde/* config/includes.chroot/usr/share/sukunaos/mde/ 2>/dev/null || true

# 3. Criando o ícone do seu MDE na Área de Trabalho
cat <<EOF > config/includes.chroot/etc/skel/Desktop/Sukuna-MDE.desktop
[Desktop Entry]
Name=Sukuna MDE Mockup
Exec=python3 /usr/share/sukunaos/mde/mockup/main.py
Icon=/usr/share/sukunaos/assets/sukunaos-logo.svg
Type=Application
Terminal=true
Categories=Development;
EOF

# 4. Lista de pacotes para o Visual funcionar
mkdir -p config/package-lists
cat <<EOF > config/package-lists/sukuna.list.chroot
task-xfce-desktop
python3-full
python3-tk
python3-pip
neofetch
firefox-esr
EOF

# Iniciar o Build (O container fará o resto)
lb build

# Organizar saída
mkdir -p out
mv *.iso out/sukunaos-custom-visual.iso || echo "ISO movida"