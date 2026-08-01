#!/usr/bin/env bash
# CPU package temperature in Celsius.
# Prefer coretemp "Package id 0"; fall back to the x86_pkg_temp thermal zone.

for h in /sys/class/hwmon/hwmon*; do
    [ "$(cat "$h/name" 2>/dev/null)" = "coretemp" ] || continue
    for lbl in "$h"/temp*_label; do
        [ -f "$lbl" ] || continue
        if grep -qi 'Package id 0' "$lbl" 2>/dev/null; then
            v=$(cat "${lbl%_label}_input" 2>/dev/null)
            [ -n "$v" ] && { echo $(( v / 1000 )); exit 0; }
        fi
    done
    v=$(cat "$h/temp1_input" 2>/dev/null)
    [ -n "$v" ] && { echo $(( v / 1000 )); exit 0; }
done

for z in /sys/class/thermal/thermal_zone*; do
    if [ "$(cat "$z/type" 2>/dev/null)" = "x86_pkg_temp" ]; then
        v=$(cat "$z/temp" 2>/dev/null)
        [ -n "$v" ] && { echo $(( v / 1000 )); exit 0; }
    fi
done

echo 0
