# Sukuna Store & Domain Compatibility Layer (DCL) — especificação

Visão geral
-----------
Sukuna Store é a loja unificada do SukunaOS que oferece apps em múltiplos formatos (Flatpak, Snap, AppImage, .deb, e programas Windows via DCL). A loja integra curadoria, build pipelines, assinaturas e sandboxing automático via Malevolent Domain.

Componentes principais
- Frontend: cliente integrado ao MDE, com busca, ratings, categorias e instalação com um clique.
- Backend: API REST, indexação e banco local (SQLite/Postgres). Gerencia metadados, builds e assinaturas.
- Build pipeline: CI que converte/empacota apps para múltiplos formatos.
- DCL (Domain Compatibility Layer): camada que orquestra Wine/Proton, cria prefixos, aplica patches e habilita dupla clique para .exe.
- Segurança: integração com `King of Curses` e Malevolent Domain para análise pré-instalação.

Principais requisitos
- Instalação com um clique para usuários.
- Suporte a Flatpak/Snap/AppImage/DEB + Windows .exe
- Sandboxed por padrão; opção de instalação global explicada ao usuário.
- Verificação e assinatura de pacotes.
- Rollback fácil via snapshots antes da instalação.

API (endpoints essenciais)
- `GET /api/apps?q=...` — busca e filtros
- `GET /api/apps/{id}` — metadados da app
- `POST /api/apps/upload` — upload/registro (admin/curadoria)
- `POST /api/apps/{id}/install` — instala o app (body: {format: "flatpak"|"deb"|"dcl", user_scope: true/false})
- `POST /api/apps/{id}/analyze` — solicita análise por Malevolent Domain
- `GET /api/categories`, `POST /api/ratings` etc.

DB Schema (simplificado)
- `apps` (id, name, short_desc, long_desc, author, categories, icon_path, created_at)
- `packages` (id, app_id, format, version, filename, checksum, signature, repo_url, created_at)
- `ratings` (id, app_id, user, score, comment, created_at)
- `builds` (id, package_id, status, log, created_at)

Flow de instalação (exemplo .exe -> DCL)
1. Usuário clica em `.exe` no Files app ou na Store.
2. MDE chama backend `/api/apps/dcl/install` ou executa `sukuna-dcl install /path/to/file`.
3. DCL cria um Wine/Proton prefix isolado ou usa containerized Proton, analisa o binário (Malevolent Domain se desconhecido).
4. DCL instala o app no prefix, gera atalho desktop (XDG .desktop) e registra no Store local.

DCL design (componentes)
- `dclctl` (CLI): comandos `install`, `run`, `uninstall`, `create-prefix`, `list-prefixes`.
- `dcl-agent` (daemon): gerencia prefixos, updates, integração com Driver Manager e Proton.
- Wrappers: `sukuna-dcl-install` invoca Proton/Wine com parâmetros otimizados (DXVK, esync, fsync, env vars de performance).
- Metadata translator: gera `package` records (icon, name, exe path) a partir de instalador .exe ou MSI.

Sandbox e segurança
- Antes de instalar um .exe desconhecido, enviar para `Malevolent Domain` para análise (estático + dinâmico).
- Se veredicto `malicious`, bloquear e alertar; se `suspicious`, pedir confirmação do usuário com detalhes.
- Instalações via DCL, por padrão, usam prefix isolado em `/var/lib/sukuna/dcl/prefixes/<id>`.

Pipeline de build e curadoria
- CI automatizado que pega repositórios/sources, cria pacotes Flatpak/Snap/AppImage e builds .deb.
- Geração automática de metadados, captura de screenshots e testes básicos (Smoke tests).
- Build artifacts assinados com chave da Sukuna Store.

UX & integrações
- Suporte a arrastar .exe para a Store para iniciar processo de empacotamento/análise.
- Notificações MDE para progresso de instalação, rollback e avaliação de compatibilidade.

Segurança operacional
- Signatures: todos pacotes assinam (GPG) e verificam no cliente.
- Scanning: King of Curses + malevolent-runner antes da publicação.
- Reversão: criar snapshot antes de ação de instalação e registrar ponto de rollback.

Extensibilidade
- Plugins de empacotamento para formatos adicionais.
- Hooks para integração com Proton upstream e Valve tooling.
