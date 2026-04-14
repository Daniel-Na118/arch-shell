import QtQuick
import QtQuick.Layouts
import Quickshell
import "../services"

Item {
    id: powerRoot

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 30

        Text {
            text: "System Controls"
            color: ThemeService.colors.text
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        GridLayout {
            columns: 2
            rowSpacing: 20
            columnSpacing: 20
            Layout.fillWidth: true
            Layout.fillHeight: true

            Repeater {
                model: [
                    { icon: "󰐥", label: "Shutdown", color: ThemeService.colors.red, cmd: ["systemctl", "poweroff"] },
                    { icon: "󰑓", label: "Reboot", color: ThemeService.colors.yellow, cmd: ["systemctl", "reboot"] },
                    { icon: "󰤄", label: "Sleep", color: ThemeService.colors.blue, cmd: ["systemctl", "suspend"] },
                    { icon: "󰍃", label: "Logout", color: ThemeService.colors.mauve, cmd: ["hyprctl", "dispatch", "exit"] }
                ]

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 20
                    color: ThemeService.colors.surface0
                    border.color: mouseArea.containsMouse ? modelData.color : "transparent"
                    border.width: 2

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        Text {
                            text: modelData.icon
                            font.pixelSize: 48
                            color: modelData.color
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: modelData.label
                            font.pixelSize: 14
                            font.bold: true
                            color: ThemeService.colors.text
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            notch.expanded = false;
                            Quickshell.execDetached(modelData.cmd);
                        }
                    }
                }
            }
        }
        
        Text {
            text: "Hold button to execute"
            color: ThemeService.colors.subtext0
            font.pixelSize: 12
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
