###############################################################################
## @file toolchains-setup.mk
## @author Y.M. Morgan
## @date 2012/11/08
##
## This file contains additional setup for toolchains.
###############################################################################

###############################################################################
# Initialize target global variables.
###############################################################################
TARGET_GLOBAL_C_INCLUDES ?=
TARGET_GLOBAL_CFLAGS ?=
TARGET_GLOBAL_CPPFLAGS ?=
TARGET_GLOBAL_ARFLAGS ?=
TARGET_GLOBAL_LDFLAGS ?=
TARGET_GLOBAL_LDFLAGS_SHARED ?=
TARGET_GLOBAL_LDLIBS ?=
TARGET_GLOBAL_LDLIBS_SHARED ?=
TARGET_GLOBAL_CFLAGS_arm ?=
TARGET_GLOBAL_CFLAGS_thumb ?=
TARGET_PCH_FLAGS ?=

###############################################################################
## Generic setup.
###############################################################################

TARGET_GLOBAL_CFLAGS += \
	-pipe \
	-O2 -g \
	-ffunction-sections \
	-fno-common

TARGET_GLOBAL_ARFLAGS += rcs

###############################################################################
## Arm setup.
###############################################################################
ifeq ("$(TARGET_ARCH)","arm")
   include $(BUILD_SYSTEM)/toolchains/arm-setup.mk
endif

###############################################################################
## Linux setup.
###############################################################################
ifeq ("$(TARGET_OS)","linux")

# Default libc is bionic for android, eglibc if not native
ifeq ("$(TARGET_LIBC)","")
  ifeq ("$(TARGET_OS_FLAVOUR)","android")
    TARGET_LIBC := bionic
  else ifeq ("$(TARGET_OS_FLAVOUR)","native")
    TARGET_LIBC := native
  else
    TARGET_LIBC := eglibc
  endif
endif

endif

###############################################################################
## Ecos setup.
###############################################################################
ifeq ("$(TARGET_OS)","ecos")

# Force libc
TARGET_LIBC := ecos

endif

###############################################################################
## Include specific libc setup.
###############################################################################
 
include $(BUILD_SYSTEM)/toolchains/$(TARGET_LIBC)/$(TARGET_LIBC)-setup.mk

###############################################################################
## Tools for target.
###############################################################################
TARGET_CC ?= $(TARGET_CROSS)gcc
TARGET_CXX ?= $(TARGET_CROSS)g++
TARGET_AR ?= $(TARGET_CROSS)ar
TARGET_LD ?= $(TARGET_CROSS)ld
TARGET_NM ?= $(TARGET_CROSS)nm
TARGET_STRIP ?= $(TARGET_CROSS)strip

# No libc or gdbserver by default
TOOLCHAIN_LIBC ?=
TOOLCHAIN_GDBSERVER ?=

# Machine targetted by toolchain to be used by autotools
TOOLCHAIN_TARGET_NAME ?= $(shell $(TARGET_CC) -dumpmachine)

