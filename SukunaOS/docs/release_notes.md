# SukunaOS Release Notes

## Versão inicial de protótipo

Este repositório contém a primeira versão conceitual do SukunaOS. Ele inclui:

- Documentação de arquitetura completa.
- POCs de kernel customizado, segurança e compatibilidade.
- Sukuna Store e Domain Compatibility Layer.
- Sukuna Dev Kit com templates e scripts de setup.
- Mockup de desktop e identidade visual.
- ISO builder usando Debian live-build.
- Instalador GUI protótipo.
- SukunaAI assistente POC.

## O que está disponível

- Script `scripts/build_iso.sh` para gerar uma ISO live bootável.
- `live/README.md` com instruções de build.
- `src/sukuna_installer_gui.py` como instalador gráfico de POC.
- `src/sukuna_securityd.py` e `src/king_of_curses_lsm.c` para segurança.
- `src/sukuna_store_server.py` e `src/sukuna_dcl_wrapper.py` para Store/DCL.
- `docs/` com todos os planos e especificações.

## Próximos passos para um release real

- Implementar o instalador real com particionamento e UEFI.
- Construir o MDE nativo em C++/Qt com suporte Wayland.
- Criar pacotes nativos e um repositório apt completo.
- Integrar o `king_of_curses` LSM com userspace de segurança.
- Validar drivers e compatibilidade com hardware real.
- Refinar a imagem ISO para inclusão de instalador e live environment.
- Adicionar testes automatizados de boot, aplicações e rollback.

## Observação

Este projeto é uma base de desenvolvimento. Ele ainda não é uma distribuição pronta para produção, mas agora contém quase todas as peças necessárias para avançar à fase de implementação real.
