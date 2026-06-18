# SukunaOS Project Index

Este documento resume o que já está implementado no repositório SukunaOS e serve como índice das especificações.

## Documentos principais

- `README.md` - visão geral do projeto.
- `README_KERNEL.md` - instruções de build do kernel customizado.
- `docs/kernel_customization.md` - especificação do kernel Sukuna.
- `docs/installer_drivers_windows.md` - plano de instalador, drivers e compatibilidade Windows.
- `docs/visual_identity.md` - identidade visual e guidelines.
- `docs/MDE_README.md` - mockup do desktop.
- `docs/mde_system_modules.md` - módulos planejados do MDE.
- `docs/test_snapshot_rollback.md` - plano de testes e rollback.
- `docs/roadmap.md` - roadmap de lançamento.
- `docs/sukuna_store_and_dcl.md` - design da Sukuna Store e DCL.
- `docs/king_of_curses.md` - especificação de segurança LSM.
- `docs/malevolent_domain_integration.md` - integração de sandboxing.
- `docs/sukuna_securityd.md` - detalhes do daemon de segurança.
- `docs/devkit.md` - especificação do Sukuna Dev Kit.
- `docs/LSM_BUILD.md` - como compilar o LSM POC.
- `docs/sukuna_ai_docs.md` - plano básico para SukunaAI.
- `docs/installer_integration.md` - integração do instalador live.
- `docs/iso_build_guide.md` - guia completo de build, testes e troubleshooting da ISO.

## Componentes de código

- `mde/mockup/Main.qml` - mockup interativo do MDE.
- `src/king_of_curses_lsm.c` - POC de LSM kernel.
- `src/sukuna_securityd.py` - daemon de segurança.
- `src/sukuna_securityctl.py` - CLI de segurança.
- `src/malevolent_runner.py` - runner de sandbox Malevolent Domain.
- `src/sukuna_installer_backend.py` - backend de instalação POC.
- `src/sukuna_installer_gui.py` - instalador visual POC.
- `src/sukuna_store_server.py` - backend POC da loja.
- `src/sukuna_dcl_wrapper.py` - wrapper DCL para Windows apps.
- `src/sukuna_ai_poc.py` - assistente AI POC.

## Scripts e utilitários

- `scripts/build_kernel.sh` - build do kernel.
- `scripts/apply_patches.sh` - aplica patches do kernel.
- `scripts/install_devkit.sh` - instalador do Dev Kit.
- `scripts/setup_dev_workspace.sh` - setup de workspace dev.
- `scripts/create_persistent_usb.sh` - cria uma mídia USB persistente a partir da ISO.
- `tools/netlink_test.py` - teste de Netlink para o LSM.

## Assets

- `assets/sukunaos-logo.svg` - logo vetorial.
- `assets/brand-guidelines.md` - guidelines de marca.
- `assets/wallpaper-1.svg` - wallpaper `Malevolent Shrine`.
- `assets/wallpaper-2.svg` - wallpaper `Cleave/Dismantle`.
- `assets/sounds-guide.md` - guia de sons.

## Como usar este repositório

1. Leia `README.md` e `README_KERNEL.md`.
2. Use os docs de cada componente para validar arquitetura.
3. Execute os POCs em `src/` e `scripts/` conforme necessário.
4. Abra `mde/mockup/main.py` para revisar a experiência visual do MDE.
5. Integre assets e refine os mockups para um release visual.
