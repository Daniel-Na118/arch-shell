pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Default colors (Catppuccin Mocha)
    property var colors: ({
        base: "#1e1e2e",
        mantle: "#181825",
        crust: "#11111b",
        text: "#cdd6f4",
        subtext0: "#a6adc8",
        subtext1: "#bac2de",
        surface0: "#313244",
        surface1: "#45475a",
        surface2: "#585b70",
        overlay0: "#6c7086",
        blue: "#89b4fa",
        lavender: "#b4befe",
        sapphire: "#74c7ec",
        sky: "#89dceb",
        teal: "#94e2d5",
        green: "#a6e3a1",
        yellow: "#f9e2af",
        peach: "#fab387",
        maroon: "#eba0ac",
        red: "#f38ba8",
        mauve: "#cba6f7",
        pink: "#f5c2e7",
        flamingo: "#f2cdcd",
        rosewater: "#f5e0dc"
    })

    // Path to Matugen generated colors
    readonly property string matugenPath: Quickshell.env("HOME") + "/.local/state/quickshell/user/generated/colors.json"

    FileView {
        path: root.matugenPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const data = JSON.parse(text());
                const m3 = data.colors.dark; // Default to dark mode colors
                
                // Map Matugen Material You names to our theme names
                root.colors = {
                    base: "#" + m3.surface,
                    mantle: "#" + m3.surface_container,
                    crust: "#" + m3.surface_container_lowest,
                    text: "#" + m3.on_surface,
                    subtext0: "#" + m3.on_surface_variant,
                    subtext1: "#" + m3.on_surface_variant,
                    surface0: "#" + m3.surface_container_high,
                    surface1: "#" + m3.surface_container_highest,
                    surface2: "#" + m3.outline,
                    overlay0: "#" + m3.outline_variant,
                    blue: "#" + m3.primary,
                    lavender: "#" + m3.secondary,
                    sapphire: "#" + m3.tertiary,
                    sky: "#" + m3.primary_container,
                    teal: "#" + m3.secondary_container,
                    green: "#" + m3.tertiary_container,
                    yellow: "#" + m3.primary_fixed,
                    peach: "#" + m3.secondary_fixed,
                    maroon: "#" + m3.tertiary_fixed,
                    red: "#" + m3.error,
                    mauve: "#" + m3.inverse_primary,
                    pink: "#" + m3.primary_fixed_dim,
                    flamingo: "#" + m3.secondary_fixed_dim,
                    rosewater: "#" + m3.tertiary_fixed_dim
                };
                console.log("Matugen colors loaded successfully");
            } catch (e) {
                console.log("Failed to load Matugen colors, using defaults: " + e);
            }
        }
    }
}
