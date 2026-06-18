#!/usr/bin/env python3
"""
SukunaOS Installer GUI prototype.

This installer frontend is a richer proof-of-concept for live installation.
"""

import json
import subprocess
import sys
from pathlib import Path

from PySide6.QtCore import QProcess
from PySide6.QtWidgets import (
    QApplication,
    QDialog,
    QFormLayout,
    QGroupBox,
    QHeaderView,
    QLineEdit,
    QMessageBox,
    QPlainTextEdit,
    QPushButton,
    QTableWidget,
    QTableWidgetItem,
    QVBoxLayout,
    QWizard,
    QWizardPage,
)


SUKUNA_STYLE = """
QWizard, QDialog {
    background: #080304;
    color: #f4e6cf;
}
QWizardPage {
    background: #080304;
}
QLabel {
    color: #f4e6cf;
}
QGroupBox {
    color: #e6b84d;
    border: 1px solid #4a1519;
    border-radius: 7px;
    margin-top: 14px;
    padding: 12px;
    background: #120608;
}
QGroupBox::title {
    subcontrol-origin: margin;
    left: 12px;
    padding: 0 6px;
}
QLineEdit, QPlainTextEdit, QTableWidget {
    background: #120608;
    color: #f4e6cf;
    border: 1px solid #3a1216;
    border-radius: 6px;
    selection-background-color: #b30d18;
    selection-color: #fff4df;
}
QHeaderView::section {
    background: #210b0e;
    color: #e6b84d;
    border: 1px solid #3a1216;
    padding: 6px;
}
QPushButton {
    background: #2b0b0f;
    color: #f4e6cf;
    border: 1px solid #b30d18;
    border-radius: 6px;
    padding: 8px 12px;
}
QPushButton:hover {
    background: #3b1015;
    border-color: #e6b84d;
}
QPushButton:disabled {
    background: #16080a;
    color: #8d7565;
    border-color: #321014;
}
"""


class WelcomePage(QWizardPage):
    def __init__(self):
        super().__init__()
        self.setTitle("Entre no Domínio do SukunaOS")
        layout = QVBoxLayout()
        layout.addWidget(QLineEdit())
        self.setLayout(layout)
        label = QPlainTextEdit()
        label.setReadOnly(True)
        label.setPlainText(
            "Bem-vindo ao instalador SukunaOS.\n\n"
            "Este ritual prepara o usuário inicial, escolhe o altar de destino "
            "e sela a instalação base.\n"
            "Antes de prosseguir, confirme que a partição escolhida pode ser formatada."
        )
        layout.addWidget(label)


class UserPage(QWizardPage):
    def __init__(self):
        super().__init__()
        self.setTitle("Pacto do Usuário")
        self.setSubTitle("Defina a conta inicial que vai abrir o domínio.")

        self.username = QLineEdit()
        self.password = QLineEdit()
        self.password.setEchoMode(QLineEdit.Password)
        self.confirm_password = QLineEdit()
        self.confirm_password.setEchoMode(QLineEdit.Password)

        form = QFormLayout()
        form.addRow("Nome de usuário:", self.username)
        form.addRow("Senha:", self.password)
        form.addRow("Confirme a senha:", self.confirm_password)

        self.registerField("username*", self.username)
        self.registerField("password*", self.password)
        self.registerField("confirm_password*", self.confirm_password)

        box = QGroupBox("Selo de acesso")
        box.setLayout(form)

        layout = QVBoxLayout()
        layout.addWidget(box)
        self.setLayout(layout)

    def validatePage(self):
        if self.password.text() != self.confirm_password.text():
            QMessageBox.warning(self, "Senha incompatível", "As senhas não coincidem. Por favor, verifique.")
            return False
        if len(self.password.text()) < 6:
            QMessageBox.warning(self, "Senha curta", "A senha deve ter pelo menos 6 caracteres.")
            return False
        return True


