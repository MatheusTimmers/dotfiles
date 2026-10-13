import QtQuick
import QtQuick.Effects
import Quickshell
import qs

Rectangle {
    id: root

    required property var context
    required property string screenName

    color: Theme.colors.crust

    property bool started: false

    function start() {
        if (started || width <= 0 || height <= 0)
            return;
        if (context.phase === "tv") {
            started = true;
            crt.width = width;
            crt.height = height;
            tvOffAnim.start();
        } else if (context.phase === "flicker") {
            started = true;
            crt.visible = false;
            container.visible = true;
        }
    }

    function powerOn() {
        tvOffAnim.stop();
        flickerAnim.stop();
        container.visible = false;
        crt.width = 0;
        crt.height = 6;
        crt.brightness = 1;
        crt.visible = true;
        tvOnAnim.start();
    }

    onWidthChanged: start()
    onHeightChanged: start()
    Component.onCompleted: {
        start();
        input.forceActiveFocus();
    }

    Connections {
        target: root.context

        function onPhaseChanged() {
            if (root.context.phase === "on")
                root.powerOn();
            else if (root.context.phase === "flicker" && root.started)
                flickerAnim.start();
            else
                root.start();
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    FontMetrics {
        id: metrics
        font: input.font
    }

    Item {
        id: container
        anchors.fill: parent
        visible: false

        Text {
            anchors {
                left: parent.left
                top: parent.top
                margins: 40
            }
            text: Qt.formatDateTime(clock.date, "yyyy-MM-dd  ·  HH:mm")
            color: Theme.colors.subtext
            font.family: Theme.font
            font.pixelSize: 22
            font.letterSpacing: 2
        }

        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.verticalCenter
            }
            spacing: metrics.averageCharacterWidth

            Text {
                text: "password:"
                color: root.context.showFailure ? Theme.colors.red : Theme.colors.text
                font: input.font
            }

            TextInput {
                id: input
                width: metrics.averageCharacterWidth * 16
                focus: true
                readOnly: root.context.unlockInProgress || root.context.phase === "on"
                echoMode: TextInput.Password
                passwordCharacter: "*"
                inputMethodHints: Qt.ImhSensitiveData
                color: Theme.colors.text
                selectionColor: Theme.colors.mauve
                font.family: Theme.font
                font.pointSize: 32
                font.bold: true
                clip: true

                onTextChanged: root.context.currentText = text
                onAccepted: root.context.tryUnlock()
                Keys.onEscapePressed: root.context.currentText = ""

                Connections {
                    target: root.context

                    function onCurrentTextChanged() {
                        if (input.text !== root.context.currentText)
                            input.text = root.context.currentText;
                    }
                }

                cursorDelegate: Rectangle {
                    id: cursor
                    width: metrics.averageCharacterWidth
                    color: root.context.showFailure ? Theme.colors.red : Theme.colors.mauve

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        PropertyAction {
                            value: 1
                        }
                        PauseAnimation {
                            duration: 500
                        }
                        PropertyAction {
                            value: 0
                        }
                        PauseAnimation {
                            duration: 500
                        }
                    }
                }
            }
        }

        Text {
            id: logo
            anchors {
                left: parent.left
                verticalCenter: label.verticalCenter
                leftMargin: 40
            }
            text: ""
            color: Theme.colors.blue
            font.family: Theme.font
            font.pixelSize: 150
        }

        WarningLabel {
            id: label
            anchors {
                left: logo.right
                bottom: parent.bottom
                leftMargin: 40
                bottomMargin: 40
            }
            name: root.context.name
        }

        Barcode {
            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: 40
            }
            value: root.context.user + "@" + root.context.host
        }
    }

    Image {
        id: shot
        anchors.fill: parent
        source: root.screenName ? "file://" + root.context.shotDir + "/" + root.screenName + ".jpg" : ""
        cache: false
        visible: false
    }

    MultiEffect {
        id: crt
        anchors.centerIn: parent
        width: root.width
        height: root.height
        source: shot
        brightness: 0
    }

    ParallelAnimation {
        id: tvOffAnim

        NumberAnimation {
            target: crt
            property: "brightness"
            to: 1
            duration: 1000
            easing.type: Easing.OutExpo
        }
        NumberAnimation {
            target: crt
            property: "height"
            to: 6
            duration: 500
            easing.type: Easing.OutExpo
        }
        SequentialAnimation {
            PauseAnimation {
                duration: 300
            }
            NumberAnimation {
                target: crt
                property: "width"
                to: 0
                duration: 300
                easing.type: Easing.OutExpo
            }
            PropertyAction {
                target: crt
                property: "visible"
                value: false
            }
        }
    }

    SequentialAnimation {
        id: tvOnAnim

        NumberAnimation {
            target: crt
            property: "width"
            to: root.width
            duration: 200
            easing.type: Easing.OutExpo
        }
        ParallelAnimation {
            NumberAnimation {
                target: crt
                property: "height"
                to: root.height
                duration: 300
                easing.type: Easing.OutExpo
            }
            NumberAnimation {
                target: crt
                property: "brightness"
                to: 0
                duration: 450
                easing.type: Easing.InQuad
            }
        }
    }

    SequentialAnimation {
        id: flickerAnim

        PauseAnimation {
            duration: 200
        }
        PropertyAction {
            target: container
            property: "visible"
            value: true
        }
        PauseAnimation {
            duration: 100
        }
        PropertyAction {
            target: container
            property: "visible"
            value: false
        }
        PauseAnimation {
            duration: 200
        }
        PropertyAction {
            target: container
            property: "visible"
            value: true
        }
    }
}
