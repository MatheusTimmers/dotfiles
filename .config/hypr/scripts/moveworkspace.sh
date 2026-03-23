#!/bin/bash
# Move janela para workspace com suporte a dual monitor independente.
# Com 1 monitor: usa workspaces 1-10 normalmente.
# Com 2 monitores: HDMI-A-1 usa 1-10, eDP-1 usa 11-20 (mapeado nas teclas 1-0).

WS=$1
MONITOR_COUNT=$(hyprctl monitors -j | jq 'length')

if [ "$MONITOR_COUNT" -gt 1 ]; then
    MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
    if [ "$MONITOR" = "eDP-1" ]; then
        WS=$((WS + 10))
    fi
fi

hyprctl dispatch movetoworkspace "$WS"
