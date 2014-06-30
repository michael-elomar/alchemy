###############################################################################
## @file eglibc-setup.mk
## @author Y.M. Morgan
## @date 2012/11/05
##
## This file contains additional setup for eglibc.
###############################################################################

# Select a default toolchain
ifndef TARGET_CROSS
  ifeq ("$(TARGET_ARCH)","arm")
    ifeq ("$(TARGET_CPU)","p6")
      TARGET_CROSS := /opt/arm-2009q1/bin/arm-none-linux-gnueabi-
    else ifeq ("$(TARGET_CPU)","p6i")
      TARGET_CROSS := /opt/arm-2009q1/bin/arm-none-linux-gnueabi-
    else
      TARGET_CROSS := /opt/arm-2012.03/bin/arm-none-linux-gnueabi-
    endif
  endif
endif

# Update flags based on architecture
# 64-bit requires -fPIC to build shared libraries
ifeq ("$(TARGET_ARCH)","x64")
  TARGET_GLOBAL_CFLAGS += -m64 -fPIC
  TARGET_GLOBAL_LDFLAGS += -m64
  TARGET_GLOBAL_LDFLAGS_SHARED += -m64
endif

ifeq ("$(TARGET_ARCH)","x86")
  TARGET_GLOBAL_CFLAGS += -m32
  TARGET_GLOBAL_LDFLAGS += -m32
  TARGET_GLOBAL_LDFLAGS_SHARED += -m32
endif

# Assume everybody will wants this
TARGET_GLOBAL_LDLIBS += -pthread -lrt
TARGET_GLOBAL_LDLIBS_SHARED += -pthread -lrt
TARGET_GLOBAL_CFLAGS += -funwind-tables

# Gcc sysroot
# We use cflags as well as arm/thumb mode to select correct variant
gcc-sysroot-flags := $(TARGET_GLOBAL_CFLAGS)
ifeq ("$(TARGET_ARCH)","arm")
  gcc-sysroot-flags += $(TARGET_GLOBAL_CFLAGS_$(TARGET_DEFAULT_ARM_MODE))
endif
gcc-sysroot := $(shell $(TARGET_CROSS)gcc $(gcc-sysroot-flags) -print-sysroot)

# Get libc/gdbserver to copy
ifneq ("$(gcc-sysroot)","")
  ifneq ("$(wildcard $(gcc-sysroot))","")
    TOOLCHAIN_LIBC := $(gcc-sysroot)
    ifneq ("$(wildcard $(gcc-sysroot)/usr/bin/gdbserver)","")
      TOOLCHAIN_GDBSERVER := $(gcc-sysroot)/usr/bin/gdbserver
    endif
  endif
endif
