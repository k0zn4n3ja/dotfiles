#!/usr/bin/env bash
# Scrolling ("marquee") song title for the eww player, streamed via deflisten.
# Shows the whole title even when it's wider than the card by sliding it past a
# fixed-width window; titles that already fit are shown static (no scroll).
# JetBrainsMono is monospace so each step shifts by exactly one cell -> smooth.
export LC_ALL=C.UTF-8   # count/slice by characters, not bytes (unicode titles)

WIDTH=18        # visible characters (must stay under the .p-title fixed width in eww.scss)
SEP="     "     # gap shown between the end and the wrapped-around start
SPEED=0.30      # seconds between scroll steps

last=""
offset=0

while :; do
    status=$(playerctl status 2>/dev/null)
    if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
        echo ""
        last=""; offset=0
        sleep 1
        continue
    fi

    title=$(playerctl metadata title 2>/dev/null)
    [ -z "$title" ] && title="(unknown)"

    # restart the scroll from the beginning whenever the song changes
    if [ "$title" != "$last" ]; then
        last="$title"
        offset=0
    fi

    if [ "${#title}" -le "$WIDTH" ]; then
        echo "$title"
        sleep 0.5
        continue
    fi

    buf="${title}${SEP}"
    len=${#buf}
    double="${buf}${buf}"          # doubled so the window wraps cleanly
    echo "${double:offset:WIDTH}"
    offset=$(( (offset + 1) % len ))
    sleep "$SPEED"
done
