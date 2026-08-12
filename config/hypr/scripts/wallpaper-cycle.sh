#!/usr/bin/env bash
# Animated wallpaper cycler.
#   - auto-advances every INTERVAL seconds
#   - responds to signals for manual control:
#       SIGUSR1 -> next wallpaper
#       SIGUSR2 -> previous wallpaper
# The PID is written to PIDFILE so keybind scripts can signal it.

WPDIR="$HOME/Videos/wp_tmp"
INTERVAL=300                 # auto-switch every 5 min
PIDFILE="$HOME/.cache/wallpaper-cycle.pid"

mkdir -p "$(dirname "$PIDFILE")"
echo $$ > "$PIDFILE"
shopt -s nullglob

idx=0

set_wall() {
    # Re-read the folder each time so newly added files are picked up.
    local vids=()
    for f in "$WPDIR"/*; do [ -f "$f" ] && vids+=("$f"); done
    local n=${#vids[@]}
    (( n == 0 )) && return
    (( idx = (idx % n + n) % n ))          # wrap around, handle negatives
    local file="${vids[$idx]}"

    # Choose mpv flags by file type so stills don't loop-thrash.
    local common="no-audio panscan=1.0 --really-quiet"
    local opts
    case "${file,,}" in
        *.jpg|*.jpeg|*.png|*.webp|*.bmp|*.tif|*.tiff|*.avif)
            opts="$common image-display-duration=inf" ;;   # still image: hold forever
        *.gif)
            opts="$common loop-file=inf" ;;                # animated gif: loop
        *)
            opts="$common loop-file=inf hwdec=vaapi" ;;    # video: loop + GPU (VA-API) decode
    esac

    pkill mpvpaper 2>/dev/null
    pkill hyprpaper 2>/dev/null
    sleep 0.2
    mpvpaper -o "$opts" '*' "$file" &
}

next() { (( idx++ )); set_wall; }
prev() { (( idx-- )); set_wall; }

trap 'next' USR1
trap 'prev' USR2

set_wall                       # show the first one immediately

while true; do
    sleep "$INTERVAL" & sleep_pid=$!
    if wait "$sleep_pid"; then
        next                   # timer elapsed -> auto advance
    else
        kill "$sleep_pid" 2>/dev/null   # a signal interrupted us; trap already switched
    fi
done
