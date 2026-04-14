import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services"

PanelWindow {
    id: clockWindow

    // Window Setup
    WlrLayershell.layer: WlrLayershell.Overlay
    anchors.top: true
    anchors.right: true
    margins { top: 10; right: 20 }
    
    implicitWidth: contentRow.implicitWidth + 24
    implicitHeight: 44
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
