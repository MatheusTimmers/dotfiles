# Set window root path. Default is `$session_root`.
# Must be called before `new_window`.
window_root "~/Projects"

new_window "nvim"

split_h 50

run_cmd "nvim"

select_pane 0
