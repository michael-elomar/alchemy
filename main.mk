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

# Alchemy version
ALCHEMY_VERSION_MAJOR := 1
ALCHEMY_VERSION_MINOR := 0
ALCHEMY_VERSION_REV   := 10
ALCHEMY_VERSION := $(ALCHEMY_VERSION_MAJOR).$(ALCHEMY_VERSION_MINOR).$(ALCHEMY_VERSION_REV)

# Make sure SHELL is correctly set
SHELL := /bin/bash

# Turns off suffix rules built into make
.SUFFIXES:

# Turns off the RCS / SCCS implicit rules of GNU Make
%: RCS/%,v
%: RCS/%
%: %,v
%: s.%
%: SCCS/s.%

# Overridable settings
V ?= 0
W ?= 0
F ?= 0
USE_CLANG ?= 0
USE_CCACHE ?= 0
USE_SCAN_CACHE ?= 0
USE_COLORS ?= 0
USE_GIT_REV ?= 1
USE_CONFIG_CHECK ?= 1

# The host module feature might break temporatily some atom/mk, add a flag
# so it can be checked
ALCHEMY_SUPPORT_HOST_MODULE := 1

# Quiet command if V is 0
ifeq ("$(V)","0")
  Q := @
  MAKEFLAGS += --no-print-directory
else
  Q :=
endif

# This is the default target.  It must be the first declared target.
all:

# To avoid use of undefined variable, force our default goal
MAKECMDGOALS ?= all

# Used to force goals to build.
.PHONY: .FORCE
.FORCE:

###############################################################################
## The following 2 macros can NOT be put in defs.mk as it will be included
## only after.
###############################################################################

# Figure out where we are
# It returns the full path without trailing '/'
my-dir = $(abspath $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST)))))

###############################################################################
## Env system setup.
###############################################################################

# Directories (full path)
ALCHEMY_WORKSPACE_DIR ?= $(shell pwd)
TOP_DIR := $(ALCHEMY_WORKSPACE_DIR)

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

# Import use colors from env
ifdef ALCHEMY_USE_COLORS
  USE_COLORS := $(ALCHEMY_USE_COLORS)
endif

###############################################################################
## Build system setup.
###############################################################################

BUILD_SYSTEM := $(call my-dir)

# Set this variable to 1 to skip a lot of things like dependencies check and
# config check. Useful if user only want some internal query or configure
# something.
SKIP_DEPS_AND_CHECKS := 0

# Set this variable to 1 to skip deps and checks of external modules built
# outside this build system (basically it force remaking them by removing
# their .done file).
SKIP_EXT_DEPS_AND_CHECKS := 0

# Include product env file
ifdef TARGET_CONFIG_DIR
-include $(TARGET_CONFIG_DIR)/product.mk
endif

# Setup macros definitions
include $(BUILD_SYSTEM)/variables.mk
include $(BUILD_SYSTEM)/defs.mk

# Make sure all TARGET_xxx variables that we received does not have trailing
# spaces or end of line
$(foreach __var,$(vars-TARGET), \
	$(if $(call is-var-defined,TARGET_$(__var)), \
		$(eval TARGET_$(__var) := $(strip $(TARGET_$(__var)))) \
	) \
)

# If a sdk has a setup.mk file, include it
$(foreach __dir,$(TARGET_SDK_DIRS), \
	$(eval -include $(__dir)/setup.mk) \
)

# Setup configuration
include $(BUILD_SYSTEM)/setup.mk

###############################################################################
# Optimizations for some goals.
###############################################################################

# Skip external checks if requested
ifeq ("$(TARGET_FORCE_EXTERNAL_CHECKS)","0")
  SKIP_EXT_DEPS_AND_CHECKS := 1
endif

# Skip some steps for some make goals
__clean-targets := clean dirclean clobber
__query-targets := scan help help-modules dump dump-depends dump-xml build-graph
__config-targets := config config-check config-update xconfig menuconfig nconfig
__fs-targets := final plf image-plf image-cpio sdk
__skip_targets := \
	$(__clean-targets) \
	$(__query-targets) \
	$(__config-targets) \
	$(__fs-targets)

# No optimization if 'all' is also given
ifeq ("$(call is-targets-in-make-goals,all)","")

ifneq ("$(call is-targets-in-make-goals,$(__skip_targets))","")
  SKIP_DEPS_AND_CHECKS := 1
