#!/usr/bin/env bash
# Generate ~/.cache/hyprlock-dyn.conf, sourced by hyprlock.conf.
# hyprlock has no relative units, so we compute EVERYTHING here (font sizes AND
# positions) scaled to the focused monitor and expose them as variables. Scaling
# both together keeps the layout proportional -> no overlaps on any screen.
# Also picks $dot: a random "weird" obscuring glyph, different every lock.
#
# Base numbers are tuned for the 1200px-tall laptop panel.

OUT="$HOME/.cache/hyprlock-dyn.conf"
mkdir -p "$(dirname "$OUT")"

# focused monitor height (external when plugged), fall back to first / 1200
h=$(hyprctl monitors -j 2>/dev/null | jq -r '(map(select(.focused))[0] // .[0]).height // 1200')
[[ "$h" =~ ^[0-9]+$ ]] || h=1200

# scale vs the 1200px reference, clamped
r=$(awk -v h="$h" 'BEGIN{r=h/1200; if(r<0.9)r=0.9; if(r>2.2)r=2.2; printf "%.4f", r}')

# scale a value, round half away from zero (keeps sign for position offsets)
p(){ awk -v b="$1" -v r="$r" 'BEGIN{v=b*r; printf "%d", v + (v<0 ? -0.5 : 0.5)}'; }

# random weird-but-renderable obscuring glyph (raw UTF-8 bytes so nothing is stripped)
glyphs=('\xe2\x9d\x96' '\xe2\x9c\xa6' '\xe2\xac\xa2' '\xe2\x97\x88' '\xe2\x9c\xb3' '\xe2\xa7\xab' '\xe2\x9c\xa7' '\xe2\x9d\x82')
dot=$(printf "${glyphs[RANDOM % ${#glyphs[@]}]}")

{
    # ── font sizes ──
    echo "\$s_clock = $(p 96)"
    echo "\$s_head  = $(p 18)"
    echo "\$s_bat   = $(p 17)"
    echo "\$s_body  = $(p 15)"

    # ── positions (x, y) per element ──
    echo "\$clk_x = $(p 64)"   ; echo "\$clk_y = $(p -56)"
    echo "\$dat_x = $(p 72)"   ; echo "\$dat_y = $(p -188)"
    echo "\$grt_x = $(p 72)"   ; echo "\$grt_y = $(p -220)"
    echo "\$bat_x = $(p -64)"  ; echo "\$bat_y = $(p -60)"
    echo "\$upt_x = $(p -64)"  ; echo "\$upt_y = $(p -100)"
    echo "\$lay_x = $(p -64)"  ; echo "\$lay_y = $(p -134)"
    echo "\$npl_y = $(p 20)"
    echo "\$inp_y = $(p -80)"
    echo "\$inp_w = $(p 300)"  ; echo "\$inp_h = $(p 52)"
    echo "\$lock_x = $(p -178)"   # persistent lock icon, a little left of the field edge

    # ── glyphs ──
    printf '$dot = %s\n'  "$dot"
    # nf lock glyph, padded with non-breaking spaces (\xc2\xa0) so its ink isn't
    # clipped by the label's own box; NBSP survives hyprlang's whitespace trim.
    printf '$lock = %s\n' "$(printf '\xc2\xa0\xef\x80\xa3\xc2\xa0')"
} > "$OUT"
