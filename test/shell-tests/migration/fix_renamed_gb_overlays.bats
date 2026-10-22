#!/usr/bin/env bats

load '../support/test_helper'

SCRIPT="$PROJECT/static/build/.tmp_update/script/migration/00022_fix_renamed_gb_overlays.sh"
RA="$SDCARD/RetroArch/.retroarch"

setup() {
    setup_sdcard
    mkdir -p "$SDCARD/Saves/CurrentProfile/config/Gambatte" "$RA/overlay/GB-GBC/Frame-Grid"
    printf 'input_overlay = ":/.retroarch/overlay/GB-GBC/GBC-100%%深.cfg"\n' > "$SDCARD/Saves/CurrentProfile/config/Gambatte/Gambatte.cfg"
    printf 'input_overlay = ":/.retroarch/overlay/GB-GBC/Frame-Grid/PAL GBP+D20.cfg"\n' > "$SDCARD/Saves/CurrentProfile/config/Gambatte/Tetris.cfg"
    printf 'input_overlay = "/mnt/SDCARD/RetroArch/.retroarch/overlay/GB-GBC/Frame-Grid/GBC-70%%深.cfg"\n' > "$RA/retroarch.cfg"
    touch "$RA/overlay/GB-GBC/Frame-Grid/GBC-70%深.cfg" "$RA/overlay/GB-GBC/Frame-Grid/GBC-70%深.png"
}

@test "points configs at the renamed GB overlays" {
    run sh "$SCRIPT"
    assert_success
    assert_file_contains "$SDCARD/Saves/CurrentProfile/config/Gambatte/Gambatte.cfg" 'overlay/GB-GBC/Frame-Grid/GBC-100\.cfg"$'
    assert_file_contains "$SDCARD/Saves/CurrentProfile/config/Gambatte/Tetris.cfg" 'overlay/GB-GBC/Frame-Grid/PALGBP+D20\.cfg"$'
    assert_file_contains "$RA/retroarch.cfg" '"/mnt/SDCARD/RetroArch/.retroarch/overlay/GB-GBC/Frame-Grid/GBC-70\.cfg"$'
}

@test "removes leftover files with the old names" {
    run sh "$SCRIPT"
    assert_success
    assert_file_not_exists "$RA/overlay/GB-GBC/Frame-Grid/GBC-70%深.cfg"
    assert_file_not_exists "$RA/overlay/GB-GBC/Frame-Grid/GBC-70%深.png"
}

@test "nothing to migrate is a no-op" {
    rm -rf "$SDCARD/Saves" "$RA"
    run sh "$SCRIPT"
    assert_success
}
