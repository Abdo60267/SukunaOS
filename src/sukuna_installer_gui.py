#!/usr/bin/env python3
"""
SukunaOS Installer GUI - Malevolent Domain Edition

Visual identity: 40% macOS (rounded corners, blur, spacing, SF-style typography)
                 60% Sukuna (crimson red, cursed gold, shrine black, domain energy)

Requires: PySide6
"""

import json
import subprocess
import sys
from pathlib import Path

from PySide6.QtCore import QProcess, Qt, QPropertyAnimation, QEasingCurve, QSize
from PySide6.QtGui import (
    QColor, QFont, QFontDatabase, QIcon, QLinearGradient,
    QPainter, QPainterPath, QPalette, QPen, QPixmap,
)
from PySide6.QtWidgets import (
    QApplication,
    QDialog,
    QFormLayout,
    QGraphicsDropShadowEffect,
    QGroupBox,
    QHBoxLayout,
    QHeaderView,
    QLabel,
    QLineEdit,
    QMessageBox,
    QPlainTextEdit,
    QProgressBar,
    QPushButton,
    QSizePolicy,
    QSpacerItem,
    QTableWidget,
    QTableWidgetItem,
    QVBoxLayout,
    QWidget,
    QWizard,
    QWizardPage,
)

# ──────────────────────────────────────────────────────────────────
# Color palette: Carmesim Sukuna + macOS dark mode
# Sukuna references: Domain, cursed energy, red marks, gold seals
# ──────────────────────────────────────────────────────────────────
COLORS = {
    # Backgrounds (Dark shrine aesthetics)
    'bg_base':       '#0a0304',    # Shrine void - pure black with crimson tint
    'bg_surface':    '#140708',    # Karmic domain surface
    'bg_elevated':   '#1d0a0f',    # Elevated cursed layer
    'bg_hover':      '#2a1115',    # Domain expansion hover
    'bg_active':     '#351620',    # Active cursed mark

    # Accent colors (Sukuna's crimson domain - pure ruby red)
    'accent_red':    '#c41020',    # Primary cursed mark (Sukuna's signature red)
    'accent_crimson':'#a50d1a',    # Darker crimson for depth
    'accent_glow':   '#ff1a33',    # Bright domain glow
    'accent_gold':   '#d4a84a',    # Sacred gold seals & marks
    'accent_dark_gold': '#9d7a2f', # Dark gold shadows

    # Text hierarchy (Parchment + translucency)
    'text_primary':  '#f0e6db',    # Primary - sacred parchment
    'text_secondary':'#b89f8f',    # Secondary labels
    'text_tertiary': '#6d5550',    # Placeholder / disabled
    'text_inverse':  '#0a0304',    # Text on bright backgrounds

    # Borders (macOS subtle + Sukuna marks)
    'border_subtle': '#2a1015',    # Subtle karmic boundary
    'border_focus':  '#c41020',    # Focus ring - cursed red
    'border_gold':   '#d4a84a88',  # Gold shimmer (translucent seal)

    # Semantic
    'success':       '#2d8a4e',    # Sacred green
    'warning':       '#d4a84a',    # Gold warning
    'error':         '#c41020',    # Cursed red
    'danger':        '#ff1a33',    # Bright domain danger
}

