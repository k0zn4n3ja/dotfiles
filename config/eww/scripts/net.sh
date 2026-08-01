#!/usr/bin/env bash
# Live network throughput on the default-route interface: "↓ 1M  ↑ 340K"
iface=$(ip route 2>/dev/null | awk '/^default/{print $5; exit}')
[ -z "$iface" ] && { echo "↓ 0  ↑ 0"; exit 0; }

rx1=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo 0)
tx1=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo 0)
sleep 1
rx2=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo 0)
tx2=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo 0)

rx=$(( rx2 - rx1 )); tx=$(( tx2 - tx1 ))

hr() {
    local b=$1
    if   [ "$b" -ge 1048576 ]; then echo "$(( b / 1048576 ))M"
    elif [ "$b" -ge 1024 ];    then echo "$(( b / 1024 ))K"
    else echo "${b}B"; fi
}

echo "↓ $(hr $rx)  ↑ $(hr $tx)"
