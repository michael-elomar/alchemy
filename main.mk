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

# Setup warnings flags
include $(BUILD_SYSTEM)/warnings.mk

# Load configuration
include $(BUILD_SYSTEM)/config.mk

# Names of makefiles that can be included by user Makefiles
CLEAR_VARS := $(BUILD_SYSTEM)/clearvars.mk
BUILD_STATIC_LIBRARY := $(BUILD_SYSTEM)/static.mk
BUILD_SHARED_LIBRARY := $(BUILD_SYSTEM)/shared.mk
BUILD_EXECUTABLE := $(BUILD_SYSTEM)/executable.mk
BUILD_AUTOTOOLS := $(BUILD_SYSTEM)/autotools.mk

# Shall be defined before including user makefiles
AUTOCONF_MERGE_FILE := $(TARGET_OUT_BUILD)/autoconf-merge.h

###############################################################################
## Makefile scan and includes.
###############################################################################

# Makefile with the list of all makefiles available and include them
SCAN_TARGET := scan
USER_MAKEFILE_NAME := ymm.mk
USER_MAKEFILES:=$(TARGET_OUT_BUILD)/makefiles.mk

# Include makefile containing all available makefile
# If it does not exists, it will trigger its creation
ifeq ("$(findstring $(SCAN_TARGET),$(MAKECMDGOALS))","")
  include $(USER_MAKEFILES)
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

# Recompute all dependencies between modules
$(call modules-compute-depends)

# Check dependencies
$(call modules-check-depends)

# Now, really generate rules for modules.
# This second pass allows to deal with exported values.
$(foreach __mod,$(__modules), \
	$(eval LOCAL_MODULE := $(__mod)) \
	$(info Generating rules for module $(__mod)) \
	$(eval include $(BUILD_SYSTEM)/module.mk) \
)

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

###############################################################################
# Main rules.
###############################################################################

.PHONY: all
all: $(foreach __mod,$(__modules),$(__mod)) $(AUTOCONF_MERGE_FILE)

.PHONY: clean
clean: $(foreach __mod,$(__modules),clean-$(__mod))
	@rm -f $(AUTOCONF_MERGE_FILE)

# Generate final tree
.PHONY: final
final: all
	@echo "Generating final tree..."
	@$(BUILD_SYSTEM)/make-final.py \
		--strip="$(STRIP)" \
		$(TARGET_OUT_STAGING) $(TARGET_OUT_FINAL)
	@echo "Done generating final tree"

# Dump the module database for debuging the build system
.PHONY: dump
dump:
	$(call modules-dump-database)

# Dump the module database for debuging the build system
.PHONY: dump-depends
dump-depends:
	$(call modules-dump-database-depends)

###############################################################################
# Display configuration.
###############################################################################
msg = $(info $(CLR_CYAN)$1$(CLR_DEFAULT))
$(info ----------------------------------------------------------------------)
$(call msg, + HOST_OS = $(HOST_OS))
$(call msg, + TARGET_OS = $(TARGET_OS))
$(call msg, + TARGET_ARCH = $(TARGET_ARCH))
$(call msg, + TARGET_OUT_BUILD = $(TARGET_OUT_BUILD))
$(call msg, + TARGET_OUT_STAGING = $(TARGET_OUT_STAGING))
$(call msg, + TARGET_OUT_FINAL = $(TARGET_OUT_FINAL))
$(call msg, + TARGET_GCC_PATH = $(TARGET_GCC_PATH))
$(call msg, + TARGET_GCC_VERSION = $(TARGET_GCC_VERSION))
$(info ----------------------------------------------------------------------)

