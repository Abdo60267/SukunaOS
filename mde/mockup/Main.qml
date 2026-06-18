import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: root
    visible: true
    width: 1280
    height: 760
    minimumWidth: 1060
    minimumHeight: 680
    title: "SukunaOS - Malevolent Desktop Environment"
    color: bg

    property color bg: "#050203"
    property color panel: "#150709"
    property color panelAlt: "#241012"
    property color accent: "#b30d18"
    property color blood: "#69020a"
    property color gold: "#e6b84d"
    property color textPrimary: "#f4e6cf"
    property color textMuted: "#b99c84"

    property bool bootVisible: true
    property bool startMenuOpen: false
    property bool controlCenterOpen: false
    property bool uraumeOpen: false
    property bool notificationVisible: false
    property string activeApp: ""
    property string currentTime: "00:00:00"
    property string notificationTitle: "SukunaOS"
    property string notificationBody: "Shrine Ready."
    property string terminalLog: "sukuna@malevolent-kernel:~$ neofetch\nOS: SukunaOS 1.0 Malevolent Domain\nKernel: linux-sukuna 6.4.0\nShell: cursed-bash\nSecurity: King of Curses LSM active\n\nDigite help, domain-status, binding-vows ou clear."
    property string uraumeLog: "Uraume: À sua disposição. O domínio está estável."

    property var slashMarks: [
        { "x": 84, "y": 142, "w": 330, "r": -18, "o": 0.48 },
        { "x": 742, "y": 118, "w": 410, "r": 14, "o": 0.42 },
        { "x": 612, "y": 468, "w": 520, "r": -12, "o": 0.38 },
        { "x": 88, "y": 510, "w": 280, "r": 10, "o": 0.30 },
        { "x": 1020, "y": 354, "w": 260, "r": 24, "o": 0.36 }
    ]

    property var appCatalog: [
        { "glyph": "S", "label": "Shrine", "desc": "Visão geral do domínio" },
        { "glyph": "F", "label": "Files", "desc": "Arquivos e vaults" },
        { "glyph": "T", "label": "Terminal", "desc": "cursed-bash" },
        { "glyph": "M", "label": "Store", "desc": "Sukuna Store" },
        { "glyph": "C", "label": "Settings", "desc": "Ajustes do sistema" },
        { "glyph": "K", "label": "Security", "desc": "King of Curses" },
        { "glyph": "D", "label": "DCL", "desc": "Apps Windows" },
        { "glyph": "R", "label": "Rituals", "desc": "Snapshots e recovery" },
        { "glyph": "U", "label": "Uraume", "desc": "Assistente local" }
    ]

    property var dockApps: [
        { "glyph": "S", "label": "Shrine" },
        { "glyph": "F", "label": "Files" },
        { "glyph": "T", "label": "Terminal" },
        { "glyph": "M", "label": "Store" },
        { "glyph": "C", "label": "Settings" },
        { "glyph": "U", "label": "Uraume" }
    ]

    function openApp(name) {
        startMenuOpen = false
        controlCenterOpen = false
        if (name === "Uraume") {
            uraumeOpen = !uraumeOpen
            showNotification("Uraume AI", uraumeOpen ? "Assistente local aguardando ordem." : "Assistente recolhido.")
            return
        }
        activeApp = name
        showNotification(name, notificationForApp(name))
    }

    function closeActiveApp() {
        activeApp = ""
        showNotification("Shrine", "Área de trabalho restaurada.")
    }

    function activeAppTitle() {
        if (activeApp === "Shrine") return "Malevolent Shrine"
        if (activeApp === "Files") return "Sukuna Files"
        if (activeApp === "Terminal") return "Cursed Terminal"
        if (activeApp === "Store") return "Sukuna Store"
        if (activeApp === "Settings") return "Domain Settings"
        if (activeApp === "Security") return "King of Curses Security"
        if (activeApp === "DCL") return "Domain Compatibility Layer"
        if (activeApp === "Rituals") return "Shrine Snapshots"
        return activeApp
    }

    function notificationForApp(name) {
        if (name === "Terminal") return "cursed-bash pronto para comandos."
        if (name === "Store") return "Catálogo carregado com pacotes nativos e DCL."
        if (name === "Security") return "Cleave Guard e Dismantle Scan online."
        if (name === "DCL") return "Camada Wine/Proton isolada por domínio."
        if (name === "Rituals") return "Snapshots preparados para rollback."
        return "Módulo aberto no domínio."
    }

    function showNotification(title, body) {
        notificationTitle = title
        notificationBody = body
        notificationVisible = true
        notificationTimer.restart()
    }

    function runTerminal(command) {
        var cmd = command.trim()
        if (cmd.length === 0) return

        if (cmd === "clear") {
            terminalLog = "sukuna@malevolent-kernel:~$"
            return
        }

        var response = ""
        if (cmd === "help") {
            response = "Comandos: help, neofetch, domain-status, binding-vows, sudo king-of-curses, ls, clear"
        } else if (cmd === "neofetch") {
            response = "SukunaOS 1.0\nKernel: linux-sukuna\nDesktop: MDE\nTheme: Malevolent Shrine\nLSM: King of Curses"
        } else if (cmd === "domain-status") {
            response = "Domain Expansion Security: EXPANDIDO\nAmeaças bloqueadas hoje: 1247\nFirewall: ativo\nSandbox: Malevolent Domain"
        } else if (cmd === "binding-vows") {
            response = "[ok] No-Ads Vow\n[ok] Privacy Vow\n[ok] Kernel Integrity Vow\n[ok] App Permission Vow"
        } else if (cmd === "sudo king-of-curses") {
            response = "[sudo] Binding Vow autenticado\nKing of Curses Mode ATIVADO\nCPU governor: performance\nRollback: armado"
        } else if (cmd === "ls") {
            response = "Maldições/  Binding_Vows/  Domain_Files/  Downloads/\nkernel.conf  sukuna_wall.svg  cursed_energy.wav"
        } else {
            response = "cursed-bash: " + cmd + ": comando não encontrado"
        }

        terminalLog += "\nsukuna@malevolent-kernel:~$ " + cmd + "\n" + response
    }

    function sendUraume(message) {
        var msg = message.trim()
        if (msg.length === 0) return
        var reply = "Uraume: Entendido. Posso abrir Terminal, Security, Store ou preparar um snapshot do Shrine."
        if (msg.toLowerCase().indexOf("segurança") >= 0 || msg.toLowerCase().indexOf("security") >= 0) {
            reply = "Uraume: Cleave Guard está ativo. Dismantle Scan observando 17 processos desconhecidos."
        } else if (msg.toLowerCase().indexOf("desempenho") >= 0 || msg.toLowerCase().indexOf("performance") >= 0) {
            reply = "Uraume: King Mode pronto, mas eu manteria Vessel para equilíbrio térmico."
        } else if (msg.toLowerCase().indexOf("store") >= 0 || msg.toLowerCase().indexOf("loja") >= 0) {
            reply = "Uraume: A Sukuna Store tem pacotes nativos, Flatpak, AppImage e DCL em filas separadas."
        }
        uraumeLog += "\nVocê: " + msg + "\n" + reply
    }

    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: currentTime = Qt.formatTime(new Date(), "HH:mm:ss")
    }

    Timer {
        id: bootTimer
        interval: 2100
        running: true
        repeat: false
        onTriggered: {
            bootVisible = false
            showNotification("SukunaOS", "Shrine Ready. Domain Control online.")
        }
    }

    Timer {
        id: notificationTimer
        interval: 3600
        running: false
        repeat: false
        onTriggered: notificationVisible = false
    }

    Rectangle {
        id: desktop
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#090304" }
            GradientStop { position: 0.42; color: "#160507" }
            GradientStop { position: 1.0; color: "#030202" }
        }

        Image {
            anchors.fill: parent
            source: "../../assets/wallpaper-2.svg"
            fillMode: Image.PreserveAspectCrop
            opacity: 0.25
            smooth: true
        }

        Repeater {
            model: 10
            Rectangle {
                width: parent.width * 1.2
                height: 1
                x: -parent.width * 0.1
                y: 92 + index * 58
                color: index % 2 === 0 ? "#311014" : "#17080a"
                opacity: 0.38
            }
        }

        Repeater {
            model: slashMarks
            Rectangle {
                x: modelData.x
                y: modelData.y
                width: modelData.w
                height: 5
                radius: 3
                rotation: modelData.r
                opacity: modelData.o
                color: accent

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * 0.38
                    height: 1
                    color: gold
                    opacity: 0.7
                }
            }
        }

        Item {
            id: domainSeal
            width: 430
            height: 430
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -8
            opacity: activeApp === "" ? 0.82 : 0.28

            Rectangle {
                anchors.centerIn: parent
                width: 330
                height: 330
                radius: 165
                color: "transparent"
                border.color: "#5d1518"
                border.width: 2
                opacity: 0.78
            }

            Rectangle {
                anchors.centerIn: parent
                width: 238
                height: 238
                radius: 119
                color: "transparent"
                border.color: "#9e241f"
                border.width: 1
                opacity: 0.8
            }

            Repeater {
                model: 12
                Rectangle {
                    width: 6
                    height: 96
                    radius: 3
                    color: index % 3 === 0 ? gold : accent
                    opacity: index % 3 === 0 ? 0.46 : 0.26
                    x: domainSeal.width / 2 - width / 2
                    y: 34
                    transform: Rotation {
                        origin.x: 3
                        origin.y: domainSeal.height / 2 - 34
                        angle: index * 30
                    }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: 128
                height: 188
                radius: 12
                color: "#0b0304"
                border.color: gold
                border.width: 1
                opacity: 0.92

                Rectangle { x: 28; y: 26; width: 72; height: 7; radius: 4; color: accent; rotation: -10 }
                Rectangle { x: 28; y: 58; width: 72; height: 7; radius: 4; color: accent; rotation: 10 }
                Rectangle { x: 23; y: 98; width: 82; height: 9; radius: 4; color: gold; opacity: 0.75 }
                Rectangle { x: 38; y: 130; width: 52; height: 7; radius: 4; color: accent; rotation: -8 }
                Rectangle { x: 38; y: 150; width: 52; height: 7; radius: 4; color: accent; rotation: 8 }
            }
        }

        Rectangle {
            id: topbar
            height: 56
            anchors.left: parent.left
            anchors.right: parent.right
            color: "#100506"
            border.color: "#321014"
            border.width: 1
            opacity: 0.97
            z: 50

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Rectangle {
                    width: 34
                    height: 34
                    radius: 8
                    color: startMenuOpen ? "#2d0b0f" : "#090304"
                    border.color: startMenuOpen ? gold : "#6f2525"
                    border.width: 1

                    Rectangle { x: 8; y: 9; width: 18; height: 3; radius: 2; color: accent; rotation: -16 }
                    Rectangle { x: 8; y: 21; width: 18; height: 3; radius: 2; color: accent; rotation: 16 }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            startMenuOpen = !startMenuOpen
                            controlCenterOpen = false
                        }
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0
                    Text { text: "SukunaOS"; color: gold; font.pixelSize: 18; font.bold: true }
                    Text { text: "Malevolent Desktop Environment"; color: textMuted; font.pixelSize: 11 }
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: 8

                Repeater {
                    model: ["Shrine", "Cleave", "Dismantle", "Binding Vows"]
                    Rectangle {
                        width: index === 3 ? 128 : 106
                        height: 32
                        radius: 6
                        color: index === 0 ? "#2d0b0f" : "#120708"
                        border.color: index === 0 ? accent : "#321014"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: index === 0 ? textPrimary : textMuted
                            font.pixelSize: 12
                        }
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 16

                Text {
                    text: "Domain Stable"
                    color: "#6dd99b"
                    font.pixelSize: 12
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            controlCenterOpen = !controlCenterOpen
                            startMenuOpen = false
                        }
                    }
                }

                Text { text: currentTime; color: textPrimary; font.pixelSize: 13 }
            }
        }

        Item {
            id: dashboard
            anchors.fill: parent
            visible: activeApp === ""

            Rectangle {
                id: leftPanel
                width: 330
                height: 430
                x: 36
                y: topbar.height + 34
                radius: 8
                color: "#130608"
                border.color: "#3c1215"
                border.width: 1
                opacity: 0.95

                Rectangle {
                    height: 42
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: "#210b0e"
                    radius: 8

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Domain Console"
                        color: gold
                        font.pixelSize: 15
                        font.bold: true
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 58
                    anchors.margins: 16
                    spacing: 12

                    Text { text: "King of Curses LSM"; color: textPrimary; font.pixelSize: 18; font.bold: true }
                    Text {
                        width: parent.width
                        text: "Políticas assinadas, sandbox local e julgamento rápido de binários desconhecidos."
                        color: textMuted
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12
                    }

                    Rectangle { width: parent.width; height: 1; color: "#351115" }

                    Repeater {
                        model: [
                            { "name": "Cleave Guard", "state": "active", "value": "98%" },
                            { "name": "Dismantle Scan", "state": "watching", "value": "17" },
                            { "name": "Malevolent Domain", "state": "isolated", "value": "on" },
                            { "name": "Shrine Snapshots", "state": "armed", "value": "4" }
                        ]
                        Row {
                            width: parent.width
                            height: 38
                            spacing: 10

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: index === 1 ? gold : accent
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                width: 210
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1
                                Text { text: modelData.name; color: textPrimary; font.pixelSize: 13 }
                                Text { text: modelData.state; color: textMuted; font.pixelSize: 11 }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.value
                                color: gold
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: missionPanel
                width: 360
                height: 244
                anchors.right: parent.right
                anchors.rightMargin: 36
                y: topbar.height + 46
                radius: 8
                color: "#120608"
                border.color: "#3d1317"
                border.width: 1
                opacity: 0.95

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text { text: "Cursed Toolkit"; color: gold; font.pixelSize: 16; font.bold: true }

                    Grid {
                        columns: 2
                        columnSpacing: 10
                        rowSpacing: 10

                        Repeater {
                            model: [
                                { "name": "Sukuna Store", "mark": "ST", "app": "Store" },
                                { "name": "DCL Portal", "mark": "DC", "app": "DCL" },
                                { "name": "Snapshot Shrine", "mark": "SS", "app": "Rituals" },
                                { "name": "Security Pact", "mark": "KP", "app": "Security" }
                            ]

                            Rectangle {
                                width: 156
                                height: 78
                                radius: 7
                                color: index === 0 ? "#2b0b0f" : "#17080a"
                                border.color: index === 0 ? accent : "#321014"
                                border.width: 1

                                Rectangle {
                                    x: 12
                                    y: 15
                                    width: 34
                                    height: 34
                                    radius: 6
                                    color: "#070203"
                                    border.color: gold
                                    border.width: 1
                                    Text { anchors.centerIn: parent; text: modelData.mark; color: gold; font.pixelSize: 11; font.bold: true }
                                }

                                Text {
                                    x: 56
                                    y: 17
                                    width: 88
                                    text: modelData.name
                                    color: textPrimary
                                    wrapMode: Text.WordWrap
                                    font.pixelSize: 12
                                }

                                MouseArea { anchors.fill: parent; onClicked: openApp(modelData.app) }
                            }
                        }
                    }
                }
            }

            Column {
                id: desktopIcons
                x: 44
                y: topbar.height + 498
                spacing: 12

                Repeater {
                    model: [
                        { "glyph": "D", "name": "Domain Files", "app": "Files" },
                        { "glyph": "T", "name": "Cursed Bash", "app": "Terminal" },
                        { "glyph": "K", "name": "King Guard", "app": "Security" }
                    ]

                    Rectangle {
                        width: 120
                        height: 42
                        radius: 7
                        color: "#120708"
                        border.color: "#351116"
                        border.width: 1
                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            Text { text: modelData.glyph; color: gold; font.bold: true; font.pixelSize: 14 }
                            Text { text: modelData.name; color: textMuted; font.pixelSize: 11 }
                        }
                        MouseArea { anchors.fill: parent; onClicked: openApp(modelData.app) }
                    }
                }
            }
        }

        Rectangle {
            id: appWindow
            visible: activeApp !== ""
            width: Math.min(parent.width - 180, 820)
            height: Math.min(parent.height - 190, 520)
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 10
            radius: 10
            color: "#100506"
            border.color: "#5c171d"
            border.width: 1
            opacity: 0.98
            z: 20

            Rectangle {
                id: titlebar
                height: 44
                anchors.left: parent.left
                anchors.right: parent.right
                color: "#210b0e"
                radius: 10

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    Rectangle { width: 11; height: 11; radius: 6; color: "#c6353d"; MouseArea { anchors.fill: parent; onClicked: closeActiveApp() } }
                    Rectangle { width: 11; height: 11; radius: 6; color: "#d8a740" }
                    Rectangle { width: 11; height: 11; radius: 6; color: "#5fc888" }
                }

                Text {
                    anchors.centerIn: parent
                    text: activeAppTitle()
                    color: gold
                    font.pixelSize: 15
                    font.bold: true
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: "sealed"
                    color: "#6dd99b"
                    font.pixelSize: 11
                }
            }

            Loader {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: titlebar.bottom
                anchors.bottom: parent.bottom
                anchors.margins: 18
                sourceComponent: activeApp === "Terminal" ? terminalApp :
                    activeApp === "Store" ? storeApp :
                    activeApp === "Settings" ? settingsApp :
                    activeApp === "Security" ? securityApp :
                    activeApp === "Files" ? filesApp :
                    activeApp === "DCL" ? dclApp :
                    activeApp === "Rituals" ? ritualsApp :
                    shrineApp
            }
        }

        Rectangle {
            id: startMenu
            visible: startMenuOpen
            width: 700
            height: 430
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: dock.top
            anchors.bottomMargin: 18
            radius: 12
            color: "#0b0305"
            border.color: "#5b171d"
            border.width: 1
            z: 70

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                Column {
                    spacing: 3
                    Text { text: "Malevolent Shrine"; color: gold; font.pixelSize: 22; font.bold: true }
                    Text { text: "Apps, rituais, proteção e compatibilidade do SukunaOS"; color: textMuted; font.pixelSize: 12 }
                }

                Rectangle {
                    width: parent.width
                    height: 38
                    radius: 7
                    color: "#130608"
                    border.color: "#351116"
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Buscar no domínio..."
                        color: textMuted
                        font.pixelSize: 12
                    }
                }

                Grid {
                    columns: 3
                    columnSpacing: 12
                    rowSpacing: 12

                    Repeater {
                        model: appCatalog
                        Rectangle {
                            width: 210
                            height: 76
                            radius: 8
                            color: index === 0 ? "#2b0b0f" : "#140709"
                            border.color: index === 0 ? accent : "#351116"
                            border.width: 1

                            Rectangle {
                                x: 14
                                y: 15
                                width: 42
                                height: 42
                                radius: 8
                                color: "#080304"
                                border.color: gold
                                border.width: 1
                                Text { anchors.centerIn: parent; text: modelData.glyph; color: gold; font.bold: true; font.pixelSize: 15 }
                            }

                            Column {
                                x: 68
                                y: 16
                                width: 128
                                spacing: 4
                                Text { text: modelData.label; color: textPrimary; font.pixelSize: 13; font.bold: true }
                                Text { text: modelData.desc; color: textMuted; font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width }
                            }

                            MouseArea { anchors.fill: parent; onClicked: openApp(modelData.label) }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: controlCenter
            visible: controlCenterOpen
            width: 360
            height: 334
            anchors.right: parent.right
            anchors.rightMargin: 28
            anchors.top: topbar.bottom
            anchors.topMargin: 14
            radius: 10
            color: "#130608"
            border.color: "#451419"
            border.width: 1
            opacity: 0.98
            z: 70

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Row {
                    width: parent.width
                    Text { text: "Domain Control"; color: gold; font.pixelSize: 16; font.bold: true; width: parent.width - 82 }
                    Text { text: "sealed"; color: "#6dd99b"; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                }

                Grid {
                    columns: 3
                    columnSpacing: 8
                    rowSpacing: 8

                    Repeater {
                        model: ["Wi-Fi", "Audio", "Display", "Focus", "Barrier", "Rollback", "VPN", "Battery", "Night"]
                        Rectangle {
                            width: 102
                            height: 42
                            radius: 6
                            color: index === 4 || index === 6 ? "#2c0b0f" : "#1b0a0c"
                            border.color: index === 4 || index === 6 ? accent : "#351116"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: index === 4 || index === 6 ? gold : textPrimary
                                font.pixelSize: 12
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#351116" }

                Text { text: "Performance Profile"; color: textMuted; font.pixelSize: 11 }

                Row {
                    spacing: 8
                    Repeater {
                        model: ["Human", "Vessel", "King"]
                        Rectangle {
                            width: 102
                            height: 34
                            radius: 6
                            color: index === 2 ? "#2b0b0f" : "transparent"
                            border.color: index === 2 ? gold : "#3a1216"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: index === 2 ? gold : textMuted
                                font.pixelSize: 12
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 48
                    radius: 7
                    color: "#0d0406"
                    border.color: "#351116"
                    Text {
                        anchors.centerIn: parent
                        text: "Cleave Guard: 98% integrity | 17 scans"
                        color: textPrimary
                        font.pixelSize: 12
                    }
                }
            }
        }

        Rectangle {
            id: notification
            visible: notificationVisible
            width: 332
            height: 92
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.top: topbar.bottom
            anchors.topMargin: controlCenterOpen ? 366 : 18
            radius: 10
            color: "#100506"
            border.color: "#5b171d"
            border.width: 1
            z: 80

            Row {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12
                Rectangle {
                    width: 42
                    height: 42
                    radius: 9
                    color: "#070203"
                    border.color: gold
                    border.width: 1
                    Text { anchors.centerIn: parent; text: "S"; color: gold; font.bold: true; font.pixelSize: 16 }
                }
                Column {
                    width: parent.width - 70
                    spacing: 4
                    Text { text: notificationTitle; color: gold; font.pixelSize: 13; font.bold: true }
                    Text { text: notificationBody; color: textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; width: parent.width }
                }
            }
        }

        Rectangle {
            id: uraumePanel
            visible: uraumeOpen
            width: 340
            height: 384
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.bottom: dock.top
            anchors.bottomMargin: 18
            radius: 12
            color: "#100506"
            border.color: "#5b171d"
            border.width: 1
            z: 65

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Row {
                    width: parent.width
                    Text { text: "Uraume AI"; color: gold; font.pixelSize: 16; font.bold: true; width: parent.width - 42 }
                    Text { text: "x"; color: textMuted; font.pixelSize: 14; MouseArea { anchors.fill: parent; onClicked: uraumeOpen = false } }
                }

                Rectangle {
                    width: parent.width
                    height: 266
                    radius: 8
                    color: "#0a0304"
                    border.color: "#321014"
                    Text {
                        anchors.fill: parent
                        anchors.margins: 12
                        text: uraumeLog
                        color: textPrimary
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 38
                    radius: 7
                    color: "#150709"
                    border.color: "#3a1216"
                    TextInput {
                        id: uraumeInput
                        anchors.fill: parent
                        anchors.margins: 10
                        color: textPrimary
                        selectionColor: accent
                        selectedTextColor: textPrimary
                        font.pixelSize: 12
                        clip: true
                        onAccepted: {
                            sendUraume(text)
                            text = ""
                        }
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Pergunte à Uraume..."
                        color: textMuted
                        font.pixelSize: 12
                        visible: uraumeInput.text.length === 0 && !uraumeInput.activeFocus
                    }
                }
            }
        }

        Rectangle {
            id: dock
            width: 626
            height: 76
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18
            radius: 12
            color: "#100506"
            border.color: "#54161b"
            border.width: 1
            opacity: 0.98
            z: 60

            Row {
                anchors.centerIn: parent
                spacing: 12

                Repeater {
                    model: dockApps

                    Rectangle {
                        width: 86
                        height: 56
                        radius: 9
                        color: activeApp === modelData.label ? "#2c0b0f" : "transparent"
                        border.color: activeApp === modelData.label ? accent : "#321014"
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 2
                            Text { text: modelData.glyph; color: gold; font.pixelSize: 17; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: modelData.label; color: textMuted; font.pixelSize: 10; anchors.horizontalCenter: parent.horizontalCenter }
                        }

                        MouseArea { anchors.fill: parent; onClicked: openApp(modelData.label) }
                    }
                }
            }
        }

        Rectangle {
            id: bootOverlay
            anchors.fill: parent
            visible: bootVisible
            color: "#000000"
            z: 999

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#000000" }
                    GradientStop { position: 0.54; color: "#180307" }
                    GradientStop { position: 1.0; color: "#000000" }
                }
            }

            Item {
                width: 340
                height: 340
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -42

                Rectangle {
                    anchors.centerIn: parent
                    width: 182
                    height: 182
                    radius: 91
                    color: "transparent"
                    border.color: "#6d171c"
                    border.width: 2
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 92
                    height: 136
                    radius: 10
                    color: "#080203"
                    border.color: gold
                    border.width: 2
                    Rectangle { x: 20; y: 24; width: 52; height: 6; radius: 3; color: accent; rotation: -12 }
                    Rectangle { x: 20; y: 54; width: 52; height: 6; radius: 3; color: accent; rotation: 12 }
                    Rectangle { x: 16; y: 88; width: 60; height: 6; radius: 3; color: gold; opacity: 0.8 }
                }
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 148
                spacing: 12

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "SukunaOS"
                    color: gold
                    font.pixelSize: 44
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Opening Malevolent Domain"
                    color: textMuted
                    font.pixelSize: 14
                }

                Rectangle {
                    width: 280
                    height: 6
                    radius: 3
                    color: "#210b0e"
                    Rectangle {
                        height: parent.height
                        radius: 3
                        color: accent
                        SequentialAnimation on width {
                            running: bootVisible
                            loops: 1
                            NumberAnimation { from: 0; to: 280; duration: 2000; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    bootVisible = false
                    showNotification("SukunaOS", "Boot pulado. Domain Control online.")
                }
            }
        }
    }

    Component {
        id: shrineApp
        Item {
            anchors.fill: parent
            Grid {
                columns: 2
                columnSpacing: 14
                rowSpacing: 14
                anchors.fill: parent

                Repeater {
                    model: [
                        { "title": "Domain Health", "value": "98%", "desc": "Integridade do shrine e políticas assinadas." },
                        { "title": "Threats Cut", "value": "1247", "desc": "Eventos bloqueados por Cleave Guard hoje." },
                        { "title": "DCL Apps", "value": "12", "desc": "Prefixos isolados para apps Windows." },
                        { "title": "Snapshots", "value": "4", "desc": "Pontos de rollback prontos." }
                    ]

                    Rectangle {
                        width: 372
                        height: 176
                        radius: 9
                        color: "#120608"
                        border.color: "#3a1216"
                        border.width: 1
                        Column {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 10
                            Text { text: modelData.title; color: gold; font.pixelSize: 15; font.bold: true }
                            Text { text: modelData.value; color: textPrimary; font.pixelSize: 42; font.bold: true }
                            Text { text: modelData.desc; color: textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; width: parent.width }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: terminalApp
        Item {
            anchors.fill: parent
            Rectangle {
                anchors.fill: parent
                radius: 8
                color: "#070203"
                border.color: "#321014"

                Column {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Rectangle {
                        width: parent.width
                        height: parent.height - 50
                        radius: 7
                        color: "#030101"
                        border.color: "#22090c"
                        Text {
                            anchors.fill: parent
                            anchors.margins: 12
                            text: terminalLog
                            color: "#9be08d"
                            font.family: "Consolas"
                            font.pixelSize: 12
                            wrapMode: Text.WrapAnywhere
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 38
                        radius: 7
                        color: "#100506"
                        border.color: "#3a1216"
                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Text { text: "$"; color: gold; font.pixelSize: 13; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                            TextInput {
                                id: terminalInput
                                width: parent.width - 24
                                anchors.verticalCenter: parent.verticalCenter
                                color: textPrimary
                                font.family: "Consolas"
                                font.pixelSize: 13
                                clip: true
                                onAccepted: {
                                    runTerminal(text)
                                    text = ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: storeApp
        Item {
            anchors.fill: parent
            Column {
                anchors.fill: parent
                spacing: 14

                Text { text: "Pacotes nativos, Flatpak, AppImage, DEB e DCL em um altar só."; color: textMuted; font.pixelSize: 12 }

                Grid {
                    columns: 3
                    columnSpacing: 12
                    rowSpacing: 12

                    Repeater {
                        model: [
                            { "name": "Sukuna Studio", "tag": "IDE", "state": "native" },
                            { "name": "Shrine Browser", "tag": "WEB", "state": "flatpak" },
                            { "name": "Cursed Proton", "tag": "DCL", "state": "windows layer" },
                            { "name": "Manga Vault", "tag": "MEDIA", "state": "appimage" },
                            { "name": "Domain Recorder", "tag": "CAPTURE", "state": "deb" },
                            { "name": "Cleave Tuner", "tag": "GPU", "state": "driver tool" }
                        ]

                        Rectangle {
                            width: 238
                            height: 124
                            radius: 8
                            color: "#120608"
                            border.color: "#3a1216"
                            border.width: 1
                            Column {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 8
                                Row {
                                    spacing: 8
                                    Rectangle {
                                        width: 34
                                        height: 34
                                        radius: 7
                                        color: "#070203"
                                        border.color: gold
                                        Text { anchors.centerIn: parent; text: modelData.tag.substring(0, 1); color: gold; font.bold: true }
                                    }
                                    Column {
                                        width: 160
                                        Text { text: modelData.name; color: textPrimary; font.pixelSize: 13; font.bold: true }
                                        Text { text: modelData.state; color: textMuted; font.pixelSize: 11 }
                                    }
                                }
                                Rectangle {
                                    width: parent.width
                                    height: 30
                                    radius: 6
                                    color: "#2b0b0f"
                                    border.color: accent
                                    Text { anchors.centerIn: parent; text: "Install"; color: gold; font.pixelSize: 12; font.bold: true }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: settingsApp
        Item {
            anchors.fill: parent
            Row {
                anchors.fill: parent
                spacing: 16

                Column {
                    width: 178
                    spacing: 8
                    Repeater {
                        model: ["General", "Appearance", "Security", "Performance", "Network", "Uraume AI", "About"]
                        Rectangle {
                            width: parent.width
                            height: 40
                            radius: 7
                            color: index === 2 ? "#2b0b0f" : "#120608"
                            border.color: index === 2 ? accent : "#351116"
                            Text { anchors.centerIn: parent; text: modelData; color: index === 2 ? gold : textMuted; font.pixelSize: 12 }
                        }
                    }
                }

                Column {
                    width: parent.width - 194
                    spacing: 12
                    Text { text: "Security - Domain Expansion"; color: gold; font.pixelSize: 18; font.bold: true }
                    Repeater {
                        model: [
                            { "name": "Domain Expansion Security", "desc": "Firewall e proteção em tempo real", "on": "on" },
                            { "name": "Binding Vows", "desc": "Permissões por contrato explícito", "on": "on" },
                            { "name": "Full Disk Seal", "desc": "Criptografia total em repouso", "on": "on" },
                            { "name": "No-Ads Vow", "desc": "Bloqueio permanente de anúncios", "on": "locked" }
                        ]

                        Rectangle {
                            width: parent.width
                            height: 68
                            radius: 8
                            color: "#120608"
                            border.color: "#351116"
                            Row {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 12
                                Column {
                                    width: parent.width - 72
                                    spacing: 3
                                    Text { text: modelData.name; color: textPrimary; font.pixelSize: 13; font.bold: true }
                                    Text { text: modelData.desc; color: textMuted; font.pixelSize: 11 }
                                }
                                Rectangle {
                                    width: 46
                                    height: 24
                                    radius: 12
                                    color: "#2b0b0f"
                                    border.color: gold
                                    Text { anchors.centerIn: parent; text: modelData.on; color: gold; font.pixelSize: 10 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: securityApp
        Item {
            anchors.fill: parent
            Row {
                anchors.fill: parent
                spacing: 14

                Rectangle {
                    width: 278
                    height: parent.height
                    radius: 9
                    color: "#120608"
                    border.color: "#3a1216"
                    Column {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 14
                        Text { text: "King of Curses"; color: gold; font.pixelSize: 20; font.bold: true }
                        Text { text: "LSM, políticas assinadas, isolamento e rollback trabalhando como uma defesa única."; color: textMuted; wrapMode: Text.WordWrap; width: parent.width; font.pixelSize: 12 }
                        Rectangle { width: parent.width; height: 1; color: "#351116" }
                        Text { text: "Threat Level"; color: textMuted; font.pixelSize: 11 }
                        Text { text: "LOW"; color: "#6dd99b"; font.pixelSize: 44; font.bold: true }
                    }
                }

                Column {
                    width: parent.width - 292
                    spacing: 12
                    Repeater {
                        model: [
                            { "name": "Cleave Guard", "desc": "Bloqueia execução não assinada.", "value": "98%" },
                            { "name": "Dismantle Scan", "desc": "Analisa binários e scripts suspeitos.", "value": "17" },
                            { "name": "Malevolent Domain", "desc": "Sandbox local para testes destrutivos.", "value": "on" },
                            { "name": "Shrine Rollback", "desc": "Snapshots antes de updates críticos.", "value": "4" }
                        ]
                        Rectangle {
                            width: parent.width
                            height: 84
                            radius: 8
                            color: "#120608"
                            border.color: "#351116"
                            Row {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 12
                                Rectangle { width: 10; height: 10; radius: 5; color: index === 1 ? gold : accent; anchors.verticalCenter: parent.verticalCenter }
                                Column {
                                    width: parent.width - 96
                                    spacing: 4
                                    Text { text: modelData.name; color: textPrimary; font.pixelSize: 14; font.bold: true }
                                    Text { text: modelData.desc; color: textMuted; font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width }
                                }
                                Text { text: modelData.value; color: gold; font.pixelSize: 18; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: filesApp
        Item {
            anchors.fill: parent
            Row {
                anchors.fill: parent
                spacing: 14
                Column {
                    width: 170
                    spacing: 8
                    Repeater {
                        model: ["Home", "Domain Files", "Binding Vows", "Downloads", "Vault", "Snapshots"]
                        Rectangle {
                            width: parent.width
                            height: 38
                            radius: 7
                            color: index === 1 ? "#2b0b0f" : "#120608"
                            border.color: index === 1 ? accent : "#351116"
                            Text { anchors.centerIn: parent; text: modelData; color: index === 1 ? gold : textMuted; font.pixelSize: 12 }
                        }
                    }
                }
                Grid {
                    columns: 4
                    columnSpacing: 12
                    rowSpacing: 12
                    Repeater {
                        model: [
                            { "name": "Maldições", "type": "DIR" },
                            { "name": "Binding_Vows", "type": "DIR" },
                            { "name": "Domain_Files", "type": "DIR" },
                            { "name": "wallpaper-2.svg", "type": "SVG" },
                            { "name": "kernel.conf", "type": "CFG" },
                            { "name": "cursed_energy.wav", "type": "WAV" },
                            { "name": "hollow_purple.exe", "type": "DCL" },
                            { "name": "snapshot_04.img", "type": "IMG" }
                        ]
                        Rectangle {
                            width: 132
                            height: 104
                            radius: 8
                            color: "#120608"
                            border.color: "#351116"
                            Column {
                                anchors.centerIn: parent
                                spacing: 8
                                Rectangle {
                                    width: 42
                                    height: 42
                                    radius: 8
                                    color: "#070203"
                                    border.color: gold
                                    Text { anchors.centerIn: parent; text: modelData.type; color: gold; font.pixelSize: 10; font.bold: true }
                                }
                                Text { width: 104; text: modelData.name; color: textMuted; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: dclApp
        Item {
            anchors.fill: parent
            Column {
                anchors.fill: parent
                spacing: 14
                Text { text: "Domain Compatibility Layer"; color: gold; font.pixelSize: 20; font.bold: true }
                Text { text: "Executa apps Windows com Wine/Proton em prefixos isolados, assinados e monitorados pelo King of Curses."; color: textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; width: parent.width }
                Repeater {
                    model: [
                        { "name": "Steam Proton Shrine", "status": "ready", "detail": "GPU passthrough e game mode" },
                        { "name": "Office Vessel", "status": "contained", "detail": "Prefixo corporativo isolado" },
                        { "name": "Unknown EXE", "status": "quarantined", "detail": "Aguardando Dismantle Scan" }
                    ]
                    Rectangle {
                        width: parent.width
                        height: 82
                        radius: 8
                        color: "#120608"
                        border.color: "#351116"
                        Row {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12
                            Rectangle { width: 42; height: 42; radius: 8; color: "#070203"; border.color: gold; Text { anchors.centerIn: parent; text: "DCL"; color: gold; font.pixelSize: 10; font.bold: true } }
                            Column {
                                width: parent.width - 150
                                spacing: 4
                                Text { text: modelData.name; color: textPrimary; font.pixelSize: 14; font.bold: true }
                                Text { text: modelData.detail; color: textMuted; font.pixelSize: 11 }
                            }
                            Text { text: modelData.status; color: gold; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: ritualsApp
        Item {
            anchors.fill: parent
            Column {
                anchors.fill: parent
                spacing: 14
                Text { text: "Shrine Snapshots"; color: gold; font.pixelSize: 20; font.bold: true }
                Text { text: "Rituais de recuperação para updates, drivers e experimentos DCL."; color: textMuted; font.pixelSize: 12 }
                Repeater {
                    model: [
                        { "name": "Before GPU Driver", "time": "hoje 13:10", "state": "restorable" },
                        { "name": "Pre-DCL Install", "time": "hoje 12:42", "state": "sealed" },
                        { "name": "Clean Boot Shrine", "time": "ontem 22:17", "state": "verified" },
                        { "name": "Factory Domain", "time": "base", "state": "locked" }
                    ]
                    Rectangle {
                        width: parent.width
                        height: 72
                        radius: 8
                        color: "#120608"
                        border.color: "#351116"
                        Row {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12
                            Rectangle { width: 38; height: 38; radius: 8; color: "#070203"; border.color: gold; Text { anchors.centerIn: parent; text: "R"; color: gold; font.bold: true } }
                            Column {
                                width: parent.width - 154
                                spacing: 4
                                Text { text: modelData.name; color: textPrimary; font.pixelSize: 13; font.bold: true }
                                Text { text: modelData.time; color: textMuted; font.pixelSize: 11 }
                            }
                            Rectangle {
                                width: 86
                                height: 28
                                radius: 6
                                color: "#2b0b0f"
                                border.color: accent
                                Text { anchors.centerIn: parent; text: modelData.state; color: gold; font.pixelSize: 10 }
                            }
                        }
                    }
                }
            }
        }
    }
}
