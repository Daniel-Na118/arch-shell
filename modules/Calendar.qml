import QtQuick
import QtQuick.Layouts
import "../services"

Item {
    id: calendarRoot

    property date today: new Date()
    property date displayDate: new Date(today.getFullYear(), today.getMonth(), 1)
    
    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    readonly property var dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Header
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: calendarRoot.monthNames[calendarRoot.displayDate.getMonth()] + " " + calendarRoot.displayDate.getFullYear()
                color: ThemeService.colors.text
                font.pixelSize: 20
                font.bold: true
                Layout.fillWidth: true
            }
            
            Row {
                spacing: 10
                Rectangle {
                    width: 32; height: 32; radius: 16; color: ThemeService.colors.surface0
                    Text { anchors.centerIn: parent; text: "󰁍"; color: ThemeService.colors.text; font.pixelSize: 16 }
                    MouseArea { anchors.fill: parent; onClicked: calendarRoot.displayDate = new Date(calendarRoot.displayDate.getFullYear(), calendarRoot.displayDate.getMonth() - 1, 1) }
                }
                Rectangle {
                    width: 32; height: 32; radius: 16; color: ThemeService.colors.surface0
                    Text { anchors.centerIn: parent; text: "󰁔"; color: ThemeService.colors.text; font.pixelSize: 16 }
                    MouseArea { anchors.fill: parent; onClicked: calendarRoot.displayDate = new Date(calendarRoot.displayDate.getFullYear(), calendarRoot.displayDate.getMonth() + 1, 1) }
                }
            }
        }

        // Days of week header
        RowLayout {
            Layout.fillWidth: true
            Repeater {
                model: calendarRoot.dayNames
                delegate: Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: ThemeService.colors.blue
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }

        // Calendar Grid
        GridLayout {
            columns: 7
            Layout.fillWidth: true
            Layout.fillHeight: true
            rowSpacing: 8
            columnSpacing: 8

            Repeater {
                model: 42 // 6 weeks
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    
                    readonly property int firstDay: calendarRoot.displayDate.getDay()
                    readonly property int dayNum: index - firstDay + 1
                    readonly property date date: new Date(calendarRoot.displayDate.getFullYear(), calendarRoot.displayDate.getMonth(), dayNum)
                    readonly property bool isToday: date.getDate() === calendarRoot.today.getDate() && 
                                                  date.getMonth() === calendarRoot.today.getMonth() && 
                                                  date.getFullYear() === calendarRoot.today.getFullYear()
                    readonly property bool isCurrentMonth: date.getMonth() === calendarRoot.displayDate.getMonth()

                    color: isToday ? ThemeService.colors.blue : "transparent"
                    opacity: isCurrentMonth ? 1.0 : 0.3

                    Text {
                        anchors.centerIn: parent
                        text: date.getDate()
                        color: isToday ? ThemeService.colors.base : ThemeService.colors.text
                        font.pixelSize: 14
                        font.bold: isToday
                    }
                }
            }
        }
    }
}
