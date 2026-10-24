#ifndef SYSTEM_CPUCLOCK_H__
#define SYSTEM_CPUCLOCK_H__

#include "system/device_model.h"

#define CPUCLOCK_MIN 500
#define CPUCLOCK_STEP 100

/**
 * @brief Safe maximum CPU clock (MHz) for the current device.
 *
 * @return int Max clock, or 0 when the device is unknown (no OC allowed)
 */
static int cpuclock_getMax(void)
{
    if (!DEVICE_ID) {
        getDeviceModel();
    }
    switch (DEVICE_ID) {
    case MIYOO285:
    case MIYOO354:
        return 1800;
    case MIYOO283:
        return 1600;
    default:
        return 0;
    }
}

#endif // SYSTEM_CPUCLOCK_H__
