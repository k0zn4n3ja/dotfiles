#!/usr/bin/env bash
# Emits JSON describing the current MPRIS player for the eww music popup.
# Nerd-font glyphs are produced with printf '\uXXXX' so their bytes are always correct.
NOART="$HOME/.config/eww/assets/nocover.png"

G_PREV=$(printf '')   # step-backward
G_NEXT=$(printf '')   # step-forward
G_PLAY=$(printf '')   # play
G_PAUSE=$(printf '')  # pause

status=$(playerctl status 2>/dev/null)
if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
    jq -cn --arg c "$NOART" --arg prev "$G_PREV" --arg next "$G_NEXT" --arg icon "$G_PLAY" \
      '{status:"none",title:"Nothing playing",artist:"",album:"",art:"",cover:$c,pos:"0:00",len:"0:00",pct:0,hasbar:false,icon:$icon,prev:$prev,next:$next}'
    exit 0
fi

title=$(playerctl metadata title 2>/dev/null);  [ -z "$title" ] && title="(unknown)"
artist=$(playerctl metadata artist 2>/dev/null)
album=$(playerctl metadata album 2>/dev/null)
arturl=$(playerctl metadata mpris:artUrl 2>/dev/null)
url=$(playerctl metadata xesam:url 2>/dev/null)

# YouTube-in-browser exposes no artUrl -> derive the thumbnail from the video id.
if [ -z "$arturl" ] && printf '%s' "$url" | grep -qiE 'youtube\.com|youtu\.be'; then
    vid=$(printf '%s' "$url" | sed -nE 's/.*[?&]v=([A-Za-z0-9_-]{11}).*/\1/p')
    [ -z "$vid" ] && vid=$(printf '%s' "$url" | sed -nE 's#.*youtu\.be/([A-Za-z0-9_-]{11}).*#\1#p')
    [ -n "$vid" ] && arturl="https://i.ytimg.com/vi/$vid/hqdefault.jpg"
fi

art=""; cover="$NOART"
if [ -n "$arturl" ]; then
    key=$(printf '%s' "$arturl" | md5sum | cut -c1-16)
    dest="/tmp/eww-cover-$key.png"
    if [ ! -s "$dest" ]; then
        case "$arturl" in
            file://*)           cp "${arturl#file://}" "$dest" 2>/dev/null ;;
            http://*|https://*) curl -sL --max-time 5 "$arturl" -o "$dest" 2>/dev/null ;;
            *)                  cp "$arturl" "$dest" 2>/dev/null ;;
        esac
    fi
    [ -s "$dest" ] && { art="$dest"; cover="$dest"; }
fi

fmt() { local s=${1:-0}; s=${s%.*}; printf '%d:%02d' $(( s / 60 )) $(( s % 60 )); }
posraw=$(playerctl position 2>/dev/null); posraw=${posraw%.*}; posraw=${posraw:-0}
lenus=$(playerctl metadata mpris:length 2>/dev/null); len=0
[ -n "$lenus" ] && len=$(( lenus / 1000000 ))
pct=0; hasbar=false
if [ "$len" -gt 0 ] 2>/dev/null; then pct=$(( posraw * 100 / len )); hasbar=true; fi

icon="$G_PLAY"; [ "$status" = "Playing" ] && icon="$G_PAUSE"

jq -cn \
  --arg status "$status" --arg title "$title" --arg artist "$artist" --arg album "$album" \
  --arg art "$art" --arg cover "$cover" --arg pos "$(fmt "$posraw")" --arg len "$(fmt "$len")" \
  --argjson pct "$pct" --argjson hasbar "$hasbar" \
  --arg icon "$icon" --arg prev "$G_PREV" --arg next "$G_NEXT" \
  '{status:$status,title:$title,artist:$artist,album:$album,art:$art,cover:$cover,pos:$pos,len:$len,pct:$pct,hasbar:$hasbar,icon:$icon,prev:$prev,next:$next}'
