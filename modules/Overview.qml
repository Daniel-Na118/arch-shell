import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import "../services"

Item {
    id: overviewRoot

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            text: "Current Workspace Overview"
            color: ThemeService.colors.text
            font.pixelSize: 20
            font.bold: true
        }

        GridView {
            id: windowGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: parent.width / 2
            cellHeight: 120
            clip: true

            model: ScriptModel {
                values: Hyprland.toplevels.values.filter(t => {
                    return t.workspace && Hyprland.focusedWorkspace && t.workspace.id === Hyprland.focusedWorkspace.id;
                })
            }

            delegate: Item {
                width: windowGrid.cellWidth
                height: windowGrid.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6
                    color: modelData.focused ? ThemeService.colors.surface0 : ThemeService.colors.mantle
                    radius: 12
                    border.color: modelData.focused ? ThemeService.colors.blue : ThemeService.colors.surface0
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        RowLayout {
                            spacing: 10
                            
                            IconImage {
                                width: 32; height: 32
                                readonly property var entry: DesktopEntries.heuristicLookup(modelData.initialClass || modelData.id)
                                source: Quickshell.iconPath(entry ? entry.icon : "application-x-executable", "application-x-executable")
                                asynchronous: true
                            }

                            Text {
                                text: modelData.title
                                color: ThemeService.colors.text
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            
                            Rectangle {
                                height: 20; radius: 4; color: ThemeService.colors.surface1
                                width: statusText.implicitWidth + 12
                                Text {
                                    id: statusText
                                    anchors.centerIn: parent
                                    text: modelData.floating ? "Floating" : "Tiled"
                                    color: ThemeService.colors.subtext0; font.pixelSize: 10
                                }
                            }
                            
                            Item { Layout.fillWidth: true } // Spacer

                            Text {
                                text: "󰅖"
                                color: ThemeService.colors.red
                                font.pixelSize: 16
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "closewindow", "address:0x" + modelData.address])
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            modelData.focus();
                            notch.expanded = false;
                        }
                    }
                }
            }
        }
        
        // Empty state
        Text {
            visible: windowGrid.count === 0
            text: "No windows open in this workspace"
            color: ThemeService.colors.surface2
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
