#!/bin/sh
# Exit 0 when it is safe to run a long write (OTA extraction): the device is
# charging, or the battery is at least $1 percent (default 50).
# An update that dies halfway leaves a card that no longer boots.
min=${1:-50}
perc_file=${BATTERY_PERC_FILE:-/tmp/percBat}
model_file=${DEVICE_MODEL_FILE:-/tmp/deviceModel}

is_charging() {
    model=$(cat "$model_file" 2> /dev/null)
    if [ "$model" = "283" ]; then
        [ "$(cat /sys/devices/gpiochip0/gpio/gpio59/value 2> /dev/null)" = "1" ]
    else
        status=$(axp 0 2> /dev/null | cut -d':' -f2)
        [ -n "$status" ] && [ $((0x$status & 0x4)) -eq 4 ]
    fi
}

is_charging && exit 0

perc=$(cat "$perc_file" 2> /dev/null)
# Unknown level while on battery: refuse rather than risk a half-written card.
[ -n "$perc" ] && [ "$perc" -eq "$perc" ] 2> /dev/null && [ "$perc" -ge "$min" ]
