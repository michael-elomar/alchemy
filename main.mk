###############################################################################
## @file main.mk
## @author Y.M. Morgan
## @date 2011/05/14
##
## Main Makefile.
###############################################################################

###############################################################################
## General setup.
###############################################################################

# Make sure SHELL is correctly set
SHELL := /bin/sh

# Turns off suffix rules built into make
.SUFFIXES:

# Overridable settings
V := 0
W := 0
DEBUG := 0
USE_CLANG := 0
USE_CCACHE := 0

# Quiet command if V is 0
ifeq ("$(V)","0")
  Q := @
#  MAKEFLAGS += -s --no-print-directory
endif

# This is the default target.  It must be the first declared target.
all:

###############################################################################
## The folowing 2 macros can NOT be put in defs.mk as it will be included
## only after.
###############################################################################

# Get full path.
# $1 : path to extend.
fullpath = $(shell readlink -m -n $1)

# Figure out where we are
# It returns the full path without trailing '/'
my-dir = $(call fullpath,$(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST)))))

###############################################################################
## Build system setup.
###############################################################################

# Directories (full path)
TOP_DIR := $(shell pwd)
BUILD_SYSTEM := $(call my-dir)

# Setup configuration
include $(BUILD_SYSTEM)/setup.mk

# Setup macros definitions
include $(BUILD_SYSTEM)/defs.mk

# Setup autotools definitions (shall be after inclusion of defs.mk)
include $(BUILD_SYSTEM)/autotools-setup.mk

# Setup warnings flags
include $(BUILD_SYSTEM)/warnings.mk

# Setup configuration definitions
include $(BUILD_SYSTEM)/config-defs.mk

# Names of makefiles that can be included by user Makefiles
CLEAR_VARS := $(BUILD_SYSTEM)/clearvars.mk
BUILD_STATIC_LIBRARY := $(BUILD_SYSTEM)/static.mk
BUILD_SHARED_LIBRARY := $(BUILD_SYSTEM)/shared.mk
BUILD_EXECUTABLE := $(BUILD_SYSTEM)/executable.mk
BUILD_AUTOTOOLS := $(BUILD_SYSTEM)/autotools.mk
BUILD_PREBUILT := $(BUILD_SYSTEM)/prebuilt.mk

# Shall be defined before including user makefiles
AUTOCONF_MERGE_FILE := $(TARGET_OUT_BUILD)/autoconf-merge.h

ifeq ("$(TARGET_OS)","LINUX")
  ifeq ("$(TARGET_OS_FLAVOUR)","ANDROID")
    include $(BUILD_SYSTEM)/toolchains/bionic.mk
  endif
else ifeq ("$(TARGET_OS)","ECOS")
  include $(BUILD_SYSTEM)/toolchains/ecos.mk
endif

###############################################################################
# Display configuration.
###############################################################################
msg = $(info $(CLR_CYAN)$1$(CLR_DEFAULT))
$(info ----------------------------------------------------------------------)
$(call msg,+ HOST_OS = $(HOST_OS))
$(call msg,+ TARGET_OS = $(TARGET_OS))
$(call msg,+ TARGET_ARCH = $(TARGET_ARCH))
$(call msg,+ TARGET_OUT_BUILD = $(TARGET_OUT_BUILD))
$(call msg,+ TARGET_OUT_STAGING = $(TARGET_OUT_STAGING))
$(call msg,+ TARGET_OUT_FINAL = $(TARGET_OUT_FINAL))
$(call msg,+ TARGET_CC_PATH = $(TARGET_CC_PATH))
$(call msg,+ TARGET_CC_VERSION = $(TARGET_CC_VERSION))
$(info ----------------------------------------------------------------------)

###############################################################################
## Makefile scan and includes.
###############################################################################

# Makefile with the list of all makefiles available and include them
SCAN_TARGET := scan
CLOBBER_TARGET := clobber
USER_MAKEFILE_NAME := atom.mk
USER_MAKEFILES:=$(TARGET_OUT_BUILD)/makefiles.mk

