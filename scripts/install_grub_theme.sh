#!/bin/bash
# SukunaOS GRUB Configuration - Ubuntu 24.04 LTS
# Malevolent Domain Edition - Crimson Theme

# Editar /etc/default/grub:

# Fundo carmesim com mensagem Sukuna
GRUB_BACKGROUND="/opt/sukuna/assets/grub-background-crimson.png"

# Tema cores
export GRUB_COLOR_NORMAL="white/black"
export GRUB_COLOR_HIGHLIGHT="white/red"

# Timeout (segundos)
GRUB_TIMEOUT=10
GRUB_TIMEOUT_STYLE=countdown

# Menu entry
GRUB_DEFAULT=0

# Modo gráfico
GRUB_GFXMODE=1920x1080x32
GRUB_GFXPAYLOAD_LINUX=keep

# Boot verbose
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash vt_handoff"
GRUB_CMDLINE_LINUX=""

# Terminal output
GRUB_TERMINAL_INPUT=console
GRUB_TERMINAL_OUTPUT=gfxterm

# Distribuição detectada
GRUB_DISTRIBUTOR=SukunaOS

# Desabilitar submenu
GRUB_DISABLE_SUBMENU=y

# Atualizar GRUB após editar:
# sudo update-grub

# Script para copiar assets:
cat << 'INSTALL' > /tmp/install-sukuna-grub.sh
#!/bin/bash
set -e

echo "🔴 Installing SukunaOS GRUB Theme..."

GRUB_THEMES_DIR="/boot/grub/themes"
SUKUNA_GRUB_THEME="$GRUB_THEMES_DIR/SukunaOS"

# Create theme directory
sudo mkdir -p "$SUKUNA_GRUB_THEME"

# Copy background (crimson gradient)
sudo cp assets/grub-background-crimson.png "$SUKUNA_GRUB_THEME/background.png"

# Create theme.txt
sudo tee "$SUKUNA_GRUB_THEME/theme.txt" > /dev/null << 'EOF'
# SukunaOS GRUB Theme - Malevolent Domain Edition

# Colors (Crimson + Gold)
color_topleft=#0A0304
color_topright=#0A0304
color_botleft=#0A0304
color_botright=#0A0304
color_border=#C41020

# Text colors
color_text_normal="#F0E6DB/black"
color_text_highlight="#FF1A33/black"

# Font settings
font_name="Unifont"
font_size="16"

# Boot message
boot_message="🔴 SukunaOS - Malevolent Domain Edition 🔴\n\nThe eternal curse governs...\nand the domain reigns supreme.\n\n"

# Terminal area
terminal_width="80"
terminal_height="24"
terminal_box="0,0,100%,100%"

# Image background
image {
  src = "/boot/grub/themes/SukunaOS/background.png"
  x = 0
  y = 0
  width = 100%
  height = 100%
}

# Title
label {
  text = "🔴 SUKUNAOS - UBUNTU 24.04 LTS 🔴"
  color = "#D4A84A"
  font = "Unifont Bold 20"
  x = center
  y = 50
}

# Menu viewport
vbox {
  left = 10%
  top = 100
  width = 80%
  height = 400
  spacing = 10
  background_color = "transparent"
  
  # Menu items rendered here
  list {
    width = 100%
    height = 100%
  }
}

# Bottom info
label {
  text = "↑↓ Navigate  |  Enter Select  |  'c' Console  |  ESC Quit"
  color = "#B89F8F"
  font = "Unifont 11"
  x = center
  y = bottom - 10
}

# Power by label
label {
  text = "Powered by the cursed energy of SukunaOS"
  color = "#6D5550"
  font = "Unifont 10"
  x = center
  y = bottom - 3
}
EOF

# Update GRUB config
sudo sed -i "s|^#GRUB_THEME=.*|GRUB_THEME=\"$SUKUNA_GRUB_THEME\"|" /etc/default/grub
sudo sed -i 's|^GRUB_TIMEOUT=.*|GRUB_TIMEOUT=10|' /etc/default/grub
sudo sed -i 's|^GRUB_TIMEOUT_STYLE=.*|GRUB_TIMEOUT_STYLE=countdown|' /etc/default/grub

# Update GRUB
sudo update-grub

echo "✅ SukunaOS GRUB theme installed!"
echo "   Theme: $SUKUNA_GRUB_THEME"
echo "   Reboot to see the theme in action 🔴"
INSTALL

chmod +x /tmp/install-sukuna-grub.sh
