#!/bin/sh

# Disable mGBA "Game Boy Player Rumble": it makes sprites flicker
# (e.g. Mario & Luigi Superstar Saga) and the Miyoo has no rumble motor.

for opt in /mnt/SDCARD/Saves/*/config/mGBA/mGBA.opt; do
    [ -f "$opt" ] || continue
    sed -i 's/^mgba_force_gbp = "ON"/mgba_force_gbp = "OFF"/' "$opt"
done
