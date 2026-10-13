import QtQuick
import qs

Row {
    id: root

    property bool active: false
    property real phase: 0

    spacing: 3

    Timer {
        interval: 90
        running: root.active && root.visible
        repeat: true
        onTriggered: root.phase += 0.55
    }

    Repeater {
        model: 7

        Rectangle {
            required property int index
            readonly property real wave: root.active ? (Math.sin(root.phase + index * 0.9) + 1) / 2 : 0

            anchors.verticalCenter: parent.verticalCenter
            width: 3
            height: 3 + wave * 7
            radius: 1.5
            color: root.active ? Theme.colors.text : Theme.colors.overlay
            opacity: 0.45 + wave * 0.55
        }
    }
}