# ──────────────────────────────────────────────────────────────────
# Global stylesheet: macOS structure with Sukuna soul
# ──────────────────────────────────────────────────────────────────
SUKUNA_MACOS_STYLE = f"""
/* ── Base reset ── */
* {{
    font-family: 'Segoe UI', 'SF Pro Display', 'Inter', 'Helvetica Neue', sans-serif;
    font-size: 13px;
    outline: none;
}}

/* ── Wizard / Dialog ── */
QWizard, QDialog {{
    background: {COLORS['bg_base']};
    color: {COLORS['text_primary']};
}}
QWizardPage {{
    background: transparent;
    padding: 24px;
}}

/* ── Labels ── */
QLabel {{
    color: {COLORS['text_primary']};
    background: transparent;
    padding: 0;
}}
QLabel[accessibleName="title"] {{
    font-size: 22px;
    font-weight: 700;
    letter-spacing: -0.3px;
    color: {COLORS['text_primary']};
}}
QLabel[accessibleName="subtitle"] {{
    font-size: 13px;
    font-weight: 400;
    color: {COLORS['text_secondary']};
    margin-bottom: 8px;
}}
QLabel[accessibleName="sectionTitle"] {{
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: {COLORS['accent_gold']};
    padding: 4px 0;
}}

/* ── GroupBox (macOS card style) ── */
QGroupBox {{
    background: {COLORS['bg_surface']};
    border: 1px solid {COLORS['border_subtle']};
    border-radius: 12px;
    margin-top: 20px;
    padding: 20px 16px 16px 16px;
    color: {COLORS['text_primary']};
}}
QGroupBox::title {{
    subcontrol-origin: margin;
    left: 16px;
    padding: 0 8px;
    font-size: 12px;
    font-weight: 600;
    color: {COLORS['accent_gold']};
}}

/* ── Line Edits (macOS rounded input) ── */
QLineEdit {{
    background: {COLORS['bg_elevated']};
    color: {COLORS['text_primary']};
    border: 1px solid {COLORS['border_subtle']};
    border-radius: 8px;
    padding: 10px 14px;
    font-size: 13px;
    selection-background-color: {COLORS['accent_red']};
    selection-color: {COLORS['text_primary']};
}}
QLineEdit:focus {{
    border: 1.5px solid {COLORS['accent_red']};
    background: {COLORS['bg_hover']};
}}
QLineEdit:disabled {{
    background: {COLORS['bg_base']};
    color: {COLORS['text_tertiary']};
    border-color: {COLORS['bg_surface']};
}}
QLineEdit::placeholder {{
    color: {COLORS['text_tertiary']};
}}

/* ── Plain Text Edit ── */
QPlainTextEdit {{
    background: {COLORS['bg_elevated']};
    color: {COLORS['text_primary']};
    border: 1px solid {COLORS['border_subtle']};
    border-radius: 10px;
    padding: 12px;
    font-family: 'Cascadia Code', 'Fira Code', 'Consolas', monospace;
    font-size: 12px;
    selection-background-color: {COLORS['accent_red']};
    selection-color: {COLORS['text_primary']};
}}

/* ── Buttons (macOS pill style with Sukuna energy) ── */
QPushButton {{
    background: {COLORS['bg_surface']};
    color: {COLORS['text_primary']};
    border: 1px solid {COLORS['border_subtle']};
    border-radius: 8px;
    padding: 8px 20px;
    font-size: 13px;
    font-weight: 500;
    min-height: 20px;
}}
QPushButton:hover {{
    background: {COLORS['bg_hover']};
    border-color: {COLORS['accent_red']};
}}
QPushButton:pressed {{
    background: {COLORS['bg_active']};
}}
QPushButton:disabled {{
    background: {COLORS['bg_base']};
    color: {COLORS['text_tertiary']};
    border-color: {COLORS['bg_surface']};
}}
/* Primary action button - Cursed Energy Gradient */
QPushButton[accessibleName="primary"] {{
    background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
        stop:0 {COLORS['accent_glow']}, stop:1 {COLORS['accent_crimson']});
    color: {COLORS['text_primary']};
    border: none;
    font-weight: 600;
    padding: 10px 28px;
    border-radius: 8px;
}}
QPushButton[accessibleName="primary"]:hover {{
    background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
        stop:0 {COLORS['accent_glow']}, stop:1 {COLORS['accent_red']});
    box-shadow: 0 4px 16px rgba(196, 16, 32, 0.4);
}}
/* Gold accent button - Sacred Seal */
QPushButton[accessibleName="gold"] {{
    background: transparent;
    color: {COLORS['accent_gold']};
    border: 1.5px solid {COLORS['accent_gold']};
    border-radius: 8px;
    font-weight: 500;
}}
QPushButton[accessibleName="gold"]:hover {{
    background: rgba(212, 168, 74, 0.08);
    border-color: {COLORS['accent_glow']};
    color: {COLORS['accent_glow']};
}}

/* ── Table Widget (macOS list style) ── */
QTableWidget {{
    background: {COLORS['bg_surface']};
    color: {COLORS['text_primary']};
    border: 1px solid {COLORS['border_subtle']};
    border-radius: 10px;
    gridline-color: {COLORS['border_subtle']};
    selection-background-color: {COLORS['accent_red']};
    selection-color: {COLORS['text_primary']};
    alternate-background-color: {COLORS['bg_elevated']};
}}
QTableWidget::item {{
    padding: 8px 12px;
    border-bottom: 1px solid {COLORS['border_subtle']};
}}
QTableWidget::item:selected {{
    background: {COLORS['accent_red']};
    color: {COLORS['text_primary']};
}}
QHeaderView::section {{
    background: {COLORS['bg_elevated']};
    color: {COLORS['accent_gold']};
    border: none;
    border-bottom: 1px solid {COLORS['border_subtle']};
    border-right: 1px solid {COLORS['border_subtle']};
    padding: 10px 12px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}}
QHeaderView::section:last {{
    border-right: none;
}}

/* ── Progress Bar ── */
QProgressBar {{
    background: {COLORS['bg_elevated']};
    border: 1px solid {COLORS['border_subtle']};
    border-radius: 6px;
    text-align: center;
    color: {COLORS['text_secondary']};
    font-size: 11px;
    height: 8px;
}}
QProgressBar::chunk {{
    background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
        stop:0 {COLORS['accent_red']}, stop:1 {COLORS['accent_gold']});
    border-radius: 5px;
}}

/* ── Scrollbar (macOS thin overlay style) ── */
QScrollBar:vertical {{
    background: transparent;
    width: 8px;
    margin: 4px 0;
}}
QScrollBar::handle:vertical {{
    background: {COLORS['text_tertiary']};
    border-radius: 4px;
    min-height: 30px;
}}
QScrollBar::handle:vertical:hover {{
    background: {COLORS['text_secondary']};
}}
QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {{
    height: 0;
}}
QScrollBar::add-page:vertical, QScrollBar::sub-page:vertical {{
    background: transparent;
}}

/* ── Form labels ── */
QFormLayout QLabel {{
    font-size: 12px;
    font-weight: 500;
    color: {COLORS['text_secondary']};
    padding-right: 8px;
}}

/* ── Wizard navigation buttons override ── */
QWizard > QWidget > QPushButton {{
    border-radius: 8px;
    padding: 8px 24px;
    font-weight: 500;
}}
"""


