import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import "services"
import "modules"

PanelWindow {
    id: notchWindow

    property bool expanded: false
    property int currentView: 0 // 0:Dash, 1:Launch, 2:Wall, 3:Cal, 4:Over, 5:Clip, 6:Emoji, 7:Power
    
    property int compactWidth: 320
    property int compactHeight: 44
    property int expandedWidth: 640
    property int expandedHeight: 640

    // Window setup - Full width anchoring to allow centering content
    WlrLayershell.layer: WlrLayershell.Overlay
    anchors.top: true
    anchors.left: true
    anchors.right: true
    
    // Height follows the expanded state
    implicitHeight: expanded ? expandedHeight : compactHeight
    color: "transparent"

    // The actual Notch component centered in the full-width window
    Item {
        id: notch
        anchors.horizontalCenter: parent.horizontalCenter
        width: expanded ? expandedWidth : (Mpris.hasPlayer && Mpris.isPlaying ? 400 : (Hyprland.activeToplevel ? compactWidth : 180))
        height: parent.height

        // Smooth transitions
        Behavior on width { 
            NumberAnimation { 
                duration: 450
                easing.bezierCurve: [0.4, 0, 0.2, 1] 
            } 
        }

        Rectangle {
            id: body
            anchors.fill: parent
            color: ThemeService.colors.base
            radius: expanded ? 24 : 22
            border.color: ThemeService.colors.surface0
            border.width: 1

            // Interaction
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!notchWindow.expanded) {
                        notchWindow.currentView = 0;
                        notchWindow.expanded = true;
                    }
                }
            }

            // Compact Content
            Item {
                id: compactContent
                anchors.fill: parent
                opacity: notchWindow.expanded ? 0 : 1
                visible: opacity > 0

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    width: parent.width - 40

                    // Media Player Mini View
                    RowLayout {
                        visible: Mpris.hasPlayer && Mpris.isPlaying
                        spacing: 10
                        Layout.fillWidth: true

                        Rectangle {
                            width: 28; height: 28; radius: 8; clip: true; color: ThemeService.colors.surface0
                            Image { 
                                anchors.fill: parent
                                source: Mpris.artUrl || ""
                                fillMode: Image.PreserveAspectCrop
                                visible: status === Image.Ready 
                            }
                            Text { 
                                anchors.centerIn: parent
                                text: "󰝚"
                                color: ThemeService.colors.blue
                                font.pixelSize: 14
                                visible: parent.children[0].status !== Image.Ready 
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            Text { 
                                text: Mpris.title
                                color: ThemeService.colors.text
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                                width: parent.width 
                            }
                            Text { 
                                text: Mpris.artist
                                color: ThemeService.colors.subtext0
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                width: parent.width 
                            }
                        }

                        // Visualizer
                        Row {
                            spacing: 2
                            height: 12
                            Repeater {
                                model: 4
                                Rectangle {
                                    width: 3; radius: 1; color: ThemeService.colors.blue
                                    height: 4 + Math.random() * 8
                                    SequentialAnimation on height { 
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 12; duration: 300 + index * 100 }
                                        NumberAnimation { to: 4; duration: 300 + index * 100 }
                                    }
                                }
                            }
                        }
                    }

                    // Default Window View
                    RowLayout {
                        visible: !(Mpris.hasPlayer && Mpris.isPlaying)
                        spacing: 12
                        Layout.fillWidth: true
                        Item {
                            width: 24
                            height: 24
                            IconImage {
                                anchors.fill: parent
                                readonly property var activeToplevel: Hyprland.activeToplevel
                                readonly property var entry: activeToplevel ? DesktopEntries.heuristicLookup(activeToplevel.initialClass || activeToplevel.id) : null
                                source: Quickshell.iconPath(entry ? entry.icon : "application-x-executable", "application-x-executable")
                                asynchronous: true
                                visible: Hyprland.activeToplevel !== null
                            }
                            Text { 
                                anchors.centerIn: parent
                                text: "󰣇"
                                color: ThemeService.colors.blue
                                font.pixelSize: 20
                                visible: Hyprland.activeToplevel === null 
                            }
                        }
                        Text { 
                            text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "Workspace " + (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : "")
                            color: ThemeService.colors.text
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                            Layout.fillWidth: true 
                        }
                    }
                }

                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // Expanded Content
            Item {
                id: expandedContent
                anchors.fill: parent
                opacity: notchWindow.expanded ? 1 : 0
                visible: opacity > 0

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 20

                    RowLayout {
                        Text {
                            text: {
                                if (notchWindow.currentView === 0) return "Dashboard";
                                if (notchWindow.currentView === 1) return "Launcher";
                                if (notchWindow.currentView === 2) return "Wallpapers";
                                if (notchWindow.currentView === 3) return "Calendar";
                                if (notchWindow.currentView === 4) return "Overview";
                                if (notchWindow.currentView === 5) return "Clipboard";
                                if (notchWindow.currentView === 6) return "Emojis";
                                if (notchWindow.currentView === 7) return "Power Menu";
                                return "";
                            }
                            color: ThemeService.colors.text
                            font.pixelSize: 22
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        
                        RowLayout {
                            spacing: 4
                            Repeater {
                                model: [
                                    { icon: "󰕮", view: 0 },
                                    { icon: "󰍉", view: 1 },
                                    { icon: "󰸉", view: 2 },
                                    { icon: "󰃭", view: 3 },
                                    { icon: "󰅂", view: 4 },
                                    { icon: "󰅍", view: 5 },
                                    { icon: "󰞅", view: 6 },
                                    { icon: "󰐥", view: 7 }
                                ]
                                delegate: Rectangle {
                                    width: 26
                                    height: 26
                                    radius: 13
                                    color: notchWindow.currentView === modelData.view ? ThemeService.colors.blue : ThemeService.colors.surface0
                                    Text { 
                                        anchors.centerIn: parent
                                        text: modelData.icon
                                        color: notchWindow.currentView === modelData.view ? ThemeService.colors.base : ThemeService.colors.blue
                                        font.pixelSize: 13 
                                    }
                                    MouseArea { 
                                        anchors.fill: parent
                                        onClicked: { notchWindow.currentView = modelData.view; }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: ThemeService.colors.surface0
                            Text { 
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: ThemeService.colors.red
                                font.pixelSize: 16 
                            }
                            MouseArea { 
                                anchors.fill: parent
                                onClicked: { notchWindow.expanded = false; }
                            }
                        }
                    }

                    StackLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: notchWindow.currentView

                        // View 0: Dashboard
                        ColumnLayout {
                            spacing: 20
                            // Media Player
                            Rectangle {
                                Layout.fillWidth: true
                                height: 120
                                color: ThemeService.colors.surface0
                                radius: 20
                                visible: Mpris.hasPlayer
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 20
                                    Rectangle {
                                        width: 90
                                        height: 90
                                        radius: 12
                                        clip: true
                                        color: ThemeService.colors.base
                                        Image { 
                                            anchors.fill: parent
                                            source: Mpris.artUrl || ""
                                            fillMode: Image.PreserveAspectCrop
                                            visible: status === Image.Ready 
                                        }
                                        Text { 
                                            anchors.centerIn: parent
                                            text: "󰝚"
                                            color: ThemeService.colors.blue
                                            font.pixelSize: 32
                                            visible: parent.children[0].status !== Image.Ready 
                                        }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 4
                                        Text { 
                                            text: Mpris.title
                                            color: ThemeService.colors.text
                                            font.pixelSize: 18
                                            font.bold: true
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true 
                                        }
                                        Text { 
                                            text: Mpris.artist
                                            color: ThemeService.colors.subtext0
                                            font.pixelSize: 14
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true 
                                        }
                                        Item { Layout.fillHeight: true }
                                        RowLayout {
                                            Layout.alignment: Qt.AlignHCenter
                                            spacing: 24
                                            Text { 
                                                text: "󰒮"
                                                color: ThemeService.colors.text
                                                font.pixelSize: 24
                                                MouseArea { anchors.fill: parent; onClicked: { Mpris.previous(); } } 
                                            }
                                            Rectangle {
                                                width: 44
                                                height: 44
                                                radius: 22
                                                color: ThemeService.colors.blue
                                                Text { 
                                                    anchors.centerIn: parent
                                                    text: Mpris.isPlaying ? "󰏤" : "󰐊"
                                                    color: ThemeService.colors.base
                                                    font.pixelSize: 24 
                                                }
                                                MouseArea { anchors.fill: parent; onClicked: { Mpris.togglePlay(); } }
                                            }
                                            Text { 
                                                text: "󰒭"
                                                color: ThemeService.colors.text
                                                font.pixelSize: 24
                                                MouseArea { anchors.fill: parent; onClicked: { Mpris.next(); } } 
                                            }
                                        }
                                    }
                                }
                            }

                            // Quick Actions
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                Text { text: "Quick Actions"; color: ThemeService.colors.text; font.pixelSize: 14; font.bold: true }
                                RowLayout {
                                    id: actionsRow
                                    spacing: 12
                                    Layout.fillWidth: true
                                    property var actions: [
                                        { icon: "󰹑", label: "Full", cmd: "full" },
                                        { icon: "󰒉", label: "Area", cmd: "area" },
                                        { icon: "󰖲", label: "Window", cmd: "window" }
                                    ]
                                    Repeater {
                                        model: actionsRow.actions
                                        delegate: Rectangle {
                                            Layout.fillWidth: true
                                            height: 50
                                            radius: 12
                                            color: ThemeService.colors.surface0
                                            RowLayout {
                                                anchors.centerIn: parent
                                                spacing: 8
                                                Text { text: modelData.icon; color: ThemeService.colors.blue; font.pixelSize: 18 }
                                                Text { text: modelData.label; color: ThemeService.colors.text; font.pixelSize: 13 }
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    notchWindow.expanded = false;
                                                    screenshotTimer.cmd = modelData.cmd;
                                                    screenshotTimer.start();
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Timer {
                                id: screenshotTimer
                                interval: 500
                                repeat: false
                                property string cmd: ""
                                onTriggered: {
                                    Quickshell.execDetached([Quickshell.shellDir + "/scripts/screenshot.sh", cmd]);
                                }
                            }

                            // System Metrics
                            GridLayout {
                                columns: 2
                                rowSpacing: 16
                                columnSpacing: 16
                                Layout.fillWidth: true
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 70
                                    color: ThemeService.colors.surface0
                                    radius: 16
                                    RowLayout { 
                                        anchors.centerIn: parent
                                        spacing: 12
                                        Text { 
                                            text: Audio.muted ? "󰝟" : "󰕾"
                                            color: ThemeService.colors.blue
                                            font.pixelSize: 20 
                                        }
                                        Text { 
                                            text: Math.round(Audio.volume * 100) + "%"
                                            color: ThemeService.colors.text 
                                        } 
                                    }
                                    MouseArea { 
                                        anchors.fill: parent
                                        onWheel: function(wheel) {
                                            if (wheel.angleDelta.y > 0) Audio.incrementVolume();
                                            else Audio.decrementVolume();
                                        }
                                        onClicked: { Audio.sink.audio.muted = !Audio.sink.audio.muted; }
                                    }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 70
                                    color: ThemeService.colors.surface0
                                    radius: 16
                                    visible: SystemInfo.hasBattery
                                    RowLayout { 
                                        anchors.centerIn: parent
                                        spacing: 12
                                        Text { 
                                            text: SystemInfo.isCharging ? "󰂄" : "󰁹"
                                            color: ThemeService.colors.green
                                            font.pixelSize: 20 
                                        }
                                        Text { 
                                            text: Math.round(SystemInfo.batteryPerc * 100) + "%"
                                            color: ThemeService.colors.text 
                                        } 
                                    }
                                }
                            }
                            Item { Layout.fillHeight: true }
                        }

                        // Modules
                        Launcher {}
                        WallpaperManager {}
                        Calendar {}
                        Overview {}
                        ClipboardManager {}
                        EmojiPicker {}
                        PowerMenu {}
                    }
                }
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }
}
