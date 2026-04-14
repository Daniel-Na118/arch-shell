import QtQuick
import Quickshell
import "services"
import "modules"

ShellRoot {
    // Top Bar Components (Pills)
    Workspaces {}
    Notch {}
    SystemTray {}
    Clock {}
    
    // Bottom Components
    Dock {}
}