endif
ifneq ("$(findstring -clean,$(MAKECMDGOALS))","")
  SKIP_DEPS_AND_CHECKS := 1
endif
ifneq ("$(findstring -dirclean,$(MAKECMDGOALS))","")
  SKIP_DEPS_AND_CHECKS := 1
endif
ifneq ("$(findstring -path,$(MAKECMDGOALS))","")
  SKIP_DEPS_AND_CHECKS := 1
endif
ifneq ("$(findstring -config,$(MAKECMDGOALS))","")
  SKIP_DEPS_AND_CHECKS := 1
endif
ifneq ("$(findstring -xconfig,$(MAKECMDGOALS))","")
  SKIP_DEPS_AND_CHECKS := 1
endif
ifneq ("$(findstring -menuconfig,$(MAKECMDGOALS))","")
  SKIP_DEPS_AND_CHECKS := 1
endif
ifneq ("$(findstring -nconfig,$(MAKECMDGOALS))","")
  SKIP_DEPS_AND_CHECKS := 1
endif

endif

# No reason to do external checks if we are skipping our own deps and checks...
ifneq ("$(SKIP_DEPS_AND_CHECKS)","0")
  SKIP_EXT_DEPS_AND_CHECKS := 1
endif

###############################################################################
## Display configuration.
###############################################################################
msg = $(info $(CLR_CYAN)$1$(CLR_DEFAULT))
$(info ----------------------------------------------------------------------)
$(call msg,+ ALCHEMY_WORKSPACE_DIR = $(ALCHEMY_WORKSPACE_DIR))
$(call msg,+ TARGET_PRODUCT = $(TARGET_PRODUCT))
$(call msg,+ TARGET_PRODUCT_VARIANT = $(TARGET_PRODUCT_VARIANT))
$(call msg,+ TARGET_OS = $(TARGET_OS))
$(call msg,+ TARGET_OS_FLAVOUR = $(TARGET_OS_FLAVOUR))
$(call msg,+ TARGET_LIBC = $(TARGET_LIBC))
$(call msg,+ TARGET_ARCH = $(TARGET_ARCH))
$(call msg,+ TARGET_CPU = $(TARGET_CPU))
$(call msg,+ TARGET_OUT_BUILD = $(TARGET_OUT_BUILD))
$(call msg,+ TARGET_OUT_STAGING = $(TARGET_OUT_STAGING))
$(call msg,+ TARGET_OUT_FINAL = $(TARGET_OUT_FINAL))
$(call msg,+ TARGET_CC_PATH = $(TARGET_CC_PATH))
$(call msg,+ TARGET_CC_VERSION = $(TARGET_CC_VERSION))
$(info ----------------------------------------------------------------------)

# Do some checking
include $(BUILD_SYSTEM)/check.mk

###############################################################################
## Setup part2 (may use optimization flags from above).
###############################################################################

# Setup autotools definitions (shall be after inclusion of defs.mk)
include $(BUILD_SYSTEM)/autotools-setup.mk

# Setup CMake definitions
include $(BUILD_SYSTEM)/cmake-setup.mk

# Setup warnings flags
include $(BUILD_SYSTEM)/warnings.mk

# Setup configuration definitions
include $(BUILD_SYSTEM)/config-defs.mk

# User specific debug setup makefile
debug-setup-makefile := Alchemy-debug-setup.mk
ifneq ("$(wildcard $(TOP_DIR)/$(debug-setup-makefile))","")
  ifneq ("$(V)","0")
    $(info Including debug setup makefile)
  endif
  include $(TOP_DIR)/$(debug-setup-makefile)
endif

# Names of makefiles that can be included by user Makefiles
CLEAR_VARS := $(BUILD_SYSTEM)/clearvars.mk
BUILD_STATIC_LIBRARY := $(BUILD_SYSTEM)/static.mk
BUILD_SHARED_LIBRARY := $(BUILD_SYSTEM)/shared.mk
BUILD_EXECUTABLE := $(BUILD_SYSTEM)/executable.mk
BUILD_AUTOTOOLS := $(BUILD_SYSTEM)/autotools.mk
BUILD_CMAKE := $(BUILD_SYSTEM)/cmake.mk
BUILD_CUSTOM := $(BUILD_SYSTEM)/custom.mk
BUILD_META_PACKAGE := $(BUILD_SYSTEM)/custom.mk
BUILD_LINUX := $(BUILD_SYSTEM)/linux-kernel.mk
BUILD_PREBUILT := $(BUILD_SYSTEM)/prebuilt.mk