class PartitionPage(QWizardPage):
    def __init__(self):
        super().__init__()
        self.setTitle("Altar de Destino")
        self.setSubTitle("Escolha a partição onde o SukunaOS será selado.")

        self.partition = QLineEdit()
        self.partition.setPlaceholderText("/dev/sda1")
        self.registerField("partition*", self.partition)

        self.disk_table = QTableWidget(0, 5)
        self.disk_table.setHorizontalHeaderLabels(["Nome", "Tamanho", "Tipo", "Ponto de montagem", "Modelo"])
        self.disk_table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.disk_table.setSelectionBehavior(QTableWidget.SelectRows)
        self.disk_table.setEditTriggers(QTableWidget.NoEditTriggers)

        self.refresh_button = QPushButton("Invocar discos")
        self.refresh_button.clicked.connect(self.load_disks)

        layout = QVBoxLayout()
        layout.addWidget(self.refresh_button)
        layout.addWidget(self.disk_table)
        layout.addWidget(QLineEdit("Digite a partição de destino acima ou selecione uma linha."))
        layout.addWidget(self.partition)
        self.setLayout(layout)

        self.disk_table.itemSelectionChanged.connect(self.on_selection_changed)
        self.load_disks()

    def on_selection_changed(self):
        selected = self.disk_table.selectedItems()
        if selected:
            self.partition.setText(selected[0].text())

    def load_disks(self):
        backend = Path(__file__).resolve().parent / "sukuna_installer_backend.py"
        if not backend.exists():
            QMessageBox.critical(self, "Erro", "Backend de instalação não encontrado.")
            return

        try:
            result = subprocess.run([
                sys.executable,
                str(backend),
                "list-disks",
            ], check=True, capture_output=True, text=True)
            data = json.loads(result.stdout)
            self.populate_table(data)
        except subprocess.CalledProcessError as exc:
            QMessageBox.critical(self, "Erro", f"Falha ao obter discos: {exc.stderr}")
        except json.JSONDecodeError:
            QMessageBox.critical(self, "Erro", "Resposta inválida do backend de disco.")

    def populate_table(self, data):
        self.disk_table.setRowCount(0)
        for device in data.get("blockdevices", []):
            self.add_device(device)

    def add_device(self, device, parent_name=""):
        name = device.get("name", "")
        size = device.get("size", "")
        typ = device.get("type", "")
        mountpoint = device.get("mountpoint", "")
        model = device.get("model", "")
        if typ in ("disk", "part"):
            row = self.disk_table.rowCount()
            self.disk_table.insertRow(row)
            self.disk_table.setItem(row, 0, QTableWidgetItem(f"/dev/{name}"))
            self.disk_table.setItem(row, 1, QTableWidgetItem(size))
            self.disk_table.setItem(row, 2, QTableWidgetItem(typ))
            self.disk_table.setItem(row, 3, QTableWidgetItem(mountpoint))
            self.disk_table.setItem(row, 4, QTableWidgetItem(model))
        for child in device.get("children", []):
            self.add_device(child, parent_name=name)


class SummaryPage(QWizardPage):
    def __init__(self):
        super().__init__()
        self.setTitle("Selo Final")
        self.setSubTitle("Verifique o pacto antes de iniciar a instalação.")
        self.summary = QPlainTextEdit()
        self.summary.setReadOnly(True)
        layout = QVBoxLayout()
        layout.addWidget(self.summary)
        self.setLayout(layout)

    def initializePage(self):
        username = self.field("username")
        partition = self.field("partition")
        self.summary.setPlainText(
            f"Usuário: {username}\n"
            f"Altar de destino: {partition}\n"
            "\nCertifique-se de que esta partição pode ser formatada."
        )


class ProgressDialog(QDialog):
    def __init__(self, command):
        super().__init__()
        self.setWindowTitle("Ritual de instalação em andamento")
        self.resize(700, 400)

        self.log = QPlainTextEdit()
        self.log.setReadOnly(True)
        self.progress = QPushButton("Cancelar")
        self.progress.clicked.connect(self.reject)

        layout = QVBoxLayout()
        layout.addWidget(self.log)
        layout.addWidget(self.progress)
        self.setLayout(layout)

        self.process = QProcess(self)
        self.process.setProgram(command[0])
        self.process.setArguments(command[1:])
        self.process.setProcessChannelMode(QProcess.MergedChannels)
        self.process.readyReadStandardOutput.connect(self.on_output)
        self.process.finished.connect(self.on_finished)

    def start(self):
        self.process.start()
        return self.exec()

    def on_output(self):
        data = self.process.readAllStandardOutput()
        text = bytes(data).decode("utf-8", errors="ignore")
        self.log.appendPlainText(text)

    def on_finished(self, exit_code, status):
        if exit_code == 0:
            self.log.appendPlainText("\nDomínio selado com sucesso.")
            self.progress.setText("Fechar")
        else:
            self.log.appendPlainText(f"\nO ritual falhou com código {exit_code}.")
            self.progress.setText("Fechar")


class InstallerWizard(QWizard):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("SukunaOS Installer - Malevolent Domain")
        self.setWizardStyle(QWizard.ModernStyle)
        self.addPage(WelcomePage())
        self.addPage(UserPage())
        self.addPage(PartitionPage())
        self.addPage(SummaryPage())

    def accept(self):
        username = self.field("username")
        password = self.field("password")
        partition = self.field("partition")
        backend = Path(__file__).resolve().parent / "sukuna_installer_backend.py"

        if not backend.exists():
            QMessageBox.critical(
                self,
                "Erro",
                "Backend de instalação não encontrado. Verifique se o arquivo "
                "src/sukuna_installer_backend.py está disponível.",
            )
            return

        if not partition.startswith("/dev/"):
            QMessageBox.warning(
                self,
                "Partição inválida",
                "Informe um dispositivo de destino válido, por exemplo /dev/sda1.",
            )
            return

        command = [
            sys.executable,
            str(backend),
            "install",
            "--partition",
            partition,
            "--username",
            username,
            "--password",
            password,
            "--hostname",
            "sukunaos",
        ]

        dialog = ProgressDialog(command)
        dialog.start()
        if dialog.process.exitCode() == 0:
            super().accept()
        else:
            QMessageBox.critical(self, "Erro", "A instalação falhou. Verifique o log acima e tente novamente.")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setStyleSheet(SUKUNA_STYLE)
    wizard = InstallerWizard()
    wizard.show()
    sys.exit(app.exec())
