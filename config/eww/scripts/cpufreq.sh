#!/usr/bin/env bash
# Average current CPU clock across cores, in GHz (e.g. "2.4G").
awk '/cpu MHz/ { sum += $4; n++ }
     END { if (n > 0) printf "%.1fG", (sum / n) / 1000; else printf "?" }' /proc/cpuinfo
