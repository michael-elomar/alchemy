###############################################################################
## @file ecos-setup.mk
## @author Y.M. Morgan
## @date 2012/10/18
##
## This file contains additional setup for ecos.
###############################################################################

ifndef TARGET_CROSS
  export PATH := /usr/local/gnutools-20080328/bin:$(PATH)
  TARGET_CROSS := /usr/local/gnutools-20080328/bin/arm-elf-
endif

# Force this
TARGET_DEFAULT_ARM_MODE := arm
TARGET_FORCE_STATIC_LIBRARIES := 1

TARGET_GLOBAL_C_INCLUDES += \
	$(TARGET_OUT_STAGING)/ecos/include

TARGET_GLOBAL_CFLAGS += \
	-mno-thumb-interwork \
	-fno-exceptions \
	-D__ECOS__

TARGET_GLOBAL_CPPFLAGS += \
	-fno-use-cxa-atexit \
	-fno-exceptions \
	-funwind-tables

TARGET_GLOBAL_LDFLAGS += \
	-Wl,-static \
	-nostdlib \

