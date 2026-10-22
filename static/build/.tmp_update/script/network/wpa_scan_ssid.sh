#!/bin/sh
# Adds scan_ssid=1 to every network block that lacks it, so hidden SSIDs
# connect (#781). Active probing is harmless for visible networks.
conf="${1:-/appconfigs/wpa_supplicant.conf}"
[ -f "$conf" ] || exit 0

tmp="$conf.tmp"
awk '
    /^[ \t]*network=\{/ { in_net = 1; has_scan = 0 }
    in_net && /^[ \t]*scan_ssid=/ { has_scan = 1 }
    in_net && /^[ \t]*\}/ { if (!has_scan) print "\tscan_ssid=1"; in_net = 0 }
    { print }
' "$conf" > "$tmp" || { rm -f "$tmp"; exit 1; }

if cmp -s "$conf" "$tmp"; then
    rm -f "$tmp"
else
    mv "$tmp" "$conf"
fi
