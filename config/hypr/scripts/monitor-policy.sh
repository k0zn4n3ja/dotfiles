#!/usr/bin/env bash
# "Clamshell" monitor policy:
#   external monitor (DP-1) plugged in  -> black out the laptop panel, use only the external
#   external monitor unplugged          -> bring the laptop panel back
#
# Uses DPMS off/on (NOT `monitor,disable`) so the laptop screen is only powered
# down, never removed from Hyprland -- it ALWAYS recovers and can never get
# stuck black (that's the failure mode of the disable-based toggles online).
# Polls every 2s, so even if it misses a hotplug event it self-corrects.

INTERNAL="eDP-1"
EXTERNAL="DP-1"

# single instance only
exec 9>/tmp/hypr-monitor-policy.lock
flock -n 9 || exit 0

# make sure the laptop panel is on if we ever exit.
# NOTE: trap INT/TERM must EXIT after cleanup -- a bare `trap cleanup TERM`
# runs the handler and then resumes the loop, making the daemon un-killable
# except via SIGKILL.
cleanup() { hyprctl dispatch dpms on "$INTERNAL" >/dev/null 2>&1; }
trap cleanup EXIT
trap 'cleanup; exit 0' INT TERM

state=""
while :; do
    # Don't fight the lock screen. hyprlock needs every output awake (a DPMS-off
    # monitor makes it black-screen), so while it's up we leave DPMS alone and
    # reset state so the clamshell rule is re-applied the moment you unlock.
    if pidof hyprlock >/dev/null 2>&1; then
        state=""
        sleep 2
        continue
    fi

    if hyprctl monitors all -j | jq -e --arg m "$EXTERNAL" 'any(.[]; .name==$m)' >/dev/null 2>&1; then
        want="off"      # external present -> laptop off
    else
        want="on"       # external gone    -> laptop on
    fi

    if [ "$want" != "$state" ]; then
        hyprctl dispatch dpms "$want" "$INTERNAL" >/dev/null 2>&1
        # when going external-only, move focus off the (now dark) laptop panel
        [ "$want" = "off" ] && hyprctl dispatch focusmonitor "$EXTERNAL" >/dev/null 2>&1
        state="$want"
    fi
    sleep 2
done
