pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real cpu: 0
    property real mem: 0
    property int temp: 0
    property bool online: false
    property bool idle: true
    property bool recording: false
    property int updates: 0
    property real uptime: 0
    property string load: "0.00"
    property int brightness: 0
    property string ssid: ""
    property bool dnd: false
    property var lastCpu: null

    function pad(n) {
        return String(n).padStart(2, "0");
    }

    function refresh() {
        probe.running = true;
    }

    function uptimeText() {
        const h = Math.floor(uptime / 3600);
        const m = Math.floor(uptime / 60) % 60;
        return h + "h " + pad(m) + "m";
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: probe.running = true
    }

    Process {
        id: probe
        command: ["sh", "-c", `
            head -1 /proc/stat
            awk '/^MemTotal|^MemAvailable/ {print $2}' /proc/meminfo
            cat /sys/class/thermal/thermal_zone0/temp
            nmcli -t -f STATE g 2>/dev/null || echo unknown
            pgrep -x hypridle >/dev/null && echo 1 || echo 0
            pgrep -x wf-recorder >/dev/null && echo 1 || echo 0
            grep -o '^[0-9]*' "\${XDG_CACHE_HOME:-$HOME/.cache}/pkg-updates" 2>/dev/null | head -1 || echo 0
            cut -d' ' -f1 /proc/uptime
            cut -d' ' -f1 /proc/loadavg
            brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d %
            nmcli -t -f ACTIVE,SSID dev wifi list --rescan no 2>/dev/null | grep '^yes' | head -1 | cut -d: -f2- || true
            echo
            makoctl mode 2>/dev/null | grep -q do-not-disturb && echo 1 || echo 0
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.split("\n");
                const cpu = l[0].trim().split(/\s+/).slice(1).map(Number);
                const idleTicks = cpu[3] + cpu[4];
                const total = cpu.reduce((a, b) => a + b, 0);
                if (root.lastCpu) {
                    const dt = total - root.lastCpu.total;
                    root.cpu = dt > 0 ? 1 - (idleTicks - root.lastCpu.idle) / dt : 0;
                }
                root.lastCpu = {
                    total: total,
                    idle: idleTicks
                };
                root.mem = 1 - Number(l[2]) / Number(l[1]);
                root.temp = Math.round(Number(l[3]) / 1000);
                root.online = l[4].trim() === "connected";
                root.idle = l[5].trim() === "1";
                root.recording = l[6].trim() === "1";
                root.updates = Number(l[7]) || 0;
                root.uptime = Number(l[8]);
                root.load = l[9].trim();
                root.brightness = Number(l[10]) || 0;
                root.ssid = (l[11] ?? "").trim();
                root.dnd = (l.slice(12).find(x => x.trim() !== "") ?? "0").trim() === "1";
            }
        }
    }
}
