pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var emojiData: ({})
    property var filteredEmojis: []
    
    readonly property url emojiFile: Qt.resolvedUrl("../../ax-shell/assets/emoji.json")

    function load() {
        fileReader.reload();
    }

    function search(query) {
        if (!query) {
            filteredEmojis = Object.keys(emojiData).slice(0, 50);
            return;
        }
        
        let results = [];
        const q = query.toLowerCase();
        for (const char in emojiData) {
            const info = emojiData[char];
            if (info.name.toLowerCase().includes(q) || (info.group && info.group.toLowerCase().includes(q))) {
                results.push(char);
            }
            if (results.length >= 50) break;
        }
        filteredEmojis = results;
    }

    FileView {
        id: fileReader
        path: root.emojiFile.toString().replace("file://", "")
        onLoaded: {
            try {
                root.emojiData = JSON.parse(text());
                search("");
            } catch (e) {
                console.log("Failed to load emojis: " + e);
            }
        }
    }

    function copy(char) {
        Quickshell.execDetached(["wl-copy", char]);
    }

    Component.onCompleted: load()
}
