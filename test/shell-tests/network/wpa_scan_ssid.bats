#!/usr/bin/env bats

load '../support/test_helper'

SCRIPT="$PROJECT/static/build/.tmp_update/script/network/wpa_scan_ssid.sh"

setup() {
    cleanup_test_data
    mkdir -p "$TEST_DATA"
    CONF="$TEST_DATA/wpa_supplicant.conf"
}

@test "adds scan_ssid=1 to networks missing it" {
    cat > "$CONF" <<'CONF'
ctrl_interface=/var/run/wpa_supplicant
update_config=1

network={
	ssid="Hidden Net"
	psk="secret"
}

network={
	ssid="Other"
	scan_ssid=1
	psk="x"
}
CONF
    run sh "$SCRIPT" "$CONF"
    assert_success
    [ "$(grep -c 'scan_ssid=1' "$CONF")" -eq 2 ]
    grep -q 'ssid="Hidden Net"' "$CONF"
}

@test "leaves file untouched when nothing to add" {
    printf 'update_config=1\n' > "$CONF"
    run sh "$SCRIPT" "$CONF"
    assert_success
    [ "$(cat "$CONF")" = "update_config=1" ]
    [ ! -f "$CONF.tmp" ]
}

@test "missing config is a no-op" {
    run sh "$SCRIPT" "$TEST_DATA/nope.conf"
    assert_success
}
