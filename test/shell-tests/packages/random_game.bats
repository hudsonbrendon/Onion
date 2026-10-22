#!/usr/bin/env bats

load '../support/test_helper'
load '../support/mocks'

SCRIPT="$PROJECT/static/packages/App/Random Game/App/RandomGamePicker/random.sh"
RECENTS="$SDCARD/Roms/recentlist.json"
GAME='/mnt/SDCARD/Emu/GBA/../../Roms/GBA/Game.gba'

setup() {
    setup_sdcard
    cleanup_test_data
    mkdir -p "$SDCARD/Roms"
    touch "$SDCARD/.tmp_update/config/.showRecents"
    mock_binary infoPanel
    cat > /usr/local/bin/randomGamePicker << EOF
#!/bin/sh
printf 'emu=GBA\nlabel=Game\npath=$GAME\nimg=\nlaunch=/mnt/SDCARD/Emu/GBA/launch.sh\n'
EOF
    chmod +x /usr/local/bin/randomGamePicker
}

@test "picked game replaces the Random Game app entry in recents" {
    cat > "$RECENTS" << EOF
{"label":"Random Game","rompath":"/mnt/SDCARD/App/RandomGamePicker/launch.sh","type":3}
{"label":"Game","rompath":"$GAME","launch":"/mnt/SDCARD/Emu/GBA/launch.sh","type":5}
{"label":"Other","rompath":"/mnt/SDCARD/Roms/GB/Other.gb","type":5}
EOF
    run sh "$SCRIPT"
    assert_success
    assert_equal "$(wc -l < "$RECENTS")" 2
    assert_equal "$(head -n 1 "$RECENTS")" "{\"label\":\"Game\",\"rompath\":\"$GAME\",\"launch\":\"/mnt/SDCARD/Emu/GBA/launch.sh\",\"type\":5}"
    assert_file_not_contains "$RECENTS" "RandomGamePicker"
    assert_file_contains "$RECENTS" "Other.gb"
}

@test "creates recents when the list does not exist yet" {
    run sh "$SCRIPT"
    assert_success
    assert_file_contains "$RECENTS" "\"rompath\":\"$GAME\""
}
