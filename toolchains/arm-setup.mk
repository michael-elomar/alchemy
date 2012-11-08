###############################################################################
## @file arm-setup.mk
## @author Y.M. Morgan
## @date 2012/11/08
##
## This file contains additional setup for arm toolchain.
###############################################################################

# arm v5te flags (to be used in cpu flags below)
cflags_armv5te :=
	-march=armv5te \
	-mfloat-abi=soft \
	-D__ARM_ARCH_5__ \
	-D__ARM_ARCH_5T__ \
	-D__ARM_ARCH_5TE__

# arm v7neon flags (to be used in cpu flags below)
cflags_armv7neon := \
	-march=armv7-a \
	-mfloat-abi=softfp \
	-mfpu=neon

ldflags_armv7neon := \
	-Wl,--fix-cortex-a8

###############################################################################
## Setup cpu flags.
###############################################################################

ifeq ("$(TARGET_CPU)","p6")
  TARGET_GLOBAL_CFLAGS += $(cflags_armv5te)
  TARGET_GLOBAL_CFLAGS += -mtune=arm926ej-s -mcpu=arm926ej-s
endif

ifeq ("$(TARGET_CPU)","p6i")
  TARGET_GLOBAL_CFLAGS += $(cflags_armv5te)
  TARGET_GLOBAL_CFLAGS += -mtune=arm926ej-s -mcpu=arm926ej-s
endif

ifeq ("$(TARGET_CPU)","omap3")
  TARGET_GLOBAL_CFLAGS += $(cflags_armv7neon)
  TARGET_GLOBAL_LDFLAGS += $(ldflags_armv7neon)
endif

###############################################################################
## Arm/thumb mode flags.
###############################################################################

# Arm mode specific flags
ifeq ("$(TARGET_GLOBAL_CFLAGS_arm)","")
TARGET_GLOBAL_CFLAGS_arm := \
	-marm \
	-O2 \
	-fomit-frame-pointer \
	-fstrict-aliasing \
	-funswitch-loops \
	-finline-limit=300
endif

# Thumb mode specific flags
ifeq ("$(TARGET_GLOBAL_CFLAGS_thumb)","")
TARGET_GLOBAL_CFLAGS_thumb ?= \
	-mthumb \
	-Os \
	-fomit-frame-pointer \
	-fno-strict-aliasing \
	-finline-limit=64
endif

