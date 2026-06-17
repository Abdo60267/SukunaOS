# King of Curses LSM — especificação

Resumo
-------
O `King of Curses` é um LSM (Linux Security Module) leve, focado em proteger endpoints de desktop e gamer do SukunaOS. Objetivos:
- Bloquear execuções não autorizadas (política por assinatura/whitelist)
- Proteger diretórios sensíveis (home, /etc, /srv/maledomin)
- Integrar com Malevolent Domain para análise de arquivos suspeitos
- Fornecer hooks de auditoria para o `Sukuna Store` e `SukunaAI`

Modelo de política
-------------------
- Política híbrida: whitelist por hash/assinatura + regras contextuais.
- Regras armazenadas em userspace (SQLite) gerenciado por `sukuna-securityd`.
- Comunicação kernel↔userspace via netlink para consultas de decisão em tempo real (com fallback local cache).

Casos de uso principais
----------------------
- Execução de binários: checar assinatura/whitelist; se desconhecido, negar execução ou redirecionar para Malevolent Domain para análise.
- Acesso a arquivos sensíveis: bloquear gravação em `/etc` fora de pacotes confiáveis; monitorar modificações em tempo real.
- Proteção contra escalation: controlar capabilities e execve de processos com privilégios.

Design técnico
------------
- Hooks LSM usados (exemplos): `bprm_check_security`, `inode_permission`, `task_alloc`, `file_open`, `ptrace_access_check`.
- Mecanismo de decisão: tentativas rápidas usando cache in-kernel; se cache miss → consulta via netlink para `sukuna-securityd`.
- Política assinada: store publica chaves trusted; atualizações via Sukuna Store.
- Modo permissivo/learning: inicialmente coleta telemetria para criar whitelist.

Integração com Malevolent Domain
--------------------------------
- Quando `bprm` encontra binário desconhecido, opcionalmente envia artefato para Malevolent Domain em modo isolado para análise automática.
- Resultado (safe/malicious/unknown) retorna para LSM via userspace e decisão é aplicada.

Admin & UX
----------
- `sukuna-securityctl` CLI para gerir whitelist, revisar logs, colocar regras em modo aprendizagem.
- Integração com MDE Control Center para alertas e opções de rollback (usar snapshots).

Performance & fallback
----------------------
- Cache in-kernel com TTL para evitar chamadas userspace frequentes.
- Modo offline com política conservadora (deny-by-default para execução não-assinada) ou permissiva conforme preferência do usuário.

Roadmap de implementação POC
----------------------------
1. Implementar LSM mínimo com `bprm_check_security` que consulta um cache in-kernel e nega execve para hashes não-allowlist.
2. Implementar userspace `sukuna-securityd` que responde a consultas via netlink e mantém DB local.
3. Integrar fluxo com Malevolent Domain para análise automatizada.
4. Adicionar políticas de arquivos e capabilities.

Segurança e privacidade
----------------------
- Todo tráfego para análise remota exige consentimento explícito; padrão é local-only.
- Logs sensíveis encriptados em repouso; acesso auditado.
