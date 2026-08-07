#!/usr/bin/env bash
# Uptime line for the hyprlock HUD: "󰅐  up 3h 12m"
awk '{
    d=int($1/86400); h=int(($1%86400)/3600); m=int(($1%3600)/60)
    if      (d>0) printf "  up %dd %dh\n", d, h
    else if (h>0) printf "  up %dh %dm\n", h, m
    else          printf "  up %dm\n", m
}' /proc/uptime
