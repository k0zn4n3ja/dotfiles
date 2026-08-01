#!/usr/bin/env bash
# Now-playing for waybar (JSON): compact text in the bar, rich details on hover.
status=$(playerctl status 2>/dev/null)
if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
    echo '{"text": ""}'
    exit 0
fi

case "$status" in
    Playing) icon="" ;;   # play
    Paused)  icon="" ;;   # pause
esac

artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)
album=$(playerctl metadata album 2>/dev/null)
[ -z "$title" ] && title="(unknown)"

# --- text shown in the bar ---
if [ -n "$artist" ]; then
    bartext="$icon  $artist - $title"
else
    bartext="$icon  $title"
fi

# --- position / length as m:ss ---
fmt() { local s=${1:-0}; printf '%d:%02d' $(( s / 60 )) $(( s % 60 )); }
pos=$(playerctl position 2>/dev/null | cut -d. -f1)
lenus=$(playerctl metadata mpris:length 2>/dev/null)
prog=""
if [ -n "$pos" ] && [ -n "$lenus" ] && [ "$lenus" -gt 0 ] 2>/dev/null; then
    len=$(( lenus / 1000000 ))
    # little text progress bar
    width=20
    filled=$(( pos * width / (len==0?1:len) )); (( filled > width )) && filled=$width
    bar=""
    for ((i=0;i<width;i++)); do [ $i -lt $filled ] && bar="$bar━" || bar="$bar─"; done
    prog="$(fmt "$pos") $bar $(fmt "$len")"
fi

# --- pango-escape for the tooltip markup ---
esc() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

tip="<b>$(esc "$title")</b>"
[ -n "$artist" ] && tip="$tip"$'\n'"$(esc "$artist")"
[ -n "$album" ]  && tip="$tip"$'\n'"<i>$(esc "$album")</i>"
[ -n "$prog" ]   && tip="$tip"$'\n'$'\n'"<tt>$prog</tt>"
tip="$tip"$'\n'$'\n'"<span size='smaller' color='#89b4fa'>$status</span>"
tip="$tip"$'\n'"<span size='smaller' color='#6c7086'>click play/pause · right-click next · scroll to skip</span>"

jq -cn --arg t "$bartext" --arg tip "$tip" '{text: $t, tooltip: $tip}'
