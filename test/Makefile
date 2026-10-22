TEST = 1
INCLUDE_UTILS = 0
CFILES := ../src/infoPanel/imagesCache.c ../src/common/utils/log.c ../src/common/utils/file.c ../src/common/utils/str.c ../src/common/utils/udp.c
include ../src/common/config.mk
CFLAGS := -DUDP_RECV_TIMEOUT_MS=300 $(CFLAGS)

TARGET = test
LDFLAGS := $(LDFLAGS) -L../lib -s -lSDL_image -lSDL -lSDL_rotozoom -lgtest -lgtest_main -lpthread

include ../src/common/commands.mk
include ../src/common/recipes.mk

$(TARGET): screen-time-tests play-activity-tests

.PHONY: screen-time-tests clean-screen-time-tests play-activity-tests clean-play-activity-tests

screen-time-tests:
	@$(MAKE) -C screenTime

play-activity-tests:
	@$(MAKE) -C playActivity

clean: clean-screen-time-tests clean-play-activity-tests

clean-screen-time-tests:
	@$(MAKE) -C screenTime clean

clean-play-activity-tests:
	@$(MAKE) -C playActivity clean
