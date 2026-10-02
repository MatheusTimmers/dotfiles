# Set window root path. Default is `$session_root`.
# Must be called before `new_window`.
window_root "~/Projects/ormacarbon/frontend"

# Create new window. If no argument is given, window name will be based on
# layout file name.
new_window "front-api"

# Split window into panes.
split_v 20

# Run commands.
run_cmd "nvim ." 0     # runs in active pane
run_cmd "npm run dev" 1  # runs in pane 1

select_pane 0
