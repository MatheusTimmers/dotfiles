import QtQuick
import qs

Rectangle {
    id: root

    readonly property real value: (AiUsage.primary?.percent ?? 0) / 100
    readonly property color ringColor: AiUsage.severityColor(AiUsage.primary?.severity)

    signal clicked(var mouse)

    implicitWidth: 30
    implicitHeight: 30
    radius: 15
    color: area.containsMouse ? Theme.colors.surface : Theme.colors.crust

    onValueChanged: ring.requestPaint()
    onRingColorChanged: ring.requestPaint()

    Canvas {
        id: ring
        anchors.fill: parent
        anchors.margins: 4

        onPaint: {
            const ctx = getContext("2d");
            const r = width / 2 - 1.5;
            ctx.reset();
            ctx.lineWidth = 2.5;
            ctx.strokeStyle = Theme.colors.surface;
            ctx.beginPath();
            ctx.arc(width / 2, height / 2, r, 0, Math.PI * 2);
            ctx.stroke();
            ctx.strokeStyle = root.ringColor;
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.arc(width / 2, height / 2, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * Math.min(1, root.value));
            ctx.stroke();
        }
    }

    Text {
        anchors.centerIn: parent
        text: "\u{f09d1}"
        color: Theme.colors.text
        font.family: Theme.font
        font.pixelSize: 10
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => root.clicked(mouse)
    }
}
