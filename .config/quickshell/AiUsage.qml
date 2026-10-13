pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var entries: []
    readonly property var ready: entries.filter(e => e.status === "ready" && e.metrics.length > 0)
    readonly property var broken: entries.filter(e => e.status === "error" && !String(e.error).includes("no API key"))
    readonly property var primary: ready.length > 0 ? ready[0].metrics[0] : null
    property bool loading: false

    function refresh() {
        if (!probe.running) {
            loading = true;
            probe.running = true;
        }
    }

    function severityColor(severity) {
        return {
            low: Theme.colors.green,
            medium: Theme.colors.yellow,
            high: Theme.colors.peach,
            critical: Theme.colors.red
        }[severity] ?? Theme.colors.blue;
    }

    Timer {
        interval: 300000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: probe
        command: [Quickshell.env("HOME") + "/.local/bin/ai-usagebar", "usage", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.entries = JSON.parse(text).entries ?? [];
                } catch (e) {
                    root.entries = [];
                }
                root.loading = false;
            }
        }
    }
}
