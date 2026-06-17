# sukuna-securityd — documentação POC

Endpoints (UNIX socket): `/run/sukuna-securityd.sock`

Commands (JSON lines):
- `{"cmd":"check","path":"/path/to/file"}` — verifica cache, analisa se necessário
- `{"cmd":"add","path":"/path/to/file","verdict":"safe"}` — adiciona manualmente
- `{"cmd":"list"}` — lista entradas recentes
- `{"cmd":"status"}` — retorna `ok`

Banco de dados:
- Local: `/var/lib/sukuna/security.db` (SQLite)

Integração:
- chama `/opt/sukuna/malevolent-runner.py analyze` quando o artefato não está em cache

Deploy (POC):
1. Copiar arquivos para `/opt/sukuna/`:
```bash
sudo mkdir -p /opt/sukuna
sudo cp src/sukuna_securityd.py /opt/sukuna/
sudo cp src/sukuna_securityctl.py /opt/sukuna/
sudo chmod +x /opt/sukuna/sukuna_securityd.py /opt/sukuna/sukuna_securityctl.py
```
2. Copiar unit para `/etc/systemd/system/sukuna-securityd.service` e enable/start:
```bash
sudo cp systemd/sukuna-securityd.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now sukuna-securityd
```
