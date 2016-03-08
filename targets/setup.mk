###############################################################################
## @file targets/setup.mk
## @author Y.M. Morgan
## @date 2016/03/05
##
## Setup variables for target.
###############################################################################

# Default OS if not set is host native
TARGET_OS ?= $(HOST_OS)
ifeq ("$(TARGET_OS)","$(HOST_OS)")
  TARGET_OS_FLAVOUR ?= native
else
  TARGET_OS_FLAVOUR ?=
endif

# OS specific setup
include $(BUILD_SYSTEM)/targets/$(TARGET_OS)/setup.mk

# Default arch if not set is host arch
ifeq ("$(TARGET_OS)","$(HOST_OS)")
  TARGET_ARCH ?= $(HOST_ARCH)
  ifeq ("$(TARGET_OS_FLAVOUR)","native")
    TARGET_LIBC ?= native
  endif
endif
ifndef TARGET_ARCH
  $(error unspecified TARGET_ARCH)
endif
TARGET_LIBC ?=
TARGET_CPU ?=

TARGET_PRODUCT ?= $(TARGET_OS)-$(TARGET_OS_FLAVOUR)
TARGET_PRODUCT_VARIANT ?= $(TARGET_ARCH)

ifeq ("$(TARGET_PRODUCT_VARIANT)","")
  TARGET_PRODUCT_FULL_NAME := $(TARGET_PRODUCT)
else
  TARGET_PRODUCT_FULL_NAME := $(TARGET_PRODUCT)-$(TARGET_PRODUCT_VARIANT)
endif

TARGET_STATIC_LIB_SUFFIX ?= .a
TARGET_SHARED_LIB_SUFFIX ?= .so
TARGET_EXE_SUFFIX ?=

TARGET_DEFAULT_BIN_DESTDIR ?= usr/bin
TARGET_DEFAULT_LIB_DESTDIR ?= usr/lib
