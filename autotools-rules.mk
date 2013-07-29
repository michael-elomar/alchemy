###############################################################################
## @file autotools-rules.mk
## @author Y.M. Morgan
## @date 2012/07/13
##
## Build a module using autotools.
###############################################################################

###############################################################################
## Configure argument sanitization.
###############################################################################

# This file is included several times, define macros only once
# (mainly to improve perf)
ifndef __autotools-macros

# List of flags to check for their actual support by configure script
__autotools-configure-flags := \
	--disable-maintainer-mode \
	--enable-silent-rules

# Check if a flag is supported by configure script. This is to avoid warning
# $1 : full path to configure script to check
# $2 : flag to check
__autotools-configure-check-flag = $(strip \
	$(if $(shell grep -e "$(strip $2)" "$(strip $1)"),$(true),$(false)))

# Get the list of flags to filter out of configure arguments
# $1 : full path to configure script to check
__autotools-configure-getfilter-args = $(strip \
	$(foreach __flag,$(__autotools-configure-flags), \
		$(if $(call __autotools-configure-check-flag,$1,$(__flag)), \
			$(empty),$(__flag) \
		) \
	))

# Remove flags not supported by configure
# $1 : full path to configure script to check
# $2 : configure arguments
__autotools-configure-filter-args = $(strip \
	$(filter-out $(call __autotools-configure-getfilter-args,$1),$2))

# Patch libtool to make it work properly for cross-compilation.
# Modify the libdir in .la files installed in staging dir so that they reference
# the staging dir and not the final dir. Do this only if dest dir is not empty
# (in native build staging dir is the final dir specified in configure script).
# Use -rpath-link instead of -rpath to avoid hardcoding host path in binaries.
# See this link for more information :
# http://www.metastatic.org/text/libtool.html
define __autotools-libtool_patch
	$(Q) for f in `find $(PRIVATE_OBJ_DIR) -name libtool -o -name ltmain.sh`; do \
		echo "Patching $$f"; \
		$(if $(AUTOTOOLS_INSTALL_DESTDIR), \
			sed -i -e "s|^libdir='\$$install_libdir'|libdir='\$${install_libdir:\+$(TARGET_OUT_STAGING)\$$install_libdir}'|1" $$f; \
		) \
		sed -i -e "s|{wl}-rpath|{wl}-rpath-link|1" $$f; \
		sed -i -e "s|{wl}--rpath|{wl}-rpath-link|1" $$f; \
	done
endef

# Simulate that some files are up to date to avoid internal reconfiguration
# that will likely fail because env or libtool patches are not correct
define __autotools-hook-pre-clean
	$(Q) if [ -d $(PRIVATE_OBJ_DIR) ]; then find $(PRIVATE_OBJ_DIR) -name config.status -exec touch {} \; ; fi
	$(Q) if [ -d $(PRIVATE_OBJ_DIR) ]; then find $(PRIVATE_OBJ_DIR) -name Makefile -exec touch {} \; ; fi
endef

endif # ifndef __autotools-macros

###############################################################################
## Add compilation/debug flags.
###############################################################################

# Compilation flags
__autotools-add_CFLAGS := $(LOCAL_CFLAGS) $(call normalize-c-includes,$(LOCAL_C_INCLUDES))
__autotools-add_CXXFLAGS := $(__autotools-add_CFLAGS) $(LOCAL_CXXFLAGS)
__autotools-add_LDFLAGS := $(LOCAL_LDFLAGS)

# Debug flags
__autotools-debug_CFLAGS := $(call module-get-debug-flags,$(LOCAL_MODULE),CFLAGS)
__autotools-debug_CXXFLAGS := $(call module-get-debug-flags,$(LOCAL_MODULE),CXXFLAGS)
__autotools-debug_LDFLAGS := $(call module-get-debug-flags,$(LOCAL_MODULE),LDFLAGS)

# Print debug messages
ifneq ("$(strip $(__autotools-debug_CFLAGS))","")
  $(info Debug: Adding '$(__autotools-debug_CFLAGS)' to '$(LOCAL_MODULE)' CFLAGS and CXXFLAGS)
  __autotools-add_CFLAGS += $(__autotools-debug_CFLAGS)
  __autotools-add_CXXFLAGS += $(__autotools-debug_CFLAGS)
endif

ifneq ("$(strip $(__autotools-debug_CXXFLAGS))","")
  $(info Debug: Adding '$(__autotools-debug_CXXFLAGS)' to '$(LOCAL_MODULE)' CXXFLAGS)
  __autotools-add_CXXFLAGS += $(__autotools-debug_CXXFLAGS)
endif

ifneq ("$(strip $(__autotools-debug_LDFLAGS))","")
  $(info Debug: Adding '$(__autotools-debug_LDFLAGS)' to '$(LOCAL_MODULE)' LDFLAGS)
  __autotools-add_LDFLAGS += $(__autotools-debug_LDFLAGS)
endif

# Add flags in environment
ifneq ("$(strip $(__autotools-add_CFLAGS))","")
  LOCAL_AUTOTOOLS_CONFIGURE_ENV += CFLAGS="$$CFLAGS $(__autotools-add_CFLAGS)"
  LOCAL_AUTOTOOLS_CONFIGURE_ENV += CPPFLAGS="$$CPPFLAGS $(__autotools-add_CFLAGS)"
endif

ifneq ("$(strip $(__autotools-add_CXXFLAGS))","")
  LOCAL_AUTOTOOLS_CONFIGURE_ENV += CXXFLAGS="$$CXXFLAGS $(__autotools-add_CXXFLAGS)"
