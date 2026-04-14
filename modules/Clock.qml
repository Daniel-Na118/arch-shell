import QtQuick
import QtQuick.Layouts
import Quickshell
import "../services"

ShellWindow {
    id: clockWindow

    // Window Setup
    level: ShellWindow.Overlay
    anchor: Qt.AlignTop | Qt.AlignRight
    margins { top: 10; right: 20 }
    
    width: contentRow.implicitWidth + 24
    height: 44
    color: "transparent"

    Rectangle {
        id: body
        anchors.fill: parent
        color: ThemeService.colors.base
        radius: 22
        border.color: ThemeService.colors.surface0
        border.width: 1

        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "󰃭"
                color: ThemeService.colors.blue
                font.pixelSize: 16
            }

            Text {
                text: Time.time
                color: ThemeService.colors.text
                font.pixelSize: 14
                font.weight: Font.Bold
            }
            
            Rectangle {
                width: 1; height: 16; color: ThemeService.colors.surface0
            }

            Text {
                text: Time.date
                color: ThemeService.colors.subtext0
                font.pixelSize: 12
            }
        }
    }
}
