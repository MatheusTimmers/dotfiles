import QtQuick
import qs

Rectangle {
    id: root

    property string name

    implicitWidth: 440
    implicitHeight: content.y + content.height + 16
    color: "transparent"
    border.color: Theme.colors.yellow
    border.width: 3

    Item {
        id: stripes
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 3
        }
        height: 22
        clip: true

        Row {
            x: -24
            spacing: 16

            Repeater {
                model: Math.ceil(stripes.width / 32) + 2

                Rectangle {
                    y: -20
                    width: 16
                    height: 64
                    rotation: 35
                    color: Theme.colors.yellow
                }
            }
        }
    }

    Column {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: stripes.bottom
            leftMargin: 18
            rightMargin: 18
            topMargin: 12
        }
        spacing: 2

        Text {
            text: "  SESSION LOCKED"
            color: Theme.colors.yellow
            font.family: Theme.font
            font.pixelSize: 32
            font.bold: true
        }

        Text {
            text: "AUTHORIZED PERSONNEL:"
            color: Theme.colors.text
            font.family: Theme.font
            font.pixelSize: 16
            font.letterSpacing: 2
        }

        Text {
            text: root.name
            color: Theme.colors.yellow
            font.family: Theme.font
            font.pixelSize: 18
            font.bold: true
        }
    }
}
