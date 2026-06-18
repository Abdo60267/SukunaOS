# Malevolent Domain — Integração com King of Curses

Visão geral
-----------
O objetivo é permitir que binários/artefatos suspeitos sejam enviados automaticamente pelo LSM `King of Curses` (via `sukuna-securityd`) para execução e análise isolada no Malevolent Domain. A análise retorna um veredicto (`safe`, `suspicious`, `malicious`, `unknown`) que é usado para decisão de execução.

Fluxo de alto nível
-------------------
1. `bprm_check_security` detecta binário desconhecido → nega execução temporariamente e envia consulta a `sukuna-securityd`.
2. `sukuna-securityd` verifica cache/local DB; em caso de desconhecido, invoca `malevolent-runner analyze <path>` (CLI) ou usa socket API.
3. `malevolent-runner` cria um ambiente isolado (QEMU microVM / overlay filesystem), injeta o binário e executa heurísticas e sandboxes comportamentais.
4. `malevolent-runner` retorna relatório JSON com evidências e veredicto.
5. `sukuna-securityd` atualiza DB e responde ao kernel via netlink; kernel aplica decisão (permitir, negar, orquedar para análise manual).

Interface CLI (POC)
-------------------
- `malevolent-runner analyze /path/to/file --timeout 30 --no-network`
  - saída JSON no stdout com campos: `verdict`, `score`, `evidence[]`, `trace_log`

API socket (opcional)
----------------------
- UNIX domain socket: `/var/run/malevolent-runner.sock`
- Mensagens JSON: `{ "cmd": "analyze", "path": "/tmp/x" , "opts": {...} }`
- Resposta JSON: `{ "verdict": "safe", "score": 0.12, "id": "inst-1234" }`

Ambiente de execução
---------------------
- Preferencial: Firecracker microVMs para isolamento forte (produção/OEM).
- POC e compatibilidade: QEMU/KVM com imagem mínima (alpine/ubuntu) e overlayfs para evitar gravações.
- Rede: por padrão `--no-network`; caso permitido, utilizar NAT e captura de tráfego para análise.

Heurísticas e análise
----------------------
- Estático: `file`, `strings`, ELF imports, PE imports, digital signature checks, yara rules.
- Dinâmico: executar binário com instrumentation (strace, ltrace), monitorar syscalls, comportamento de rede, criação de processos, escrita em disco.
- Pós-análise: regras para gerar veredicto com pontuação.

Segurança e privacidade
------------------------
- Todo arquivo examinado fica isolado; uploads remotos só com consentimento.
- Logs sensíveis encriptados e retidos conforme política.

Exemplo de integração com `sukuna-securityd`
--------------------------------------------
- `sukuna-securityd` chama `malevolent-runner analyze` em modo bloqueante com timeout configurável.
- Resposta avaliada; se `malicious` → deny and alert user; se `safe` → allow execution and add to allowlist (optional learning mode).

POC limitations
---------------
- POC usa QEMU e heurísticas locais; produção deve migrar para microVMs e motores de análise dedicados.
