#!/usr/bin/env bats

load '../support/test_helper'

SCRAPER="$PROJECT/static/build/.tmp_update/script/scraper"

# Pull a single function out of a scraper script without running the script.
load_function() {
    eval "$(sed -n "/^$2() {/,/^}/p" "$1")"
}

@test "screenscraper maps NDS to system id 15" {
    load_function "$SCRAPER/scrap_screenscraper.sh" get_ssSystemID
    get_ssSystemID NDS
    [ "$ssSystemID" = "15" ]
}

@test "launchbox maps NDS to Nintendo DS and ships its database" {
    load_function "$SCRAPER/scrap_launchbox.sh" get_launchbox_alias
    get_launchbox_alias NDS
    [ "$platform" = "Nintendo DS" ]
    assert_file_exists "$SCRAPER/launchbox_database/Nintendo DS.db"
}

@test "retroarch thumbnails map NDS" {
    grep -q 'NDS) *remoteSystem="Nintendo - Nintendo DS"' "$SCRAPER/scrap_retroarch.sh"
}
