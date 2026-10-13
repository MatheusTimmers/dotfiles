import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import qs

Scope {
    id: root

    readonly property string shotDir: Quickshell.env("XDG_RUNTIME_DIR") + "/qs-lock"
    readonly property string name: "Matheus Susin Timmers"
    readonly property string user: Quickshell.env("USER")
    property string host: ""
    readonly property real volume: 1.0
    property string phase: "off"
    property bool capturing: false
    property var pausedPlayers: []
    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    onCurrentTextChanged: showFailure = false

    function lock() {
        if (session.locked || capturing)
            return;
        capturing = true;
        capture.command = ["sh", "-c", 'd=$1; shift; mkdir -p -m 700 "$d"; for o; do grim -t jpeg -q 85 -o "$o" "$d/$o.jpg" & done; wait', "sh", shotDir].concat(Quickshell.screens.map(s => s.name));
        capture.running = true;
        pause.running = true;
    }

    function tryUnlock() {
        if (currentText === "" || unlockInProgress)
            return;
        unlockInProgress = true;
        pam.start();
    }

    function powerOn() {
        phase = "on";
        flickerTimer.stop();
        noiseSound.running = false;
        flickerSound.running = false;
        tvOffSound.running = false;
        play(tvOnSound, "tv_on.wav");
        unlockTimer.start();
    }

    function unlock() {
        session.locked = false;
        phase = "off";
        currentText = "";
        if (pausedPlayers.length > 0) {
            resume.command = ["sh", "-c", 'for p; do playerctl -p "$p" play; done', "sh"].concat(pausedPlayers);
            resume.running = true;
            pausedPlayers = [];
        }
        cleanup.running = true;
    }

    function play(proc, file) {
        proc.command = ["pw-play", "--volume", String(volume), Quickshell.shellPath("assets/" + file)];
        proc.running = true;
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            root.lock();
        }
    }

    Process {
        running: true
        command: ["hostname", "-s"]
        stdout: StdioCollector {
            onStreamFinished: root.host = text.trim()
        }
    }

    Process {
        id: capture
        onExited: {
            root.capturing = false;
            session.locked = true;
            root.phase = "tv";
            root.play(tvOffSound, "tv_off.wav");
            flickerTimer.start();
        }
    }

    Process {
        id: pause
        command: ["sh", "-c", 'for p in $(playerctl -l 2>/dev/null); do [ "$(playerctl -p "$p" status 2>/dev/null)" = Playing ] && playerctl -p "$p" pause && echo "$p"; done']
        stdout: StdioCollector {
            onStreamFinished: root.pausedPlayers = text.split("\n").filter(p => p !== "")
        }
    }

    Process {
        id: resume
    }

    Process {
        id: cleanup
        command: ["rm", "-rf", root.shotDir]
    }

    Process {
        id: tvOffSound
    }

    Process {
        id: tvOnSound
    }

    Process {
        id: flickerSound
        onExited: {
            if (session.locked && root.phase === "flicker")
                noiseSound.running = true;
        }
    }

    Process {
        id: noiseSound
        command: ["sh", "-c", 'trap \'kill $p 2>/dev/null; exit\' TERM INT; while :; do pw-play --volume "$1" "$2" & p=$!; wait $p; done', "sh", String(root.volume), Quickshell.shellPath("assets/lights_noise.wav")]
    }

    Timer {
        id: flickerTimer
        interval: 800
        onTriggered: {
            root.phase = "flicker";
            root.play(flickerSound, "lights_flicker.wav");
        }
    }

    Timer {
        id: unlockTimer
        interval: 650
        onTriggered: root.unlock()
    }

    PamContext {
        id: pam
        configDirectory: Quickshell.shellPath("pam")
        config: "password.conf"

        onPamMessage: {
            if (responseRequired)
                respond(root.currentText);
        }

        onCompleted: result => {
            root.unlockInProgress = false;
            if (result === PamResult.Success) {
                root.powerOn();
            } else {
                root.currentText = "";
                root.showFailure = true;
            }
        }
    }

    WlSessionLock {
        id: session

        WlSessionLockSurface {
            id: surface
            color: Theme.colors.crust

            LockSurface {
                anchors.fill: parent
                context: root
                screenName: surface.screen?.name ?? ""
            }
        }
    }
}
