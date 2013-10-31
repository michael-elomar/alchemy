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

TARGET_CONFIG_DIR ?= $(TOP_DIR)/Alchemy-config/$(TARGET_PRODUCT)-$(TARGET_PRODUCT_VARIANT)

# Force usind static libraries instead of shared for module that specifies they support it
TARGET_PBUILD_FORCE_STATIC ?= 0

# Register list of tags used by a module. It can be retrieved at run time with
# pal function 'pal_lib_desc_get_table_entry'
TARGET_PBUILD_HOOK_USE_DESCRIBE ?= 0

# Extra directories to skip/add during makefile scan
TARGET_SCAN_PRUNE_DIRS ?=
TARGET_SCAN_ADD_DIRS ?=

# Set to 1 to follow symbolic links during scan
TARGET_SCAN_FOLLOW_LINKS ?= 0

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

# Add a section in executable/shared library with dependencies used
TARGET_ADD_DEPENDS_SECTION ?= 0
TARGET_DEPENDS_SECTION_NAME ?= .alchemy.depends
ifneq ("$(TARGET_ADD_DEPENDS_SECTION)","0")
ifeq ("$(USE_GIT_REV)","0")
  $(warning TARGET_ADD_DEPENDS_SECTION requires USE_GIT_REV, disabling ...)
  TARGET_ADD_DEPENDS_SECTION := 0
endif
endif

# Add a section in executable/shared library with a sha1 of loadable sections
# of binary
TARGET_ADD_BUILDID_SECTION ?= 0
TARGET_BUILDID_SECTION_NAME ?= .alchemy.build-id

# List of filenames to filter during strip (no wildcard allowed here because
# module.mk will also look in this list to filter, not only final.mk)
TARGET_STRIP_FILTER :=

# List of files with permissions to be applied
# See documentation for format of file.
TARGET_PERMISSIONS_FILES ?=

# Set to 1 if the result of the compilation will be executed in a chroot
# environment. Used by some modules to adapt their configuration
TARGET_CHROOT ?= 0

# File containing path mapping to be used when generating image (plf for example)
# Used by chroot target that are not flashed in the same root as the build.
# See documentation for format of file.
TARGET_IMAGE_PATH_MAP_FILE ?=

# List of target wise build properties to be put in build.prop file
TARGET_BUILD_PROPERTIES ?=

###############################################################################
## Toolchain setup.
###############################################################################
include $(BUILD_SYSTEM)/toolchains/toolchains-setup.mk

###############################################################################
## Host setup.
###############################################################################

HOST_OS := linux
HOST_OUT_BUILD ?= $(TARGET_OUT)/build-host
HOST_OUT_STAGING ?= $(TARGET_OUT)/staging-host

# Setup flags
HOST_GLOBAL_C_INCLUDES ?=
HOST_GLOBAL_CFLAGS ?=
HOST_GLOBAL_CXXFLAGS ?=
HOST_GLOBAL_ARFLAGS ?=
HOST_GLOBAL_LDFLAGS ?=
HOST_GLOBAL_LDFLAGS_SHARED ?=
HOST_GLOBAL_LDLIBS ?=
HOST_GLOBAL_LDLIBS_SHARED ?=
HOST_GLOBAL_PCH_FLAGS ?=

# Add some generic flags
HOST_GLOBAL_CFLAGS += -pipe -O2 -g0
HOST_GLOBAL_ARFLAGS += rcs
HOST_GLOBAL_LDFLAGS +=

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

