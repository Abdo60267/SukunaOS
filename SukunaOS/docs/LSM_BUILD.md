# Compilando e testando o LSM POC (king_of_curses_lsm)

Este documento descreve como compilar e carregar o POC `king_of_curses_lsm.c` em um sistema de desenvolvimento. Use uma máquina de teste/VM — NÃO carregue em máquinas de produção.

Pré-requisitos
- kernel headers para a versão em execução (ex: `linux-headers-$(uname -r)`)
- ferramentas de build: `make`, `gcc`, `git`

Passos (modo módulo)
1. Copie `src/king_of_curses_lsm.c` para um diretório de trabalho, por exemplo:

```bash
mkdir -p ~/kernel-lsm-poc
cp src/king_of_curses_lsm.c ~/kernel-lsm-poc/
cd ~/kernel-lsm-poc
```

2. Crie um `Makefile` simples:

```makefile
obj-m := king_of_curses_lsm.o
KDIR ?= /lib/modules/$(shell uname -r)/build
all:
	make -C $(KDIR) M=$(PWD) modules
clean:
	make -C $(KDIR) M=$(PWD) clean
```

3. Compile o módulo:

```bash
make
```

4. Carregue o módulo (requer root):

```bash
sudo insmod king_of_curses_lsm.ko
dmesg | tail -n 20
```

5. Teste o fluxo:
- Inicie `sukuna-securityd` (veja `docs/sukuna_securityd.md`).
- Use `tools/netlink_test.py /path/to/binary` como root para enviar um evento `exec_check`.
- Observe logs do `sukuna-securityd` e `dmesg` para ver mensagens do LSM.

Observações e segurança
- O módulo LSM POC faz broadcasts via Netlink e nega execuções desconhecidas. Em ambiente de produção, implemente respostas síncronas e mecanismos de cache apropriados para evitar false-positives.
- Para remover o módulo:

```bash
sudo rmmod king_of_curses_lsm
```