# ──────────────────────────────────────────────────────────────────
# Helper: Create stylized section title
# ──────────────────────────────────────────────────────────────────
def make_section_label(text):
    label = QLabel(text)
    label.setAccessibleName("sectionTitle")
    return label


def make_card_shadow(widget):
    """Apply a macOS-like subtle drop shadow to a widget."""
    shadow = QGraphicsDropShadowEffect()
    shadow.setBlurRadius(24)
    shadow.setXOffset(0)
    shadow.setYOffset(4)
    shadow.setColor(QColor(0, 0, 0, 80))
    widget.setGraphicsEffect(shadow)
    return widget


# ──────────────────────────────────────────────────────────────────
# Page 1: Welcome
# ──────────────────────────────────────────────────────────────────
class WelcomePage(QWizardPage):
    def __init__(self):
        super().__init__()
        self.setTitle("")

        layout = QVBoxLayout()
        layout.setSpacing(16)
        layout.setContentsMargins(8, 8, 8, 8)

        # Spacer to center content
        layout.addSpacerItem(QSpacerItem(0, 20, QSizePolicy.Minimum, QSizePolicy.Expanding))

        # Logo / Brand mark
        brand = QLabel("👹")
        brand.setAlignment(Qt.AlignCenter)
        brand.setStyleSheet("font-size: 64px; background: transparent;")
        layout.addWidget(brand)

        # Title
        title = QLabel("SukunaOS")
        title.setAlignment(Qt.AlignCenter)
        title.setAccessibleName("title")
        title.setStyleSheet(f"""
            font-size: 36px;
            font-weight: 800;
            letter-spacing: -1px;
            color: {COLORS['text_primary']};
            background: transparent;
        """)
        layout.addWidget(title)

        # Version tag
        version = QLabel("v0.1.0-alpha  ·  Malevolent Domain Edition")
        version.setAlignment(Qt.AlignCenter)
        version.setStyleSheet(f"""
            font-size: 12px;
            color: {COLORS['accent_gold']};
            letter-spacing: 1.5px;
            font-weight: 500;
            background: transparent;
        """)
        layout.addWidget(version)

        layout.addSpacing(20)

        # Description card
        desc_card = QGroupBox()
        desc_layout = QVBoxLayout()
        desc_layout.setSpacing(8)

        desc_text = QLabel(
            "Bem-vindo ao ritual de instalação do SukunaOS.\n\n"
            "Este assistente irá guiá-lo através da criação do usuário "
            "inicial, seleção da partição de destino e selagem final "
            "da instalação.\n\n"
            "Certifique-se de que a partição escolhida pode ser formatada."
        )
        desc_text.setWordWrap(True)
        desc_text.setStyleSheet(f"""
            font-size: 13px;
            line-height: 1.6;
            color: {COLORS['text_secondary']};
            background: transparent;
            padding: 4px;
        """)
        desc_layout.addWidget(desc_text)
        desc_card.setLayout(desc_layout)
        make_card_shadow(desc_card)
        layout.addWidget(desc_card)

        layout.addSpacerItem(QSpacerItem(0, 20, QSizePolicy.Minimum, QSizePolicy.Expanding))

        # Footer
        footer = QLabel("Pressione Próximo para iniciar o pacto.")
        footer.setAlignment(Qt.AlignCenter)
        footer.setStyleSheet(f"font-size: 11px; color: {COLORS['text_tertiary']}; background: transparent;")
        layout.addWidget(footer)

        self.setLayout(layout)


