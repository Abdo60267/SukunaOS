# SukunaAI Integration Plan

## Objetivo

Criar um assistente de IA nativo que ajude usuários com:
- Sugestões de terminal
- Solução de problemas de instalação
- Correção de erros
- Automatização de tarefas comuns
- Ajuda contextual no desktop

## Componentes

- `sukuna-ai-agent`: daemon local que utiliza modelos leves ou integração com serviços remotos.
- `sukuna-ai-frontend`: UI no MDE para chat, sugestões e notificações.
- `sukuna-ai-connector`: adaptador para comandos de terminal e análise de logs.

## Funcionalidade inicial

- Modo Novato com assistente passo a passo.
- Sugestões de comandos com base em erro de terminal.
- Captura de logs simples e recomendações de correção.
- Integração com o `Sukuna Store` para instalar dependências automaticamente.

## Arquitetura

- Backend local processando consultas de texto.
- Cache de respostas e histórico de sessão.
- Política de privacidade: processamento local por padrão, dados nunca enviados sem consentimento.

## Roadmap

1. Build POC local (já existe `src/sukuna_ai_poc.py`).
2. Adicionar UI no MDE para chat e sugestões.
3. Expandir com plugins para terminal, store e segurança.
4. Integrar com processamento local offline/online.
