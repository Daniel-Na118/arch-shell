import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "../services"

Item {
    id: launcherRoot
    
    property string searchText: ""
    property int selectedIndex: 0
    property var results: []
    property string mode: "apps" // "apps", "calc", "files"

    // Process for file searching
    Process {
        id: fileSearchProc
        command: ["fd", "--type", "f", "--max-results", "10", fileSearchProc.query, Quickshell.env("HOME")]
        property string query: ""
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (launcherRoot.mode !== "files") return;
                const lines = text.trim().split("\n");
                let searchResults = [];
                for (const line of lines) {
                    if (!line) continue;
                    searchResults.push({
                        name: line.split("/").pop(),
                        path: line,
                        is_file: true
                    });
                }
                launcherRoot.results = searchResults;
            }
        }
    }

    function updateSearch(text) {
        searchText = text;
        selectedIndex = 0;
        
        if (text.trim() === "") {
            results = [];
            mode = "apps";
            return;
        }

        // 1. Calculator Mode
        if (text.startsWith("=")) {
            mode = "calc";
            const expr = text.substring(1).trim();
            try {
                if (expr === "") {
                    results = [{ name: "Type a math expression", result: "", is_calc: true }];
                } else {
                    // Safe basic math eval
                    const result = Function('"use strict"; return (' + expr + ')')();
                    results = [{ name: "= " + result, result: result.toString(), is_calc: true }];
                }
            } catch (e) {
                results = [{ name: "Invalid expression", result: "", is_calc: true }];
            }
            return;
        }

        // 2. File Search Mode
        if (text.startsWith("~") || text.startsWith("/")) {
            mode = "files";
            fileSearchProc.query = text.startsWith("~") ? text.substring(1) : text;
            fileSearchProc.exec();
            return;
        }

        // 3. App Mode (Default)
        mode = "apps";
        let searchResults = [];
        const apps = DesktopEntries.applications.values;
        const query = text.toLowerCase();
        
        for (let i = 0; i < apps.length; i++) {
            const app = apps[i];
            if (app.name.toLowerCase().includes(query) || app.id.toLowerCase().includes(query)) {
                searchResults.push(app);
            }
        }
        searchResults.sort((a, b) => a.name.localeCompare(b.name));
        results = searchResults.slice(0, 8);
    }

    function launchSelected() {
        if (results.length === 0) return;
        const item = results[selectedIndex];
        
        if (mode === "apps") {
            item.execute();
        } else if (mode === "calc") {
            if (item.result) {
                Quickshell.execDetached(["wl-copy", item.result]);
                notifyProc.exec(["Calculator", "Copied " + item.result + " to clipboard"]);
            }
        } else if (mode === "files") {
            Quickshell.execDetached(["xdg-open", item.path]);
        }
        notch.expanded = false;
    }

    Process { id: notifyProc; command: ["notify-send", "-a", "Arch-Shell"] }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 20; spacing: 15

        // Search Bar
        Rectangle {
            Layout.fillWidth: true; height: 46; radius: 14; color: ThemeService.colors.surface0
            border.color: searchInput.activeFocus ? ThemeService.colors.blue : "transparent"
            
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 15; spacing: 12
                Text { 
                    text: mode === "calc" ? "󰪚" : (mode === "files" ? "󰈔" : "󰍉")
                    color: ThemeService.colors.blue; font.pixelSize: 18 
                }
                TextInput {
                    id: searchInput; Layout.fillWidth: true; color: ThemeService.colors.text
                    font.pixelSize: 16; focus: true
                    onTextChanged: launcherRoot.updateSearch(text)
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Down) selectedIndex = (selectedIndex + 1) % results.length;
                        else if (event.key === Qt.Key_Up) selectedIndex = (selectedIndex - 1 + results.length) % results.length;
                        else if (event.key === Qt.Key_Return) launchSelected();
                        else if (event.key === Qt.Key_Escape) notch.expanded = false;
                    }
                }
            }
        }

        // Results List
        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 6
            Repeater {
                model: launcherRoot.results
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 52; radius: 12
                    color: launcherRoot.selectedIndex === index ? ThemeService.colors.surface1 : "transparent"
                    
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 15
                        
                        // Icon Logic
                        IconImage {
                            width: 32; height: 32
                            source: {
                                if (modelData.is_calc) return "";
                                if (modelData.is_file) return Quickshell.iconPath("text-x-generic", "text-x-generic");
                                return Quickshell.iconPath(modelData.icon, "application-x-executable");
                            }
                            visible: !modelData.is_calc
                        }
                        
                        Text {
                            text: "󰪚"
                            color: ThemeService.colors.yellow; font.pixelSize: 24
                            visible: modelData.is_calc
                        }

                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 0
                            Text {
                                text: modelData.name; color: ThemeService.colors.text
                                font.pixelSize: 14; font.bold: true
                            }
                            Text {
                                text: modelData.is_file ? modelData.path : (modelData.comment || "")
                                color: ThemeService.colors.subtext0; font.pixelSize: 11
                                elide: Text.ElideMiddle; Layout.fillWidth: true
                                visible: text !== ""
                            }
                        }
                        
                        Text {
                            text: mode === "calc" ? "󰅍" : "󰌑"
                            color: ThemeService.colors.overlay0; font.pixelSize: 14
                            visible: launcherRoot.selectedIndex === index
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; hoverEnabled: true
                        onEntered: launcherRoot.selectedIndex = index
                        onClicked: launcherRoot.launchSelected()
                    }
                }
            }
            Item { Layout.fillHeight: true } // Spacer
        }
    }

    Connections {
        target: notch
        function onCurrentViewChanged() {
            if (notch.currentView === 1) {
                searchInput.text = "";
                searchInput.forceActiveFocus();
            }
        }
    }
}
