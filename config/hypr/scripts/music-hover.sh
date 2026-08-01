#!/usr/bin/env bash
# Reveal the eww "music" popup when the cursor is over the now-playing area of
# the top bar, and keep it open while the cursor is over the popup itself.
# (waybar can't trigger popups on hover, so we poll the cursor like the bar does.)

POPW=250          # popup width (must match the eww geometry)
POPBOTTOM=440     # how far down the popup reaches
open=0

# logical monitor width (physical width / scale)
read -r MW SC < <(hyprctl monitors -j 2>/dev/null | jq -r '.[0] | "\(.width) \(.scale)"')
[[ "$MW" =~ ^[0-9]+$ ]] || MW=1280
[[ "$SC" =~ ^[0-9.]+$ ]] || SC=1
LW=$(awk -v w="$MW" -v s="$SC" 'BEGIN{ printf "%d", w/s }')

PAD=50
PX1=$(( (LW - POPW) / 2 - PAD ))
PX2=$(( (LW + POPW) / 2 + PAD ))

while sleep 0.15; do
    read -r x y < <(hyprctl cursorpos 2>/dev/null | tr -d ',')
    [[ "$x" =~ ^-?[0-9]+$ && "$y" =~ ^-?[0-9]+$ ]] || continue

    inzone=0
    if   (( y <= 34   && x >= PX1 && x <= PX2 )); then inzone=1   # over the bar's now-playing area
    elif (( y > 30 && y <= POPBOTTOM && x >= PX1 && x <= PX2 )); then inzone=1   # over the popup
    fi

    if   (( inzone == 1 && open == 0 )); then eww open  music >/dev/null 2>&1; open=1
    elif (( inzone == 0 && open == 1 )); then eww close music >/dev/null 2>&1; open=0
    fi
done
