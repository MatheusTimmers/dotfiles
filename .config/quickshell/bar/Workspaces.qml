import QtQuick
import Quickshell.Hyprland
import qs

Pill {
    id: root

    readonly property var existing: Hyprland.workspaces.values.filter(w => w.id > 0)
    readonly property int focusedId: Hyprland.focusedWorkspace?.id ?? 1
    readonly property var ids: [...new Set([1, 2, 3, 4, 5, ...existing.map(w => w.id), focusedId])].sort((a, b) => a - b)

    spacing: 6

    Repeater {
        model: root.ids

        Rectangle {
            required property int modelData
            readonly property int wsId: modelData
            readonly property bool active: wsId === root.focusedId
            readonly property bool used: root.existing.some(w => w.id === wsId)

            anchors.verticalCenter: parent.verticalCenter
            width: active ? 22 : 7
            height: 7
            radius: 3.5
            color: active ? Theme.colors.blue : (used ? Theme.colors.subtext : Theme.colors.surface)

            Behavior on width {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 160
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + parent.wsId)
            }
        }
    }

    MouseArea {
        parent: root
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => Hyprland.dispatch("workspace " + (wheel.angleDelta.y > 0 ? "e-1" : "e+1"))
    }
}
