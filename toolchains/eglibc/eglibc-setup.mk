###############################################################################
## @file eglibc-setup.mk
## @author Y.M. Morgan
## @date 2012/11/05
##
## This file contains additional setup for eglibc.
###############################################################################

ifndef TARGET_CROSS
  ifeq ("$(TARGET_ARCH)","arm")
    TARGET_CROSS := /opt/arm-2009q1/bin/arm-none-linux-gnueabi-
  endif
endif

# Assume everybody will wants this
TARGET_GLOBAL_LDLIBS += -lpthread -lrt
TARGET_GLOBAL_LDLIBS_SHARED += -lpthread -lrt

# Gcc sysroot
gcc-sysroot := $(shell $(TARGET_CROSS)gcc -print-sysroot)

# Get libc/gdbserver to copy
ifneq ("$(gcc-sysroot)","")
  ifneq ("$(wildcard $(gcc-sysroot))","")
    TOOLCHAIN_LIBC := $(gcc-sysroot)
    ifneq ("$(wildcard $(gcc-sysroot)/usr/bin/gdbserver)","")
      TOOLCHAIN_GDBSERVER := $(gcc-sysroot)/usr/bin/gdbserver
    endif
  endif
endif

