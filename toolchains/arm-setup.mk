###############################################################################
## @file arm-setup.mk
## @author Y.M. Morgan
## @date 2012/11/08
##
## This file contains additional setup for arm toolchain.
###############################################################################

# Use thumb mode by default
# TODO: is it necessary/usefull/wise ?
TARGET_DEFAULT_ARM_MODE ?= thumb

# Allow mix thumb/arm mode (XXX not supported by clang ?)
ifneq ("$(TARGET_OS)","ecos")
ifneq ("$(TARGET_DEFAULT_ARM_MODE)","arm")
  TARGET_GLOBAL_CFLAGS_gcc += -mthumb-interwork
endif
endif

# Required for compilation of shared libraries
ifneq ("$(TARGET_OS)","ecos")
  TARGET_GLOBAL_CFLAGS += -fPIC
endif

# arm v5te flags (to be used in cpu flags below)
ifneq ("$(TARGET_OS)","ecos")
cflags_armv5te := \
	-march=armv5te \
	-mfloat-abi=soft \
	-D__ARM_ARCH_5__ \
	-D__ARM_ARCH_5T__ \
	-D__ARM_ARCH_5TE__
else
cflags_armv5te :=
endif

# armv7-a neon flags (to be used in cpu flags below)
cflags_armv7a_neon := \
	-march=armv7-a \
	-mfloat-abi=softfp \
	-mfpu=neon

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

# If compiler does not support this -mcpu option a warning will be generated
# and removed from flags later
ifeq ("$(TARGET_CPU)","p7")
  TARGET_GLOBAL_CFLAGS += $(cflags_armv7a_neon)
  TARGET_GLOBAL_CFLAGS += -mtune=cortex-a9 -mcpu=cortex-a9
  TARGET_CPU_ARMV7A_NEON := 1
endif

# TODO: see if interresting to put -mtune=cortex-a8 -mcpu=cortex-a8
ifeq ("$(TARGET_CPU)","omap3")
  TARGET_GLOBAL_CFLAGS += $(cflags_armv7a_neon)
  TARGET_GLOBAL_LDFLAGS += -Wl,--fix-cortex-a8
  TARGET_CPU_ARMV7A_NEON := 1
endif

ifeq ("$(TARGET_CPU)","omap4")
  TARGET_GLOBAL_CFLAGS += $(cflags_armv7a_neon)
  TARGET_GLOBAL_CFLAGS += -mtune=cortex-a9 -mcpu=cortex-a9
  TARGET_CPU_ARMV7A_NEON := 1
endif

# generic armv7a-neon
ifeq ("$(TARGET_CPU)","armv7a-neon")
  TARGET_GLOBAL_CFLAGS += $(cflags_armv7a_neon)
  TARGET_GLOBAL_LDFLAGS += -Wl,--fix-cortex-a8
  TARGET_CPU_ARMV7A_NEON := 1
endif

###############################################################################
## Arm/thumb mode flags.
## Taken from Android build system setup.
###############################################################################

# Arm mode specific flags
TARGET_GLOBAL_CFLAGS_arm ?= \
	-marm \
	-O2 \
	-fomit-frame-pointer \
	-fstrict-aliasing \
	-funswitch-loops

TARGET_GLOBAL_CFLAGS_arm_gcc ?= -finline-limit=300


# Thumb mode specific flags
ifneq ("$(TARGET_DEFAULT_ARM_MODE)","arm")
TARGET_GLOBAL_CFLAGS_thumb ?= \
	-mthumb \
	-Os \
	-fomit-frame-pointer \
	-fno-strict-aliasing

TARGET_GLOBAL_CFLAGS_thumb_gcc ?= -finline-limit=64

else
# Make sure that if in arm mode, the thumb flags will not be used
override TARGET_GLOBAL_CFLAGS_thumb :=
override TARGET_GLOBAL_CFLAGS_thumb_gcc :=
endif
