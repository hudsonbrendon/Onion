#!/usr/bin/env bats

load '../support/test_helper'

# MainUI's RSSI -> signal level helper used to accept 0..127 as a strong
# signal, so a lost/unknown reading (RSSI 0) drew the full-bars icon.
# The patch turns `cmp r3, #127` into `cmn r3, #1` (only RSSI <= -1 is valid).
@test "all MainUI variants carry the wifi signal level patch" {
    for bin in "$PROJECT"/static/build/.tmp_update/bin/MainUI-*; do
        bytes=$(od -An -tx1 -j $((0x13e138)) -N4 "$bin" | tr -d ' \n')
        [ "$bytes" = "010073e3" ] || {
            echo "$bin: $bytes"
            return 1
        }
    done
}
