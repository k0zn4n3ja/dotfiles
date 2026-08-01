#!/usr/bin/env bash
# Toggle the desktop dashboard: system-monitor (top-left) + music player
# (to its right, only shown when something is playing). Bound to Super+M.

playing() {
    local s; s=$(playerctl status 2>/dev/null)
    [ "$s" = "Playing" ] || [ "$s" = "Paused" ]
}

open_all() {
    eww open desktop-stats
    if playing; then eww open music; else eww close music 2>/dev/null; fi
}

close_all() {
    eww close desktop-stats 2>/dev/null
    eww close music 2>/dev/null
}

case "$1" in
    open)  open_all ;;
    close) close_all ;;
    toggle|*)
        if eww active-windows 2>/dev/null | grep -q 'desktop-stats'; then
            close_all
        else
            open_all
        fi
        ;;
esac
