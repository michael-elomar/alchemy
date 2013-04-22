###############################################################################
## @file setup.mk
## @author Y.M. Morgan
## @date 2011/05/14
###############################################################################

###############################################################################
## Check some stuff first.
###############################################################################

# Make sure that there are no spaces in the absolute path; the build system
# can't deal with them.
ifneq ("$(words $(shell pwd))","1")
$(error Top directory contains space characters)
endif

###############################################################################
## Target configuration.
###############################################################################

TARGET_ARCH ?= x86
TARGET_CPU ?=
TARGET_OS ?= linux
TARGET_OS_FLAVOUR ?= native
TARGET_LIBC ?=
TARGET_PRODUCT ?= $(TARGET_OS)-$(TARGET_OS_FLAVOUR)
TARGET_PRODUCT_VARIANT ?= $(TARGET_ARCH)

ifeq ("$(TARGET_PRODUCT_VARIANT)","")
  TARGET_PRODUCT_FULL_NAME := $(TARGET_PRODUCT)
else
  TARGET_PRODUCT_FULL_NAME := $(TARGET_PRODUCT)-$(TARGET_PRODUCT_VARIANT)
endif

TARGET_OUT ?= $(TOP_DIR)/Alchemy-out/$(TARGET_PRODUCT_FULL_NAME)
TARGET_OUT_BUILD ?= $(TARGET_OUT)/build
TARGET_OUT_STAGING ?= $(TARGET_OUT)/staging
TARGET_OUT_FINAL ?= $(TARGET_OUT)/final
TARGET_SKEL ?=
TARGET_SKEL_DIRS ?=
TARGET_NOSTRIP_FINAL ?= 0

# TODO: remove when all projects have been migrated
ifneq ("$(TARGET_SKEL)","")
$(warning Please use 'TARGET_SKEL_DIRS' instead of 'TARGET_SKEL')
endif
TARGET_SKEL_DIRS += $(TARGET_SKEL)

TARGET_CONFIG_DIR ?= $(TOP_DIR)/Alchemy-config/$(TARGET_PRODUCT)-$(TARGET_PRODUCT_VARIANT)

TARGET_PBUILD_FORCE_STATIC ?= 0

# Extra directories to skip/add during makefile scan
TARGET_SCAN_PRUNE_DIRS ?=
TARGET_SCAN_ADD_DIRS ?=

# Directories to use as sdk
TARGET_SDK_DIRS ?=

# Default : do NOT force external checks of module that have sub-makefiles
# (autotools, linux kernel...)
# make F=1 enable force checking
TARGET_FORCE_EXTERNAL_CHECKS ?= 0
ifneq ("$(F)","0")
  TARGET_FORCE_EXTERNAL_CHECKS := 1
endif

# Global prerequisites (shall be used only by os makefile)
TARGET_GLOBAL_PREREQUISITES :=

###############################################################################
## Toolchain setup.
###############################################################################
include $(BUILD_SYSTEM)/toolchains/toolchains-setup.mk

###############################################################################
## Tools for host.
###############################################################################
HOST_CC ?= gcc
HOST_CXX ?= g++
HOST_AR ?= ar
HOST_LD ?= ld
HOST_NM ?= nm
HOST_STRIP ?= strip

###############################################################################
## Host/Target OS.
###############################################################################

# Host OS
HOST_OS := linux

# Binary suffixes
ifeq ("$(TARGET_OS)","linux")
  TARGET_STATIC_LIB_SUFFIX := .a
  TARGET_SHARED_LIB_SUFFIX := .so
  TARGET_EXE_SUFFIX :=
else ifeq ("$(TARGET_OS)","ecos")
  TARGET_STATIC_LIB_SUFFIX := .a
  TARGET_SHARED_LIB_SUFFIX := .so.a
  TARGET_EXE_SUFFIX := .elf
else
  $(error Unsupported target OS : $(TARGET_OS))
endif

# To be able to use ccache with pre-compiled headers, some environment
# variables are required
CCACHE :=
ifeq ("$(USE_CCACHE)","1")
  ifneq ("$(shell which ccache)","")
    export CCACHE_SLOPPINESS := time_macros
    CCACHE := ccache
    TARGET_GLOBAL_CFLAGS += -fpch-preprocess
  endif
endif

# Pre-compiled header generation flag
ifneq ("$(USE_CLANG)","1")
  TARGET_GLOBAL_PCH_FLAGS := -c
else
  TARGET_GLOBAL_PCH_FLAGS := -x c++-header
endif

###############################################################################
## Update flags.
###############################################################################

# Make sure that staging dir are found first in case we want to override something
__extra-c-includes := $(strip \
	$(foreach __dir,$(TARGET_OUT_STAGING) $(TARGET_SDK_DIRS), \
		$(__dir)/usr/include \
	))
TARGET_GLOBAL_C_INCLUDES := $(__extra-c-includes) $(TARGET_GLOBAL_C_INCLUDES)

# TODO : is it really the place and where to do it ?
TARGET_GLOBAL_CFLAGS += -DALCHEMY_BUILD
ifeq ("$(findstring -D__STDC_LIMIT_MACROS,$(TARGET_GLOBAL_CXXFLAGS))","")
  TARGET_GLOBAL_CXXFLAGS += -D__STDC_LIMIT_MACROS
endif

# Add staging/sdk dirs to linker
# To make sure linker does not hardcode path to libs, set rpath-link
__extra-ldflags := $(strip \
	$(foreach __dir,$(TARGET_OUT_STAGING) $(TARGET_SDK_DIRS), \
		-L$(__dir)/lib \
		-L$(__dir)/usr/lib \
		-Wl,-rpath-link=$(__dir)/lib \
		-Wl,-rpath-link=$(__dir)/usr/lib \
	))

TARGET_GLOBAL_LDFLAGS += $(__extra-ldflags)
TARGET_GLOBAL_LDFLAGS_SHARED += $(__extra-ldflags)

# Make sure the architecture specific flags is defined
# For arm/thumb it is done above
TARGET_GLOBAL_CFLAGS_$(TARGET_ARCH) ?=

# Don't emit warning for unused driver arguments
ifeq ("$(USE_CLANG)","1")
  TARGET_GLOBAL_CFLAGS += -Qunused-arguments
endif

###############################################################################
## Default rules of makefile add TARGET_ARCH in CFLAGS.
## As it is not the way we use it, prevent export of this variable
###############################################################################
unexport TARGET_ARCH

###############################################################################
## Override all TARGET_xxx variables so that they are 'simple' and not
## 'recursive'. Mainly to avoid expnasion over and over when we known they
## won't change during rule execution.
###############################################################################
$(foreach __var,$(vars-TARGET), \
	$(eval override TARGET_$(__var) := $(TARGET_$(__var))) \
)
