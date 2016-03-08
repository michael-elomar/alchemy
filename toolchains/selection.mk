###############################################################################
## @file toolchains/selection.mk
## @author Y.M. Morgan
## @date 2016/03/05
##
## Setup toolchain variables.
###############################################################################

HOST_CC ?= gcc
HOST_CXX ?= g++
HOST_AS ?= as
HOST_AR ?= ar
HOST_LD ?= ld
HOST_NM ?= nm
HOST_STRIP ?= strip
HOST_CPP ?= cpp
HOST_RANLIB ?= ranlib
HOST_OBJCOPY ?= objcopy
HOST_OBJDUMP ?= objdump

# Select correct toolchain
include $(BUILD_SYSTEM)/toolchains/$(TARGET_OS)/selection.mk

TARGET_CROSS ?=

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
ifeq ("$(TARGET_OS_FLAVOUR)","native")
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

# Nvidia cuda compiler
TARGET_NVCC ?=

# Determine compiler path
TARGET_CC_PATH := $(shell which $(TARGET_CC))

# Determine compiler version
TARGET_CC_VERSION := $(shell $(TARGET_CC) -dumpversion)

# Check compiler path
ifeq ("$(TARGET_CC_PATH)","")
  $(error Unable to find compiler: $(TARGET_CC))
endif

# TODO: remove when not used anymore
TARGET_COMPILER_PATH := $(shell PARAM="$(TARGET_CC)";echo $${PARAM%/bin*})
