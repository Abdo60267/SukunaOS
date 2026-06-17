#!/usr/bin/env python3
"""
SukunaAI POC - Assistente local básico para comandos e sugestões.

Este POC expõe um CLI simples que sugere comandos e revisa mensagens de erro.
"""

import argparse
import subprocess
import sys


def suggest_command(error_text):
    if 'command not found' in error_text:
        return 'Tente instalar o pacote correto ou use `sudo apt install <nome>`.'
    if 'permission denied' in error_text.lower():
        return 'Verifique permissões ou execute o comando com sudo se for seguro.'
    return 'Revise o comando e tente novamente. Se precisar, use `sukuna-ai help`.'


def run_command(command):
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        return result.returncode, result.stdout, result.stderr
    except Exception as exc:
        return 1, '', str(exc)


def main():
    parser = argparse.ArgumentParser(description='SukunaAI POC local assistant')
    parser.add_argument('--cmd', help='Comando a executar ou analisar')
    args = parser.parse_args()

    if not args.cmd:
        print('Use --cmd "<comando>" para executar ou analisar um comando.')
        sys.exit(1)

    code, out, err = run_command(args.cmd)
    if code == 0:
        print('Comando executado com sucesso:\n', out)
    else:
        print('Erro ao executar comando:\n', err)
        print('\nSugestão SukunaAI:')
        print(suggest_command(err))


if __name__ == '__main__':
    main()