# Include makefile containing all available makefile
# If it does not exists, it will trigger its creation
ifeq ("$(findstring $(SCAN_TARGET),$(MAKECMDGOALS))","")
ifeq ("$(findstring $(CLOBBER_TARGET),$(MAKECMDGOALS))","")
  include $(USER_MAKEFILES)
endif
endif

# Create a file that will contain all user makefiles available
define create-user-makefiles-file
	rm -f $(USER_MAKEFILES); \
	mkdir -p $(dir $(USER_MAKEFILES)); \
	touch $(USER_MAKEFILES); \
	echo "Scanning $(TOP_DIR) for makefiles..."; \
	for f in `find $(TOP_DIR) -name $(USER_MAKEFILE_NAME)`; do \
		echo "$$f"; \
		echo "include $$f" >> $(USER_MAKEFILES); \
	done;
endef

# Rule that will trigger creation of list of makefiles when needed
$(USER_MAKEFILES):
	@$(create-user-makefiles-file)

# Rule to force creation of list of makefiles
.PHONY: $(SCAN_TARGET)
$(SCAN_TARGET):
	@$(create-user-makefiles-file)

###############################################################################
# Module dependencies generation.
###############################################################################

# All modules
ALL_MODULES := \
	$(foreach __mod,$(__modules),$(__mod))

# All module to actually build
ALL_BUILD_MODULES := \
	$(foreach __mod,$(__modules), \
		$(if $(call is-module-in-build-config,$(__mod)),$(__mod)))

# Recompute all dependencies between modules
$(call modules-compute-depends)

# Check dependencies and variables of modules (unless we want to configure something)
ifeq ("$(findstring config,$(MAKECMDGOALS))","")
  $(call modules-check-depends)
  $(call modules-check-variables)
endif

# Now, really generate rules for modules.
# This second pass allows to deal with exported values.
ifeq ("$(findstring config,$(MAKECMDGOALS))","")
$(foreach __mod,$(ALL_MODULES), \
	$(eval LOCAL_MODULE := $(__mod)) \
	$(eval include $(BUILD_SYSTEM)/module.mk) \
)
endif

###############################################################################
# Rule to merge autoconf.h files.
###############################################################################

# List of all available autoconf.h files
__autoconf-list := $(foreach __mod,$(__modules),$(call module-get-autoconf,$(__mod)))

# Concatenate all in one
$(AUTOCONF_MERGE_FILE): $(__autoconf-list)
	@echo "Generating autoconf-merge.h"
	@mkdir -p $(dir $@)
	@rm -f $@
	@for f in $^; do cat $$f >> $@; done

# Confifuration rules (once module database is built)
include $(BUILD_SYSTEM)/config-rules.mk

###############################################################################
# Main rules.
###############################################################################

.PHONY: all
all: $(ALL_BUILD_MODULES) $(AUTOCONF_MERGE_FILE)

.PHONY: clean
clean: $(foreach __mod,$(ALL_MODULES),clean-$(__mod))
	@rm -f $(AUTOCONF_MERGE_FILE)

.PHONY: clobber
clobber:
	@rm -rf $(TARGET_OUT_BUILD)
	@rm -rf $(TARGET_OUT_STAGING)
	@rm -rf $(TARGET_OUT_FINAL)

# Generate final tree
.PHONY: final
final: all
	@echo "Generating final tree..."
	@$(BUILD_SYSTEM)/make-final.py \
		--strip="$(TARGET_STRIP)" \
		$(TARGET_OUT_STAGING) $(TARGET_OUT_FINAL)
	@echo "Done generating final tree"

# Generate final tree without stripping executables
.PHONY: final-nostrip
final-nostrip: all
	@echo "Generating final tree (no stripping)..."
	@$(BUILD_SYSTEM)/make-final.py \
		$(TARGET_OUT_STAGING) $(TARGET_OUT_FINAL)
	@echo "Done generating final tree (no stripping)"

# Dump the module database for debuging the build system
.PHONY: dump
dump:
	$(call modules-dump-database)

# Dump the module database for debuging the build system
.PHONY: dump-depends
dump-depends:
	$(call modules-dump-database-depends)

# Dummy target to check internal variables
.PHONY: check
check:

