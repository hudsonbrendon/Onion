#!/usr/bin/env bats

load '../support/test_helper'
load '../support/mocks'

SCRIPT="$PROJECT/static/build/.tmp_update/script/network/set_ip.sh"

setup() {
    cleanup_test_data
    for bin in ifconfig route udhcpc pkill; do
        mock_binary "$bin"
    done
    export CONFDIR="$TEST_DATA/config"
    export RESOLV_CONF="$TEST_DATA/resolv.conf"
    mkdir -p "$CONFDIR"
}

teardown() {
    rm -f /usr/local/bin/ifconfig /usr/local/bin/route /usr/local/bin/udhcpc /usr/local/bin/pkill
}

set_static() {
    touch "$CONFDIR/.staticIp"
    echo 192.168.1.50 > "$CONFDIR/.staticIpAddr"
}

@test "uses DHCP when static IP is disabled" {
    echo 192.168.1.50 > "$CONFDIR/.staticIpAddr"
    run sh "$SCRIPT"
    assert_success
    sleep 0.2
    grep -q "called udhcpc with: -i wlan0" "$MOCK_LOG"
    ! grep -q "called ifconfig" "$MOCK_LOG"
}

@test "uses DHCP when static IP enabled but no address set" {
    touch "$CONFDIR/.staticIp"
    run sh "$SCRIPT"
    assert_success
    sleep 0.2
    grep -q "called udhcpc" "$MOCK_LOG"
}

@test "applies full static config" {
    set_static
    echo 255.255.0.0 > "$CONFDIR/.staticIpMask"
    echo 192.168.1.1 > "$CONFDIR/.staticIpGw"
    echo 1.1.1.1 > "$CONFDIR/.staticIpDns"
    run sh "$SCRIPT"
    assert_success
    grep -q "called pkill with: -9 udhcpc" "$MOCK_LOG"
    grep -q "called ifconfig with: wlan0 192.168.1.50 netmask 255.255.0.0 up" "$MOCK_LOG"
    grep -q "called route with: add default gw 192.168.1.1 dev wlan0" "$MOCK_LOG"
    ! grep -q "called udhcpc" "$MOCK_LOG"
    [ "$(cat "$RESOLV_CONF")" = "nameserver 1.1.1.1" ]
}

@test "defaults netmask and uses gateway as DNS" {
    set_static
    echo 10.0.0.1 > "$CONFDIR/.staticIpGw"
    run sh "$SCRIPT"
    assert_success
    grep -q "netmask 255.255.255.0 up" "$MOCK_LOG"
    [ "$(cat "$RESOLV_CONF")" = "nameserver 10.0.0.1" ]
}

@test "skips route and resolv without gateway or DNS" {
    set_static
    run sh "$SCRIPT"
    assert_success
    ! grep -q "called route" "$MOCK_LOG"
    [ ! -f "$RESOLV_CONF" ]
}
