# 🔴 SukunaOS - Malevolent Domain Edition 🔴

**Uma distribuição Linux baseada em Ubuntu, inspirada em Ryomen Sukuna de Jujutsu Kaisen**

> "A Maldição Eterna governa... e o domínio reina supremo"

SukunaOS é um sistema operacional moderno e usável com identidade visual de domínio malevolente: marcas vermelhas carmesim, cortes Cleave/Dismantle, selos dourados, shrines sagradas e segurança com linguagem de maldição.

## 🌋 Visão Geral

- **Desktop**: `Malevolent Desktop Environment (MDE)` - painel Domain Control, modos Human/Vessel/King, visual de shrine carmesim com influência macOS
- **Base**: Ubuntu 24.04 LTS (Wayland-ready, performance otimizada)
- **Segurança**: `King of Curses` LSM, `Cleave Guard`, sandboxing avançado, `Malevolent Domain`
- **Compatibilidade**: `Domain Compatibility Layer (DCL)` com Wine/Proton
- **Loja**: `Sukuna Store` para Flatpak, Snap, AppImage, debs e apps Windows
- **Dev Kit**: Toolchains para C, C++, Python, Java, C#, Rust, Go, Lua, JavaScript

## 🎨 Identidade Sukuna + Mac Carmesim

**Cores:**
- 🔴 **Crimson Carmesim**: #C41020 (marca Sukuna primária)
- 🟡 **Ouro Sagrado**: #D4A84a (selos shrine)
- ⚫ **Void Shrine**: #0c0406 (fundos profundos)
- ⚪ **Ferro Frio**: #E8E8E8 (texto, inspirado em SF Pro Display)

**Elementos visuais:**
- Cantos arredondados (estilo Mac)
- Efeitos de blur e profundidade (depth layers)
- Ícones geométricos com marcas Sukuna
- Animações fluidas e responsivas

**Assets:**
- `assets/sukunaos-logo.svg` - brasão com marcas, selo, silhueta shrine
- `assets/wallpaper-crimson.svg` - Malevolent Shrine (carmesim)
- `assets/wallpaper-cleave.svg` - Cleave/Dismantle (cortes dourados)
- `assets/dock-icons/` - ícones Mac-style com marca Sukuna

## 📁 Estrutura do Repositório

```
SukunaOS/
├── docs/              # Especificações, design, roadmaps
├── src/               # Protótipos de componentes e POCs
├── scripts/           # Build, instalação, setup (Ubuntu-focused)
├── systemd/           # Units de serviço
├── mde/               # Mockup visual do MDE
├── devkit/            # Templates e docs do Dev Kit
├── assets/            # Logos, wallpapers, ícones
├── live/              # Configuração live-build (Ubuntu)
└── tools/             # Utilitários de teste
```

## 🚀 Como Usar

### Build da ISO (Ubuntu 24.04)
```bash
cd SukunaOS
./scripts/build_iso.sh
```

### Teste Local (MDE)
```bash
python3 mde/mockup/main.py
```

### Instalar Dev Kit
```bash
./scripts/install_devkit.sh
```

### Teste da Store (POC)
```bash
python3 src/sukuna_store_server.py
```

### Criar USB Persistente
```bash
./scripts/create_persistent_usb.sh /dev/sdX
```

## 📖 Documentação Principal

- `README_KERNEL.md` - Build de kernel customizado
- `docs/king_of_curses.md` - Sistema LSM security
- `docs/malevolent_domain_integration.md` - Sandbox avançado
- `docs/sukuna_store_and_dcl.md` - Loja e compatibilidade
- `docs/visual_identity.md` - Linguagem visual (Mac+Sukuna)
- `docs/devkit.md` - Developer Kit
- `docs/roadmap.md` - Mapa de desenvolvimento

## 📊 Status

- **Fase 1**: MVP Alpha (5% completo)
- **Sprint 1.1**: MDE Foundations (20% completo)
- **Sprint 1.2**: King of Curses LSM (15% completo)
- **Próximos**: Sukuna Store, Malevolent Domain, Build Pipeline

Base: **Ubuntu 24.04 LTS** ✅
