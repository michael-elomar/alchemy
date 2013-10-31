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
TARGET_GLOBAL_CXXFLAGS ?=
TARGET_GLOBAL_ARFLAGS ?=
TARGET_GLOBAL_LDFLAGS ?=
TARGET_GLOBAL_LDFLAGS_SHARED ?=
TARGET_GLOBAL_LDLIBS ?=
TARGET_GLOBAL_LDLIBS_SHARED ?=

# Pre-compiled header generation flag
ifneq ("$(USE_CLANG)","1")
  TARGET_GLOBAL_PCH_FLAGS ?= -c
else
  TARGET_GLOBAL_PCH_FLAGS ?= -x c++-header
endif

###############################################################################
## Generic setup.
###############################################################################

# Add some generic flags
# -fdata-sections causes issues with some packages
TARGET_GLOBAL_CFLAGS += \
	-pipe \
	-O2 -g \
	-ffunction-sections

# TODO: check for these flags
#TARGET_GLOBAL_CFLAGS += \
#	-fpic -fPIE \
#	-funwind-tables \
#	-fstack-protector \
#	-Wa,--noexecstack \

# TODO: check for these flags
#TARGET_GLOBAL_LDFLAGS += \
#	-Wl,-z,noexecstack \
#	-Wl,-z,relro \
#	-Wl,-z,now

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
  else ifeq ("$(TARGET_OS_FLAVOUR)","native-chroot")
    TARGET_LIBC := native
  else
    TARGET_LIBC := eglibc
  endif
endif

# Prefix of output
TARGET_STATIC_LIB_SUFFIX := .a
TARGET_SHARED_LIB_SUFFIX := .so
TARGET_EXE_SUFFIX :=

endif

###############################################################################
## Ecos setup.
###############################################################################
ifeq ("$(TARGET_OS)","ecos")

# Force libc
TARGET_LIBC := ecos

# Prefix of output
TARGET_STATIC_LIB_SUFFIX := .a
TARGET_SHARED_LIB_SUFFIX := .so.a
TARGET_EXE_SUFFIX := .elf

endif

###############################################################################
## Include specific libc setup.
###############################################################################

include $(BUILD_SYSTEM)/toolchains/$(TARGET_LIBC)/$(TARGET_LIBC)-setup.mk

###############################################################################
## Tools for target.
###############################################################################

ifneq ("$(USE_CLANG)","1")

TARGET_CC ?= $(TARGET_CROSS)gcc
TARGET_CXX ?= $(TARGET_CROSS)g++
TARGET_AS ?= $(TARGET_CROSS)as
TARGET_AR ?= $(TARGET_CROSS)ar
TARGET_LD ?= $(TARGET_CROSS)ld
TARGET_NM ?= $(TARGET_CROSS)nm
TARGET_STRIP ?= $(TARGET_CROSS)strip
TARGET_CPP ?= $(TARGET_CROSS)cpp
TARGET_RANLIB ?= $(TARGET_CROSS)ranlib
TARGET_OBJCOPY ?= $(TARGET_CROSS)objcopy
TARGET_OBJDUMP ?= $(TARGET_CROSS)objdump

else

# llvm-ar causes issues, so use ar
TARGET_CC ?= clang
TARGET_CXX ?= clang++
TARGET_AS ?= llvm-as
TARGET_AR ?= ar
TARGET_LD ?= llvm-ld
TARGET_NM ?= llvm-nm
TARGET_STRIP ?= strip
TARGET_CPP ?= cpp
TARGET_RANLIB ?= llvm-ranlib
TARGET_OBJCOPY ?= objcopy
TARGET_OBJDUMP ?= llvm-objdump

endif

# Linux Toolchain
ifndef TARGET_LINUX_CROSS
  TARGET_LINUX_CROSS := $(TARGET_CROSS)
endif

# Old name compat
ifndef LINUX_CROSS
  override LINUX_CROSS = $(error please use TARGET_LINUX_CROSS instead of LINUX_CROSS)
endif

# No libc or gdbserver by default
TOOLCHAIN_LIBC ?=
TOOLCHAIN_GDBSERVER ?=

# Determine compiler path
TARGET_CC_PATH := $(shell which $(TARGET_CC))

# Check compiler path
ifeq ("$(TARGET_CC_PATH)","")
$(error Unable to find compiler: $(TARGET_CC))
endif

# Machine targetted by toolchain to be used by autotools
TOOLCHAIN_TARGET_NAME ?= $(shell $(TARGET_CC) -dumpmachine)

# Determine compiler version (accept x for 3rd digit)
ifneq ("$(USE_CLANG)","1")
TARGET_CC_VERSION := $(shell $(TARGET_CC) --version | head -1 | sed "s/.*\([0-9]\.[0-9]\.[0-9x]\).*/\1/")
else
TARGET_CC_VERSION := $(shell $(TARGET_CC) --version | head -1 | sed "s/.*\([0-9]\.[0-9]\).*/\1/")
endif
