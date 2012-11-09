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

# Quiet command if V is 0
ifeq ("$(V)","0")
  Q := @
  MAKEFLAGS += --no-print-directory
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

# Get full path.
# $1 : path to extend.
fullpath = $(strip $(shell readlink -m -n $1))

# Figure out where we are
# It returns the full path without trailing '/'
my-dir = $(call fullpath,$(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST)))))

###############################################################################
## Build system setup.
###############################################################################

# Directories (full path)
TOP_DIR := $(shell pwd)
BUILD_SYSTEM := $(call my-dir)

# Set this variable to 1 to skip a lot of things like dependencies check and
# config check. Useful if user only want some internal query or configure
# something.
SKIP_DEPS_AND_CHECKS := 0

# Set this variable to 1 to skip deps and checks of external modules built
# outside this build system (basically it force remaking them by removing
# their .done file).
SKIP_EXT_DEPS_AND_CHECKS := 0

# Setup configuration
include $(BUILD_SYSTEM)/setup.mk

# Setup macros definitions
include $(BUILD_SYSTEM)/defs.mk

###############################################################################
# Optimizations for some goals.
###############################################################################

# Skip external checks if requested
ifeq ("$(TARGET_FORCE_EXTERNAL_CHECKS)","0")
  SKIP_EXT_DEPS_AND_CHECKS := 1
endif

# Skip some steps for some make goals
__clean-targets := clean dirclean clobber
__query-targets := scan help help-modules dump dump-depends build-graph
__config-targets := config xconfig menuconfig nconfig
__fs-targets := final final-nostrip plf
__skip_targets := $(__clean-targets) $(__query-targets) $(__config-targets) $(__fs-targets)
ifneq ("$(call is-targets-in-make-goals,$(__skip_targets))","")
  SKIP_DEPS_AND_CHECKS := 1
endif
ifneq ("$(findstring clean-,$(MAKECMDGOALS))","")
  SKIP_DEPS_AND_CHECKS := 1
endif
ifneq ("$(findstring dirclean-,$(MAKECMDGOALS))","")
  SKIP_DEPS_AND_CHECKS := 1
endif
ifneq ("$(findstring config-,$(MAKECMDGOALS))","")
  SKIP_DEPS_AND_CHECKS := 1
endif

# No reason to do external checks if we are skipping our own deps and checks...
ifneq ("$(SKIP_DEPS_AND_CHECKS)","0")
  SKIP_EXT_DEPS_AND_CHECKS := 1
endif

###############################################################################
## Setup part2 (may use optimization flags from above).
###############################################################################

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
## Display configuration.
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
include $(BUILD_SYSTEM)/toolchains/toolchains-packages.mk

# Makefile with the list of all makefiles available and include them
USER_MAKEFILE_NAME := atom.mk
USER_MAKEFILES_CACHE := $(TARGET_OUT_BUILD)/makefiles.mk
USER_MAKEFILES :=

# Command to find files
find-cmd = $(BUILD_SYSTEM)/scripts/findfiles.py \
	--prune=.git --prune=.repo --prune=$(TARGET_OUT) \
	$(foreach __d,$(TARGET_SCAN_PRUNE_DIRS),--prune=$(__d)) \
	$(TOP_DIR) \
	$(USER_MAKEFILE_NAME)

# Create a file that will contain all user makefiles available
# Redirect everything to stderr so we can use it in a $(shell ...) below
define create-user-makefiles-cache
	( \
		rm -f $(USER_MAKEFILES_CACHE); \
		mkdir -p $$(dirname $(USER_MAKEFILES_CACHE)); \
		touch $(USER_MAKEFILES_CACHE); \
		echo "Scanning $(TOP_DIR) for makefiles..."; \
		for f in `$(find-cmd)`; do \
			echo "USER_MAKEFILES += $$f" >> $(USER_MAKEFILES_CACHE); \
			echo "include $$f" >> $(USER_MAKEFILES_CACHE); \
		done; \
	) >&2;
endef

