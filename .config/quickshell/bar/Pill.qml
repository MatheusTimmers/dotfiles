import QtQuick
import qs

Rectangle {
    default property alias content: row.data
    property alias spacing: row.spacing

    implicitWidth: row.implicitWidth + 24
    implicitHeight: 30
    radius: height / 2
    color: Theme.colors.crust

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 12
    }
}