endif

ifneq ("$(strip $(__autotools-add_LDFLAGS))","")
  LOCAL_AUTOTOOLS_CONFIGURE_ENV += LDFLAGS="$$LDFLAGS $(__autotools-add_LDFLAGS)"
  LOCAL_AUTOTOOLS_CONFIGURE_ENV += DYN_LDFLAGS="$$DYN_LDFLAGS $(__autotools-add_LDFLAGS)"
endif

###############################################################################
## Default commands
###############################################################################

# This file is included several times, define macros only once
# (mainly to improve perf)
ifndef __autotools-macros

define __autotools-default-cmd-configure
	$(Q) cd $(PRIVATE_OBJ_DIR) && \
		$(AUTOTOOLS_CONFIGURE_ENV) $(PRIVATE_CONFIGURE_ENV) \
		$(PRIVATE_SRC_DIR)/configure \
		$(call __autotools-configure-filter-args, \
			$(PRIVATE_SRC_DIR)/configure,$(AUTOTOOLS_CONFIGURE_ARGS)) \
		$(PRIVATE_CONFIGURE_ARGS)
endef

define __autotools-default-cmd-build
	$(Q) $(AUTOTOOLS_MAKE_ENV) $(PRIVATE_MAKE_BUILD_ENV) \
		$(MAKE) -C $(PRIVATE_OBJ_DIR) \
		$(AUTOTOOLS_MAKE_ARGS) $(PRIVATE_MAKE_BUILD_ARGS)
endef

define __autotools-default-cmd-install
	$(Q) $(AUTOTOOLS_MAKE_ENV) $(PRIVATE_MAKE_INSTALL_ENV) \
		$(MAKE) -C $(PRIVATE_OBJ_DIR) \
		$(AUTOTOOLS_MAKE_ARGS) $(PRIVATE_MAKE_INSTALL_ARGS) install
endef

# Force success for command in case "uninstall" or "clean" is not supported
# or Makefile not present
define __autotools-default-cmd-clean
	$(Q) if [ -f $(PRIVATE_OBJ_DIR)/Makefile ]; then \
		$(AUTOTOOLS_MAKE_ENV) $(PRIVATE_MAKE_INSTALL_ENV) \
			$(MAKE) --keep-going --ignore-errors -C $(PRIVATE_OBJ_DIR) \
			$(AUTOTOOLS_MAKE_ARGS) $(PRIVATE_MAKE_INSTALL_ARGS) \
			uninstall || echo "Ignoring uninstall errors"; \
		$(AUTOTOOLS_MAKE_ENV) $(PRIVATE_MAKE_INSTALL_ENV) \
			$(MAKE) --keep-going --ignore-errors -C $(PRIVATE_OBJ_DIR) \
			$(AUTOTOOLS_MAKE_ARGS) \
			clean || echo "Ignoring clean errors"; \
	fi;
endef

endif # ifndef __autotools-macros

###############################################################################
###############################################################################

# Because autootools is widely used for generic build to not try to support
# out ouf source build
generic-build-out-of-src := 0

include $(BUILD_SYSTEM)/generic-rules.mk

# Restart configuration step if configure file has changed
# Note: if configure file is in an archive the wildcard test will fail the
# first time, but it is not a problem. The important thing is to detect by
# ourself that the configure file is newer.
ifneq ("$(wildcard $(src_dir)/configure)","")
$(configured_file): $(src_dir)/configure
endif

# Setup commands
$(LOCAL_TARGETS): PRIVATE_MSG := Autotools
$(LOCAL_TARGETS): PRIVATE_CMD_PREFIX := AUTOTOOLS
$(LOCAL_TARGETS): PRIVATE_DEFAULT_CMD_CONFIGURE := __autotools-default-cmd-configure
$(LOCAL_TARGETS): PRIVATE_DEFAULT_CMD_BUILD := __autotools-default-cmd-build
$(LOCAL_TARGETS): PRIVATE_DEFAULT_CMD_INSTALL := __autotools-default-cmd-install
$(LOCAL_TARGETS): PRIVATE_DEFAULT_CMD_CLEAN := __autotools-default-cmd-clean

# Internal hooks to be applied before/after steps.
$(LOCAL_TARGETS): PRIVATE_HOOK_POST_CONFIGURE := __autotools-libtool_patch
$(LOCAL_TARGETS): PRIVATE_HOOK_PRE_CLEAN := __autotools-hook-pre-clean

# Variables needed by default commands
$(LOCAL_TARGETS): PRIVATE_CONFIGURE_ENV := $(LOCAL_AUTOTOOLS_CONFIGURE_ENV)
$(LOCAL_TARGETS): PRIVATE_CONFIGURE_ARGS := $(LOCAL_AUTOTOOLS_CONFIGURE_ARGS)
$(LOCAL_TARGETS): PRIVATE_MAKE_BUILD_ENV := $(LOCAL_AUTOTOOLS_MAKE_BUILD_ENV)
$(LOCAL_TARGETS): PRIVATE_MAKE_BUILD_ARGS := $(LOCAL_AUTOTOOLS_MAKE_BUILD_ARGS)
$(LOCAL_TARGETS): PRIVATE_MAKE_INSTALL_ENV := $(LOCAL_AUTOTOOLS_MAKE_INSTALL_ENV)
$(LOCAL_TARGETS): PRIVATE_MAKE_INSTALL_ARGS := $(LOCAL_AUTOTOOLS_MAKE_INSTALL_ARGS)

# Macros of this file have been defined
__autotools-macros := 1
