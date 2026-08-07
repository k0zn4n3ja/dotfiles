#!/usr/bin/env bash
# Lock wrapper: refresh the live-wallpaper background, then lock.
# Guards against double-locking (hypridle + keybind + before_sleep can all fire).

pidof hyprlock >/dev/null 2>&1 && exit 0

# Wake EVERY monitor first. hyprlock waits for all outputs to present a frame;
# a DPMS-off monitor (the laptop panel, when the clamshell policy has blanked it)
# never presents -> hyprlock black-screens. Turning them all on avoids that.
# monitor-policy.sh pauses while hyprlock runs and re-blanks the laptop on unlock.
hyprctl dispatch dpms on >/dev/null 2>&1

~/.config/hypr/scripts/lock-bg.sh     # live-wallpaper background frame
~/.config/hypr/scripts/lock-dyn.sh    # monitor-scaled font sizes + random obscuring glyph
exec hyprlock
