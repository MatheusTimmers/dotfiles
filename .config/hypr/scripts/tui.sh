#!/bin/bash
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
if [ "$1" = nmtui ]; then
    export NEWT_COLORS='root=white,default;roottext=gray,default;border=blue,default;window=white,default;shadow=default,default;title=brightblue,default;button=black,blue;actbutton=black,yellow;compactbutton=white,default;checkbox=white,default;actcheckbox=black,blue;entry=white,black;disentry=gray,default;label=white,default;listbox=white,default;actlistbox=black,blue;sellistbox=blue,default;actsellistbox=black,blue;textbox=white,default;acttextbox=black,blue;helpline=gray,default;emptyscale=,black;fullscale=,blue'
fi
exec kitty --class tui.float -e "$@"
