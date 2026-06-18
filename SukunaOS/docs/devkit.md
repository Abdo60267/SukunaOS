# Sukuna Dev Kit — especificação e instalação

Visão geral
-----------
O Sukuna Dev Kit fornece um conjunto de toolchains, SDKs e templates para programadores em C, C++, Python, Java, C#, Rust, Go, Lua e JavaScript. Inclui scripts de instalação, configurações recomendadas e templates de projeto para início rápido.

Componentes incluídos
- Compiladores: `gcc`, `g++`, `clang`, `clang++`
- Java: `OpenJDK 17+` (via apt/openjdk or sdkman)
- .NET: `dotnet` SDK (instalador oficial)
- Python: Python 3.11+, `pip`, `venv`
- Rust: `rustup` + toolchain estável
- Go: `go` (1.20+)
- Node.js: `node` + `npm` (LTS)
- Tools: `git`, `cmake`, `make`, `ninja`, `pkg-config`, `docker`/`podman`
- Extras: `docker`, `podman`, `openjdk`, `maven` (opcional)

Instalação (Linux Debian/Ubuntu/Kali base)
--------------------------------------
1. Atualize pacotes:

```bash
sudo apt update && sudo apt upgrade -y
```

2. Execute o instalador de Dev Kit (requere permissões):

```bash
sudo bash scripts/install_devkit.sh
```

O script instala componentes principais via `apt` e instala `rustup`, `go` e `dotnet` onde aplicável. Ele tenta não sobrescrever configurações do usuário e oferece instruções finais para adicionar variáveis de ambiente (por exemplo `~/.profile`).

Templates
---------
Templates de projeto ficam em `devkit/templates/` e incluem exemplos mínimos para cada linguagem suportada.

Uso recomendado
---------------
- Configure `git` e chaves SSH: `git config --global user.name "Your Name"` e `git config --global user.email you@example.com`.
- Use `venv` para projetos Python e `cargo` para Rust.
- Configure `dotnet` e `maven` para projetos Java/C#.

Notas
-----
- Este é um instalador de referência para ambientes de desenvolvimento. Em imagens oficiais do SukunaOS, muitos componentes virão pré-instalados ou empacotados de forma otimizada.
- Para ambientes corporativos, adapte o script para mirrors internos e políticas de proxy.
