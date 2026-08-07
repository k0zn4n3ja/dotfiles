#!/usr/bin/env bash
# Battery glyph + percent for the hyprlock HUD.  Nerd-font icons.
BAT=/sys/class/power_supply/BAT1
[ -d "$BAT" ] || { echo ""; exit 0; }

pct=$(cat "$BAT/capacity" 2>/dev/null)
st=$(cat "$BAT/status" 2>/dev/null)
[ -z "$pct" ] && { echo ""; exit 0; }

if [ "$st" = "Charging" ] || [ "$st" = "Full" ]; then
    icon="󰂄"
elif   [ "$pct" -ge 80 ]; then icon="󰁹"
elif   [ "$pct" -ge 60 ]; then icon="󰂀"
elif   [ "$pct" -ge 40 ]; then icon="󰁾"
elif   [ "$pct" -ge 20 ]; then icon="󰁻"
else                           icon="󰁺"
fi

printf '%s  %s%%\n' "$icon" "$pct"