# Shall be defined before including user makefiles
AUTOCONF_MERGE_FILE := $(TARGET_OUT_BUILD)/autoconf-merge.h

###############################################################################
## Makefile scan and includes.
###############################################################################

# Target/os specific packages
include $(BUILD_SYSTEM)/toolchains/toolchains-packages.mk

# Makefile with the list of all makefiles available and include them
USER_MAKEFILE_NAME := atom.mk
USER_MAKEFILES_CACHE := $(TARGET_OUT_BUILD)/makefiles.mk
USER_MAKEFILES :=

# Command to find files
find-cmd := $(BUILD_SYSTEM)/scripts/findfiles.py \
	--prune=.git --prune=.repo \
	--prune=$(TARGET_OUT) \
	--prune=$(TARGET_OUT_BUILD) \
	--prune=$(TARGET_OUT_STAGING) \
	--prune=$(TARGET_OUT_FINAL) \
	--prune=$(BUILD_SYSTEM) \
	$(foreach __d,$(TARGET_SCAN_PRUNE_DIRS),--prune=$(__d)) \
	$(foreach __d,$(TARGET_SCAN_ADD_DIRS),--add=$(__d)) \
	$(foreach __d,$(TARGET_SDK_DIRS),--prune=$(__d)) \
	$(if $(call streq,$(TARGET_SCAN_FOLLOW_LINKS),1),--follow-links) \
	$(TOP_DIR) \
	$(USER_MAKEFILE_NAME)

# Summary of what we found
display-user-makefiles-summary = \
	$(if $(call strneq,$(V),0), \
		$(foreach __f,$(USER_MAKEFILES),$(info $(__f))) \
	) \
	$(info Found $(words $(USER_MAKEFILES)) makefiles)

# Create a file that will contain all user makefiles available
# Make sure that atom.mk from sdk are included first so they can be overriden
create-user-makefiles-cache = \
	rm -f $(USER_MAKEFILES_CACHE); \
	mkdir -p $(dir $(USER_MAKEFILES_CACHE)); \
	touch $(USER_MAKEFILES_CACHE); \
	( \
		files="$(addsuffix /$(USER_MAKEFILE_NAME),$(TARGET_SDK_DIRS))"; \
		for f in $$files `$(find-cmd)`; do \
			echo "USER_MAKEFILES += $$f"; \
			echo "\$$(call user-makefile-before-include,$$f)"; \
			echo "include $$f"; \
			echo "\$$(call user-makefile-after-include,$$f)"; \
		done \
	) >> $(USER_MAKEFILES_CACHE);

# Determine if we need to re-create the cache
do-create-cache := 0
ifeq ("$(USE_SCAN_CACHE)","0")
  do-create-cache := 1
else ifneq ("$(call is-targets-in-make-goals,scan)","")
  do-create-cache := 1
else
  $(warning Using scan cache, some atom.mk might be missing...)
endif

ifneq ("$(do-create-cache)","0")

# Force regeneration of cache and include scanned files
# Assignation to dummy variable is to ignore any output of shell command
dummy := $(shell $(create-user-makefiles-cache))
include $(USER_MAKEFILES_CACHE)
$(call display-user-makefiles-summary)

else

# Force not checking config if cache is not present. This is to avoid some
# warnings due to the fact that no module could be registered. Another parsing
# of Alchemy will anyway be triggered after generation of the cache.
ifeq ("$(wildcard $(USER_MAKEFILES_CACHE))","")
  CONFIG_DIR_AVAILABLE := 0
endif

# Include makefile containing all available makefiles
# If it does not exists, it will trigger its creation
ifeq ("$(call is-targets-in-make-goals,scan clobber)","")
  -include $(USER_MAKEFILES_CACHE)
  $(call display-user-makefiles-summary)
endif

endif

# Rule that will trigger creation of list of makefiles when needed
$(USER_MAKEFILES_CACHE):
	@$(create-user-makefiles-cache)

# Rule to force creation of list of makefiles
# This doesn't do a a lot, everything is done above. Scan in make goals
# triggers the creation of the cache of makefiles
.PHONY: scan
scan:
	@echo "Scan done"

###############################################################################
## pbuild-hook management.
###############################################################################

include $(BUILD_SYSTEM)/pbuild-hook/pbuild-hook.mk

