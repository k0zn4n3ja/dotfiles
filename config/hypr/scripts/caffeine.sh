#!/usr/bin/env bash
# Caffeine-style toggle for Hyprland.
# hypridle running  = normal idle (dim/lock/sleep)
# hypridle killed   = "caffeinated" — display stays awake
if pgrep -x hypridle >/dev/null 2>&1; then
    pkill -x hypridle
    notify-send -u low -i preferences-desktop-screensaver \
        "☕ Caffeine ON" "Screen will stay awake — no idle lock/sleep"
else
    setsid hypridle >/dev/null 2>&1 &
    notify-send -u low -i preferences-desktop-screensaver \
        "Caffeine OFF" "Normal idle: lock 5m · screen-off 5.5m · suspend 30m"
fi
