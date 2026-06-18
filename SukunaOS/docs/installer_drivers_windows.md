# Instalador, drivers e compatibilidade Windows

## Objetivo

Criar um instalador simples e confiável que coloque o SukunaOS no mesmo nível de facilidade de uso do Windows, oferecendo instalação amigável, detecção automática de hardware e compatibilidade ampla com programas Windows.

## Fluxo do instalador

1. **Live environment** inicializa com instalador GUI.
2. **Verificação de hardware** identifica CPU, GPU, storage, Wi-Fi e placa de rede.
3. **Seleção de disco** com suporte a instalação lado a lado e particionamento automático.
4. **Configuração de usuário** com escolha de idioma, timezone e credenciais.
5. **Driver installer** instala automaticamente drivers proprietários e open source.
6. **Configuração Windows apps** instala Wine/Proton e configura o DCL.
7. **Finalização** gera snapshot de backup inicial e reinicia.

## Driver Manager

- Detecta automaticamente GPUs Nvidia, AMD e Intel.
- Suporte a drivers proprietários e open-source.
- Atualizações contínuas automáticas via repositório Sukuna.
- Integração com `Driver Manager Service` que monitora hardware e aplica updates.
- Inclui instalação DKMS para módulos personalizados e recompilação automática após atualizações de kernel.

## Compatibilidade Windows

### Domain Compatibility Layer (DCL)

- Camada integrada que abstrai Wine, Proton e prefixos.
- Permite duplo clique em `.exe` e `msi` para instalar.
- Cria prefixos isolados em `/var/lib/sukuna/dcl/prefixes/`.
- Gera atalho `.desktop` automático para apps instalados.
- Suporta ambiente GPU via DXVK, VKD3D e performance tuning.

### Instalação de aplicativos Windows

- Arquivos `.exe` são detectados pelo gerenciador de arquivos.
- O instalador solicita análise via `Malevolent Domain` para binários desconhecidos.
- Em caso de veredicto seguro, o app é instalado no prefixo.
- O Store mostra compatibilidade e status de instalação em cada app.

## Recursos do instalador

- `sukuna-installer` em C#/.NET com UI estilo Windows.
- `sukuna-driver-manager` daemon para atualizações e detecção por BIOS/ACPI.
- Suporte a `Secure Boot` e imagens de inicialização personalizadas.
- Opção de `Modo Novato` com assistente passo a passo.

## Estratégia de QA

- Teste em VMs e hardware real.
- Verificação de drivers em Nvidia, AMD, Intel e Wi-Fi comuns.
- Validação de boot e rollback após instalação.
- Teste de compatibilidade `Wine/Proton` com jogos e apps populares.