###############################################################################
## Module dependencies generation.
###############################################################################

# Now that all modules have been registered, sort the variable
__modules := $(sort $(__modules))

# Recompute all dependencies between modules
$(call modules-compute-depends)

# Check dependencies and variables of modules
ifeq ("$(SKIP_DEPS_AND_CHECKS)","0")
  $(call modules-check-depends)
  $(call modules-check-variables)
endif

# Compute revision of all modules
ifneq ("$(USE_GIT_REV)","0")
  $(call module-compute-revisions)
endif

# All modules
ALL_MODULES := $(__modules)

# All modules to actually build (without host modules)
ALL_BUILD_MODULES := $(strip \
	$(foreach __mod,$(ALL_MODULES), \
		$(if $(call is-module-host,$(__mod)),$(empty), \
			$(if $(call is-module-in-build-config,$(__mod)),$(__mod)) \
		) \
	))

# All host modules to actually build (based on built modules)
ALL_BUILD_MODULES_HOST := $(call modules-get-required-host,$(ALL_BUILD_MODULES))

# Generate files with module list
$(shell mkdir -p $(TARGET_OUT_BUILD))
$(shell echo "$(ALL_MODULES)" > $(TARGET_OUT_BUILD)/modules)
$(shell echo "$(ALL_BUILD_MODULES)" > $(TARGET_OUT_BUILD)/build-modules)

###############################################################################
## Module rules generation.
###############################################################################

# Configuration rules (once module database is built)
include $(BUILD_SYSTEM)/config-rules.mk

# Now, really generate rules for modules.

# Completely skip this for simple queries or clobber.
ifeq ("$(call is-targets-in-make-goals,$(__query-targets) clobber)","")

# Check that, if a registered module is specified in goals,
# it is in the build config
$(foreach __mod,$(ALL_MODULES), \
	$(if $(call is-module-in-make-goals,$(__mod)), \
		$(if $(call is-module-host,$(__mod)), \
			$(if $(call is-not-item-in-list,$(__mod),$(ALL_BUILD_MODULES_HOST)), \
				$(eval ALL_BUILD_MODULES_HOST += $(__mod)) \
			), \
			$(if $(call is-not-item-in-list,$(__mod),$(ALL_BUILD_MODULES)), \
				$(warning $(__mod) is not enabled in the config) \
				$(eval ALL_BUILD_MODULES += $(__mod) \
					$(call module-get-all-depends,$(__mod)) \
				) \
			) \
		) \
	) \
)

ifneq ("$(V)","0")
  $(info Generating rules: start)
endif

# Determine the list of modules to really include
# If a module is specified in goals, only include this one and its dependencies.
# If 'all' is also given do not do the filter
__dofilter := 0
__modlist := $(empty)
ifeq ("$(call is-targets-in-make-goals,all)","")
$(foreach __mod,$(ALL_BUILD_MODULES) $(ALL_BUILD_MODULES_HOST), \
	$(if $(call is-module-in-make-goals,$(__mod)), \
		$(eval __dofilter := 1) \
		$(eval __modlist += $(__mod) $(call module-get-all-depends,$(__mod))) \
	) \
)
endif

# Update module list, based on filtering
ifeq ("$(__dofilter)","0")
  __modlist := $(ALL_BUILD_MODULES) $(ALL_BUILD_MODULES_HOST)
endif

# Add required host modules
# Sorting will ensure they appear only once as well
__modlist += $(call modules-get-required-host,$(__modlist))
__modlist := $(sort $(__modlist))

# Now, generate rules of selected modules
$(foreach __mod,$(__modlist), \
	$(eval LOCAL_MODULE := $(__mod)) \
	$(eval include $(BUILD_SYSTEM)/module.mk) \
)

ifneq ("$(V)","0")
  $(info Generating rules: done)
endif

endif

# Once all module rules have been generated, make sure nobody will reference
# LOCAL_XXX variables anymore.
# In commands, PRIVATE_XXX variables shall be used.
$(foreach __var,$(vars-LOCAL) $(macros-LOCAL), \
	$(eval override LOCAL_$(__var) = \
		$$(error Do NOT use LOCAL_$(__var) in commands)) \
)

###############################################################################
## Rule to merge autoconf.h files.
###############################################################################

# List of all available autoconf.h files
__autoconf-list := $(strip \
	$(foreach __mod,$(ALL_BUILD_MODULES), \
		$(call module-get-autoconf,$(__mod)) \
	))

