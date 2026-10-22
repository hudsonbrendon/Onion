#!/bin/sh
# Configures the wlan0 address: static IP when enabled in Tweaks (#48),
# otherwise (re)starts the DHCP client.
confdir="${CONFDIR:-/mnt/SDCARD/.tmp_update/config}"
resolv="${RESOLV_CONF:-/etc/resolv.conf}"

read_conf() {
    [ -f "$confdir/$1" ] && head -n 1 "$confdir/$1"
}

ip=$(read_conf .staticIpAddr)

pkill -9 udhcpc

if [ ! -f "$confdir/.staticIp" ] || [ -z "$ip" ]; then
    udhcpc -i wlan0 -s /etc/init.d/udhcpc.script &
    exit 0
fi

mask=$(read_conf .staticIpMask)
gw=$(read_conf .staticIpGw)
dns=$(read_conf .staticIpDns)

ifconfig wlan0 "$ip" netmask "${mask:-255.255.255.0}" up
if [ -n "$gw" ]; then
    route del default dev wlan0 2> /dev/null
    route add default gw "$gw" dev wlan0
fi
dns="${dns:-$gw}"
[ -n "$dns" ] && echo "nameserver $dns" > "$resolv"
exit 0
