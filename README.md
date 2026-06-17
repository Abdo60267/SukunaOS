# SukunaOS

SukunaOS é uma distribuição Linux conceitual inspirada em Ryomen Sukuna de Jujutsu Kaisen, projetada para ser moderna, profissional, segura e amigável para usuários comuns, programadores e gamers.

## Visão geral

- **Kernel**: Linux customizado `linux-sukuna` com foco em performance, segurança e compatibilidade.
- **Desktop**: `Malevolent Desktop Environment (MDE)` com tema escuro, vermelho e dourado.
- **Segurança**: `King of Curses` LSM, sandboxing avançado e análise dinâmica com `Malevolent Domain`.
- **Compatibilidade Windows**: `Domain Compatibility Layer (DCL)` integrado com Wine/Proton.
- **Loja**: `Sukuna Store` unificada para Flatpak, Snap, AppImage, pacotes Debian e apps Windows.
- **Dev Kit**: toolchains para C, C++, Python, Java, C#, Rust, Go, Lua e JavaScript.

## Estrutura do repositório

- `docs/` — especificações, design e roadmaps.
- `src/` — protótipos de componentes, serviços e POCs.
- `scripts/` — scripts de build, instalação e setup.
- `systemd/` — units de serviço POC.
- `mde/` — mockup visual do ambiente de desktop.
- `devkit/` — templates e documentação do Sukuna Dev Kit.
- `tools/` — utilitários de teste e suporte.
- `ci/` — CI de build de kernel.

## Documentos principais

- `docs/king_of_curses.md`
- `docs/malevolent_domain_integration.md`
- `docs/sukuna_store_and_dcl.md`
- `docs/devkit.md`
- `docs/installer_drivers_windows.md`
- `docs/visual_identity.md`
- `docs/test_snapshot_rollback.md`
- `docs/roadmap.md`

## Como usar

1. Leia `README_KERNEL.md` para detalhes de build de kernel.
2. Instale o Dev Kit com `scripts/install_devkit.sh`.
3. Teste o MDE mockup com `mde/mockup/main.py`.
4. Execute o backend da loja em `src/sukuna_store_server.py` se desejar testar a Store POC.
5. Use `scripts/build_iso.sh` para gerar uma ISO live bootável e, no ambiente live, teste o instalador gráfico com `python3 src/sukuna_installer_gui.py`.
6. Para fazer a mídia persistente, use `scripts/create_persistent_usb.sh` em um dispositivo USB maior que a ISO.
7. Veja `docs/iso_build_guide.md` para instruções completas de build, testes em VM e troubleshooting.
8. Quer compartilhar? Veja `docs/tutorial_pegar_iso.md` para um tutorial super simples (até criança entende!).

## Status

Este repositório contém um projeto conceitual completo com docs, POCs de segurança, fluxos de compatibilidade e design. Para converter em uma distribuição real, cada componente precisará ser implementado de forma nativa, empacotado e testado em hardware real.
