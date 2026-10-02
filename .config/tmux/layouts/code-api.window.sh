# Set window root path. Default is `$session_root`.
# Must be called before `new_window`.
window_root "~/Projects/ormacarbon/backend"

# Create new window. If no argument is given, window name will be based on
# layout file name.
new_window "code-api"

split_v 20

run_cmd "nvim ." 0   # runs in active pane
run_cmd "source ./env.env" 1  # runs in pane 1
run_cmd "go run cmd/api/main.go" 1  # runs in pane 1

select_pane 0
