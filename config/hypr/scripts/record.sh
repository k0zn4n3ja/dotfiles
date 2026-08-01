#!/usr/bin/env bash
# Screen-record a region WITH desktop audio, toggle-style (like the screenshot key).
#   1st press: drag a region (slurp), recording starts.
#   2nd press: recording stops, file is saved to ~/Videos/Recordings and its
#              path is copied to the clipboard.
# Bound to Super+Shift+R. Uses wf-recorder + slurp + pactl (desktop-audio monitor).

OUTDIR="$HOME/Videos/Recordings"

# --- already recording? -> stop, finalize, notify ---
if pgrep -x wf-recorder >/dev/null; then
    pkill -INT -x wf-recorder                       # SIGINT makes wf-recorder flush the file cleanly
    for _ in $(seq 1 30); do
        pgrep -x wf-recorder >/dev/null || break
        sleep 0.1
    done
    last=$(ls -t "$OUTDIR"/rec-*.mp4 2>/dev/null | head -1)
    if [ -n "$last" ]; then
        printf '%s' "$last" | wl-copy
        notify-send -i media-playback-stop "Recording saved" "${last##*/}  (path copied)"
    else
        notify-send -i dialog-error "Recording stopped" "No file was written."
    fi
    exit 0
fi

# --- not recording -> pick a region and start ---
mkdir -p "$OUTDIR"

region=$(slurp) || exit 0                            # user hit Esc / cancelled selection
out="$OUTDIR/rec-$(date +%Y%m%d-%H%M%S).mp4"

# desktop audio = the ".monitor" source of the current default output sink
sink=$(pactl get-default-sink 2>/dev/null)
audio_arg="--audio"
[ -n "$sink" ] && audio_arg="--audio=${sink}.monitor"

notify-send -i media-record "Recording..." "Super+Shift+R again to stop"
exec wf-recorder -g "$region" "$audio_arg" -f "$out"
