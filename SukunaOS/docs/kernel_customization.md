# Kernel customizado SukunaOS

## Objetivo

Proporcionar um kernel Linux derivado com otimizações específicas para performance de jogos, segurança reforçada e compatibilidade com drivers proprietários, mantendo estabilidade e facilidade de atualização.

## Base

- Baseado em `linux-stable` ou `linux` upstream.
- Distribuição alvo: Debian/Kali base, com empacotamento `.deb`.
- Ramo principal: `linux-sukuna`.

## Patches e tuning

### Prioridade alta

- `preempt_rt-lite`: caminho de baixa latência sem RT completo.
- Scheduler otimizado para jogos e desktop interativo.
- `zswap` com compressão `zstd` e tuning de memória.
- `io_uring` habilitado e tunado para workloads de GPU/arquivo.
- `king_of_curses` LSM leve para checagens de execução e políticas básicas.
- Otimizações de initramfs para boot rápido e carregamento paralelo de módulos.

### Segurança

- Módulo LSM integrado para controles adicionais de execução e arquivos.
- Hardening: `restrict_kernel_module_loading`, `lockdown`, `spectre/meltdown` mitigations, `page-table-isolation`.
- Suporte a `secure boot` e assinatura de kernel.

### Compatibilidade de drivers

- Suporte DKMS para módulos customizados.
- Hooks para recompilação automática após atualizações de kernel.
- Meta-pacotes `linux-sukuna-image`, `linux-sukuna-headers`, `linux-sukuna-modules`.
- Matcher de hardware para escolher drivers Nvidia/AMD/Intel.

## Processos de build

- Scripts de build local: `scripts/build_kernel.sh`, `ci/debian-package.sh`.
- Aplicação de patches: `scripts/apply_patches.sh`.
- CI: `.github/workflows/build.yml` constrói `x86_64` e `arm64`.
- Empacotamento `.deb` com `bindeb-pkg` ou `kernel-package`.

## POC

- `src/king_of_curses_lsm.c` contém POC de LSM com notificação Netlink.
- `README_KERNEL.md` contém instruções de build local.

## Roadmap de implementação

1. Refino de patch list e configuração do `defconfig` para desktops/games.
2. Testes de boot e módulo via VM.
3. Empacotamento e assinatura de kernel.
4. Distribuição de meta-pacotes e habilitação do Driver Manager.