# ──────────────────────────────────────────────────────────────────
# Page 2: User Setup
# ──────────────────────────────────────────────────────────────────
class UserPage(QWizardPage):
    def __init__(self):
        super().__init__()
        self.setTitle("")

        layout = QVBoxLayout()
        layout.setSpacing(12)
        layout.setContentsMargins(8, 8, 8, 8)

        # Page header
        header = QLabel("Pacto do Usuário")
        header.setAccessibleName("title")
        layout.addWidget(header)

        subtitle = QLabel("Defina a conta inicial que terá acesso ao domínio.")
        subtitle.setAccessibleName("subtitle")
        layout.addWidget(subtitle)

        layout.addSpacing(8)

        # Form card
        card = QGroupBox("Selo de Acesso")
        form = QFormLayout()
        form.setSpacing(14)
        form.setContentsMargins(12, 16, 12, 12)
        form.setLabelAlignment(Qt.AlignRight)

        self.username = QLineEdit()
        self.username.setPlaceholderText("ex: sukuna")
        self.username.setMinimumHeight(38)

        self.password = QLineEdit()
        self.password.setEchoMode(QLineEdit.Password)
        self.password.setPlaceholderText("Mínimo 6 caracteres")
        self.password.setMinimumHeight(38)

        self.confirm_password = QLineEdit()
        self.confirm_password.setEchoMode(QLineEdit.Password)
        self.confirm_password.setPlaceholderText("Repita a senha")
        self.confirm_password.setMinimumHeight(38)

        form.addRow("Nome de usuário", self.username)
        form.addRow("Senha", self.password)
        form.addRow("Confirmar senha", self.confirm_password)

        self.registerField("username*", self.username)
        self.registerField("password*", self.password)
        self.registerField("confirm_password*", self.confirm_password)

        card.setLayout(form)
        make_card_shadow(card)
        layout.addWidget(card)

        # Validation hint
        self.hint_label = QLabel("")
        self.hint_label.setStyleSheet(f"color: {COLORS['error']}; font-size: 12px; background: transparent; padding: 4px;")
        layout.addWidget(self.hint_label)

        layout.addStretch()
        self.setLayout(layout)

    def validatePage(self):
        if self.password.text() != self.confirm_password.text():
            self.hint_label.setText("⚠ As senhas não coincidem.")
            return False
        if len(self.password.text()) < 6:
            self.hint_label.setText("⚠ A senha deve ter pelo menos 6 caracteres.")
            return False
        self.hint_label.setText("")
        return True


