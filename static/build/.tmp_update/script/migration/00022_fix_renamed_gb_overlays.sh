#!/bin/sh

# The GB-GBC overlays "GBC-100%深", "GBC-70%深" and "PAL GBP+D20" were renamed in
# 4.2.0 (RetroArch can't load them: non-ASCII / space in the name), but configs
# saved before that (or amended by 00012) still point to the old names.

ra_dir=/mnt/SDCARD/RetroArch/.retroarch
overlay_dir=$ra_dir/overlay/GB-GBC

{
    [ -f "$ra_dir/retroarch.cfg" ] && echo "$ra_dir/retroarch.cfg"
    find /mnt/SDCARD/Saves/*/config -name '*.cfg' 2> /dev/null
} | while read -r cfg; do
    grep -q 'GBC-100%深\|GBC-70%深\|PAL GBP+D20' "$cfg" || continue
    sed -i \
        -e 's#overlay/GB-GBC/\(Frame-Grid/\)\{0,1\}GBC-100%深\.cfg#overlay/GB-GBC/Frame-Grid/GBC-100.cfg#' \
        -e 's#overlay/GB-GBC/\(Frame-Grid/\)\{0,1\}GBC-70%深\.cfg#overlay/GB-GBC/Frame-Grid/GBC-70.cfg#' \
        -e 's#overlay/GB-GBC/\(Frame-Grid/\)\{0,1\}PAL GBP+D20\.cfg#overlay/GB-GBC/Frame-Grid/PALGBP+D20.cfg#' \
        "$cfg"
done

for name in 'GBC-100%深' 'GBC-70%深' 'PAL GBP+D20'; do
    rm -f "$overlay_dir/$name.cfg" "$overlay_dir/$name.png" \
        "$overlay_dir/Frame-Grid/$name.cfg" "$overlay_dir/Frame-Grid/$name.png"
done
