###############################################################################
## @file native-setup.mk
## @author Y.M. Morgan
## @date 2012/10/18
##
## This file contains additional setup for native linux.
###############################################################################

# Use empty cross compilation flag by default
TARGET_CROSS ?=

# Update flags based on architecture
# 64-bit requires -fPIC to build shared libraries
ifeq ("$(TARGET_ARCH)","x64")
  TARGET_GLOBAL_CFLAGS += -m64 -fPIC
  TARGET_GLOBAL_LDFLAGS += -m64
  TARGET_GLOBAL_LDFLAGS_SHARED += -m64
else
  TARGET_GLOBAL_CFLAGS += -m32
  TARGET_GLOBAL_LDFLAGS += -m32
  TARGET_GLOBAL_LDFLAGS_SHARED += -m32
endif

# Assume everybody will want this
TARGET_GLOBAL_LDLIBS += -pthread -lrt
TARGET_GLOBAL_LDLIBS_SHARED += -pthread -lrt

# Machine targetted by toolchain to be used by autotools
ifeq ("$(TARGET_ARCH)","x64")
  GNU_TARGET_NAME := x86_64-pc-linux-gnu
  TOOLCHAIN_TARGET_NAME := x86_64-linux-gnu
else
  GNU_TARGET_NAME := i386-pc-linux-gnu
  TOOLCHAIN_TARGET_NAME := i386-linux-gnu
endif

# Let autotools detect full native builds
ifeq ("$(TARGET_OS_FLAVOUR)","native")
  ifeq ("$(TARGET_ARCH)","$(HOST_ARCH)")
    GNU_TARGET_NAME := $(TOOLCHAIN_TARGET_NAME)
  endif
endif

TARGET_CPU_HAS_SSE2 := 1
TARGET_CPU_HAS_SSSE3 := 1
# -march=native seems better but this would most likely break distcc builds
TARGET_GLOBAL_CFLAGS += -msse -msse2 -mssse3
