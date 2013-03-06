###############################################################################
## @file autotools-rules.mk
## @author Y.M. Morgan
## @date 2012/07/13
##
## Build a module using autotools.
###############################################################################

# Name of files indicating steps done
unpacked_file := $(build_dir)/$(LOCAL_MODULE).unpacked
configured_file := $(build_dir)/$(LOCAL_MODULE).configured
built_file := $(build_dir)/$(LOCAL_MODULE).built
installed_file := $(build_dir)/$(LOCAL_MODULE).installed

# Archive file (optional)
ifneq ("$(strip $(LOCAL_AUTOTOOLS_ARCHIVE))","")
  archive_file := $(LOCAL_PATH)/$(LOCAL_AUTOTOOLS_ARCHIVE)
else
  archive_file :=
endif

# Where to unpack
unpack_dir := $(build_dir)

# Where the source will actually be found once unpacked
ifneq ("$(archive_file)","")
  src_dir := $(unpack_dir)/$(LOCAL_AUTOTOOLS_SUBDIR)
else
  src_dir := $(LOCAL_PATH)
endif

# Patches to apply
patches := $(strip $(LOCAL_AUTOTOOLS_PATCHES))

# Where the package will be configured and built
ifneq ("$(archive_file)","")
  obj_dir := $(src_dir)
else
  obj_dir := $(build_dir)/obj
endif

# Delete some additionnal 'done' files if a skip of external checks is not done
ifeq ("$(skip_ext_checks)","0")
$(call delete-one-done-file,$(built_file))
$(call delete-one-done-file,$(installed_file))
endif

# Dependencies for reconfiguration
# Note: if configure file is in an archive the wildcard test will fail the
# first time, but it is not a problem. The important thing is to detect by
# ourself that the configure file is newer to make sure we apply all patches.
ifneq ("$(wildcard $(src_dir)/configure)","")
  configure_file := $(src_dir)/configure
else
  configure_file := $(empty)
endif

###############################################################################
## Configure argument sanitization.
###############################################################################

# This file is included several times, define macros only once
# (mainly to improve perf)
ifndef autotools-macros

# List of flag to check for their actual support by configure script
configure-flags := \
	--disable-maintainer-mode \
	--enable-silent-rules

# Check if a flag is supported by configure script. This is to avoid warning
# $1 : full path to configure script to check
# $2 : flag to check
configure-check-flag = $(strip \
	$(if $(shell grep -e "$(strip $2)" "$(strip $1)"),$(true),$(false)))

# Get the list of flags to filter out of configure arguments
# $1 : full path to configure script to check
configure-getfilter-args = $(strip \
	$(foreach __flag,$(configure-flags), \
		$(if $(call configure-check-flag,$1,$(__flag)), \
			$(empty),$(__flag) \
		) \
	))

# Remove flags not supported by configure
# $1 : full path to configure script to check
# $2 : configure arguments
configure-filter-args = $(strip \
	$(filter-out $(call configure-getfilter-args,$1),$2))

endif

###############################################################################
## Add debug flags.
###############################################################################

debug_CFLAGS := $(call module-get-debug-flags,$(LOCAL_MODULE),CFLAGS)
debug_CXXFLAGS := $(call module-get-debug-flags,$(LOCAL_MODULE),CXXFLAGS)
debug_LDFLAGS := $(call module-get-debug-flags,$(LOCAL_MODULE),LDFLAGS)

# Add CFLAGS to CXXFLAGS as well
ifneq ("$(debug_CFLAGS)","")
  $(info Debug: Adding '$(debug_CFLAGS)' to '$(LOCAL_MODULE)' CFLAGS and CXXFLAGS)
  LOCAL_AUTOTOOLS_CONFIGURE_ENV += CFLAGS="$$CFLAGS $(debug_CFLAGS)"
  LOCAL_AUTOTOOLS_CONFIGURE_ENV += CXXFLAGS="$$CXXFLAGS $(debug_CFLAGS)"
endif

ifneq ("$(debug_CXXFLAGS)","")
  $(info Debug: Adding '$(debug_CXXFLAGS)' to '$(LOCAL_MODULE)' CXXFLAGS)
  LOCAL_AUTOTOOLS_CONFIGURE_ENV += CXXFLAGS="$$CXXFLAGS $(debug_CFLAGS)"
endif

