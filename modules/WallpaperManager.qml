import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import "../services"

Item {
    id: wallpaperRoot
    
    property string searchText: ""
    property int selectedIndex: -1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Header with Random Button
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 12
                color: "#313244"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    Text { text: "󰍉"; color: "#89b4fa"; font.pixelSize: 16 }
                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: "#cdd6f4"
                        font.pixelSize: 14
                        clip: true
                        onTextChanged: wallpaperRoot.searchText = text
                    }
                }
            }

            Rectangle {
                width: 40
                height: 40
                radius: 12
                color: "#313244"
                Text {
                    anchors.centerIn: parent
                    text: "󰒝"
                    color: "#a6e3a1"
                    font.pixelSize: 18
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: WallpaperService.applyRandom()
                }
            }
        }

        // Wallpaper Grid
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Flow {
                width: parent.width
                spacing: 12

                Repeater {
                    model: WallpaperService.folderModel
                    delegate: Rectangle {
                        width: (parent.width - 12) / 2
                        height: width * 0.6
                        radius: 12
                        color: "#313244"
                        clip: true
                        border.color: WallpaperService.currentWallpaper === filePath ? "#89b4fa" : "transparent"
                        border.width: 2

                        Image {
                            anchors.fill: parent
                            source: fileURL
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }

                        // Gradient overlay for name
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 24
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 1.0; color: "#1e1e2e" }
                            }
                        }

                        Text {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 6
                            text: fileName
                            color: "#cdd6f4"
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: WallpaperService.apply(filePath)
                        }
                    }
                }
            }
        }
    }
}
