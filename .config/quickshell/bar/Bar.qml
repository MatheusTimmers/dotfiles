import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs

Scope {
    id: root

    function run(cmd) {
        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property ShellScreen modelData

            screen: modelData
            color: "transparent"
            implicitHeight: 520
            exclusiveZone: 40
            WlrLayershell.namespace: "qs-bar"
            anchors {
                top: true
                left: true
                right: true
            }

            mask: Region {
                Region {
                    item: left
                }
                Region {
                    item: island
                }
                Region {
                    item: right
                }
            }

            Row {
                id: left
                x: 12
                y: 6
                spacing: 6

                Workspaces {}
            }

            Island {
                id: island
                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
                window: win
            }

            Row {
                id: right
                anchors.right: parent.right
                anchors.rightMargin: 12
                y: 6
                spacing: 6

                StatusPill {
                    window: win
                    onOpen: island.openPanel()
                }
                AiRing {
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton)
                            root.run(Quickshell.env("HOME") + "/.local/bin/ai-usagebar-tui");
                        else
                            island.openAi();
                    }
                }
                RoundButton {
                    icon: "\u{f0425}"
                    iconColor: Theme.colors.red
                    onClicked: root.run("~/.config/hypr/scripts/menu.sh power")
                }
            }
        }
    }
}
