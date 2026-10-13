import QtQuick
import qs

Column {
    id: root

    property string value
    readonly property var bars: {
        const out = [];
        for (const ch of value) {
            const code = ch.charCodeAt(0);
            for (let i = 0; i < 7; i++)
                out.push((code >> i) & 1 ? 5 : 2);
        }
        return out;
    }

    spacing: 6

    Row {
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            model: root.bars

            Rectangle {
                required property int index
                required property int modelData
                width: modelData
                height: 90
                color: index % 2 === 0 ? Theme.colors.subtext : "transparent"
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.value.toUpperCase()
        color: Theme.colors.subtext
        font.family: Theme.font
        font.pixelSize: 16
        font.letterSpacing: 6
    }
}
