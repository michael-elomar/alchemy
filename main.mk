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

# Turns off the RCS / SCCS implicit rules of GNU Make
% : RCS/%,v
% : RCS/%
% : %,v
% : s.%
% : SCCS/s.%

# Overridable settings
V := 0
W := 0
F := 0
USE_CLANG := 0
USE_CCACHE := 0
USE_SCAN_CACHE := 0

# Quiet command if V is 0
ifeq ("$(V)","0")
  Q := @
  MAKEFLAGS += -s --no-print-directory
endif

# This is the default target.  It must be the first declared target.
all:

# Used to force goals to build.
.PHONY: .FORCE
.FORCE:

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

# Target/os specific setup
ifeq ("$(TARGET_OS)","linux")
  ifeq ("$(TARGET_OS_FLAVOUR)","android")
    include $(BUILD_SYSTEM)/toolchains/bionic-setup.mk
  else ifeq ("$(TARGET_OS_FLAVOUR)","native")
    include $(BUILD_SYSTEM)/toolchains/native-setup.mk
  endif
else ifeq ("$(TARGET_OS)","ecos")
  include $(BUILD_SYSTEM)/toolchains/ecos-setup.mk
endif

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

# Target/os specific packages
ifeq ("$(TARGET_OS)","linux")
  ifeq ("$(TARGET_OS_FLAVOUR)","android")
    include $(BUILD_SYSTEM)/toolchains/bionic-packages.mk
  else ifeq ("$(TARGET_OS_FLAVOUR)","native")
    include $(BUILD_SYSTEM)/toolchains/native-packages.mk
  endif
else ifeq ("$(TARGET_OS)","ecos")
  include $(BUILD_SYSTEM)/toolchains/ecos-packages.mk
endif

# Makefile with the list of all makefiles available and include them
USER_MAKEFILE_NAME := atom.mk
USER_MAKEFILES_CACHE := $(TARGET_OUT_BUILD)/makefiles.mk
USER_MAKEFILES :=

ifneq ("$(USE_SCAN_CACHE)","1")

# Delete cache and include scanned files
$(shell rm -f $(USER_MAKEFILES_CACHE))
$(info Scanning $(TOP_DIR) for makefiles...)
USER_MAKEFILES := $(shell find $(TOP_DIR) -name $(USER_MAKEFILE_NAME))
include $(USER_MAKEFILES)
ifeq ("$(V)","1")
$(foreach __f,$(USER_MAKEFILES),$(info $(__f)))
endif
$(info Found $(words $(USER_MAKEFILES)) makefiles)

else

# Include makefile containing all available makefile
# If it does not exists, it will trigger its creation
ifeq ("$(call is-in-make-goals scan","")
ifeq ("$(call is-in-make-goals clobber","")
  -include $(USER_MAKEFILES_CACHE)
endif
endif

endif

# Create a file that will contain all user makefiles available
define create-user-makefiles-cache
	rm -f $(USER_MAKEFILES_CACHE); \
	mkdir -p $(dir $(USER_MAKEFILES_CACHE)); \
	touch $(USER_MAKEFILES_CACHE); \
	echo "Scanning $(TOP_DIR) for makefiles..."; \
	for f in `find $(TOP_DIR) -name $(USER_MAKEFILE_NAME)`; do \
		echo "$$f"; \
		echo "USER_MAKEFILES += $$f" >> $(USER_MAKEFILES_CACHE); \
		echo "include $$f" >> $(USER_MAKEFILES_CACHE); \
	done;
endef

# Rule that will trigger creation of list of makefiles when needed
$(USER_MAKEFILES_CACHE):
	@$(create-user-makefiles-cache)

# Rule to force creation of list of makefiles
.PHONY: scan
scan:
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
ifeq ("$(CONFIG_IN_MAKE_GOALS)","0")
  $(call modules-check-depends)
  $(call modules-check-variables)
endif

# Now, really generate rules for modules (skip this step if we are just configuring something.
# This second pass allows to deal with exported values.
ifeq ("$(CONFIG_IN_MAKE_GOALS)","0")
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
	@touch $@
	@for f in $^; do cat $$f >> $@; done

# Confifuration rules (once module database is built)
include $(BUILD_SYSTEM)/config-rules.mk

###############################################################################
# Main rules.
###############################################################################

.PHONY: all
all: $(ALL_BUILD_MODULES)
	@echo "Done building all"

.PHONY: clean
clean: $(foreach __mod,$(ALL_MODULES),clean-$(__mod))
	@rm -f $(AUTOCONF_MERGE_FILE)
	@echo "Done cleaning"

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

# Graph of build dependencies
include $(BUILD_SYSTEM)/build-graph.mk

###############################################################################
# Under native linux target, copy wrapper scripts
###############################################################################

ifeq ("$(TARGET_OS)","linux")
ifeq ("$(TARGET_OS_FLAVOUR)","native")

NATIVE_WRAPPER_SCRIPT := native-wrapper.sh

$(eval $(call copy-one-file, \
	$(BUILD_SYSTEM)/$(NATIVE_WRAPPER_SCRIPT), \
	$(TARGET_OUT_STAGING)/$(NATIVE_WRAPPER_SCRIPT)))
$(eval $(call copy-one-file, \
	$(BUILD_SYSTEM)/$(NATIVE_WRAPPER_SCRIPT), \
	$(TARGET_OUT_FINAL)/$(NATIVE_WRAPPER_SCRIPT)))

all: $(TARGET_OUT_STAGING)/$(NATIVE_WRAPPER_SCRIPT)
final: $(TARGET_OUT_FINAL)/$(NATIVE_WRAPPER_SCRIPT)
final-nostrip: $(TARGET_OUT_FINAL)/$(NATIVE_WRAPPER_SCRIPT)

endif
endif