ifneq ("$(USE_SCAN_CACHE)","1")

# Force regeneration of cache and include scanned files
$(shell $(create-user-makefiles-cache))
include $(USER_MAKEFILES_CACHE)

else

# Force not checking config if cache is not present. This is to avoid some
# warnings due to the fact that no module could be registered
# Another parsing of Alchemy will anyway be triggered after generation of the cache
ifeq ("$(wildcard $(USER_MAKEFILES_CACHE))","")
  CONFIG_DIR_AVAILABLE := 0
endif

# Include makefile containing all available makefiles
# If it does not exists, it will trigger its creation
ifeq ("$(call is-targets-in-make-goals,scan clobber)","")
  -include $(USER_MAKEFILES_CACHE)
endif

endif

# Summary of what we found
ifneq ("$(V)","0")
$(foreach __f,$(USER_MAKEFILES),$(info $(__f)))
endif
$(info Found $(words $(USER_MAKEFILES)) makefiles)

# Rule that will trigger creation of list of makefiles when needed
$(USER_MAKEFILES_CACHE):
	@$(create-user-makefiles-cache)

# Rule to force creation of list of makefiles
.PHONY: scan
scan:
	@$(create-user-makefiles-file)

###############################################################################
## Module dependencies generation.
###############################################################################

# All modules
ALL_MODULES := \
	$(foreach __mod,$(sort $(__modules)),$(__mod))

# All modules to actually build
ALL_BUILD_MODULES := \
	$(foreach __mod,$(sort $(__modules)), \
		$(if $(call is-module-in-build-config,$(__mod)),$(__mod)))

# Recompute all dependencies between modules
$(call modules-compute-depends)

# Check dependencies and variables of modules
ifeq ("$(SKIP_DEPS_AND_CHECKS)","0")
  $(call modules-check-depends)
  $(call modules-check-variables)
endif

###############################################################################
## Module rules generation.
###############################################################################

# Configuration rules (once module database is built)
include $(BUILD_SYSTEM)/config-rules.mk

# Now, really generate rules for modules.

# Completely skip this for simple queries or clobber.
# If a module is specified in goals, only include this one and its dependencies.
ifeq ("$(call is-targets-in-make-goals,$(__query-targets) clobber)","")

ifneq ("$(V)","0")
  $(info Generating rules: start)
endif

# Determine the list of modules to really include
__dofilter := 0
__modlist := $(empty)
$(foreach __mod,$(ALL_BUILD_MODULES), \
	$(if $(call is-module-in-make-goals,$(__mod)), \
		$(eval __dofilter := 1) \
		$(eval __modlist += $(__mod) $(call module-get-all-depends,$(__mod))) \
	) \
)

# Update module list, based on filtering, make sure items are only once in the list
ifeq ("$(__dofilter)","0")
  __modlist := $(ALL_BUILD_MODULES)
else
  __modlist := $(call uniq2,$(__modlist))
endif

# Now, generate rules of selected modules
$(foreach __mod,$(__modlist), \
	$(eval LOCAL_MODULE := $(__mod)) \
	$(eval include $(BUILD_SYSTEM)/module.mk) \
)

ifneq ("$(V)","0")
  $(info Generating rules: done)
endif

endif

# Once all modules have been parsed, make sure nobody will reference LOCAL_XXX
# variables anymore. In commands, PRIVATE_XXX variables shall be used.
$(foreach __var,$(modules-LOCALS), \
	$(eval override LOCAL_$(__var) = $$(error Do NOT use LOCAL_$(__var) in commands)) \
)

###############################################################################
## Rule to merge autoconf.h files.
###############################################################################

