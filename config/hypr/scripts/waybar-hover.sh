#!/usr/bin/env bash
# Hover-reveal top bar: waybar only runs while the cursor is at the top edge.
# Deterministic — presence is checked each tick, so it never gets stuck.

pkill waybar 2>/dev/null      # ensure no leftover bar at startup

while sleep 0.2; do
    read -r x y < <(hyprctl cursorpos 2>/dev/null | tr -d ',')
    [[ "$y" =~ ^[0-9]+$ ]] || continue

    if (( y <= 3 )); then
        # cursor slammed to the top edge -> make sure the bar is up
        pgrep waybar >/dev/null || waybar >/dev/null 2>&1 &
    elif (( y > 45 )); then
        # cursor left the bar zone -> tear it down
        pgrep waybar >/dev/null && pkill waybar 2>/dev/null
    fi
done
