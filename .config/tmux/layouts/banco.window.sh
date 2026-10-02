# Set window root path. Default is `$session_root`.
# Must be called before `new_window`.
window_root "~/Projects/ormacarbon/backend"

# Create new window. If no argument is given, window name will be based on
# layout file name.
new_window "banco"

# Run commands.
run_cmd "psql -U ormacarbon_app -d ormacarbon"     # runs in active pane

run_cmd "admin"    # paste into active pane
#send_keys "date" 1 # paste into pane 1

# Set active pane.
select_pane 0
