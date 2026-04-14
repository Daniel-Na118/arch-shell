pragma Singleton

import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Change this to your actual wallpaper directory
    property url wallpaperFolder: Qt.resolvedUrl("../../ax-shell/assets/wallpapers_example/")
    
    property string currentWallpaper: ""

    function apply(path) {
        if (!path) return;
        currentWallpaper = path;
        
        // Using awww for transitions
        Quickshell.execDetached([
            "awww", "img", path,
            "--transition-type", "grow",
            "--transition-pos", "top",
            "--transition-duration", "1.5"
        ]);
        
        console.log("Applied wallpaper via awww: " + path);
    }

    function applyRandom() {
        if (folderModel.count > 0) {
            const index = Math.floor(Math.random() * folderModel.count);
            const path = folderModel.get(index, "filePath");
            apply(path);
        }
    }

    property alias folderModel: folderModel
    FolderListModel {
        id: folderModel
        folder: root.wallpaperFolder
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.svg"]
        showDirs: false
    }
}
