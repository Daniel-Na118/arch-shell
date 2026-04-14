import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import "../services"

PanelWindow {
    id: workspacesWindow

    // Window Setup
    WlrLayershell.layer: WlrLayershell.Overlay
    anchors.top: true
    anchors.left: true
    margins { top: 10; left: 20 }
    
    implicitWidth: contentRow.implicitWidth + 24
    implicitHeight: 44
    color: "transparent"

    // Scroll to switch workspaces
    MouseArea {
        anchors.fill: parent
        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) Quickshell.execDetached(["hyprctl", "dispatch", "workspace", "e-1"]);
            else Quickshell.execDetached(["hyprctl", "dispatch", "workspace", "e+1"]);
        }
    }

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
            spacing: 6

            Repeater {
                model: 10 // 10 Workspaces by default
                delegate: Rectangle {
                    id: wsPill
                    
                    readonly property int wsId: index + 1
                    readonly property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
                    
                    // Filter toplevels for THIS workspace
                    readonly property var wsToplevels: {
                        return Hyprland.toplevels.values.filter(function(t) { return t.workspace && t.workspace.id === wsId; });
                    }
                    readonly property bool isOccupied: wsToplevels.length > 0

                    // Dynamic Width
                    implicitWidth: {
                        if (isActive) return Math.max(32, (wsToplevels.length * 20) + 12);
                        if (isOccupied) return (wsToplevels.length * 20) + 12;
                        return 10; // Empty dot
                    }
                    
                    height: 26
                    radius: 13
                    color: isActive ? ThemeService.colors.blue : (isOccupied ? ThemeService.colors.surface0 : "transparent")
                    
                    Behavior on implicitWidth { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }
                    Behavior on color { ColorAnimation { duration: 300 } }

                    // Row of Icons inside the Pill
                    Row {
                        anchors.centerIn: parent
                        spacing: 2
                        visible: isOccupied

                        Repeater {
                            model: wsToplevels
                            delegate: Item {
                                width: 18; height: 18
                                
                                IconImage {
                                    anchors.centerIn: parent
                                    width: 14; height: 16
                                    readonly property var entry: DesktopEntries.heuristicLookup(modelData.initialClass || modelData.id)
                                    source: Quickshell.iconPath(entry ? entry.icon : "application-x-executable", "application-x-executable")
                                    asynchronous: true
                                    opacity: wsPill.isActive ? 1.0 : 0.7
                                }
                            }
                        }
                    }

                    // Simple dot if empty and NOT active
                    Rectangle {
                        anchors.centerIn: parent
                        width: 4; height: 4; radius: 2
                        color: ThemeService.colors.surface2
                        visible: !isOccupied && !isActive
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: function() { Quickshell.execDetached(["hyprctl", "dispatch", "workspace", wsId.toString()]); }
                    }
                }
            }
        }
    }
}
