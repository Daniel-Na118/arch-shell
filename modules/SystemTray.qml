import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../services"

PanelWindow {
    id: trayWindow

    // Window Setup
    WlrLayershell.layer: WlrLayershell.Overlay
    anchors.top: true
    anchors.right: true
    margins { top: 10; right: 240 } // Shifted left to make room for clock
    
    implicitWidth: contentRow.implicitWidth + 24
    implicitHeight: 44
    color: "transparent"
    
    visible: trayRepeater.count > 0

    Rectangle {
        id: body
        anchors.fill: parent
        color: ThemeService.colors.base
        radius: 22
        border.color: ThemeService.colors.surface0
        border.width: 1
        
        opacity: trayWindow.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 300 } }

        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: 12

            Repeater {
                id: trayRepeater
                model: SystemTray.items.values
                
                delegate: MouseArea {
                    id: trayItemRoot
                    required property SystemTrayItem modelData
                    
                    width: 24
                    height: 24
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true

                    IconImage {
                        anchors.fill: parent
                        source: Quickshell.iconPath(modelData.icon, "image-missing")
                        asynchronous: true
                        opacity: trayItemRoot.containsMouse ? 1.0 : 0.8
                        scale: trayItemRoot.containsMouse ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 200 } }
                    }

                    onClicked: function(event) {
                        if (event.button === Qt.LeftButton) {
                            modelData.activate();
                        } else {
                            modelData.secondaryActivate();
                        }
                    }
                    
                    Rectangle {
                        visible: trayItemRoot.containsMouse
                        anchors.top: parent.bottom
                        anchors.topMargin: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: tooltipText.implicitWidth + 16
                        height: 24
                        color: ThemeService.colors.mantle
                        radius: 6
                        border.color: ThemeService.colors.surface0
                        border.width: 1
                        z: 100

                        Text {
                            id: tooltipText
                            anchors.centerIn: parent
                            text: modelData.title || modelData.id
                            color: ThemeService.colors.text
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }
}