# ──────────────────────────────────────────────────────────────────
# Page 3: Partition Selection
# ──────────────────────────────────────────────────────────────────
class PartitionPage(QWizardPage):
    def __init__(self):
        super().__init__()
        self.setTitle("")

        layout = QVBoxLayout()
        layout.setSpacing(12)
        layout.setContentsMargins(8, 8, 8, 8)

        # Page header
        header = QLabel("Altar de Destino")
        header.setAccessibleName("title")
        layout.addWidget(header)

        subtitle = QLabel("Escolha a partição onde o SukunaOS será instalado.")
        subtitle.setAccessibleName("subtitle")
        layout.addWidget(subtitle)

        layout.addSpacing(4)

        # Refresh button row
        btn_row = QHBoxLayout()
        self.refresh_button = QPushButton("⟳  Detectar Discos")
        self.refresh_button.setAccessibleName("gold")
        self.refresh_button.setMinimumHeight(36)
        self.refresh_button.setCursor(Qt.PointingHandCursor)
        self.refresh_button.clicked.connect(self.load_disks)
        btn_row.addWidget(self.refresh_button)
        btn_row.addStretch()
        layout.addLayout(btn_row)

        # Disk table
        self.disk_table = QTableWidget(0, 5)
        self.disk_table.setHorizontalHeaderLabels(
            ["Dispositivo", "Tamanho", "Tipo", "Montagem", "Modelo"]
        )
        self.disk_table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.disk_table.setSelectionBehavior(QTableWidget.SelectRows)
        self.disk_table.setEditTriggers(QTableWidget.NoEditTriggers)
        self.disk_table.setAlternatingRowColors(True)
        self.disk_table.verticalHeader().setVisible(False)
        self.disk_table.setMinimumHeight(200)
        make_card_shadow(self.disk_table)
        layout.addWidget(self.disk_table)

        # Partition input
        layout.addSpacing(4)
        input_label = QLabel("Partição de destino")
        input_label.setAccessibleName("sectionTitle")
        layout.addWidget(input_label)

        self.partition = QLineEdit()
        self.partition.setPlaceholderText("/dev/sda1")
        self.partition.setMinimumHeight(38)
        self.registerField("partition*", self.partition)
        layout.addWidget(self.partition)

        # Hint
        hint = QLabel("Selecione uma linha da tabela ou digite manualmente o dispositivo.")
        hint.setStyleSheet(f"font-size: 11px; color: {COLORS['text_tertiary']}; background: transparent;")
        layout.addWidget(hint)

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
            result = subprocess.run(
                [sys.executable, str(backend), "list-disks"],
                check=True, capture_output=True, text=True,
            )
            data = json.loads(result.stdout)
            self.populate_table(data)
        except subprocess.CalledProcessError as exc:
            QMessageBox.critical(self, "Erro", f"Falha ao obter discos:\n{exc.stderr}")
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
        mountpoint = device.get("mountpoint", "") or ""
        model = device.get("model", "") or ""
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


