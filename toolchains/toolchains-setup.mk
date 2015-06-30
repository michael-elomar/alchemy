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

TARGET_GLOBAL_CFLAGS_gcc ?=
TARGET_GLOBAL_CFLAGS_clang ?=
TARGET_GLOBAL_LDFLAGS_gcc ?=
TARGET_GLOBAL_LDFLAGS_clang ?=
TARGET_GLOBAL_LDFLAGS_SHARED_gcc ?=
TARGET_GLOBAL_LDFLAGS_SHARED_clang ?=

# Pre-compiled header generation flag
TARGET_GLOBAL_PCH_FLAGS ?= -x c++-header

###############################################################################
## Generic setup.
###############################################################################

# Add some generic flags
# -fdata-sections causes issues with some packages
TARGET_GLOBAL_CFLAGS += \
	-pipe \
	-g -O2 \
	-ffunction-sections \
	-fno-short-enums

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


ifeq ("$(TARGET_USE_CXX_EXCEPTIONS)","0")
  TARGET_GLOBAL_CXXFLAGS += -fno-exceptions
endif

TARGET_GLOBAL_ARFLAGS += rcs

###############################################################################
## Arm setup.
###############################################################################
ifeq ("$(TARGET_ARCH)","arm")
   include $(BUILD_SYSTEM)/toolchains/arm-setup.mk
endif

ifeq ("$(TARGET_ARCH)","aarch64")
  TARGET_GLOBAL_CFLAGS += -fPIC
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
## MacOS/iOS setup.
###############################################################################
ifeq ("$(TARGET_OS)","darwin")

# Force libc
TARGET_LIBC := darwin

# Prefix of output
TARGET_STATIC_LIB_SUFFIX := .a
TARGET_SHARED_LIB_SUFFIX := .dylib
TARGET_EXE_SUFFIX :=

# Overide various flags
TARGET_GLOBAL_PCH_FLAGS := -x c++-header

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
ifneq ("$(TARGET_ARCH)","arm")
  TARGET_AS ?= llvm-as
  TARGET_AR ?= ar
  TARGET_LD ?= llvm-ld
  TARGET_NM ?= llvm-nm
  TARGET_STRIP ?= strip
  TARGET_CPP ?= cpp
  TARGET_RANLIB ?= llvm-ranlib
  TARGET_OBJCOPY ?= objcopy
  TARGET_OBJDUMP ?= llvm-objdump
else
  TARGET_AS ?= $(TARGET_CROSS)as
  TARGET_AR ?= $(TARGET_CROSS)ar
  TARGET_LD ?= $(TARGET_CROSS)ld
  TARGET_NM ?= $(TARGET_CROSS)nm
  TARGET_STRIP ?= $(TARGET_CROSS)strip
  TARGET_CPP ?= $(TARGET_CROSS)cpp
  TARGET_RANLIB ?= $(TARGET_CROSS)ranlib
  TARGET_OBJCOPY ?= $(TARGET_CROSS)objcopy
  TARGET_OBJDUMP ?= $(TARGET_CROSS)objdump
endif
endif

# No libc or gdbserver by default
TOOLCHAIN_LIBC ?=
TOOLCHAIN_GDBSERVER ?=

TARGET_DEFAULT_BIN_DESTDIR ?= usr/bin
TARGET_DEFAULT_LIB_DESTDIR ?= usr/lib

# Determine compiler path
TARGET_CC_PATH := $(shell which $(TARGET_CC))

# Check compiler path
ifeq ("$(TARGET_CC_PATH)","")
$(error Unable to find compiler: $(TARGET_CC))
endif

# Machine targetted by toolchain to be used by autotools and libc installation
ifndef TOOLCHAIN_TARGET_NAME
  TOOLCHAIN_TARGET_NAME := $(shell $(TARGET_CC) -dumpmachine)
endif

# Determine compiler version
TARGET_CC_VERSION := $(shell $(TARGET_CC) -dumpversion)

# Remove warning about mangling changes of va_list in gcc 4.4 for arm
ifeq ("$(TARGET_ARCH)","arm")
ifneq ("$(call check-version,$(TARGET_CC_VERSION),4.4.0)","")
TARGET_GLOBAL_CXXFLAGS += \
	-Wno-psabi
endif
endif

# retrieve the path to the target's loader
$(shell rm -f a.out)
TARGET_LOADER := $(shell sh -c " \
	mkdir -p $(TARGET_OUT_BUILD); \
	echo 'int main;' | \
	$(TARGET_CC) -o $(TARGET_OUT_BUILD)/a.out -xc -; \
	readelf -l $(TARGET_OUT_BUILD)/a.out | \
	grep 'interpreter:' | \
	sed 's/.*: \\(.*\\)\\]/\\1/g'; \
	rm -f $(TARGET_OUT_BUILD)/a.out")
