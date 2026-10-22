#!/usr/bin/env bash
# Plaintext cpu/ram/swap/temp on the overlay layer, above fullscreen windows.
# waybar-hover.sh only starts and kills the hover bar. This process is the other one.
set -u

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/waybar/overlay.jsonc"
STYLE="${XDG_CONFIG_HOME:-$HOME/.config}/waybar/overlay.css"
LOCK="${XDG_RUNTIME_DIR:-/tmp}/waybar-overlay.lock"

exec 9>"$LOCK"
flock -n 9 || exit 0

while true; do
  waybar -c "$CONFIG" -s "$STYLE"
  sleep 2
done