# ──────────────────────────────────────────────────────────────────
# Page 4: Summary / Confirmation
# ──────────────────────────────────────────────────────────────────
class SummaryPage(QWizardPage):
    def __init__(self):
        super().__init__()
        self.setTitle("")

        layout = QVBoxLayout()
        layout.setSpacing(12)
        layout.setContentsMargins(8, 8, 8, 8)

        header = QLabel("Selo Final")
        header.setAccessibleName("title")
        layout.addWidget(header)

        subtitle = QLabel("Verifique o pacto antes de iniciar a instalação.")
        subtitle.setAccessibleName("subtitle")
        layout.addWidget(subtitle)

        layout.addSpacing(8)

        # Summary card
        self.summary_card = QGroupBox("Detalhes da Instalação")
        self.summary_layout = QVBoxLayout()
        self.summary_layout.setSpacing(12)
        self.summary_layout.setContentsMargins(16, 16, 16, 16)

        self.user_line = QLabel("")
        self.part_line = QLabel("")
        self.host_line = QLabel("")

        for lbl in [self.user_line, self.part_line, self.host_line]:
            lbl.setStyleSheet(f"""
                font-size: 14px;
                color: {COLORS['text_primary']};
                background: {COLORS['bg_elevated']};
                border-radius: 8px;
                padding: 10px 14px;
            """)

        self.summary_layout.addWidget(self.user_line)
        self.summary_layout.addWidget(self.part_line)
        self.summary_layout.addWidget(self.host_line)

        self.summary_card.setLayout(self.summary_layout)
        make_card_shadow(self.summary_card)
        layout.addWidget(self.summary_card)

        # Warning
        warning = QLabel(
            "⚠  A partição selecionada será FORMATADA.\n"
            "Todos os dados existentes serão apagados permanentemente."
        )
        warning.setWordWrap(True)
        warning.setAlignment(Qt.AlignCenter)
        warning.setStyleSheet(f"""
            font-size: 12px;
            font-weight: 500;
            color: {COLORS['warning']};
            background: rgba(212, 168, 74, 0.08);
            border: 1px solid {COLORS['border_gold']};
            border-radius: 10px;
            padding: 14px;
            margin-top: 12px;
        """)
        layout.addWidget(warning)

        layout.addStretch()
        self.setLayout(layout)

    def initializePage(self):
        username = self.field("username")
        partition = self.field("partition")
        self.user_line.setText(f"👤  Usuário:  {username}")
        self.part_line.setText(f"💾  Partição:  {partition}")
        self.host_line.setText(f"🖥  Hostname:  sukunaos")


# ──────────────────────────────────────────────────────────────────
# Progress Dialog (macOS sheet-style)
# ──────────────────────────────────────────────────────────────────
class ProgressDialog(QDialog):
    def __init__(self, command):
        super().__init__()
        self.setWindowTitle("Ritual de Instalação")
        self.resize(720, 460)
        self.setStyleSheet(f"background: {COLORS['bg_base']};")

        layout = QVBoxLayout()
        layout.setSpacing(12)
        layout.setContentsMargins(24, 24, 24, 24)

        # Header
        header = QLabel("Instalação em andamento...")
        header.setAccessibleName("title")
        header.setStyleSheet(f"font-size: 18px; font-weight: 700; color: {COLORS['text_primary']};")
        layout.addWidget(header)

        # Progress bar
        self.progress = QProgressBar()
        self.progress.setRange(0, 0)  # indeterminate
        self.progress.setTextVisible(False)
        self.progress.setFixedHeight(6)
        layout.addWidget(self.progress)

        # Log output
        self.log = QPlainTextEdit()
        self.log.setReadOnly(True)
        self.log.setMinimumHeight(280)
        layout.addWidget(self.log)

        # Button row
        btn_row = QHBoxLayout()
        btn_row.addStretch()
        self.cancel_btn = QPushButton("Cancelar")
        self.cancel_btn.setMinimumHeight(36)
        self.cancel_btn.setCursor(Qt.PointingHandCursor)
        self.cancel_btn.clicked.connect(self.reject)
        btn_row.addWidget(self.cancel_btn)
        layout.addLayout(btn_row)

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
        self.progress.setRange(0, 100)
        if exit_code == 0:
            self.progress.setValue(100)
            self.log.appendPlainText("\n✅ Domínio selado com sucesso.")
            self.cancel_btn.setText("Concluir")
            self.cancel_btn.setAccessibleName("primary")
            self.cancel_btn.setStyleSheet(f"""
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 {COLORS['success']}, stop:1 #1a6638);
                color: {COLORS['text_primary']};
                border: none;
                border-radius: 8px;
                font-weight: 600;
                padding: 10px 28px;
            """)
        else:
            self.progress.setValue(0)
            self.log.appendPlainText(f"\n❌ O ritual falhou com código {exit_code}.")
            self.cancel_btn.setText("Fechar")


