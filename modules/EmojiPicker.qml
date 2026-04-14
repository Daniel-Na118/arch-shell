import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../services"

Item {
    id: emojiRoot

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Rectangle {
            Layout.fillWidth: true; height: 40; radius: 12; color: ThemeService.colors.surface0
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 12
                Text { text: "󰍉"; color: ThemeService.colors.blue; font.pixelSize: 16 }
                TextInput {
                    id: searchInput; Layout.fillWidth: true; color: ThemeService.colors.text
                    font.pixelSize: 14; clip: true
                    onTextChanged: EmojiService.search(text)
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true
            Flow {
                width: parent.width; spacing: 8
                Repeater {
                    model: EmojiService.filteredEmojis
                    delegate: Rectangle {
                        width: 44; height: 44; radius: 10; color: ThemeService.colors.surface0
                        Text {
                            anchors.centerIn: parent; text: modelData; font.pixelSize: 20
                        }
                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true
                            onClicked: {
                                EmojiService.copy(modelData);
                                notch.expanded = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
