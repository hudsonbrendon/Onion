#!/usr/bin/env bats

# Static checks on the bundled RetroArch overlays (no device needed).

load 'support/test_helper'

RA="$PROJECT/static/build/RetroArch/.retroarch"

# Value as RetroArch's config_file parser reads it: the quoted string, or the
# first whitespace-separated token when unquoted.
@test "every overlay cfg points to an existing image" {
    missing=""
    while IFS= read -r cfg; do
        dir=$(dirname "$cfg")
        while IFS= read -r img; do
            [ -n "$img" ] && [ ! -f "$dir/$img" ] && missing="$missing\n$cfg -> $img"
        done < <(grep -E '^[[:space:]]*overlay[0-9]+_overlay[[:space:]]*=' "$cfg" | tr -d '\r' |
            sed -E 's/^[^=]*=[[:space:]]*//' | sed -E 's/^"([^"]*)".*/\1/; t; s/[[:space:]].*//')
    done < <(find "$RA/overlay" -name '*.cfg')
    [ -z "$missing" ] || fail "$(echo -e "missing overlay images:$missing")"
}

@test "overlay and filter file names are plain ASCII" {
    run bash -c "find '$RA/overlay' '$RA/filters' -type f | LC_ALL=C grep '[^ -~]'"
    assert_failure
}

@test "overlay/filter migration only moves files to paths that exist" {
    missing=""
    while IFS=$'\t' read -r mode src dst; do
        [ "$mode" = M ] && [ ! -f "$RA/$dst" ] && missing="$missing\n$dst"
    done < "$PROJECT/static/build/.tmp_update/script/migration/data/overlay_filter_changes.tsv"
    [ -z "$missing" ] || fail "$(echo -e "missing destinations:$missing")"
}
