#!/usr/bin/env bash
# Now-playing line for hyprlock. Outputs a single space when nothing is playing
# so hyprlock renders a blank label instead of its "Sample Text" placeholder.
out=$(playerctl -a metadata --format '  {{artist}} — {{title}}' 2>/dev/null | head -1)
[ -z "$out" ] && out=" "
printf '%s\n' "$out"
