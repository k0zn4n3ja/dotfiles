#!/usr/bin/env bash
# "Show only on the second display" clamshell policy (like Windows/macOS):
#   ANY real external monitor connected -> DISABLE the laptop panel entirely
#                                          (removed from the layout; Hyprland
#                                          moves its workspaces to the external,
#                                          nothing can land on a dead screen)
#   all externals unplugged             -> re-enable the laptop panel
#
# We DISABLE (not DPMS-off): DPMS only powers the glass down while the output
# stays in the layout, so windows/cursor still stray onto a black screen. Disable
# actually takes it out of the desktop, which is what "only on 2" means.
#
# Stranding safety (disable's one risk = getting stuck with no usable screen):
#   * polls every 2s and re-enables the laptop the moment no external is seen
#   * re-enables the laptop on ANY clean exit (trap)
#   * ignores Hyprland's HEADLESS fallback output, so an unplug can never be
#     mistaken for "an external is still there" (which would keep us disabled)

INTERNAL="eDP-1"

# single instance only
exec 9>/tmp/hypr-monitor-policy.lock
flock -n 9 || exit 0

# always leave the laptop panel usable if we exit. trap must EXIT after cleanup,
# else a bare TERM handler resumes the loop and the daemon is unkillable but -9.
cleanup() { hyprctl keyword monitor "${INTERNAL}, preferred, auto, auto" >/dev/null 2>&1; }
trap cleanup EXIT
trap 'cleanup; exit 0' INT TERM

state=""
while :; do
    # first connected monitor that is neither the laptop nor a headless fallback
    ext=$(hyprctl monitors all -j 2>/dev/null | jq -r --arg i "$INTERNAL" '
        [ .[] | select(.name != $i and (.name | startswith("HEADLESS") | not)) ][0].name // empty')

    if [ -n "$ext" ]; then
        want="off"      # external present -> laptop disabled
    else
        want="on"       # no external      -> laptop enabled
    fi

    if [ "$want" != "$state" ]; then
        if [ "$want" = "off" ]; then
            hyprctl keyword monitor "${INTERNAL}, disable" >/dev/null 2>&1
        else
            hyprctl keyword monitor "${INTERNAL}, preferred, auto, auto" >/dev/null 2>&1
        fi
        state="$want"
    fi
    sleep 2
done
