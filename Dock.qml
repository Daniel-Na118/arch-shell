import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import "services"

ShellWindow {
    id: dockWindow

    // Configuration
    property int iconSize: 42
    property int spacing: 12
    property bool isHovered: false
    
    property var pinnedApps: [
        "foot",
        "zen-alpha",
        "nautilus",
        "spotify"
    ]

    // Window Setup
    level: ShellWindow.Overlay
    anchor: Qt.AlignBottom | Qt.AlignHCenter
    width: contentRow.implicitWidth + 32
    height: 64
    color: "transparent"

    property real revealProgress: isHovered ? 1 : 0
    Behavior on revealProgress { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
    
    y: screen.height - (height * revealProgress) + 4

    ShellWindow {
        id: hoverArea
        level: ShellWindow.Overlay
        anchor: Qt.AlignBottom | Qt.AlignHCenter
        width: dockWindow.width
        height: 10
        color: "transparent"
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: dockWindow.isHovered = true
        }
    }

    Rectangle {
        id: body
        anchors.fill: parent
        color: ThemeService.colors.base
        radius: 18
        border.color: ThemeService.colors.surface0
        border.width: 1
        opacity: dockWindow.revealProgress

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: dockWindow.isHovered = true
            onExited: dockWindow.isHovered = false
        }

        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: dockWindow.spacing

            Repeater {
                model: dockWindow.pinnedApps
                delegate: DockItem {
                    appId: modelData
                    isPinned: true
                }
            }

            Rectangle {
                width: 1
                height: 24
                color: ThemeService.colors.surface0
                visible: runningAppsRepeater.count > 0 && dockWindow.pinnedApps.length > 0
            }

            Repeater {
                id: runningAppsRepeater
                model: {
                    return Hyprland.toplevels.values.filter(t => {
                        return !dockWindow.pinnedApps.includes(t.id) && 
                               !dockWindow.pinnedApps.includes(t.initialClass);
                    });
                }
                delegate: DockItem {
                    appId: modelData.id
                    toplevel: modelData
                    isPinned: false
                }
            }
        }
    }

    component DockItem: Rectangle {
        id: itemRoot
        required property string appId
        property var toplevel: null
        property bool isPinned: false
        
        readonly property bool isRunning: toplevel !== null || 
                                         Hyprland.toplevels.values.some(t => t.id === appId || t.initialClass === appId)
        
        readonly property var activeToplevel: toplevel || 
                                              Hyprland.toplevels.values.find(t => t.id === appId || t.initialClass === appId)

        width: dockWindow.iconSize + 8
        height: dockWindow.iconSize + 8
        radius: 12
        color: mouseArea.containsMouse ? ThemeService.colors.surface0 : "transparent"
        
        property var entry: DesktopEntries.heuristicLookup(appId)
        property string iconName: entry ? entry.icon : appId

        IconImage {
            id: icon
            anchors.centerIn: parent
            width: dockWindow.iconSize
            height: dockWindow.iconSize
            source: Quickshell.iconPath(itemRoot.iconName, "application-x-executable")
            asynchronous: true
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            anchors.horizontalCenter: parent.horizontalCenter
            width: activeToplevel && activeToplevel.focused ? 12 : 4
            height: 4
            radius: 2
            color: activeToplevel && activeToplevel.focused ? ThemeService.colors.blue : ThemeService.colors.overlay0
            visible: itemRoot.isRunning
            
            Behavior on width { NumberAnimation { duration: 200 } }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (itemRoot.isRunning) {
                    itemRoot.activeToplevel.focus()
                } else if (itemRoot.entry) {
                    itemRoot.entry.execute()
                }
            }
        }
        
        Rectangle {
            id: tooltip
            visible: mouseArea.containsMouse
            anchors.bottom: parent.top
            anchors.bottomMargin: 10
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
                text: itemRoot.entry ? itemRoot.entry.name : itemRoot.appId
                color: ThemeService.colors.text
                font.pixelSize: 12
            }
        }
    }
}
