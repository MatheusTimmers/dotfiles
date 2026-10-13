import QtQuick
import Quickshell
import qs

Item {
    id: root

    property real startedAt: Date.now()
    property int t: 0
    readonly property var bars: ["subtext", "yellow", "sky", "green", "mauve", "red", "blue"]

    function pad(n) {
        return String(n).padStart(2, "0");
    }

    Timer {
        interval: 1000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.t = Math.floor((Date.now() - root.startedAt) / 1000)
    }

    Column {
        anchors.fill: parent

        Row {
            width: parent.width
            height: parent.height * 0.62

            Repeater {
                model: root.bars

                Rectangle {
                    required property string modelData
                    width: root.width / root.bars.length
                    height: parent.height
                    color: Theme.colors[modelData]
                }
            }
        }

        Row {
            width: parent.width
            height: parent.height * 0.08

            Repeater {
                model: root.bars.slice().reverse()

                Rectangle {
                    required property string modelData
                    required property int index
                    width: root.width / root.bars.length
                    height: parent.height
                    color: index % 2 === 0 ? Theme.colors[modelData] : Theme.colors.crust
                }
            }
        }

        Row {
            width: parent.width
            height: parent.height * 0.3

            Repeater {
                model: [Theme.colors.mantle, Theme.colors.text, Theme.colors.surface, Theme.colors.crust, Theme.colors.base, Theme.colors.crust]

                Rectangle {
                    required property color modelData
                    width: root.width / 6
                    height: parent.height
                    color: modelData
                }
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: card.width + 96
        height: card.height + 64
        color: Theme.colors.crust
        border.color: Theme.colors.text
        border.width: 4

        Column {
            id: card
            anchors.centerIn: parent
            spacing: 10

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "PLEASE STAND BY"
                color: Theme.colors.text
                font.family: Theme.font
                font.pixelSize: 72
                font.bold: true
                font.letterSpacing: 4
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "TRANSMISSION WILL RESUME SHORTLY"
                color: Theme.colors.subtext
                font.family: Theme.font
                font.pixelSize: 20
                font.letterSpacing: 4
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: 8
                text: "MSN-01  ·  T+ " + root.pad(Math.floor(root.t / 3600)) + ":" + root.pad(Math.floor(root.t / 60) % 60) + ":" + root.pad(root.t % 60)
                color: Theme.colors.yellow
                font.family: Theme.font
                font.pixelSize: 20
                font.bold: true
                font.letterSpacing: 2
            }
        }
    }

    Canvas {
        anchors.fill: parent
        opacity: 0.12
        onPaint: {
            const ctx = getContext("2d");
            ctx.fillStyle = "black";
            for (let y = 0; y < height; y += 4)
                ctx.fillRect(0, y, width, 2);
        }
    }

    Rectangle {
        id: roll
        width: parent.width
        height: parent.height * 0.12
        gradient: Gradient {
            GradientStop {
                position: 0
                color: "transparent"
            }
            GradientStop {
                position: 0.5
                color: Qt.rgba(1, 1, 1, 0.06)
            }
            GradientStop {
                position: 1
                color: "transparent"
            }
        }

        NumberAnimation on y {
            from: -roll.height
            to: root.height
            duration: 7000
            loops: Animation.Infinite
            running: root.visible
        }
    }
}
