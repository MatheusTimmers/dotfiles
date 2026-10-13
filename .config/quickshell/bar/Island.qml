import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Widgets
import qs

Item {
    id: root

    required property var window
    property string mode: "rest"
    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
    readonly property bool playing: player?.isPlaying ?? false
    readonly property real maxWidth: window.width - 40
    readonly property real targetWidth: mode === "panel" ? Math.min(960, maxWidth) : mode === "ai" ? 460 : mode === "glance" ? 400 : rest.implicitWidth + 36
    readonly property real targetHeight: mode === "panel" ? panel.implicitHeight + 28 : mode === "ai" ? ai.implicitHeight + 36 : mode === "glance" ? glance.implicitHeight + 32 : 34

    function openPanel() {
        mode = "panel";
    }

    function openAi() {
        mode = mode === "ai" ? "rest" : "ai";
        if (mode === "ai")
            AiUsage.refresh();
    }

    width: shape.width
    height: shape.height - shape.radius

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Timer {
        id: leave
        interval: 180
        onTriggered: {
            if (root.mode === "glance")
                root.mode = "rest";
        }
    }

    HyprlandFocusGrab {
        windows: [root.window]
        active: (root.mode === "panel" || root.mode === "ai") && shape.height > 120
        onCleared: root.mode = "rest"
    }

    Rectangle {
        id: shape

        anchors.horizontalCenter: parent.horizontalCenter
        y: -radius
        width: root.targetWidth
        height: root.targetHeight + radius
        radius: root.mode === "rest" ? 17 : 26
        color: Theme.colors.crust
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: 340
                easing.type: Easing.OutQuint
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 340
                easing.type: Easing.OutQuint
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: 240
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.mode === "panel" ? Qt.ArrowCursor : Qt.PointingHandCursor
            onEntered: {
                leave.stop();
                if (root.mode === "rest")
                    root.mode = "glance";
            }
            onExited: leave.restart()
            onClicked: {
                if (root.mode === "rest" || root.mode === "glance")
                    root.mode = "panel";
            }
        }

        Item {
            id: body
            x: 0
            y: shape.radius
            width: shape.width
            height: shape.height - shape.radius

            Row {
                id: rest
                anchors.centerIn: parent
                spacing: 12
                opacity: root.mode === "rest" ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 160
                    }
                }

                ClippingRectangle {
                    visible: root.player !== null && (root.player.trackArtUrl ?? "") !== ""
                    width: 20
                    height: 20
                    radius: 5
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.colors.surface

                    Image {
                        anchors.fill: parent
                        source: root.player?.trackArtUrl ?? ""
                        sourceSize: Qt.size(40, 40)
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatTime(clock.date, "HH:mm")
                    color: Theme.colors.text
                    font.family: Theme.sans
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                Dots {
                    anchors.verticalCenter: parent.verticalCenter
                    active: root.playing
                }
            }

            Glance {
                id: glance
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 14
                width: 400 - 40
                player: root.player
                date: clock.date
                opacity: root.mode === "glance" ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }

            AiView {
                id: ai
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 16
                width: 460 - 36
                opacity: root.mode === "ai" && shape.width > width ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }

            ControlCenter {
                id: panel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 12
                width: Math.min(960, root.maxWidth) - 32
                player: root.player
                date: clock.date
                active: root.mode === "panel"
                opacity: root.mode === "panel" && shape.width > width ? 1 : 0
                visible: opacity > 0
                onDone: root.mode = "rest"

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
        }
    }
}
