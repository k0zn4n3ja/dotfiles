#!/usr/bin/env bash
# Swap percent for the overlay bar. Class "critical" at 80, which overlay.css turns red.
set -u

total=0
free=0
while read -r key val _; do
  case "$key" in
    SwapTotal:) total=$val ;;
    SwapFree:) free=$val ;;
  esac
done < /proc/meminfo

if (( total <= 0 )); then
  printf '%s\n' '{"text":"swap off","class":"ok"}'
  exit 0
fi

pct=$(( (total - free) * 100 / total ))
cls=ok
if (( pct >= 80 )); then
  cls=critical
fi
printf '{"text":"swap %s%%","class":"%s"}\n' "$pct" "$cls"