ifneq ("$(debug_LDFLAGS)","")
  $(info Debug: Adding '$(debug_LDFLAGS)' to '$(LOCAL_MODULE)' LDFLAGS)
  LOCAL_AUTOTOOLS_CONFIGURE_ENV += LDFLAGS="$$LDFLAGS $(debug_LDFLAGS)"
  LOCAL_AUTOTOOLS_CONFIGURE_ENV += DYN_LDFLAGS="$$DYN_LDFLAGS $(debug_LDFLAGS)"
endif

###############################################################################
## Default commands
###############################################################################

# This file is included several times, define macros only once
# (mainly to improve perf)
ifndef autotools-macros

define __default-unpack
	$(Q) tar -C $(PRIVATE_UNPACK_DIR) -xf $(PRIVATE_ARCHIVE)
endef

define __default-configure
	$(Q) cd $(PRIVATE_OBJ_DIR) && \
		$(AUTOTOOLS_CONFIGURE_ENV) $(PRIVATE_CONFIGURE_ENV) \
		$(PRIVATE_SRC_DIR)/configure \
		$(call configure-filter-args, \
			$(PRIVATE_SRC_DIR)/configure,$(AUTOTOOLS_CONFIGURE_ARGS)) \
		$(PRIVATE_CONFIGURE_ARGS)
endef

define __default-make-build
	$(Q) $(AUTOTOOLS_MAKE_ENV) $(PRIVATE_MAKE_BUILD_ENV) \
		$(MAKE) -C $(PRIVATE_OBJ_DIR) \
		$(AUTOTOOLS_MAKE_ARGS) $(PRIVATE_MAKE_BUILD_ARGS)
endef

define __default-make-install
	$(Q) $(AUTOTOOLS_MAKE_ENV) $(PRIVATE_MAKE_INSTALL_ENV) \
		$(MAKE) -C $(PRIVATE_OBJ_DIR) \
		$(AUTOTOOLS_MAKE_ARGS) $(PRIVATE_MAKE_INSTALL_ARGS) install
endef

# Force success for command in case "uninstall" or "clean" is not supported
# or Makefile not present
define __default-clean
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

define __apply-patches
	$(Q) $(BUILD_SYSTEM)/scripts/apply-patches.sh \
		$(PRIVATE_SRC_DIR) $(PRIVATE_PATH) $(PRIVATE_PATCHES)
endef

# Patch libtool to make it work properly for cross-compilation.
# Modify the libdir in .la files installed in staging dir so that they reference
# the staging dir and not the final dir. Do this only if dest dir is not empty
# (in native build staging dir is the final dir specified in configure script).
# Use -rpath-link instead of -rpath to avoid hardcoding host path in binaries.
# See this link for more information :
# http://www.metastatic.org/text/libtool.html
define __libtool_patch
	$(Q) for f in `find $(PRIVATE_OBJ_DIR) -name libtool -o -name ltmain.sh`; do \
		echo "Patching $$f"; \
		$(if $(AUTOTOOLS_INSTALL_DESTDIR), \
			sed -i -e "s|^libdir='\$$install_libdir'|libdir='\$${install_libdir:\+$(TARGET_OUT_STAGING)\$$install_libdir}'|1" $$f; \
		) \
		sed -i -e "s|{wl}-rpath|{wl}-rpath-link|1" $$f; \
		sed -i -e "s|{wl}--rpath|{wl}-rpath-link|1" $$f; \
	done
endef

# Display a message
# $1 : message
__autotools-msg = \
	$(call print-banner2,Autotools,$(PRIVATE_MODULE),$1)

endif

###############################################################################
## Rules.
## Note : use '+' to make sure sub-make is properly managed, this avoid:
## warning: jobserver unavailable: using -j1.  Add `+' to parent make rule.
###############################################################################

# Make sure all prerequisites files are generated first
# But do NOT force recompilation (order only)
$(unpacked_file): | $(all_prerequisites)

# Unpack + patch
$(unpacked_file): $(archive_file) $(addprefix $(LOCAL_PATH)/,$(patches))
ifneq ("$(archive_file)","")
	$(call __autotools-msg,Unpacking $(call path-from-top,$<))
	@mkdir -p $(PRIVATE_UNPACK_DIR)
	+$(call macro-exec-cmd,AUTOTOOLS_CMD_UNPACK,__default-unpack)
	+$(if $(PRIVATE_PATCHES),$(__apply-patches))
