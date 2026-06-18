# MDE System Modules

Este documento transforma o protótipo visual do MDE em módulos de sistema que podem ser implementados de verdade.

## Shell

- `Top Bar`: status do domínio, relógio, menu do sistema e acesso ao `Domain Control`.
- `Dock`: apps fixos, estado de execução e atalhos para Uraume.
- `Start Menu / Malevolent Shrine`: busca de apps, rituais, configurações e ferramentas.
- `Window Manager`: abertura, foco, fechamento e animações de janelas.

## Apps Nativos

- `Sukuna Files`: gerenciador de arquivos com vaults, snapshots e áreas DCL.
- `Cursed Terminal`: terminal com integração ao `sukuna-securityctl`, snapshots e diagnóstico.
- `Sukuna Store`: frontend para apps nativos, Flatpak, AppImage, DEB e DCL.
- `Domain Settings`: configurações de aparência, rede, performance, segurança e Uraume AI.
- `King of Curses Security`: painel de LSM, firewall, sandbox e auditoria.
- `Domain Compatibility Layer`: gerenciador de prefixos Wine/Proton e apps Windows.
- `Shrine Snapshots`: rollback, pontos de restauração e recuperação pós-update.
- `Uraume AI`: assistente local contextual.

## Estados Do Sistema

- `Human`: perfil silencioso e econômico.
- `Vessel`: perfil equilibrado para uso diário.
- `King`: perfil máximo para jogos, render e workloads pesados.
- `Safe Domain`: modo seguro com DCL desligado e políticas restritivas.

## Segurança

- `Cleave Guard`: bloqueio rápido de execução suspeita.
- `Dismantle Scan`: análise de binários, scripts e instaladores.
- `Malevolent Domain`: sandbox local para abrir arquivos desconhecidos.
- `Binding Vows`: contratos de permissão por app.
- `Shrine Rollback`: snapshot obrigatório antes de updates críticos.

## Integração Com Serviços

- `sukuna-securityd`: estado de políticas e eventos de segurança.
- `sukuna-store-server`: catálogo, formatos e instalação.
- `sukuna-dcl-wrapper`: criação e isolamento de prefixos Windows.
- `malevolent-runner`: execução isolada de artefatos suspeitos.
- `sukuna-ai-agent`: chat local, sugestões de terminal e leitura de logs.

## Critério Visual

Cada app precisa carregar pelo menos um motivo Sukuna de forma funcional:

- cortes diagonais para progresso, scanning ou alerta;
- selo circular para proteção, assinatura ou estado seguro;
- shrine/altar para instalação, rollback e ações irreversíveis;
- vermelho para risco/ação, ouro para estado selado/confirmado.