# List of all available autoconf.h files
__autoconf-list := $(strip \
	$(foreach __mod,$(sort $(ALL_BUILD_MODULES)), \
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
all: $(ALL_BUILD_MODULES)
	@echo "Done building all"

.PHONY: clean
clean: $(foreach __mod,$(ALL_BUILD_MODULES),clean-$(__mod))
	@rm -f $(AUTOCONF_MERGE_FILE)
	@rm -f $(USER_MAKEFILES_CACHE)
	@echo "Done cleaning"

.PHONY: dirclean
dirclean: $(foreach __mod,$(ALL_BUILD_MODULES),dirclean-$(__mod))
	@rm -f $(AUTOCONF_MERGE_FILE)
	@rm -f $(USER_MAKEFILES_CACHE)
	@echo "Done cleaning directories"

.PHONY: clobber
clobber:
	@echo "Deleting build, staging and final directories..."
	@rm -rf $(TARGET_OUT_BUILD)
	@rm -rf $(TARGET_OUT_STAGING)
	@rm -rf $(TARGET_OUT_FINAL)

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

# Final tree generation
include $(BUILD_SYSTEM)/final.mk

# Plf generation
include $(BUILD_SYSTEM)/plf.mk

###############################################################################
## Help rule.
###############################################################################
.PHONY: help
help:
	@echo "Main targets:"
	@echo "  all     : build everything."
	@echo "  clean   : clean all modules."
	@echo "  dirclean: clean all modules and delete build directories".
	@echo "  clobber : delete output directory (build, staging, final)."
	@echo "  scan    : force a rescan of workspace in case the makefile cache is used."
	@echo "  final   : generate the final tree from the staging directory."
	@echo ""
	@echo "Module targets:"
	@echo "  <module>         : build specified module."
	@echo "  clean-<module>   : clean specified module."
	@echo "  dirclean-<module>: clean specified module and delete its build directory."
	@echo ""
	@echo "Main configuration targets:"
	@echo "  config       : configure the build as well as modules."
	@echo "  config-check : check all config files."
	@echo "  config-update: update all config files with new options."
	@echo ""
	@echo "Module configuration targets:"
	@echo "  config-<module>       : configure the specified module."
	@echo "  config-check-<module> : check the specified module config file."
	@echo "  config-update-<module>: update the specified module config file new options."
	@echo ""
	@echo "Other available frontends for configuration:"
	@echo "  xconfig   : use qconf (Qt), default."
	@echo "  menuconfig: use mconf (ncurses)."
	@echo "  nconf     : use nconf (ncurses, basic)."
	@echo ""
	@echo "Other targets:"
	@echo "  help        : display this help message."
	@echo "  help-modules: display the list of registered modules."
	@echo "  dump        : dump the full module database."
	@echo "  dump-depends: dump dependencies of module database."
	@echo "  build-graph : create a graph of build dependencies."
	@echo ""
	@echo "Usefull variables:"
	@echo "  V: set to 1 to activate verbose mode."
	@echo "  F: set to 1 to activate force mode (modules built externally will be re-checked)."
	@echo "  W: set to 1 to activate more compilation warnings."

.PHONY: help-modules
help-modules:
	@echo "List of registered modules:"
	@echo "$(sort $(__modules))"

###############################################################################
## Under native linux target, copy wrapper scripts
###############################################################################

ifeq ("$(TARGET_OS)","linux")
ifeq ("$(TARGET_OS_FLAVOUR)","native")

NATIVE_WRAPPER_SCRIPT := native-wrapper.sh

$(eval $(call copy-one-file, \
	$(BUILD_SYSTEM)/scripts/$(NATIVE_WRAPPER_SCRIPT), \
	$(TARGET_OUT_STAGING)/$(NATIVE_WRAPPER_SCRIPT)))
$(eval $(call copy-one-file, \
	$(BUILD_SYSTEM)/scripts/$(NATIVE_WRAPPER_SCRIPT), \
	$(TARGET_OUT_FINAL)/$(NATIVE_WRAPPER_SCRIPT)))

all: $(TARGET_OUT_STAGING)/$(NATIVE_WRAPPER_SCRIPT)
final: $(TARGET_OUT_FINAL)/$(NATIVE_WRAPPER_SCRIPT)
final-nostrip: $(TARGET_OUT_FINAL)/$(NATIVE_WRAPPER_SCRIPT)

endif
endif

