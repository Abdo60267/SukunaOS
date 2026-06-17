# SukunaOS Installer Integration

Este documento descreve a integração entre o frontend do instalador e o backend no ambiente live do SukunaOS.

## Componentes

- `src/sukuna_installer_gui.py`: instalador gráfico Qt/PySide6.
- `src/sukuna_installer_backend.py`: backend de instalação que formata partições, monta o sistema de arquivos, executa `debootstrap` e configura o sistema.
- `scripts/build_iso.sh`: script de criação da ISO live que injeta o repositório em `/opt/sukuna`.

## Fluxo de instalação

1. O usuário inicia o live media e abre o instalador GUI.
2. O instalador pede o dispositivo de destino, nome de usuário e senha.
3. O GUI chama o backend `src/sukuna_installer_backend.py install ...`.
4. O backend formata a partição selecionada, monta-a em `/mnt/sukuna` e executa `debootstrap`.
5. Após a finalização, o backend configura hostname, usuário inicial, senha e `sources.list`.
6. O usuário reinicia o sistema para iniciar o SukunaOS instalado.

## Requisitos do ambiente live

- `live-build` e `squashfs-tools` para criar a mídia.
- `debootstrap` para bootstrap do sistema alvo.
- `grub-pc` e `grub-efi-amd64` para suporte a boot EFI.
- `python3` para executar os scripts POC.

## Testes recomendados

- Testar em um ambiente virtualizado (qemu, VirtualBox, VMware).
- Executar `python3 src/sukuna_installer_backend.py list-disks` no live para verificar os dispositivos.
- Usar uma partição de teste ou disco virtual para evitar perda de dados.

## Limitações atuais

- O backend atual formata diretamente a partição como `ext4`.
- Não há suporte a LVM, criptografia de disco ou RAID no POC.
- A instalação de GRUB EFI presume a presença de uma partição EFI montável.
- O instalador não oferece interface de particionamento gráfico ainda.

## Próximos passos

- Adicionar suporte a particionamento automático/manual no frontend.
- Criar um serviço de instalação completo que detecte partições e configure UEFI automaticamente.
- Incluir suporte a snapshots e rollback pós-instalação.
- Melhorar o backend para copiar assets Sukuna e configurar o MDE nativo.
