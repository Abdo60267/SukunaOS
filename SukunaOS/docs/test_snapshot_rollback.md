# Plano de testes, snapshots e rollback

## Objetivo

Garantir que atualizações, instalações e alterações de sistema possam ser revertidas de forma confiável, e que o sistema seja testado automaticamente antes do rollout.

## Estratégia de snapshots

- Usar `Btrfs` ou `ZFS` para snapshots do sistema raiz.
- Snapshots automáticos antes de atualizações de pacotes e mudanças de drivers.
- Interface de rollback com um clique no MDE.
- Snapshot carry-forward para pontos seguros de atualização.

## Fluxo de rollback

1. Atualização iniciada.
2. Criar snapshot `before-update-<timestamp>`.
3. Aplicar atualização no ambiente de teste.
4. Se a atualização falhar, restaurar snapshot automaticamente.
5. Se o usuário desejar, rollback manual via MDE.

## Testes de validação

- `smoke-test` de boot em VM com cada snapshot.
- Validação de rede, GPU, armazenamento e login.
- Testes de regressão de aplicativos críticos.
- Testes de performance de I/O com `fio`/`phoronix`.

## Ferramentas de suporte

- `Dismantle Cleaner`: limpeza inteligente de cache e arquivos temporários entre snapshots.
- `Cleave Performance Engine`: monitora e corta processos inúteis antes de snapshots.
- `sukuna-snapshotctl`: CLI para criar/listar/restaurar snapshots.

## Recomendações

- Snapshots diários por padrão quando o sistema estiver ocioso.
- Snapshots antes de instalação de drivers ou apps Windows importantes.
- Retenção configurável: 7 dias de snapshots automáticos, 30 dias de snapshots manuais.