endif
	+$(call macro-exec-cmd,AUTOTOOLS_CMD_POST_UNPACK)
	@mkdir -p $(dir $@)
	@touch $@

# Configuration
$(configured_file): $(unpacked_file) $(configure_file)
	$(call __autotools-msg,Configuring)
	@mkdir -p $(PRIVATE_OBJ_DIR)
	+$(call macro-exec-cmd,AUTOTOOLS_CMD_CONFIGURE,__default-configure)
	+$(call macro-exec-cmd,AUTOTOOLS_CMD_POST_CONFIGURE)
	+$(__libtool_patch)
	@mkdir -p $(dir $@)
	@touch $@

# Build
$(built_file): $(configured_file)
	$(call __autotools-msg,Building)
	@mkdir -p $(PRIVATE_OBJ_DIR)
	+$(call macro-exec-cmd,AUTOTOOLS_CMD_BUILD,__default-make-build)
	+$(call macro-exec-cmd,AUTOTOOLS_CMD_POST_BUILD)
	@mkdir -p $(dir $@)
	@touch $@

# Installation
$(installed_file): $(built_file)
	$(call __autotools-msg,Installing)
	+$(call macro-exec-cmd,AUTOTOOLS_CMD_INSTALL,__default-make-install)
	+$(call macro-exec-cmd,AUTOTOOLS_CMD_POST_INSTALL)
	@mkdir -p $(dir $@)
	@touch $@

# Done
$(LOCAL_BUILD_MODULE): $(installed_file)
	@mkdir -p $(dir $@)
	@touch $@

# Clean targets additional commands
# Simulate that some files are up to date to avoid internal reconfiguration
# that will likely fail because env or libtool patches are not correct
$(LOCAL_MODULE)-clean:
	$(Q) if [ -d $(PRIVATE_OBJ_DIR) ]; then find $(PRIVATE_OBJ_DIR) -name config.status -exec touch {} \; ; fi
	$(Q) if [ -d $(PRIVATE_OBJ_DIR) ]; then find $(PRIVATE_OBJ_DIR) -name Makefile -exec touch {} \; ; fi
	+$(call macro-exec-cmd,AUTOTOOLS_CMD_CLEAN,__default-clean)
	+$(call macro-exec-cmd,AUTOTOOLS_CMD_POST_CLEAN)

###############################################################################
## Rule-specific variable definitions.
###############################################################################

# clean targets additional variables
# To NOT put build dir in PRIVATE_CLEAN_DIRS
# we need to call some makefiles during our custom clean
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(installed_file)
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(built_file)

# We don't create target-specific variables for macros because it does not
# work when created with 'define ... endef'. They will be accessed directly
# from module database
$(LOCAL_TARGETS): PRIVATE_ARCHIVE := $(archive_file)
$(LOCAL_TARGETS): PRIVATE_UNPACK_DIR := $(unpack_dir)
$(LOCAL_TARGETS): PRIVATE_SRC_DIR := $(src_dir)
$(LOCAL_TARGETS): PRIVATE_OBJ_DIR := $(obj_dir)
$(LOCAL_TARGETS): PRIVATE_PATCHES := $(patches)
$(LOCAL_TARGETS): PRIVATE_CONFIGURE_ENV := $(LOCAL_AUTOTOOLS_CONFIGURE_ENV)
$(LOCAL_TARGETS): PRIVATE_CONFIGURE_ARGS := $(LOCAL_AUTOTOOLS_CONFIGURE_ARGS)
$(LOCAL_TARGETS): PRIVATE_MAKE_BUILD_ENV := $(LOCAL_AUTOTOOLS_MAKE_BUILD_ENV)
$(LOCAL_TARGETS): PRIVATE_MAKE_BUILD_ARGS := $(LOCAL_AUTOTOOLS_MAKE_BUILD_ARGS)
$(LOCAL_TARGETS): PRIVATE_MAKE_INSTALL_ENV := $(LOCAL_AUTOTOOLS_MAKE_INSTALL_ENV)
$(LOCAL_TARGETS): PRIVATE_MAKE_INSTALL_ARGS := $(LOCAL_AUTOTOOLS_MAKE_INSTALL_ARGS)

# Macros of this file have been defined
autotools-macros := 1
