#!/usr/bin/env python3
"""
Simple Qt Quick MDE mockup using PySide6.

Requires: PySide6
Run: python3 mde/mockup/main.py
"""
import sys
from pathlib import Path
from PySide6.QtCore import QUrl
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine


def main():
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / 'Main.qml'
    engine.load(QUrl.fromLocalFile(str(qml_file)))
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())


if __name__ == '__main__':
    main()
