#!/usr/bin/env bats

load '../support/test_helper'

SCRIPT="$PROJECT/static/build/.tmp_update/script/battery_ok.sh"

setup() {
    cleanup_test_data
    export BATTERY_PERC_FILE="$TEST_DATA/percBat"
    export DEVICE_MODEL_FILE="$TEST_DATA/deviceModel"
    echo -n 354 > "$DEVICE_MODEL_FILE"
    mkdir -p "$TEST_DATA/bin"
    export PATH="$TEST_DATA/bin:$PATH"
}

fake_axp() { # $1 = status register value, e.g. 70 (charging) or 00
    printf '#!/bin/sh\necho "0x00:%s"\n' "$1" > "$TEST_DATA/bin/axp"
    chmod +x "$TEST_DATA/bin/axp"
}

@test "charging is always ok, even with low battery" {
    fake_axp 74
    echo 5 > "$BATTERY_PERC_FILE"
    run sh "$SCRIPT" 50
    assert_success
}

@test "on battery above threshold is ok" {
    fake_axp 00
    echo 80 > "$BATTERY_PERC_FILE"
    run sh "$SCRIPT" 50
    assert_success
}

@test "on battery below threshold refuses" {
    fake_axp 00
    echo 20 > "$BATTERY_PERC_FILE"
    run sh "$SCRIPT" 50
    assert_failure
}

@test "unknown level on battery refuses" {
    fake_axp 00
    run sh "$SCRIPT" 50
    assert_failure
}
