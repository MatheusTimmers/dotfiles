import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import qs

Pill {
    id: root

    required property var window
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var battery: UPower.displayDevice
    readonly property int batteryPct: Math.round((battery?.percentage ?? 0) * 100)
    readonly property bool charging: !UPower.onBattery
    readonly property int volume: Math.round((sink?.audio?.volume ?? 0) * 100)
    readonly property bool muted: sink?.audio?.muted ?? false

    signal open

    spacing: 14

    PwObjectTracker {
        objects: [root.sink]
    }

    component Glyph: Text {
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.colors.text
        font.family: Theme.font
        font.pixelSize: 13
    }

    Tray {
        window: root.window
    }

    Glyph {
        text: Telemetry.dnd ? "\u{f009b}" : "\u{f009a}"
        color: Telemetry.dnd ? Theme.colors.overlay : Theme.colors.text
    }

    Item {
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: volRow.implicitWidth
        implicitHeight: volRow.implicitHeight

        Row {
            id: volRow
            spacing: 5

            Glyph {
                text: root.muted ? "\u{f075f}" : (root.volume > 60 ? "\u{f057e}" : (root.volume > 25 ? "\u{f0580}" : "\u{f057f}"))
                color: root.muted ? Theme.colors.overlay : Theme.colors.text
            }
            Glyph {
                visible: !root.muted
                text: root.volume + "%"
                font.pixelSize: 12
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                if (mouse.button === Qt.MiddleButton)
                    root.sink.audio.muted = !root.sink.audio.muted;
                else
                    root.open();
            }
            onWheel: wheel => {
                if (root.sink?.audio)
                    root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + (wheel.angleDelta.y > 0 ? 0.02 : -0.02)));
            }
        }
    }

    Row {
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter

        Glyph {
            text: root.charging ? "\u{f0084}" : ["\u{f007a}", "\u{f007b}", "\u{f007c}", "\u{f007d}", "\u{f007e}", "\u{f007f}", "\u{f0080}", "\u{f0081}", "\u{f0082}", "\u{f0079}"][Math.min(9, Math.floor(root.batteryPct / 10))]
            color: root.batteryPct <= 15 && !root.charging ? Theme.colors.red : Theme.colors.text
        }
        Glyph {
            text: root.batteryPct + "%"
            font.pixelSize: 12
            color: root.batteryPct <= 15 && !root.charging ? Theme.colors.red : Theme.colors.text
        }
    }

    MouseArea {
        parent: root
        anchors.fill: parent
        z: -1
        cursorShape: Qt.PointingHandCursor
        onClicked: root.open()
    }
}
