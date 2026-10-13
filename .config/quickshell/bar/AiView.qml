import QtQuick
import Quickshell
import qs

Column {
    id: root

    spacing: 16

    Row {
        width: parent.width

        Text {
            width: parent.width - refresh.width
            text: "Uso de IA"
            color: Theme.colors.text
            font.family: Theme.sans
            font.pixelSize: 15
            font.weight: Font.Bold
        }

        Text {
            id: refresh
            text: AiUsage.loading ? "\u{f0450}  atualizando" : "\u{f0450}  atualizar"
            color: refreshArea.containsMouse ? Theme.colors.text : Theme.colors.overlay
            font.family: Theme.font
            font.pixelSize: 11

            MouseArea {
                id: refreshArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: AiUsage.refresh()
            }
        }
    }

    Repeater {
        model: AiUsage.ready

        Rectangle {
            id: card

            required property var modelData

            width: root.width
            height: cardBody.implicitHeight + 28
            radius: 16
            color: Theme.colors.base

            Column {
                id: cardBody
                x: 14
                y: 14
                width: parent.width - 28
                spacing: 14

                Row {
                    width: parent.width

                    Text {
                        width: parent.width - plan.width
                        text: card.modelData.display_name
                        color: Theme.colors.text
                        font.family: Theme.sans
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                    Text {
                        id: plan
                        text: card.modelData.plan ?? ""
                        color: Theme.colors.overlay
                        font.family: Theme.sans
                        font.pixelSize: 11
                    }
                }

                Repeater {
                    model: card.modelData.metrics

                    Column {
                        id: metric

                        required property var modelData
                        readonly property color tint: AiUsage.severityColor(modelData.severity)

                        width: cardBody.width
                        spacing: 6

                        Row {
                            width: parent.width

                            Text {
                                width: parent.width - value.width
                                text: metric.modelData.label
                                color: Theme.colors.subtext
                                font.family: Theme.sans
                                font.pixelSize: 12
                            }
                            Text {
                                id: value
                                text: metric.modelData.value
                                color: metric.tint
                                font.family: Theme.sans
                                font.pixelSize: 18
                                font.weight: Font.Bold
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 5
                            radius: 2.5
                            color: Theme.colors.surface

                            Rectangle {
                                width: parent.width * Math.min(1, (metric.modelData.percent ?? 0) / 100)
                                height: parent.height
                                radius: 2.5
                                color: metric.tint
                            }
                        }

                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: metric.modelData.detail ?? ""
                            color: Theme.colors.overlay
                            font.family: Theme.sans
                            font.pixelSize: 10
                        }
                    }
                }
            }
        }
    }

    Repeater {
        model: AiUsage.broken

        Row {
            required property var modelData

            width: root.width
            spacing: 8

            Text {
                text: "\u{f0026}"
                color: Theme.colors.yellow
                font.family: Theme.font
                font.pixelSize: 12
            }
            Text {
                width: parent.width - 20
                elide: Text.ElideRight
                text: parent.modelData.display_name + ": " + parent.modelData.error
                color: Theme.colors.overlay
                font.family: Theme.sans
                font.pixelSize: 11
            }
        }
    }

    Text {
        visible: AiUsage.ready.length === 0 && !AiUsage.loading
        text: "Sem dados de uso"
        color: Theme.colors.overlay
        font.family: Theme.sans
        font.pixelSize: 12
    }
}
