import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs

Scope {
    id: root

    readonly property string dir: Quickshell.env("HOME") + "/Pictures/nasa"
    property var names: []
    property int offset: 0
    property int hour: Math.floor(Date.now() / 3600000)
    readonly property string current: names.length > 0 ? names[(hour + offset) % names.length] : ""

    function next() {
        offset += 1;
    }

    IpcHandler {
        target: "wallpaper"

        function next(): void {
            root.next();
        }
        function reload(): void {
            scan.running = true;
        }
    }

    Process {
        id: scan
        running: true
        command: ["sh", "-c", 'for f in "$1"/*-2560x1080.jpg; do [ -e "$f" ] && basename "$f" -2560x1080.jpg; done', "sh", root.dir]
        stdout: StdioCollector {
            onStreamFinished: root.names = text.split("\n").filter(n => n !== "")
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 3600000 - Date.now() % 3600000
        onTriggered: {
            interval = 3600000;
            root.hour = Math.floor(Date.now() / 3600000);
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property ShellScreen modelData
            property bool front: true

            function source(name) {
                if (!name)
                    return "";
                return "file://" + root.dir + "/" + name + "-" + modelData.width + "x" + modelData.height + ".jpg";
            }

            screen: modelData
            color: "black"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "qs-wallpaper"
            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            Connections {
                target: root

                function onCurrentChanged() {
                    const target = win.front ? b : a;
                    target.source = win.source(root.current);
                }
            }

            Component.onCompleted: a.source = source(root.current)

            Image {
                id: a
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(win.width, win.height)
                asynchronous: true
                cache: false
                opacity: win.front ? 1 : 0
                onStatusChanged: {
                    if (status === Image.Error && !source.toString().includes("-2560x1080"))
                        source = "file://" + root.dir + "/" + root.current + "-2560x1080.jpg";
                    if (status === Image.Ready && !win.front)
                        win.front = true;
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 1500
                    }
                }
            }

            Image {
                id: b
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(win.width, win.height)
                asynchronous: true
                cache: false
                opacity: win.front ? 0 : 1
                onStatusChanged: {
                    if (status === Image.Error && !source.toString().includes("-2560x1080"))
                        source = "file://" + root.dir + "/" + root.current + "-2560x1080.jpg";
                    if (status === Image.Ready && win.front)
                        win.front = false;
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 1500
                    }
                }
            }
        }
    }
}
