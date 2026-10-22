#!/usr/bin/env bash
# Hover-reveal top bar. Presence is checked each tick, so it never gets stuck.
# Only this bar is started and killed. The overlay bar (overlay.jsonc) stays up.
set -u

HOVER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/waybar/config.jsonc"
HOVER_STYLE="${XDG_CONFIG_HOME:-$HOME/.config}/waybar/style.css"
LOCK="${XDG_RUNTIME_DIR:-/tmp}/waybar-hover.lock"
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-hover.pid"

exec 9>"$LOCK"
flock -n 9 || exit 0

hover_cmdline() {
  tr '\0' ' ' < "/proc/$1/cmdline" 2>/dev/null || true
}

hover_alive() {
  [[ -f "$PIDFILE" ]] || return 1
  local pid cmd
  pid=$(<"$PIDFILE")
  [[ "$pid" =~ ^[0-9]+$ ]] || return 1
  kill -0 "$pid" 2>/dev/null || return 1
  cmd=$(hover_cmdline "$pid")
  case "$cmd" in
    *config.jsonc*) return 0 ;;
    *) return 1 ;;
  esac
}

# A hover bar left over from the old script was launched as plain `waybar`.
for pid in $(pgrep -x waybar || true); do
  cmd=$(hover_cmdline "$pid")
  case "$cmd" in
    *overlay.jsonc*) ;;
    *config.jsonc*|*waybar*) kill "$pid" 2>/dev/null || true ;;
  esac
done
rm -f "$PIDFILE"

start_hover() {
  hover_alive && return 0
  waybar -c "$HOVER_CONFIG" -s "$HOVER_STYLE" >/dev/null 2>&1 &
  echo $! > "$PIDFILE"
}

stop_hover() {
  if hover_alive; then
    kill "$(<"$PIDFILE")" 2>/dev/null || true
  fi
  rm -f "$PIDFILE"
}

while sleep 0.2; do
  read -r x y < <(hyprctl cursorpos 2>/dev/null | tr -d ',')
  [[ "$y" =~ ^[0-9]+$ ]] || continue

  if (( y <= 3 )); then
    start_hover
  elif (( y > 45 )); then
    stop_hover
  fi
done