# Copy content of host staging from sdk
$(foreach __dir,$(TARGET_SDK_DIRS), \
	$(if $(wildcard $(__dir)/host), \
		$(shell mkdir -p $(HOST_OUT_STAGING)) \
		$(shell cp -Raf $(__dir)/host/* $(HOST_OUT_STAGING)) \
	) \
)

###############################################################################
## Update host flags.
###############################################################################

# Make sure that staging dir are found first in case we want to override something
# TODO add SDK dirs
__extra-host-c-includes := $(strip \
	$(foreach __dir,$(HOST_OUT_STAGING), \
		$(__dir)/usr/include \
	))
HOST_GLOBAL_C_INCLUDES := $(__extra-host-c-includes) $(HOST_GLOBAL_C_INCLUDES)

# Notify that build is performed by alchemy
HOST_GLOBAL_CFLAGS += -DALCHEMY_BUILD

# Add staging/sdk dirs to linker
# To make sure linker does not hardcode path to libs, set rpath-link.
# TODO add SDK dirs
# TODO should not be needed because we don't support dynamic linking in host.
__extra-host-ldflags := $(strip \
	$(foreach __dir,$(HOST_OUT_STAGING), \
		-L$(__dir)/lib \
		-L$(__dir)/usr/lib \
		-Wl,-rpath-link=$(__dir)/lib \
		-Wl,-rpath-link=$(__dir)/usr/lib \
	))

HOST_GLOBAL_LDFLAGS += $(__extra-host-ldflags)
HOST_GLOBAL_LDFLAGS_SHARED += $(__extra-host-ldflags)

# Don't emit warning for unused driver arguments
ifeq ("$(USE_CLANG)","1")
  HOST_GLOBAL_CFLAGS += -Qunused-arguments
endif

###############################################################################
## Update target flags.
###############################################################################

# Make sure that staging dir are found first in case we want to override something
__extra-target-c-includes := $(strip \
	$(foreach __dir,$(TARGET_OUT_STAGING) $(TARGET_SDK_DIRS), \
		$(__dir)/usr/include \
	))
TARGET_GLOBAL_C_INCLUDES := $(__extra-target-c-includes) $(TARGET_GLOBAL_C_INCLUDES)

# So that everyone knowns we are building with alchemy.
TARGET_GLOBAL_CFLAGS += -DALCHEMY_BUILD

# TODO : is it really the place and where to do it ?
ifeq ("$(findstring -D__STDC_LIMIT_MACROS,$(TARGET_GLOBAL_CXXFLAGS))","")
  TARGET_GLOBAL_CXXFLAGS += -D__STDC_LIMIT_MACROS
endif

# Add staging/sdk dirs to linker
# To make sure linker does not hardcode path to libs, set rpath-link
__extra-target-ldflags := $(strip \
	$(foreach __dir,$(TARGET_OUT_STAGING) $(TARGET_SDK_DIRS), \
		-L$(__dir)/lib \
		-L$(__dir)/usr/lib \
		-Wl,-rpath-link=$(__dir)/lib \
		-Wl,-rpath-link=$(__dir)/usr/lib \
	))

TARGET_GLOBAL_LDFLAGS += $(__extra-target-ldflags)
TARGET_GLOBAL_LDFLAGS_SHARED += $(__extra-target-ldflags)

# Make sure the architecture specific flags is defined
# For arm/thumb it is done in toolchain setup
TARGET_GLOBAL_CFLAGS_$(TARGET_ARCH) ?=

# Don't emit warning for unused driver arguments
ifeq ("$(USE_CLANG)","1")
  TARGET_GLOBAL_CFLAGS += -Qunused-arguments
endif

# TODO : get this based on real version of valac and glib used.
TARGET_GLOBAL_VALAFLAGS += \
	--vapidir=$(HOST_OUT_STAGING)/usr/share/vala-0.20/vapi \
	--vapidir=$(TARGET_OUT_STAGING)/usr/share/vala/vapi \
	--target-glib=2.32

###############################################################################
## ccache setup.
###############################################################################

# To be able to use ccache with pre-compiled headers, some environment
# variables are required
CCACHE :=
ifeq ("$(USE_CCACHE)","1")
  ifneq ("$(shell which ccache)","")
    export CCACHE_SLOPPINESS := time_macros
    CCACHE := ccache
    TARGET_GLOBAL_CFLAGS += -fpch-preprocess
    HOST_GLOBAL_CFLAGS += -fpch-preprocess
  endif
endif

###############################################################################
## Default rules of makefile add TARGET_ARCH in CFLAGS.
## As it is not the way we use it, prevent export of this variable
###############################################################################
unexport TARGET_ARCH
