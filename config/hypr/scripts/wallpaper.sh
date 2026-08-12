#!/usr/bin/env bash
# Animated wallpaper via mpvpaper. Pass a file to change it, else default below.
WALL="${1:-$HOME/Videos/wp_tmp/pixel_1.mp4}"
pkill mpvpaper 2>/dev/null
pkill hyprpaper 2>/dev/null
sleep 0.2
exec mpvpaper -o "no-audio loop-file=inf hwdec=vaapi panscan=1.0 --really-quiet" '*' "$WALL"
