###############################################################################
## @file target-setup.mk
## @author Y.M. Morgan
## @date 2016/03/08
###############################################################################

###############################################################################
# Import some variables from environment
###############################################################################

# Directories (full and real path)
ifndef ALCHEMY_WORKSPACE_DIR
  ALCHEMY_WORKSPACE_DIR := $(shell pwd)
endif
TOP_DIR := $(realpath $(ALCHEMY_WORKSPACE_DIR))

# Import target product from env
ifdef ALCHEMY_TARGET_PRODUCT
  TARGET_PRODUCT := $(ALCHEMY_TARGET_PRODUCT)
endif

# Import target product variant from env
ifdef ALCHEMY_TARGET_PRODUCT_VARIANT
  TARGET_PRODUCT_VARIANT := $(ALCHEMY_TARGET_PRODUCT_VARIANT)
endif

# Import target config dir from env
ifdef ALCHEMY_TARGET_CONFIG_DIR
  TARGET_CONFIG_DIR := $(ALCHEMY_TARGET_CONFIG_DIR)
endif

# Import target out dir from env
ifdef ALCHEMY_TARGET_OUT
  TARGET_OUT := $(ALCHEMY_TARGET_OUT)
endif

# Import skel dis from env
ifdef ALCHEMY_TARGET_SKEL_DIRS
  TARGET_SKEL_DIRS := $(ALCHEMY_TARGET_SKEL_DIRS)
endif

# Import scan add dirs from env
ifdef ALCHEMY_TARGET_SCAN_ADD_DIRS
  TARGET_SCAN_ADD_DIRS := $(ALCHEMY_TARGET_SCAN_ADD_DIRS)
endif

# Import scan prune dirs from env
ifdef ALCHEMY_TARGET_SCAN_PRUNE_DIRS
  TARGET_SCAN_PRUNE_DIRS := $(ALCHEMY_TARGET_SCAN_PRUNE_DIRS)
endif

# Import sdk dirs from env
ifdef ALCHEMY_TARGET_SDK_DIRS
  TARGET_SDK_DIRS := $(ALCHEMY_TARGET_SDK_DIRS)
endif

###############################################################################
## Host preliminary setup.
###############################################################################
HOST_OS := $(shell $(BUILD_SYSTEM)/scripts/host.py OS)
HOST_ARCH := $(shell $(BUILD_SYSTEM)/scripts/host.py ARCH)

###############################################################################
###############################################################################

# Include product env file
ifdef TARGET_CONFIG_DIR
  -include $(TARGET_CONFIG_DIR)/target-setup.mk
  -include $(TARGET_CONFIG_DIR)/product.mk
endif

# If a sdk has a target-setup.mk file, include it, otherwise include the legacy
# setup.mk file
TARGET_SDK_DIRS ?=
$(foreach __dir,$(TARGET_SDK_DIRS), \
	$(eval -include $(__dir)/target-setup.mk) \
	$(eval -include $(__dir)/setup.mk) \
)

###############################################################################
## Target OS aliases.
###############################################################################

# TARGET_OS aliases to simplify selection of android/iphone/iphonesimulator targets
ifdef TARGET_OS
  ifeq ("$(TARGET_OS)","android")
    override TARGET_OS := linux
    override TARGET_OS_FLAVOUR := android
  else ifeq ("$(TARGET_OS)","parrot")
    override TARGET_OS := linux
    override TARGET_OS_FLAVOUR := parrot
  else ifeq ("$(TARGET_OS)","iphone")
    override TARGET_OS := darwin
    override TARGET_OS_FLAVOUR := iphoneos
  else ifeq ("$(TARGET_OS)","iphonesimulator")
    override TARGET_OS := darwin
    override TARGET_OS_FLAVOUR := iphonesimulator
  else ifeq ("$(TARGET_OS)","yocto")
    override TARGET_OS := linux
    override TARGET_OS_FLAVOUR := yocto
  endif
endif

# Setup target specific variables
include $(BUILD_SYSTEM)/targets/setup.mk

# Setup Output directories
TARGET_OUT_PREFIX ?= Alchemy-out/
TARGET_OUT ?= $(TOP_DIR)/$(TARGET_OUT_PREFIX)$(TARGET_PRODUCT_FULL_NAME)
TARGET_OUT_BUILD ?= $(TARGET_OUT)/build
TARGET_OUT_DOC ?= $(TARGET_OUT)/doc
TARGET_OUT_STAGING ?= $(TARGET_OUT)/staging
TARGET_OUT_FINAL ?= $(TARGET_OUT)/final
TARGET_OUT_GCOV ?= $(TARGET_OUT)/gcov

