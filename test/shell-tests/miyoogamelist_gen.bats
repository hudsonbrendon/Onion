#!/usr/bin/env bats

load 'support/test_helper'

SCRIPT="$PROJECT/static/build/.tmp_update/script/miyoogamelist_gen.sh"

setup() {
    setup_sdcard
    mkdir -p "$SDCARD/Emu/GB" "$SDCARD/Roms/GB"
    cat >"$SDCARD/Emu/GB/config.json" <<'EOF'
{
    "rompath": "../../Roms/GB",
    "imgpath": "../../Roms/GB/Imgs",
    "gamelist": "../../Roms/GB/miyoogamelist.xml",
    "extlist": "gb|zip"
}
EOF
    touch "$SDCARD/Roms/GB/Tetris (USA).gb" "$SDCARD/Roms/GB/Zelda (USA).gb"
}

@test "rewrites favourite and recent labels with digest names (#1584)" {
    cat >"$SDCARD/Roms/favourite.json" <<'EOF'
{"label":"Tetris (USA)","launch":"/mnt/SDCARD/Emu/GB/launch.sh","type":5,"rompath":"/mnt/SDCARD/Emu/GB/../../Roms/GB/Tetris (USA).gb","imgpath":"","emupath":"/mnt/SDCARD/Emu/GB"}
{"label":"Other","launch":"/mnt/SDCARD/Emu/GBA/launch.sh","type":5,"rompath":"/mnt/SDCARD/Emu/GBA/../../Roms/GBA/Tetris (USA).gb","imgpath":"","emupath":"/mnt/SDCARD/Emu/GBA"}
EOF
    cat >"$SDCARD/Roms/recentlist.json" <<'EOF'
{"label":"Zelda (USA)","launch":"/mnt/SDCARD/Emu/GB/launch.sh","type":5,"rompath":"/mnt/SDCARD/Emu/GB/../../Roms/GB/Zelda (USA).gb","imgpath":"","emupath":"/mnt/SDCARD/Emu/GB"}
EOF

    run sh "$SCRIPT"
    assert_success

    assert_file_contains "$SDCARD/Roms/GB/miyoogamelist.xml" "<name>Tetris</name>"
    run jq -r .label "$SDCARD/Roms/favourite.json"
    assert_output "$(printf 'Tetris\nOther')"
    run jq -r .label "$SDCARD/Roms/recentlist.json"
    assert_output "Zelda"
    assert_file_not_exists /tmp/miyoogamelist_labels.tsv
}

@test "no favourites file is a no-op" {
    run sh "$SCRIPT"
    assert_success
    assert_file_not_exists "$SDCARD/Roms/favourite.json"
}
