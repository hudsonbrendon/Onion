#!/usr/bin/env bats

load '../support/test_helper'
load '../support/mocks'

STANDALONE="$PROJECT/static/packages/RApp/SCUMM (ScummVM standalone)/RApp/scummvm/scripts/import_scummvm.sh"
CORE="$PROJECT/static/packages/Emu/SCUMM (ScummVM)/Emu/SCUMMVM/import_scummvm.sh"
ROMS="$SDCARD/Roms/SCUMMVM"

setup() {
    setup_sdcard
    cleanup_test_data
    mkdir -p "$ROMS/Imgs" "$ROMS/Shortcuts" "$ROMS/Shortcuts_Standalone" \
        "$SDCARD/Emu/SCUMMVM" "$SDCARD/BIOS" "$SDCARD/.tmp_update/script" \
        "$SDCARD/Saves/CurrentProfile/config/scummvm_standalone"
    mock_binary infoPanel
    # prompt exits 0 -> naming scheme "Use database name"
    printf '#!/bin/sh\nexit 0\n' > "$SDCARD/.tmp_update/bin/prompt"
    printf '#!/bin/sh\nexit 0\n' > "$SDCARD/.tmp_update/script/reset_list.sh"
    chmod +x "$SDCARD/.tmp_update/bin/prompt" "$SDCARD/.tmp_update/script/reset_list.sh"
    config='[scummvm]
versioninfo=2.8.0git

[samnmax]
description=Sam & Max Hit the Road (CD/DOS/English)
path=/mnt/SDCARD/Roms/SCUMMVM/Sam and Max Hit the Road (CD DOS)
'
    echo "$config" > "$SDCARD/BIOS/scummvm.ini"
    echo "$config" > "$SDCARD/Saves/CurrentProfile/config/scummvm_standalone/.scummvmrc"
}

@test "standalone importer keeps '&' in database names" {
    run sh "$STANDALONE" skip_scan
    assert_success
    assert_file_exists "$ROMS/Shortcuts_Standalone/Sam & Max Hit the Road (CD, DOS, English).scummvm"
    assert_equal "$(cat "$ROMS/Shortcuts_Standalone/Sam & Max Hit the Road (CD, DOS, English).scummvm")" "samnmax"
}

@test "core importer keeps '&' in database names" {
    run sh "$CORE" skip_scan
    assert_success
    assert_file_exists "$ROMS/Shortcuts/Sam & Max Hit the Road (CD, DOS, English).target"
}

@test "box art saved under the old '&'-stripped name is renamed" {
    touch "$ROMS/Imgs/Sam  Max Hit the Road (CD, DOS, English).png"
    run sh "$STANDALONE" skip_scan
    assert_success
    assert_file_exists "$ROMS/Imgs/Sam & Max Hit the Road (CD, DOS, English).png"
    assert_file_not_exists "$ROMS/Imgs/Sam  Max Hit the Road (CD, DOS, English).png"
}
