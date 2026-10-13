import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs

Row {
    id: root

    required property var window

    spacing: 12
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

    Repeater {
        model: SystemTray.items.values

        Item {
            id: entry

            required property var modelData

            width: 15
            height: 15

            Image {
                anchors.fill: parent
                source: entry.modelData.icon
                sourceSize: Qt.size(36, 36)
                smooth: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    const item = entry.modelData;
                    if (mouse.button === Qt.MiddleButton) {
                        item.secondaryActivate();
                    } else if (item.hasMenu) {
                        const p = entry.mapToItem(null, 0, entry.height + 6);
                        item.display(root.window, p.x, p.y);
                    } else {
                        item.activate();
                    }
                }
            }
        }
    }
}