# Concatenate all in one
$(AUTOCONF_MERGE_FILE): $(__autoconf-list)
	@echo "Generating autoconf-merge.h"
	@mkdir -p $(dir $@)
	@rm -f $@
	@touch $@
	@for f in $^; do cat $$f >> $@; done

###############################################################################
## Main rules.
###############################################################################

.PHONY: all
all: $(ALL_BUILD_MODULES) $(ALL_BUILD_MODULES_HOST)
	@echo "Done building all"

.PHONY: clean
clean: $(foreach __mod,$(ALL_BUILD_MODULES),$(__mod)-clean)
	$(Q)rm -f $(AUTOCONF_MERGE_FILE)
	$(Q)rm -f $(USER_MAKEFILES_CACHE)
	@echo "Done cleaning"

.PHONY: dirclean
dirclean: $(foreach __mod,$(ALL_BUILD_MODULES),$(__mod)-dirclean)
	$(Q)rm -f $(AUTOCONF_MERGE_FILE)
	$(Q)rm -f $(USER_MAKEFILES_CACHE)
	@echo "Done cleaning directories"

.PHONY: clobber
clobber:
	@echo "Deleting build directory..."
	$(Q)rm -rf $(TARGET_OUT_BUILD)
	@echo "Deleting staging directory..."
	$(Q)rm -rf $(TARGET_OUT_STAGING)
	@echo "Deleting build-host directory..."
	$(Q)rm -rf $(HOST_OUT_BUILD)
	@echo "Deleting staging-host directory..."
	$(Q)rm -rf $(HOST_OUT_STAGING)
ifneq ("$(TARGET_OS_FLAVOUR)","native-chroot")
ifneq ("$(TARGET_OS_FLAVOUR)","native")
	@echo "Deleting final directory..."
	$(Q)rm -rf $(TARGET_OUT_FINAL)
endif
endif
	@echo "Done deleting directories..."

# Dummy target to check internal variables
.PHONY: check
check:

# Dump internal database
include $(BUILD_SYSTEM)/dump-database.mk

# Graph of build dependencies
include $(BUILD_SYSTEM)/build-graph.mk

# Final tree generation
include $(BUILD_SYSTEM)/final.mk

# Image generation
include $(BUILD_SYSTEM)/image.mk

# Gdb helpers
include $(BUILD_SYSTEM)/gdb.mk

# Sdk helpers
include $(BUILD_SYSTEM)/sdk.mk

# Sdk helpers
include $(BUILD_SYSTEM)/properties.mk

# Help
include $(BUILD_SYSTEM)/help.mk

###############################################################################
## Under native linux target, copy wrapper scripts
###############################################################################

ifeq ("$(TARGET_OS)","linux")

NATIVE_WRAPPER_SCRIPT :=
NATIVE_CHROOT_WRAPPER_SCRIPT :=

ifeq ("$(TARGET_OS_FLAVOUR)","native")
  NATIVE_WRAPPER_SCRIPT := native-wrapper.sh
endif

ifeq ("$(TARGET_OS_FLAVOUR)","native-chroot")
  NATIVE_WRAPPER_SCRIPT := native-wrapper.sh
  NATIVE_CHROOT_WRAPPER_SCRIPT := native-chroot-wrapper.sh
endif

ifneq ("$(NATIVE_WRAPPER_SCRIPT)","")

$(eval $(call copy-one-file, \
	$(BUILD_SYSTEM)/scripts/$(NATIVE_WRAPPER_SCRIPT), \
	$(TARGET_OUT_STAGING)/$(NATIVE_WRAPPER_SCRIPT)))

$(ALL_BUILD_MODULES): $(TARGET_OUT_STAGING)/$(NATIVE_WRAPPER_SCRIPT)

endif

ifneq ("$(NATIVE_CHROOT_WRAPPER_SCRIPT)","")

$(eval $(call copy-one-file, \
	$(BUILD_SYSTEM)/scripts/$(NATIVE_CHROOT_WRAPPER_SCRIPT), \
	$(TARGET_OUT_STAGING)/$(NATIVE_CHROOT_WRAPPER_SCRIPT)))

$(ALL_BUILD_MODULES): $(TARGET_OUT_STAGING)/$(NATIVE_CHROOT_WRAPPER_SCRIPT)

endif

endif
