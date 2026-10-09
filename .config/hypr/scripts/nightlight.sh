#!/bin/bash
current=$(hyprctl hyprsunset temperature 2>/dev/null)

if [[ "$current" =~ ^[0-9]+$ ]] && (( current < 6000 )); then
    hyprctl hyprsunset temperature 6000 >/dev/null
    notify-send -t 1500 "Luz noturna" "Desligada"
else
    hyprctl hyprsunset temperature 4000 >/dev/null
    notify-send -t 1500 "Luz noturna" "Ligada (4000K)"
fi
