#!/bin/bash
pidof hyprlock >/dev/null && exit 0
for _ in 1 2 3 4 5 6; do
    qs ipc call lock lock 2>/dev/null && exit 0
    sleep 0.5
done
exec hyprlock