# ──────────────────────────────────────────────────────────────────
# Main Wizard
# ──────────────────────────────────────────────────────────────────
class InstallerWizard(QWizard):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("SukunaOS Installer — Malevolent Domain")
        self.setWizardStyle(QWizard.ModernStyle)
        self.setMinimumSize(640, 540)
        self.resize(700, 580)

        # Set custom button text
        self.setButtonText(QWizard.NextButton, "Próximo  →")
        self.setButtonText(QWizard.BackButton, "←  Voltar")
        self.setButtonText(QWizard.FinishButton, "Instalar  ⚡")
        self.setButtonText(QWizard.CancelButton, "Cancelar")

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
                "Backend de instalação não encontrado.\n"
                "Verifique se o arquivo src/sukuna_installer_backend.py está disponível.",
            )
            return

        if not partition.startswith("/dev/"):
            QMessageBox.warning(
                self,
                "Partição inválida",
                "Informe um dispositivo de destino válido, por exemplo /dev/sda1.",
            )
            return

        # Final confirmation dialog
        confirm = QMessageBox(self)
        confirm.setWindowTitle("Confirmar Instalação")
        confirm.setText(
            f"Você está prestes a FORMATAR {partition} e instalar o SukunaOS.\n\n"
            "Todos os dados nessa partição serão perdidos.\n"
            "Deseja continuar?"
        )
        confirm.setIcon(QMessageBox.Warning)
        confirm.setStandardButtons(QMessageBox.Yes | QMessageBox.No)
        confirm.setDefaultButton(QMessageBox.No)
        confirm.setStyleSheet(f"""
            QMessageBox {{
                background: {COLORS['bg_surface']};
                color: {COLORS['text_primary']};
            }}
            QMessageBox QLabel {{
                color: {COLORS['text_primary']};
                font-size: 13px;
            }}
        """)

        if confirm.exec() != QMessageBox.Yes:
            return

        command = [
            sys.executable,
            str(backend),
            "install",
            "--partition", partition,
            "--username", username,
            "--password", password,
            "--hostname", "sukunaos",
        ]

        dialog = ProgressDialog(command)
        dialog.start()
        if dialog.process.exitCode() == 0:
            super().accept()
        else:
            QMessageBox.critical(
                self,
                "Erro",
                "A instalação falhou. Verifique o log acima e tente novamente.",
            )


# ──────────────────────────────────────────────────────────────────
# Entry point
# ──────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    app = QApplication(sys.argv)

    # Set application-wide dark palette (macOS-like)
    palette = QPalette()
    palette.setColor(QPalette.Window, QColor(COLORS['bg_base']))
    palette.setColor(QPalette.WindowText, QColor(COLORS['text_primary']))
    palette.setColor(QPalette.Base, QColor(COLORS['bg_elevated']))
    palette.setColor(QPalette.AlternateBase, QColor(COLORS['bg_surface']))
    palette.setColor(QPalette.Text, QColor(COLORS['text_primary']))
    palette.setColor(QPalette.Button, QColor(COLORS['bg_surface']))
    palette.setColor(QPalette.ButtonText, QColor(COLORS['text_primary']))
    palette.setColor(QPalette.Highlight, QColor(COLORS['accent_red']))
    palette.setColor(QPalette.HighlightedText, QColor(COLORS['text_primary']))
    palette.setColor(QPalette.PlaceholderText, QColor(COLORS['text_tertiary']))
    app.setPalette(palette)

    app.setStyleSheet(SUKUNA_MACOS_STYLE)

    wizard = InstallerWizard()
    wizard.show()
    sys.exit(app.exec())
