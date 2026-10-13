import QtQuick
import qs

Rectangle {
    id: root

    property string icon
    property color iconColor: Theme.colors.text
    property int iconSize: 14

    signal clicked(var mouse)

    implicitWidth: 30
    implicitHeight: 30
    radius: 15
    color: area.containsMouse ? Theme.colors.surface : Theme.colors.crust

    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.family: Theme.font
        font.pixelSize: root.iconSize
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => root.clicked(mouse)
    }
}
