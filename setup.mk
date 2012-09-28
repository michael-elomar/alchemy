###############################################################################
## @file setup.mk
## @author Y.M. Morgan
## @date 2011/05/14
###############################################################################

###############################################################################
## Make sure that there are no spaces in the absolute path; the build system
## can't deal with them.
###############################################################################

ifneq ("$(words $(shell pwd))","1")
$(error Top directory contains space characters)
endif

###############################################################################
## Tools for target.
###############################################################################
TARGET_CC ?= $(TARGET_CROSS)gcc
TARGET_CXX ?= $(TARGET_CROSS)g++
TARGET_AR ?= $(TARGET_CROSS)ar
TARGET_LD ?= $(TARGET_CROSS)ld
TARGET_NM ?= $(TARGET_CROSS)nm
TARGET_STRIP ?= $(TARGET_CROSS)strip

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
# Target global variables.
###############################################################################
TARGET_GLOBAL_C_INCLUDES ?=
TARGET_GLOBAL_CFLAGS ?=
TARGET_GLOBAL_CPPFLAGS ?=
TARGET_GLOBAL_ARFLAGS ?= rcs
TARGET_GLOBAL_LDFLAGS ?=
TARGET_GLOBAL_LDFLAGS_SHARED ?=
TARGET_GLOBAL_LDLIBS ?=
TARGET_GLOBAL_LDLIBS_SHARED ?=
TARGET_GLOBAL_CFLAGS_ARM ?=
TARGET_GLOBAL_CFLAGS_THUMB ?=

TARGET_PCH_FLAGS ?=
TARGET_DEFAULT_ARM_MODE ?= THUMB
TARGET_FORCE_STATIC_LIBRARIES ?= 0

# Global prerequisites (shall be used only by os makefile)
TARGET_GLOBAL_PREREQUISITES :=

###############################################################################
## Host/Target OS.
###############################################################################

# Host OS
HOST_OS := LINUX

# Target OS
ifndef TARGET_OS
  $(error TARGET_OS is not defined)
endif

# Binary suffixes
ifeq ("$(TARGET_OS)","LINUX")
  TARGET_STATIC_LIB_SUFFIX := .a
  TARGET_SHARED_LIB_SUFFIX := .so
  TARGET_EXE_SUFFIX :=
else ifeq ("$(TARGET_OS)","ECOS")
  TARGET_STATIC_LIB_SUFFIX := .a
  TARGET_SHARED_LIB_SUFFIX := .so.a
  TARGET_EXE_SUFFIX := .elf
else
  $(error Unsupported target OS : $(TARGET_OS))
endif

# To be able to use ccache with pre-complied headers, some env variables are required
CCACHE := 
ifeq ("$(USE_CCACHE)","1")
  ifneq ("$(shell which ccache)","")
    CCACHE := CCACHE_SLOPPINESS=time_macros ccache
    TARGET_GLOBAL_CFLAGS += -fpch-preprocess
  endif
endif

# Pre-compiled header generation flag
ifneq ("$(USE_CLANG)","1")
  TARGET_PCH_FLAGS := -c
else
  TARGET_PCH_FLAGS := -x c++-header
endif

###############################################################################
## Update flags
###############################################################################

# Make sure that staging dir are found first in case we want to override something
TARGET_GLOBAL_C_INCLUDES := \
	$(TARGET_OUT_STAGING)/include \
	$(TARGET_OUT_STAGING)/usr/include \
	$(TARGET_GLOBAL_C_INCLUDES)

# TODO : is it really the place and where to do it ?
TARGET_GLOBAL_CFLAGS += -DNEW_BUILD
ifeq ("$(findstring -D__STDC_LIMIT_MACROS,$(TARGET_GLOBAL_CPPFLAGS))","")
  TARGET_GLOBAL_CPPFLAGS += -D__STDC_LIMIT_MACROS
endif

# Add staging dirs to linker as well
TARGET_GLOBAL_LDFLAGS += -L$(TARGET_OUT_STAGING)/lib
TARGET_GLOBAL_LDFLAGS += -L$(TARGET_OUT_STAGING)/usr/lib
TARGET_GLOBAL_LDFLAGS_SHARED += -L$(TARGET_OUT_STAGING)/lib
TARGET_GLOBAL_LDFLAGS_SHARED += -L$(TARGET_OUT_STAGING)/usr/lib

###############################################################################
## Default rules of makefile add TARGET_ARCH in CFLAGS.
## As it is not the way we se it, prevent export of this variable
###############################################################################
unexport TARGET_ARCH

###############################################################################
## Determine compiler path and version.
###############################################################################

TARGET_CC_PATH := $(shell which $(TARGET_CC))

ifneq ("$(USE_CLANG)","1")
TARGET_CC_VERSION := $(shell $(TARGET_CC) --version | head -1 | sed "s/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/")
else
TARGET_CC_VERSION := $(shell $(TARGET_CC) --version | head -1 | sed "s/.*\([0-9]\.[0-9]\).*/\1/")
endif
