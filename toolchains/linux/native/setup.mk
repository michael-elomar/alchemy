###############################################################################
## @file linux/native/setup.mk
## @author Y.M. Morgan
## @date 2012/10/18
##
## This file contains additional setup for native linux.
###############################################################################

# Use empty cross compilation flag by default
TARGET_CROSS ?=

# Assume everybody will want this
TARGET_GLOBAL_LDLIBS += -pthread -lrt
TARGET_GLOBAL_LDLIBS_SHARED += -pthread -lrt

# Machine targetted by toolchain to be used by autotools
# Use a name that will force autotools to believe we are cross-compiling
ifeq ("$(TARGET_ARCH)","x64")
  GNU_TARGET_NAME := x86_64-pc-linux-gnu
  TOOLCHAIN_TARGET_NAME := x86_64-linux-gnu
else
  GNU_TARGET_NAME := i386-pc-linux-gnu
  TOOLCHAIN_TARGET_NAME := i386-linux-gnu
endif

# Get gdbserver path if available
TOOLCHAIN_GDBSERVER := $(wildcard /usr/bin/gdbserver)
