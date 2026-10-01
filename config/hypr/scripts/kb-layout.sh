#!/usr/bin/env bash
# One layout for every keyboard. Hyprland tracks the active layout per device,
# so these always set an absolute index on all of them — they can't drift apart.
#   kb-layout.sh         switch every keyboard to the next layout
#   kb-layout.sh sync    put every keyboard on the current layout
#   kb-layout.sh watch   sync whenever a keyboard is plugged in (KVM switch)

# The first keyboard is the reference — it is also the one waybar displays.
kb=$(hyprctl devices -j | jq -c '.keyboards[0]')
n=$(jq -r '.layout | split(",") | length' <<<"$kb")
cur=$(jq -r '.active_layout_index' <<<"$kb")

case "${1:-next}" in
    next) hyprctl switchxkblayout all $(( (cur + 1) % n )) >/dev/null ;;
    sync) hyprctl switchxkblayout all "$cur" >/dev/null ;;
    watch)
        udevadm monitor --udev --subsystem-match=input | while read -r line; do
            [[ $line == *" add "* ]] || continue
            while read -r -t 1 _; do :; done    # let the hotplug burst finish
            "$0" sync
        done
        ;;
esac
