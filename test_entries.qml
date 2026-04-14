import QtQuick
import Quickshell

ShellRoot {
    Component.onCompleted: {
        console.log("DesktopEntries available: " + (typeof DesktopEntries !== "undefined"));
        if (typeof DesktopEntries !== "undefined") {
            console.log("Heuristic lookup for 'foot': " + DesktopEntries.heuristicLookup("foot")?.icon);
        }
    }
}
