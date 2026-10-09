#!/bin/bash
CONF="$HOME/.config/hypr/keybinds.conf"

parse() {
    grep -E '^\s*bind[lem]*\s*=' "$CONF" | while IFS= read -r line; do
        body="${line#*=}"
        IFS=',' read -r mod key action rest <<< "$body"
        mod="$(echo "$mod" | xargs | sed 's/\$mainMod/SUPER/g')"
        key="$(echo "$key" | xargs)"
        action="$(echo "$action" | xargs)"
        rest="$(echo "${rest:-}" | xargs)"
        [[ -z "$key" ]] && continue
        combo="${mod:+$mod + }$key"
        desc="$action${rest:+ $rest}"
        desc="${desc#exec }"
        desc="${desc//\~\/.config\/hypr\/scripts\//}"
        printf '%-26s  %s\n' "$combo" "$desc"
    done
}

parse | sort -u | fuzzel --dmenu --prompt "Atalhos ❯ " --width 90 --lines 20 >/dev/null
