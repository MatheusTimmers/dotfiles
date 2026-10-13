import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Widgets
import qs

Column {
    id: root

    property var player: null
    property date date: new Date()
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property int batteryPct: Math.round((UPower.displayDevice?.percentage ?? 0) * 100)
    readonly property var locale: Qt.locale("pt_BR")

    spacing: 12

    Row {
        width: parent.width
        spacing: 12

        Text {
            id: time
            text: Qt.formatTime(root.date, "HH:mm")
            color: Theme.colors.text
            font.family: Theme.sans
            font.pixelSize: 36
            font.weight: Font.Bold
        }

        Column {
            anchors.verticalCenter: time.verticalCenter
            spacing: 0

            Text {
                text: root.locale.dayName(root.date.getDay(), Locale.LongFormat)
                color: Theme.colors.overlay
                font.family: Theme.sans
                font.pixelSize: 11
            }
            Text {
                text: root.date.getDate() + " de " + root.locale.standaloneMonthName(root.date.getMonth())
                color: Theme.colors.text
                font.family: Theme.sans
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.colors.surface
    }

    Row {
        width: parent.width
        spacing: 12

        ClippingRectangle {
            width: 38
            height: 38
            radius: 8
            color: Theme.colors.surface

            Image {
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                sourceSize: Qt.size(76, 76)
                fillMode: Image.PreserveAspectCrop
            }

            Text {
                anchors.centerIn: parent
                visible: (root.player?.trackArtUrl ?? "") === ""
                text: "\u{f075a}"
                color: Theme.colors.overlay
                font.family: Theme.font
                font.pixelSize: 16
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 38 - 12 - 40 - 12

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: root.player?.trackTitle || "Nada tocando"
                color: Theme.colors.text
                font.family: Theme.sans
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }
            Text {
                width: parent.width
                elide: Text.ElideRight
                text: root.player?.trackArtist || ""
                color: Theme.colors.overlay
                font.family: Theme.sans
                font.pixelSize: 11
            }
        }

        Dots {
            anchors.verticalCenter: parent.verticalCenter
            active: root.player?.isPlaying ?? false
        }
    }

    Row {
        spacing: 16

        Text {
            text: (UPower.onBattery ? "\u{f0079}" : "\u{f0084}") + "  " + root.batteryPct + "%"
            color: Theme.colors.subtext
            font.family: Theme.font
            font.pixelSize: 11
        }
        Text {
            text: (root.sink?.audio?.muted ? "\u{f075f}" : "\u{f057e}") + "  " + Math.round((root.sink?.audio?.volume ?? 0) * 100) + "%"
            color: Theme.colors.subtext
            font.family: Theme.font
            font.pixelSize: 11
        }
        Text {
            text: "\u{f05a9}  " + (Telemetry.ssid || (Telemetry.online ? "conectado" : "offline"))
            color: Theme.colors.subtext
            font.family: Theme.font
            font.pixelSize: 11
        }
    }
}
