pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property string time: ""
    property string date: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const now = new Date();
            root.time = now.toLocaleTimeString(Qt.locale(), "HH:mm");
            root.date = now.toLocaleDateString(Qt.locale(), "MMM d, ddd");
        }
    }
}
