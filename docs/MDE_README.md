# MDE Mockup (Qt/QML)

Este mockup demonstra a aparência e o fluxo inicial do `Malevolent Desktop Environment` usando Qt Quick (QML) e PySide6.

## Pré-requisitos

- Python 3.8+
- PySide6: `pip install PySide6`

## Executando

```bash
python3 mde/mockup/main.py
```

## O que o mockup mostra

- Boot/splash `Opening Malevolent Domain`.
- Desktop com wallpaper oficial, selo central, cortes e dock.
- Menu `Malevolent Shrine` com catálogo de apps.
- Janelas simuladas para `Files`, `Terminal`, `Store`, `Settings`, `Security`, `DCL` e `Rituals`.
- `Domain Control` no topo direito com rede, áudio, rollback, VPN, perfil de performance e estado do `Cleave Guard`.
- Terminal fake `cursed-bash` com comandos como `help`, `neofetch`, `domain-status`, `binding-vows` e `sudo king-of-curses`.
- Painel `Uraume AI` como assistente local do sistema.
- Notificações de sistema com linguagem visual do SukunaOS.

## Intenção

O mockup não é o MDE final, mas define a experiência alvo: um sistema operacional real com identidade Sukuna presente em cada superfície, não apenas um tema escuro com vermelho e dourado.

## Próximo passo técnico

As telas simuladas devem virar componentes nativos em C++/Qt/QML, conversando com serviços separados:

- `sukuna-securityd` para segurança e políticas.
- `sukuna-store-server` para catálogo e instalação.
- `sukuna-dcl-wrapper` para apps Windows.
- `sukuna-ai-agent` para Uraume AI.
- gerenciador de snapshots para rollback.
