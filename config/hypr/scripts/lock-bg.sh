#!/usr/bin/env bash
# Grab a still frame of whatever wallpaper is currently playing and stash it
# blurred-later as the hyprlock background, so the lock screen always matches
# the live desktop wallpaper.
#
# We read the current file straight off the running mpvpaper command line
# (wallpaper-cycle.sh launches: mpvpaper -o <opts> '*' <file>), then pull one
# frame with ffmpeg. Stills are copied as-is. Any failure leaves the previous
# cached frame (or the fallback image) in place, so lock never breaks.

OUT="$HOME/.cache/hyprlock-bg.jpg"
FALLBACK="$HOME/Pictures/gatsu.jpeg"

mkdir -p "$(dirname "$OUT")"

# last arg of the mpvpaper process = the wallpaper file
file=$(pgrep -af '[m]pvpaper' | head -1 | awk '{print $NF}')

# nothing playing? fall back to a fixed image, keep whatever we had otherwise
if [ -z "$file" ] || [ ! -f "$file" ]; then
    [ -f "$OUT" ] || cp "$FALLBACK" "$OUT" 2>/dev/null
    exit 0
fi

case "${file,,}" in
    *.jpg|*.jpeg|*.png|*.webp|*.bmp|*.tif|*.tiff|*.avif|*.gif)
        cp "$file" "$OUT" ;;
    *)
        # video: grab a frame a few seconds in (skips black intro frames).
        # -ss before -i = fast seek; if the clip is shorter, retry from 0.
        if ! ffmpeg -y -nostdin -loglevel error -ss 3 -i "$file" \
                    -frames:v 1 -q:v 3 "$OUT" 2>/dev/null; then
            ffmpeg -y -nostdin -loglevel error -i "$file" \
                   -frames:v 1 -q:v 3 "$OUT" 2>/dev/null
        fi ;;
esac

# guarantee something usable exists
[ -s "$OUT" ] || cp "$FALLBACK" "$OUT" 2>/dev/null
exit 0
