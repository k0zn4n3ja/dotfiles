#!/usr/bin/env bash
# Tell the running wallpaper cycler to go next/prev.
# Usage: wallpaper-ctl.sh next | prev
PIDFILE="$HOME/.cache/wallpaper-cycle.pid"
[ -r "$PIDFILE" ] || exit 0
pid="$(cat "$PIDFILE")"
case "$1" in
    next) kill -USR1 "$pid" 2>/dev/null ;;
    prev) kill -USR2 "$pid" 2>/dev/null ;;
esac
