#!/usr/bin/env bash
# Toggle the desktop dashboard (one eww window: music player on top, which
# collapses when nothing is playing, + system monitor below). Bound to Super+M.

case "$1" in
    open)  eww open  dashboard ;;
    close) eww close dashboard ;;
    toggle|*)
        if eww active-windows 2>/dev/null | grep -q 'dashboard'; then
            eww close dashboard
        else
            eww open dashboard
        fi
        ;;
esac
