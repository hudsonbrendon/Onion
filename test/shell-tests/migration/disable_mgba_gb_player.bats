#!/usr/bin/env bats

load '../support/test_helper'

SCRIPT="$PROJECT/static/build/.tmp_update/script/migration/00021_disable_mgba_gb_player.sh"

setup() {
    setup_sdcard
    for p in CurrentProfile GuestProfile; do
        mkdir -p "$SDCARD/Saves/$p/config/mGBA"
        printf 'mgba_force_gbp = "ON"\nmgba_gb_model = "Autodetect"\n' > "$SDCARD/Saves/$p/config/mGBA/mGBA.opt"
    done
}

@test "turns GB Player rumble off in every profile" {
    run sh "$SCRIPT"
    assert_success
    for p in CurrentProfile GuestProfile; do
        assert_file_contains "$SDCARD/Saves/$p/config/mGBA/mGBA.opt" 'mgba_force_gbp = "OFF"'
        assert_file_contains "$SDCARD/Saves/$p/config/mGBA/mGBA.opt" 'mgba_gb_model = "Autodetect"'
    done
}

@test "no mGBA config is a no-op" {
    rm -rf "$SDCARD/Saves"
    run sh "$SCRIPT"
    assert_success
}
