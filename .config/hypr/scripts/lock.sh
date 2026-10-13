#!/bin/bash
pidof hyprlock >/dev/null && exit 0
qs ipc call lock lock 2>/dev/null || exec hyprlock
