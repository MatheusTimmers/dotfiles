#!/bin/bash
dir="$HOME/Videos/Screencasts"

if pgrep -x wf-recorder >/dev/null; then
    pkill -INT -x wf-recorder
    notify-send -t 2500 "Gravação encerrada" "Salva em $dir"
    exit 0
fi

mkdir -p "$dir"
file="$dir/$(date +%Y%m%d_%H%M%S).mp4"
args=(-f "$file")
[[ "$2" == "audio" ]] && args+=(--audio)

if [[ "$1" == "region" ]]; then
    region=$(slurp) || exit 0
    args+=(-g "$region")
else
    args+=(-o "$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')")
fi

setsid wf-recorder "${args[@]}" >/dev/null 2>&1 &
notify-send -t 2500 "Gravando" "Rode de novo (SUPER+ALT+Print) para parar"
