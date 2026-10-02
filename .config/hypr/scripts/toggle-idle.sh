#!/bin/bash
if pgrep -x hypridle >/dev/null; then
    pkill -x hypridle
    notify-send -u low "󰒲  Idle desativado" "A tela não bloqueia nem suspende"
else
    setsid hypridle >/dev/null 2>&1 &
    notify-send -u low "󰒳  Idle reativado" "Bloqueio em 10min, suspensão em 30min"
fi
