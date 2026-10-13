import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs

Scope {
    id: root

    property bool active: false
    property int scene: 0
    property real startedAt: 0
    readonly property var scenes: [orbit, standBy]

    onActiveChanged: {
        if (active) {
            startedAt = Date.now();
            scene = 1 - scene;
        }
    }

    Component {
        id: orbit

        Orbit {
            startedAt: root.startedAt
        }
    }

    Component {
        id: standBy

        StandBy {
            startedAt: root.startedAt
        }
    }

    IpcHandler {
        target: "screensaver"

        function on(): void {
            root.active = true;
        }
        function off(): void {
            root.active = false;
        }
    }

    Variants {
        model: root.active ? Quickshell.screens : []

        PanelWindow {
            required property ShellScreen modelData

            screen: modelData
            color: Theme.colors.crust
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qs-screensaver"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            Loader {
                anchors.fill: parent
                sourceComponent: root.scenes[root.scene]
            }

            MouseArea {
                property point origin: Qt.point(-1, -1)

                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.AllButtons
                onPressed: root.active = false
                onWheel: root.active = false
                onPositionChanged: mouse => {
                    if (origin.x < 0)
                        origin = Qt.point(mouse.x, mouse.y);
                    else if (Math.abs(mouse.x - origin.x) + Math.abs(mouse.y - origin.y) > 10)
                        root.active = false;
                }
            }

            Item {
                anchors.fill: parent
                focus: true
                Keys.onPressed: root.active = false
            }
        }
    }
}
