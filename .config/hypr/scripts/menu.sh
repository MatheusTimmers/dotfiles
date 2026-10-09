#!/bin/bash
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
S="$HOME/.config/hypr/scripts"

pick() {
    printf '%s\n' "$@" | fuzzel --dmenu --prompt "❯ " --lines "$#"
}

theme() {
    local flavor
    flavor=$(pick mocha macchiato frappe latte) || exit 0
    switch-flavor "$flavor" >/dev/null
}

record() {
    case $(pick "󰹑  Tela" "󰆞  Região" "󰹑  Tela com áudio" "󰆞  Região com áudio") in
        *"Tela com áudio")   "$S/screenrecord.sh" screen audio ;;
        *"Região com áudio") "$S/screenrecord.sh" region audio ;;
        *Tela)               "$S/screenrecord.sh" screen ;;
        *Região)             "$S/screenrecord.sh" region ;;
    esac
}

power() {
    case $(pick "󰌾  Bloquear" "󰤄  Suspender" "󰍃  Sair" "󰜉  Reiniciar" "󰐥  Desligar") in
        *Bloquear)  loginctl lock-session ;;
        *Suspender) systemctl suspend ;;
        *Sair)      hyprctl dispatch exit ;;
        *Reiniciar) systemctl reboot ;;
        *Desligar)  systemctl poweroff ;;
    esac
}

rec_label="󰻃  Gravar tela"
pgrep -x wf-recorder >/dev/null && rec_label="󰓛  Parar gravação"

case $(pick \
    "󰹑  Screenshot" \
    "$rec_label" \
    "󰖔  Luz noturna" \
    "󰖩  Wi-Fi" \
    "󰂯  Bluetooth" \
    "󰕾  Áudio" \
    "󰏘  Tema" \
    "󰁯  Snapshots" \
    "󰚰  Atualizar sistema" \
    "󰐥  Energia") in
    *Screenshot)         "$S/screenshot.sh" ;;
    *"Parar gravação")   "$S/screenrecord.sh" ;;
    *"Gravar tela")      record ;;
    *"Luz noturna")      "$S/nightlight.sh" ;;
    *Wi-Fi)              "$S/tui.sh" nmtui ;;
    *Bluetooth)          "$S/tui.sh" bluetui ;;
    *Áudio)              "$S/tui.sh" wiremix ;;
    *Tema)               theme ;;
    *Snapshots)          btrfs-assistant-launcher ;;
    *"Atualizar sistema") "$S/tui.sh" sh -c 'sudo dnf upgrade --refresh; flatpak update; echo; read -rp "Enter para fechar"' ;;
    *Energia)            power ;;
esac
