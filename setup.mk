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
TARGET_GCC ?= $(TARGET_CROSS)gcc
TARGET_GXX ?= $(TARGET_CROSS)g++
TARGET_AR ?= $(TARGET_CROSS)ar
TARGET_LD ?= $(TARGET_CROSS)ld
TARGET_NM ?= $(TARGET_CROSS)nm
TARGET_STRIP ?= $(TARGET_CROSS)strip

###############################################################################
## Tools for host.
###############################################################################
HOST_GCC ?= gcc
HOST_GXX ?= g++
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
## Update flags to use staging directory.
###############################################################################

# Make sure that staging dir are found first in case we want to override something
TARGET_GLOBAL_C_INCLUDES := -I$(TARGET_OUT_STAGING)/include $(TARGET_GLOBAL_C_INCLUDES)
TARGET_GLOBAL_C_INCLUDES := -I$(TARGET_OUT_STAGING)/usr/include $(TARGET_GLOBAL_C_INCLUDES)

TARGET_GLOBAL_LDFLAGS += -L$(TARGET_OUT_STAGING)/lib
TARGET_GLOBAL_LDFLAGS += -L$(TARGET_OUT_STAGING)/usr/lib
TARGET_GLOBAL_LDFLAGS_SHARED += -L$(TARGET_OUT_STAGING)/lib
TARGET_GLOBAL_LDFLAGS_SHARED += -L$(TARGET_OUT_STAGING)/usr/lib

###############################################################################
## Variable used for autotools.
###############################################################################

# Environment to use when executing configure script
AUTOTOOLS_CONFIGURE_ENV := \
	AR="$(TARGET_CROSS)ar" \
	AS="$(TARGET_CROSS)as" \
	LD="$(TARGET_CROSS)ld" \
	NM="$(TARGET_CROSS)nm" \
	CC="$(TARGET_CROSS)gcc" \
	GCC="$(TARGET_CROSS)gcc" \
	CXX="$(TARGET_CROSS)g++" \
	CPP="$(TARGET_CROSS)cpp" \
	RANLIB="$(TARGET_CROSS)ranlib" \
	STRIP="$(TARGET_STRIP)" \
	OBJCOPY="$(TARGET_CROSS)objcopy" \
	CC_FOR_BUILD="$(HOST_GCC)" \
	CPPFLAGS="$(TARGET_GLOBAL_C_INCLUDES) $(TARGET_GLOBAL_CFLAGS)" \
	CFLAGS="$(TARGET_GLOBAL_C_INCLUDES) $(TARGET_GLOBAL_CFLAGS)" \
	CXXFLAGS="$(TARGET_GLOBAL_C_INCLUDES) $(TARGET_GLOBAL_CFLAGS) $(TARGET_GLOBAL_CPPFLAGS)" \
	LDFLAGS="$(TARGET_GLOBAL_LDFLAGS) $(TARGET_GLOBAL_LDLIBS)" \
	DYN_LDFLAGS="$(TARGET_GLOBAL_LDFLAGS_SHARED) $(TARGET_GLOBAL_LDLIBS_SHARED)" \

#	PKG_CONFIG_SYSROOT="$(TARGET_OUT_STAGING)" \
#	PKG_CONFIG="$(TARGET_OUT_STAGING)/usr/bin/pkg-config"

# FIXME : put this somewehere else...
ifeq ("$(TARGET_ARCH)","ARM")
  ifeq ("$(TARGET_OS_FLAVOUR)","ANDROID")
    GNU_TARGET_NAME := arm-eabi
  else
    GNU_TARGET_NAME := arm-none-linux-gnueabi
  endif
else
  GNU_TARGET_NAME := i386-linux-gnu
endif

# Arguments to give to configure script
AUTOTOOLS_CONFIGURE_ARGS := \
	--host="${GNU_TARGET_NAME}" \
	--prefix="$(TARGET_OUT_STAGING)/usr"

# Environment to use when executing make
AUTOTOOLS_MAKE_ENV :=

# Arguments to give to make
AUTOTOOLS_MAKE_ARGS :=

# Quiet flags
ifeq ("$(V)","0")
  AUTOTOOLS_CONFIGURE_ARGS += -q
  AUTOTOOLS_MAKE_ENV += LIBTOOLFLAGS="--quiet"
  AUTOTOOLS_MAKE_ARGS += -s --no-print-directory
endif

###############################################################################
## Default rules of makefile add TARGET_ARCH in CFLAGS.
## As it is not the way we se it, prevent export of this variable
###############################################################################
unexport TARGET_ARCH

###############################################################################
## Determine gcc path and version.
###############################################################################

TARGET_GCC_PATH := $(shell which $(TARGET_GCC))

ifneq ("$(USE_CLANG)","1")
TARGET_GCC_VERSION := $(shell $(TARGET_GCC) --version | head -1 | sed "s/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/")
else
TARGET_GCC_VERSION := 0.0.0
endif
