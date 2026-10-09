#!/bin/bash
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
exec kitty --class tui.float -e "$@"
