import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Widgets
import qs

Column {
    id: root

    property var player: null
    property date date: new Date()
    property bool active: false
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var locale: Qt.locale("pt_BR")
    readonly property real gap: 12
    readonly property real colA: Math.floor((width - gap * 2) * 0.34)
    readonly property real colB: Math.floor((width - gap * 2) * 0.36)
    readonly property real colC: width - gap * 2 - colA - colB

    signal done

    spacing: 14

    function run(cmd, close) {
        Quickshell.execDetached(["sh", "-c", cmd]);
        if (close)
            done();
        Telemetry.refresh();
    }

    function fmt(seconds) {
        const s = Math.max(0, Math.floor(seconds || 0));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    Timer {
        interval: 1000
        running: root.active && (root.player?.isPlaying ?? false)
        repeat: true
        triggeredOnStart: true
        onTriggered: root.player.positionChanged()
    }

    component Card: Rectangle {
        radius: 16
        color: Theme.colors.base
    }

    component IconButton: Rectangle {
        id: ib

        property string icon
        property color tint: Theme.colors.text
        signal clicked

        width: 32
        height: 32
        radius: 16
        color: ibArea.containsMouse ? Theme.colors.surface : "transparent"

        Text {
            anchors.centerIn: parent
            text: ib.icon
            color: ib.tint
            font.family: Theme.font
            font.pixelSize: 15
        }

        MouseArea {
            id: ibArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ib.clicked()
        }
    }

    component Tile: Rectangle {
        id: tile

        property string icon
        property string title
        property string subtitle
        property bool on: false
        signal clicked

        height: 54
        radius: 14
        color: tileArea.containsMouse ? Theme.colors.surface : Theme.colors.base

        Rectangle {
            id: bubble
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            height: 32
            radius: 16
            color: tile.on ? Theme.colors.blue : Theme.colors.surface

            Text {
                anchors.centerIn: parent
                text: tile.icon
                color: tile.on ? Theme.colors.crust : Theme.colors.text
                font.family: Theme.font
                font.pixelSize: 15
            }
        }

        Column {
            anchors.left: bubble.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: tile.title
                color: Theme.colors.text
                font.family: Theme.sans
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
            Text {
                width: parent.width
                elide: Text.ElideRight
                text: tile.subtitle
                color: tile.on ? Theme.colors.blue : Theme.colors.overlay
                font.family: Theme.sans
                font.pixelSize: 10
            }
        }

        MouseArea {
            id: tileArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.clicked()
        }
    }

    component Slider: Rectangle {
        id: slider

        property string icon
        property real value: 0
        signal moved(real value)

        height: 36
        radius: 18
        color: Theme.colors.base
        clip: true

        Rectangle {
            width: Math.max(parent.height, parent.width * Math.min(1, slider.value))
            height: parent.height
            radius: parent.radius
            color: Theme.colors.blue
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 13
            anchors.verticalCenter: parent.verticalCenter
            text: slider.icon
            color: Theme.colors.crust
            font.family: Theme.font
            font.pixelSize: 14
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(slider.value * 100) + "%"
            color: Theme.colors.text
            font.family: Theme.sans
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => slider.moved(Math.max(0, Math.min(1, mouse.x / width)))
            onPositionChanged: mouse => {
                if (pressed)
                    slider.moved(Math.max(0, Math.min(1, mouse.x / width)));
            }
            onWheel: wheel => slider.moved(Math.max(0, Math.min(1, slider.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
        }
    }

    component Meter: Column {
        id: meter

        property string label
        property real value: 0
        property string detail

        spacing: 6

        Row {
            width: parent.width

            Text {
                width: parent.width / 2
                text: meter.label
                color: Theme.colors.text
                font.family: Theme.sans
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
            Text {
                width: parent.width / 2
                horizontalAlignment: Text.AlignRight
                text: Math.round(meter.value * 100) + "%"
                color: Theme.colors.text
                font.family: Theme.sans
                font.pixelSize: 16
                font.weight: Font.Bold
            }
        }

        Rectangle {
            width: parent.width
            height: 4
            radius: 2
            color: Theme.colors.surface

            Rectangle {
                width: parent.width * Math.min(1, meter.value)
                height: parent.height
                radius: 2
                color: Theme.colors.blue

                Behavior on width {
                    NumberAnimation {
                        duration: 400
                    }
                }
            }
        }

        Text {
            text: meter.detail
            color: Theme.colors.overlay
            font.family: Theme.sans
            font.pixelSize: 10
        }
    }

    Item {
        id: top
        width: parent.width
        height: 32

        Row {
            spacing: 4

            IconButton {
                icon: "\u{f033e}"
                onClicked: root.run("~/.config/hypr/scripts/lock.sh", true)
            }
            IconButton {
                icon: "\u{f0904}"
                onClicked: root.run("systemctl suspend", true)
            }
            IconButton {
                icon: "\u{f0425}"
                tint: Theme.colors.red
                onClicked: root.run("~/.config/hypr/scripts/menu.sh power", true)
            }
        }

        Row {
            anchors.right: parent.right
            spacing: 4

            IconButton {
                icon: "\u{f0e51}"
                onClicked: root.run("~/.config/hypr/scripts/screenshot.sh", true)
            }
            IconButton {
                icon: "\u{f02e9}"
                onClicked: root.run("qs ipc call wallpaper next", false)
            }
            IconButton {
                icon: "\u{f0493}"
                onClicked: root.run("~/.config/hypr/scripts/menu.sh", true)
            }
        }
    }

    Row {
        id: cards
        spacing: root.gap

        Column {
            width: root.colA
            spacing: 10

            Grid {
                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                Tile {
                    width: (root.colA - 8) / 2
                    icon: Telemetry.online ? "\u{f05a9}" : "\u{f05aa}"
                    title: "Wi-Fi"
                    subtitle: Telemetry.ssid || (Telemetry.online ? "Conectado" : "Desconectado")
                    on: Telemetry.online
                    onClicked: root.run("~/.config/hypr/scripts/tui.sh nmtui", true)
                }
                Tile {
                    width: (root.colA - 8) / 2
                    icon: "\u{f00af}"
                    title: "Bluetooth"
                    subtitle: "Abrir"
                    onClicked: root.run("~/.config/hypr/scripts/tui.sh bluetui", true)
                }
                Tile {
                    width: (root.colA - 8) / 2
                    icon: Telemetry.dnd ? "\u{f009b}" : "\u{f009a}"
                    title: "Não perturbe"
                    subtitle: Telemetry.dnd ? "Ligado" : "Desligado"
                    on: Telemetry.dnd
                    onClicked: root.run("makoctl mode -t do-not-disturb >/dev/null", false)
                }
                Tile {
                    width: (root.colA - 8) / 2
                    icon: Telemetry.idle ? "\u{f04b2}" : "\u{f04b3}"
                    title: "Idle"
                    subtitle: Telemetry.idle ? "Ativo" : "Desligado"
                    on: Telemetry.idle
                    onClicked: root.run("~/.config/hypr/scripts/toggle-idle.sh", false)
                }
                Tile {
                    width: (root.colA - 8) / 2
                    icon: "\u{f0594}"
                    title: "Luz noturna"
                    subtitle: "Alternar"
                    onClicked: root.run("~/.config/hypr/scripts/nightlight.sh", false)
                }
                Tile {
                    width: (root.colA - 8) / 2
                    icon: Telemetry.recording ? "\u{f04db}" : "\u{f0ec3}"
                    title: "Gravar tela"
                    subtitle: Telemetry.recording ? "Gravando" : "Região"
                    on: Telemetry.recording
                    onClicked: root.run(Telemetry.recording ? "~/.config/hypr/scripts/screenrecord.sh" : "~/.config/hypr/scripts/screenrecord.sh region", true)
                }
            }

            Slider {
                width: root.colA
                icon: root.sink?.audio?.muted ? "\u{f075f}" : "\u{f057e}"
                value: root.sink?.audio?.volume ?? 0
                onMoved: v => {
                    if (root.sink?.audio)
                        root.sink.audio.volume = v;
                }
            }

            Slider {
                width: root.colA
                icon: "\u{f00df}"
                value: Telemetry.brightness / 100
                onMoved: v => root.run("brightnessctl -q set " + Math.max(1, Math.round(v * 100)) + "%", false)
            }
        }

        Column {
            width: root.colB
            spacing: 10

            Card {
                width: root.colB
                height: 150

                ClippingRectangle {
                    id: art
                    x: 14
                    y: 14
                    width: 56
                    height: 56
                    radius: 10
                    color: Theme.colors.surface

                    Image {
                        anchors.fill: parent
                        source: root.player?.trackArtUrl ?? ""
                        sourceSize: Qt.size(112, 112)
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Column {
                    anchors.left: art.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: art.verticalCenter

                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: root.player?.trackTitle || "Nada tocando"
                        color: Theme.colors.text
                        font.family: Theme.sans
                        font.pixelSize: 14
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

                Rectangle {
                    id: track
                    x: 14
                    y: 84
                    width: parent.width - 28
                    height: 4
                    radius: 2
                    color: Theme.colors.surface

                    Rectangle {
                        width: parent.width * ((root.player?.length ?? 0) > 0 ? Math.min(1, root.player.position / root.player.length) : 0)
                        height: parent.height
                        radius: 2
                        color: Theme.colors.blue
                    }
                }

                Text {
                    anchors.left: track.left
                    anchors.top: track.bottom
                    anchors.topMargin: 10
                    text: root.fmt(root.player?.position)
                    color: Theme.colors.overlay
                    font.family: Theme.font
                    font.pixelSize: 10
                }

                Text {
                    anchors.right: track.right
                    anchors.top: track.bottom
                    anchors.topMargin: 10
                    text: root.fmt(root.player?.length)
                    color: Theme.colors.overlay
                    font.family: Theme.font
                    font.pixelSize: 10
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: track.bottom
                    anchors.topMargin: 6
                    spacing: 14

                    IconButton {
                        icon: "\u{f04ae}"
                        onClicked: root.player?.previous()
                    }
                    IconButton {
                        icon: root.player?.isPlaying ? "\u{f03e4}" : "\u{f040a}"
                        onClicked: root.player?.togglePlaying()
                    }
                    IconButton {
                        icon: "\u{f04ad}"
                        onClicked: root.player?.next()
                    }
                }
            }

            Card {
                width: root.colB
                height: 120

                Row {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 16

                    Meter {
                        width: (parent.width - 16) / 2
                        label: "Processador"
                        value: Telemetry.cpu
                        detail: "load " + Telemetry.load + "  ·  " + Telemetry.temp + "°C"
                    }
                    Meter {
                        width: (parent.width - 16) / 2
                        label: "Memória"
                        value: Telemetry.mem
                        detail: "uptime " + Telemetry.uptimeText()
                    }
                }
            }
        }

        Card {
            id: calendar
            width: root.colC
            height: 280

            readonly property int year: root.date.getFullYear()
            readonly property int month: root.date.getMonth()
            readonly property int offset: new Date(year, month, 1).getDay()
            readonly property int days: new Date(year, month + 1, 0).getDate()

            Text {
                id: monthTitle
                x: 16
                y: 14
                text: root.locale.standaloneMonthName(calendar.month) + "  " + calendar.year
                color: Theme.colors.text
                font.family: Theme.sans
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Grid {
                id: grid
                anchors.top: monthTitle.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 7
                columnSpacing: 2
                rowSpacing: 4
                readonly property real cell: Math.floor((calendar.width - 32 - 12) / 7)

                Repeater {
                    model: ["D", "S", "T", "Q", "Q", "S", "S"]

                    Text {
                        required property string modelData
                        width: grid.cell
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: Theme.colors.overlay
                        font.family: Theme.sans
                        font.pixelSize: 10
                    }
                }

                Repeater {
                    model: calendar.offset + calendar.days

                    Item {
                        required property int index
                        readonly property int day: index - calendar.offset + 1
                        readonly property bool today: day === root.date.getDate()

                        width: grid.cell
                        height: 28

                        Rectangle {
                            anchors.centerIn: parent
                            width: 26
                            height: 26
                            radius: 13
                            visible: parent.today
                            color: Theme.colors.blue
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: parent.day > 0
                            text: parent.day
                            color: parent.today ? Theme.colors.crust : Theme.colors.text
                            font.family: Theme.sans
                            font.pixelSize: 12
                            font.weight: parent.today ? Font.Bold : Font.Normal
                        }
                    }
                }
            }
        }
    }
}
