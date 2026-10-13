pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var palettes: ({
            mocha: {
                base: "#1e1e2e", mantle: "#181825", crust: "#11111b", surface: "#313244",
                text: "#cdd6f4", subtext: "#a6adc8", overlay: "#6c7086",
                blue: "#89b4fa", mauve: "#cba6f7", pink: "#f5c2e7", green: "#a6e3a1", yellow: "#f9e2af",
                red: "#f38ba8", teal: "#94e2d5", sky: "#89dceb", sapphire: "#74c7ec", peach: "#fab387"
            },
            macchiato: {
                base: "#24273a", mantle: "#1e2030", crust: "#181926", surface: "#363a4f",
                text: "#cad3f5", subtext: "#a5adcb", overlay: "#6e738d",
                blue: "#8aadf4", mauve: "#c6a0f6", pink: "#f5bde6", green: "#a6da95", yellow: "#eed49f",
                red: "#ed8796", teal: "#8bd5ca", sky: "#91d7e3", sapphire: "#7dc4e4", peach: "#f5a97f"
            },
            frappe: {
                base: "#303446", mantle: "#292c3c", crust: "#232634", surface: "#414559",
                text: "#c6d0f5", subtext: "#a5adce", overlay: "#737994",
                blue: "#8caaee", mauve: "#ca9ee6", pink: "#f4b8e4", green: "#a6d189", yellow: "#e5c890",
                red: "#e78284", teal: "#81c8be", sky: "#99d1db", sapphire: "#85c1dc", peach: "#ef9f76"
            },
            latte: {
                base: "#eff1f5", mantle: "#e6e9ef", crust: "#dce0e8", surface: "#ccd0da",
                text: "#4c4f69", subtext: "#6c6f85", overlay: "#9ca0b0",
                blue: "#1e66f5", mauve: "#8839ef", pink: "#ea76cb", green: "#40a02b", yellow: "#df8e1d",
                red: "#d20f39", teal: "#179299", sky: "#04a5e5", sapphire: "#209fb5", peach: "#fe640b"
            }
        })

    property string flavor: "mocha"
    readonly property var colors: palettes[flavor]
    readonly property var accents: ["blue", "mauve", "pink", "green", "yellow", "red", "teal", "sky", "sapphire", "peach"]
    readonly property string font: "Hack Nerd Font"
    readonly property string sans: "Adwaita Sans"

    FileView {
        path: Quickshell.shellPath("flavor")
        watchChanges: true
        blockLoading: true
        onFileChanged: reload()
        onLoaded: {
            const name = text().trim();
            if (name in root.palettes)
                root.flavor = name;
        }
    }
}
