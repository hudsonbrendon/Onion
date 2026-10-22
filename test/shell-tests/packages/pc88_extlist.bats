#!/usr/bin/env bats

load '../support/test_helper'

CONFIG="$PROJECT/static/packages/RApp/NEC - PC-8000 (Quasi88)/RApp/quasi88/config.json"
INFO="$PROJECT/static/build/RetroArch/.retroarch/cores/quasi88_libretro.info"

@test "PC88 lists exactly the extensions quasi88 can load" {
    core_exts=$(sed -n 's/^supported_extensions = "\(.*\)"/\1/p' "$INFO")
    run jq -r .extlist "$CONFIG"
    assert_success
    assert_output "$core_exts"
}
