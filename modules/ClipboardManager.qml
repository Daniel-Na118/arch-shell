import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../services"

Item {
    id: clipRoot

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true; height: 40; radius: 12; color: ThemeService.colors.surface0
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 12
                    Text { text: "󰍉"; color: ThemeService.colors.blue; font.pixelSize: 16 }
                    TextInput {
                        id: searchInput; Layout.fillWidth: true; color: ThemeService.colors.text
                        font.pixelSize: 14; clip: true
                        onTextChanged: {
                            // Basic local filtering could be added here
                        }
                    }
                }
            }

            Rectangle {
                width: 40; height: 40; radius: 12; color: ThemeService.colors.surface0
                Text { anchors.centerIn: parent; text: "󰃢"; color: ThemeService.colors.red; font.pixelSize: 18 }
                MouseArea { anchors.fill: parent; onClicked: ClipboardService.clear() }
            }
        }

        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true
            ColumnLayout {
                width: parent.width; spacing: 8
                Repeater {
                    model: ClipboardService.items
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 50; radius: 10; color: ThemeService.colors.surface0
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 12; spacing: 12
                            Text { text: "󰅍"; color: ThemeService.colors.blue; font.pixelSize: 16 }
                            Text {
                                text: modelData.text; color: ThemeService.colors.text; font.pixelSize: 13
                                elide: Text.ElideRight; Layout.fillWidth: true
                            }
                        }
                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true
                            onClicked: {
                                ClipboardService.select(modelData.id);
                                notch.expanded = false;
                            }
                        }
                    }
                }
            }
        }
    }
    
    Connections {
        target: notch
        function onCurrentViewChanged() {
            if (notch.currentView === 5) ClipboardService.reload();
        }
    }
}
