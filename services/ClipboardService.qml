pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var items: []

    function reload() {
        listProc.exec();
    }

    function select(id) {
        decodeProc.item_id = id;
        decodeProc.exec();
    }

    function clear() {
        Quickshell.execDetached(["cliphist", "wipe"]);
        reload();
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                let newItems = [];
                for (const line of lines) {
                    if (!line) continue;
                    const parts = line.split("\t");
                    if (parts.length >= 2) {
                        newItems.push({ id: parts[0], text: parts[1] });
                    }
                }
                root.items = newItems;
            }
        }
    }

    Process {
        id: decodeProc
        property string item_id: ""
        command: ["cliphist", "decode", item_id]
        stdout: StdioCollector {
            onStreamFinished: {
                const content = text;
                Quickshell.execDetached(["wl-copy"], content);
            }
        }
    }

    Component.onCompleted: reload()
}