HOST_OUT_BUILD ?= $(TARGET_OUT)/build-host
HOST_OUT_STAGING ?= $(TARGET_OUT)/staging-host

TARGET_CONFIG_PREFIX ?= Alchemy-config/
TARGET_CONFIG_DIR ?= $(TOP_DIR)/$(TARGET_CONFIG_PREFIX)$(TARGET_PRODUCT_FULL_NAME)

# Extra directories to skip/add during makefile scan
TARGET_SCAN_PRUNE_DIRS ?=
TARGET_SCAN_ADD_DIRS ?=

# Ignore config and out directorie(s)
ifneq ("$(dir $(TOP_DIR)/$(TARGET_CONFIG_PREFIX))","$(TOP_DIR)")
  TARGET_SCAN_PRUNE_DIRS += $(dir $(TOP_DIR)/$(TARGET_CONFIG_PREFIX))
endif
ifneq ("$(dir $(TOP_DIR)/$(TARGET_OUT_PREFIX))","$(TOP_DIR)")
  TARGET_SCAN_PRUNE_DIRS += $(dir $(TOP_DIR)/$(TARGET_OUT_PREFIX))
endif

# Skeleton directories
TARGET_SKEL_DIRS ?=

# Stip final directory
TARGET_NOSTRIP_FINAL ?= 0

# Force compilation of all modules as static (disable shared libraries)
TARGET_FORCE_STATIC ?= 0

# Force using static libraries instead of shared for module that specifies they support it
ifeq ("$(TARGET_FORCE_STATIC)","1")
  TARGET_PBUILD_FORCE_STATIC := 1
else
  TARGET_PBUILD_FORCE_STATIC ?= 0
endif

# Register list of tags used by a module. It can be retrieved at run time with
# pal function 'pal_lib_desc_get_table_entry'
TARGET_PBUILD_HOOK_USE_DESCRIBE ?= 0

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
TARGET_STRIP_FILTER ?=

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

# Include gdbserver (GPLv3) or not in target
TARGET_INCLUDE_GDBSERVER ?= 1

# Include TZData or not in the target
TARGET_INCLUDE_TZDATA ?= 0

# Include Gconv or not on the target
TARGET_INCLUDE_GCONV ?= 0

# Enable c++ exceptions
TARGET_USE_CXX_EXCEPTIONS ?= 1

# Link cpio image inside the kernel.
TARGET_LINUX_LINK_CPIO_IMAGE ?= 0

# Generate a Uboot image of linux
TARGET_LINUX_GENERATE_UIMAGE ?= 0

# Copy device tree files to the boot directory
TARGET_LINUX_DEVICE_TREE_NAMES ?=

# TODO: remove compatibility with old name in future version
ifdef TARGET_LINUX_DEVICE_TREE
  TARGET_LINUX_DEVICE_TREE_NAMES += $(TARGET_LINUX_DEVICE_TREE)
endif

# Extra argument for linux build
TARGET_LINUX_MAKE_BUILD_ARGS ?=

# Linux source directory (required by some kernel drivers)
TARGET_LINUX_DIR ?=

# Target image format (tar, cpio, ext2, ext3, ext4, plf)
# It can optionaly be suffixed with .gz or .bz2 to compress the image
TARGET_IMAGE_FORMAT ?= tar.gz

# Target image generation options (not used for plf images)
# --size : size ((in bytes, suffixes K,M,G allowed)) of the image file
# --sparse : generate a sparse image
TARGET_IMAGE_OPTIONS ?=

# Customize how final tree is done (what will be filtered)
# full: nothing filtered
# firmware: filtered according to internal heuristics suitable for embedded execution
TARGET_FINAL_MODE ?= firmware

# List of directories to add in ldconfig cache
TARGET_LDCONFIG_DIRS ?=

###############################################################################
## Default rules of makefile add TARGET_ARCH in CFLAGS.
## As it is not the way we use it, prevent export of this variable
###############################################################################
# Unexport does not work when TARGET_ARCH is set on command line, force clearing it
MAKEOVERRIDES ?=
MAKEOVERRIDES := $(filter-out TARGET_ARCH=%,$(MAKEOVERRIDES))
unexport TARGET_ARCH

###############################################################################
## gobject-introspection setup.
###############################################################################
TARGET_XDG_DATA_DIRS := $(TARGET_OUT_STAGING)/usr/share
HOST_XDG_DATA_DIRS := $(HOST_OUT_STAGING)/usr/share
