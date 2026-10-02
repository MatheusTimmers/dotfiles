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
        printf '%-28s  %s\n' "$combo" "$action${rest:+ $rest}"
    done
}

parse | sort -u | wofi --dmenu --prompt "Atalhos" --width 700 --height 600 >/dev/null
