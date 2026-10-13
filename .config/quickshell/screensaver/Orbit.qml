import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.lock

Item {
    id: root

    property real startedAt: Date.now()
    property real t: 0
    property real elapsed: 0
    property var trail: []
    property string battery: "--"
    property string temp: "--"
    property string uptime: "--"
    property string load: "--"
    property string host: ""
    readonly property string user: Quickshell.env("USER")
    readonly property int orbitNumber: Math.floor(t / 10.47) + 1

    function pad(n) {
        return String(n).padStart(2, "0");
    }

    function met(seconds) {
        const s = Math.floor(seconds);
        return "T+ " + pad(Math.floor(s / 3600)) + ":" + pad(Math.floor(s / 60) % 60) + ":" + pad(s % 60);
    }

    Timer {
        interval: 50
        running: root.visible
        repeat: true
        onTriggered: {
            root.t += interval / 1000;
            root.elapsed = (Date.now() - root.startedAt) / 1000;
            const trail = root.trail;
            trail.push(root.theta);
            while (trail.length > 30)
                trail.shift();
            back.requestPaint();
            front.requestPaint();
        }
    }

    Timer {
        interval: 5000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: telemetry.running = true
    }

    Process {
        id: telemetry
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1; cat /sys/class/thermal/thermal_zone0/temp; cut -d' ' -f1 /proc/uptime; cut -d' ' -f1 /proc/loadavg; hostname -s"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [bat, temp, up, load, host] = text.trim().split("\n");
                const h = Math.floor(Number(up) / 3600);
                const m = Math.floor(Number(up) / 60) % 60;
                root.battery = bat ? bat + "%" : "AC";
                root.temp = Math.round(Number(temp) / 1000) + "°C";
                root.uptime = h + "h " + root.pad(m) + "m";
                root.load = load;
                root.host = host;
            }
        }
    }

    readonly property real cx: width / 2
    readonly property real cy: height / 2
    readonly property real planetR: Math.min(width, height) * 0.2
    readonly property real orbitR: planetR * 2.1
    readonly property real tilt: -0.32
    readonly property real flat: 0.3
    readonly property real theta: t * 0.6

    function orbitPoint(a) {
        const x = orbitR * Math.cos(a);
        const y = orbitR * flat * Math.sin(a);
        return [cx + x * Math.cos(tilt) - y * Math.sin(tilt), cy + x * Math.sin(tilt) + y * Math.cos(tilt)];
    }

    function drawOrbit(ctx, front) {
        ctx.strokeStyle = front ? Theme.colors.subtext : Theme.colors.overlay;
        ctx.globalAlpha = front ? 0.9 : 0.5;
        ctx.lineWidth = front ? 1.5 : 1;
        ctx.beginPath();
        let open = false;
        for (let i = 0; i <= 360; i++) {
            const a = i * Math.PI / 180;
            if ((Math.sin(a) >= 0) !== front) {
                open = false;
                continue;
            }
            const [x, y] = orbitPoint(a);
            if (open)
                ctx.lineTo(x, y);
            else
                ctx.moveTo(x, y);
            open = true;
        }
        ctx.stroke();
        ctx.globalAlpha = 1;
    }

    function drawSatellite(ctx, front) {
        const trail = root.trail;
        for (let i = 0; i < trail.length; i++) {
            const a = trail[i];
            if ((Math.sin(a) >= 0) !== front)
                continue;
            const [x, y] = orbitPoint(a);
            ctx.globalAlpha = i / trail.length * 0.6;
            ctx.fillStyle = Theme.colors.yellow;
            ctx.fillRect(x - 2, y - 2, 4, 4);
        }
        ctx.globalAlpha = 1;

        if ((Math.sin(theta) >= 0) !== front)
            return;
        const [sx, sy] = orbitPoint(theta);
        ctx.fillStyle = Theme.colors.sapphire;
        ctx.fillRect(sx - 16, sy - 3, 9, 6);
        ctx.fillRect(sx + 7, sy - 3, 9, 6);
        ctx.fillStyle = Theme.colors.yellow;
        ctx.fillRect(sx - 5, sy - 5, 10, 10);

        const hidden = !front && Math.hypot(sx - cx, sy - cy) < planetR;
        if (hidden)
            return;
        ctx.strokeStyle = Theme.colors.yellow;
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(sx + 8, sy - 8);
        ctx.lineTo(sx + 28, sy - 28);
        ctx.lineTo(sx + 90, sy - 28);
        ctx.stroke();
        ctx.font = "bold 14px '" + Theme.font + "'";
        ctx.fillText("SAT-01", sx + 32, sy - 34);
    }

    Canvas {
        id: back
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.globalAlpha = 0.35;
            ctx.strokeStyle = Theme.colors.surface;
            ctx.lineWidth = 1;
            for (const k of [1.35, 2.6]) {
                ctx.beginPath();
                ctx.arc(root.cx, root.cy, root.planetR * k, 0, Math.PI * 2);
                ctx.stroke();
            }
            ctx.beginPath();
            ctx.moveTo(root.cx - root.orbitR * 1.25, root.cy);
            ctx.lineTo(root.cx + root.orbitR * 1.25, root.cy);
            ctx.moveTo(root.cx, root.cy - root.orbitR * 0.75);
            ctx.lineTo(root.cx, root.cy + root.orbitR * 0.75);
            ctx.stroke();
            ctx.globalAlpha = 1;
            root.drawOrbit(ctx, false);
            root.drawSatellite(ctx, false);
        }
    }

    Image {
        id: earthMask
        source: "file://" + Quickshell.shellPath("assets/earth-mask.png")
        visible: false
    }

    ShaderEffect {
        x: root.cx - root.planetR
        y: root.cy - root.planetR
        width: root.planetR * 2
        height: root.planetR * 2

        property real spin: -0.9 + root.t * 0.08
        property real tilt: 0.35
        property color ocean: Qt.tint(Theme.colors.base, Qt.alpha(Theme.colors.blue, 0.6))
        property color land: Qt.tint(Theme.colors.base, Qt.alpha(Theme.colors.green, 0.9))
        property color grid: Theme.colors.text
        property color shade: Theme.colors.crust
        property color rim: Qt.tint(Theme.colors.base, Qt.alpha(Theme.colors.sapphire, 0.8))
        property var mask: earthMask

        fragmentShader: "file://" + Quickshell.shellPath("screensaver/shaders/earth.frag.qsb")
    }

    Canvas {
        id: front
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            root.drawOrbit(ctx, true);
            root.drawSatellite(ctx, true);
        }
    }

    Column {
        anchors {
            left: parent.left
            top: parent.top
            margins: 40
        }
        spacing: 6

        Text {
            text: "MISSION CONTROL  ·  STANDBY"
            color: Theme.colors.yellow
            font.family: Theme.font
            font.pixelSize: 28
            font.bold: true
            font.letterSpacing: 3
        }

        Text {
            text: "TRACKING SAT-01  ·  ORBIT " + String(root.orbitNumber).padStart(3, "0")
            color: Theme.colors.subtext
            font.family: Theme.font
            font.pixelSize: 16
            font.letterSpacing: 2
        }
    }

    Column {
        anchors {
            right: parent.right
            top: parent.top
            margins: 40
        }
        spacing: 2

        Text {
            anchors.right: parent.right
            text: "MISSION ELAPSED TIME"
            color: Theme.colors.subtext
            font.family: Theme.font
            font.pixelSize: 14
            font.letterSpacing: 3
        }

        Text {
            anchors.right: parent.right
            text: root.met(root.elapsed)
            color: Theme.colors.text
            font.family: Theme.font
            font.pixelSize: 48
            font.bold: true
        }
    }

    Column {
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 40
        }
        spacing: 4

        Repeater {
            model: [["FUEL", root.battery], ["HULL TEMP", root.temp], ["UPTIME", root.uptime], ["LOAD", root.load]]

            Text {
                required property var modelData
                text: modelData[0].padEnd(11, " ") + modelData[1]
                color: Theme.colors.subtext
                font.family: Theme.font
                font.pixelSize: 18
            }
        }
    }

    Barcode {
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 40
        }
        value: root.user + "@" + root.host
    }
}
