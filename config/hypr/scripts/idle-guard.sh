#!/usr/bin/env bash
# Idle-action gate for hypridle.
#
# Usage:  idle-guard.sh <command> [args...]
#
# If the laptop is on AC power ("plugged in"), the idle action is SKIPPED --
# no auto-lock, no screen-off, no suspend while sitting at a desk. On battery
# the command runs normally, so the usual idle timeline still saves power.
#
# hypridle just calls this in place of the raw command, e.g.
#   on-timeout = ~/.config/hypr/scripts/idle-guard.sh loginctl lock-session

on_ac() {
    # any AC/ADP adapter reporting online = plugged in
    for f in /sys/class/power_supply/A*/online; do
        [ -r "$f" ] && [ "$(cat "$f")" = "1" ] && return 0
    done
    return 1
}

on_ac && exit 0   # plugged in -> do nothing
exec "$@"          # on battery -> run the real idle action
