import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    visible: true
    width: 1200
    height: 700
    title: "Malevolent Desktop Environment - Mockup"
    color: "#0b0b0b"

    // Theme colors: dark red, black, gold
    property color bg: "#0b0b0b"
    property color panel: "#1f0f0f"
    property color accent: "#8b0000"
    property color gold: "#d4af37"

    Rectangle {
        anchors.fill: parent
        color: bg

        // Top bar
        Rectangle {
            id: topbar
            height: 48
            anchors.left: parent.left
            anchors.right: parent.right
            color: panel
            opacity: 0.95

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12
                padding: 12
                Text { text: "SukunaOS"; color: gold; font.pixelSize: 18 }
            }
        }

        // Dock (bottom)
        Rectangle {
            id: dock
            width: parent.width
            height: 80
            anchors.bottom: parent.bottom
            color: "transparent"

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                width: 600
                height: 64
                radius: 12
                color: "rgba(20,20,20,0.6)"
                border.color: accent

                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 16
                    Repeater {
                        model: ["","","",""]
                        delegate: Rectangle {
                            width: 56; height: 56; radius: 8; color: "transparent"
                            Text { anchors.centerIn: parent; text: modelData; color: gold; font.pixelSize: 24 }
                            MouseArea { anchors.fill: parent; onClicked: console.log("Clicked", modelData) }
                        }
                    }
                }
            }
        }

        // Control Center quick panel
        Rectangle {
            id: controlCenter
            width: 320
            height: 420
            anchors.right: parent.right
            anchors.bottom: dock.top
            color: panel
            radius: 8
            anchors.margins: 12

            Column { anchors.fill: parent; anchors.margins: 12; spacing: 8
                Text { text: "Control Center"; color: gold; font.pixelSize: 16 }
                Row { spacing: 8;
                    Button { text: "Wi-Fi" }
                    Button { text: "Sound" }
                    Button { text: "Display" }
                }
                Rectangle { height: 1; color: "#2b2b2b" }
                Text { text: "Profiles"; color: "#ddd" }
                ListView { model: ["Normal","Gamer","Novice"]; height: 120;
                    delegate: Rectangle { height: 36; color: "transparent"; Text { text: modelData; anchors.verticalCenter: parent.verticalCenter; color: "#ccc" } }
                }
            }
        }
    }
}
