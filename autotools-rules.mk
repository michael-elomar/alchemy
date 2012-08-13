###############################################################################
## @file autotools-rules.mk
## @author Y.M. Morgan
## @date 2012/07/13
##
## Build a module using autotools.
###############################################################################

# Name of files indicating steps done
module_build_dir := $(call module-get-build-dir,$(LOCAL_MODULE))
unpacked_file := $(module_build_dir)/$(LOCAL_MODULE).unpacked
configured_file := $(module_build_dir)/$(LOCAL_MODULE).configured
built_file := $(module_build_dir)/$(LOCAL_MODULE).built
installed_file := $(module_build_dir)/$(LOCAL_MODULE).installed

# Archive file
archive_file := $(LOCAL_PATH)/$(LOCAL_AUTOTOOLS_ARCHIVE)

# Where to unpack
unpack_dir := $(module_build_dir)

# Where the source will actually be found once unpacked
src_dir := $(unpack_dir)/$(LOCAL_AUTOTOOLS_DIR)

# Patched to apply
patches := $(strip $(LOCAL_AUTOTOOLS_PATCHES))

###############################################################################
## Default commands
###############################################################################

__default-unpack = \
	tar -C $(PRIVATE_UNPACK_DIR) -xf $(PRIVATE_ARCHIVE)

__default-configure = \
	cd $(PRIVATE_SRC_DIR) && \
		$(AUTOTOOLS_CONFIGURE_ENV) $(PRIVATE_CONFIGURE_ENV) ./configure \
		$(AUTOTOOLS_CONFIGURE_ARGS) $(PRIVATE_CONFIGURE_ARGS)

# Note : use '+' to make sure sub-make is properly managed, this avoid the message :
# warning: jobserver unavailable: using -j1.  Add `+' to parent make rule.
__default-make-build = \
	+$(AUTOTOOLS_MAKE_ENV) $(PRIVATE_MAKE_BUILD_ENV) $(MAKE) -C $(PRIVATE_SRC_DIR) \
		$(AUTOTOOLS_MAKE_ARGS) $(PRIVATE_MAKE_BUILD_ARGS)

# Note : use '+' to make sure sub-make is properly managed, this avoid the message :
# warning: jobserver unavailable: using -j1.  Add `+' to parent make rule.
__default-make-install = \
	+$(AUTOTOOLS_MAKE_ENV) $(PRIVATE_MAKE_INSTALL_ENV) $(MAKE) -C $(PRIVATE_SRC_DIR) \
		$(AUTOTOOLS_MAKE_ARGS) $(PRIVATE_MAKE_INSTALL_ARGS) install

# Note force success for command in case "uninstall" is not supported or Makefile not present
__default-clean = \
	([ -d $(PRIVATE_SRC_DIR) ] && \
		$(AUTOTOOLS_MAKE_ENV) $(MAKE) -C $(PRIVATE_SRC_DIR) \
			$(AUTOTOOLS_MAKE_ARGS) uninstall) \
		|| true

__apply-patches = \
	$(BUILD_SYSTEM)/apply-patches.sh $(PRIVATE_SRC_DIR) $(PRIVATE_PATH) $(PRIVATE_PATCHES)

###############################################################################
###############################################################################

LOCAL_AUTOTOOLS_CMD_UNPACK := $(strip $(LOCAL_AUTOTOOLS_CMD_UNPACK))
ifeq ("$(LOCAL_AUTOTOOLS_CMD_UNPACK)","")
  LOCAL_AUTOTOOLS_CMD_UNPACK := __default-unpack
endif

LOCAL_AUTOTOOLS_CMD_CONFIGURE := $(strip $(LOCAL_AUTOTOOLS_CMD_CONFIGURE))
ifeq ("$(LOCAL_AUTOTOOLS_CMD_CONFIGURE)","")
  LOCAL_AUTOTOOLS_CMD_CONFIGURE := __default-configure
endif

LOCAL_AUTOTOOLS_CMD_BUILD := $(strip $(LOCAL_AUTOTOOLS_CMD_BUILD))
ifeq ("$(LOCAL_AUTOTOOLS_CMD_BUILD)","")
  LOCAL_AUTOTOOLS_CMD_BUILD := __default-make-build
endif

LOCAL_AUTOTOOLS_CMD_INSTALL := $(strip $(LOCAL_AUTOTOOLS_CMD_INSTALL))
ifeq ("$(LOCAL_AUTOTOOLS_CMD_INSTALL)","")
  LOCAL_AUTOTOOLS_CMD_INSTALL := __default-make-install
endif

LOCAL_AUTOTOOLS_CMD_CLEAN := $(strip $(LOCAL_AUTOTOOLS_CMD_CLEAN))
ifeq ("$(LOCAL_AUTOTOOLS_CMD_CLEAN)","")
  LOCAL_AUTOTOOLS_CMD_CLEAN := __default-clean
endif

###############################################################################
## Rules.
###############################################################################

# Unpack + patch
$(unpacked_file): $(archive_file) $(addprefix $(LOCAL_PATH)/,$(patches)) $(all_external_libraries)
	@echo "Unpacking $(call path-from-top,$<)"
	@mkdir -p $(PRIVATE_UNPACK_DIR)
	$(Q)$(call $(PRIVATE_CMD_UNPACK))
	$(Q)$(if $(PRIVATE_PATCHES), $(call __apply-patches))
	$(Q)$(if $(PRIVATE_CMD_POST_UNPACK), $(call $(PRIVATE_CMD_POST_UNPACK)))
	@touch $@

# Configuration
$(configured_file): $(unpacked_file)
	@echo "Configuring $(PRIVATE_MODULE)"
	$(Q)$(call $(PRIVATE_CMD_CONFIGURE))
	$(Q)$(if $(PRIVATE_CMD_POST_CONFIGURE), $(call $(PRIVATE_CMD_POST_CONFIGURE)))
	@touch $@

# Build
$(built_file): $(configured_file)
	@echo "Building $(PRIVATE_MODULE)"
	$(Q)$(call $(PRIVATE_CMD_BUILD))
	$(Q)$(if $(PRIVATE_CMD_POST_BUILD), $(call $(PRIVATE_CMD_POST_BUILD)))
	@touch $@

# Installation
$(installed_file): $(built_file)
	@echo "Installing $(PRIVATE_MODULE)"
	$(Q)$(call $(PRIVATE_CMD_INSTALL))
	$(Q)$(if $(PRIVATE_CMD_POST_INSTALL), $(call $(PRIVATE_CMD_POST_INSTALL)))
	@touch $@

# Done
$(LOCAL_BUILD_MODULE): $(installed_file)
	@touch $@

# clean- targets additional commands
clean-$(LOCAL_MODULE)::
	$(Q)$(call $(PRIVATE_CMD_CLEAN))
	$(Q)$(if $(PRIVATE_CMD_POST_CLEAN), $(call $(PRIVATE_CMD_POST_CLEAN)))
	$(Q)rm -f $(installed_file)
	$(Q)rm -f $(built_file)
	$(Q)rm -f $(configured_file)
	$(Q)rm -f $(unpacked_file)
	$(Q)rm -rf $(PRIVATE_MODULE_BUILD_DIR)

###############################################################################
## Rule-specific variable definitions.
###############################################################################

$(LOCAL_TARGETS): PRIVATE_MODULE_BUILD_DIR := $(module_build_dir)
$(LOCAL_TARGETS): PRIVATE_ARCHIVE := $(archive_file)
$(LOCAL_TARGETS): PRIVATE_UNPACK_DIR := $(unpack_dir)
$(LOCAL_TARGETS): PRIVATE_SRC_DIR := $(src_dir)
$(LOCAL_TARGETS): PRIVATE_PATCHES := $(patches)
$(LOCAL_TARGETS): PRIVATE_CONFIGURE_ENV  := $(LOCAL_AUTOTOOLS_CONFIGURE_ENV)
$(LOCAL_TARGETS): PRIVATE_CONFIGURE_ARGS  := $(LOCAL_AUTOTOOLS_CONFIGURE_ARGS)
$(LOCAL_TARGETS): PRIVATE_MAKE_BUILD_ENV  := $(LOCAL_AUTOTOOLS_MAKE_BUILD_ENV)
$(LOCAL_TARGETS): PRIVATE_MAKE_BUILD_ARGS  := $(LOCAL_AUTOTOOLS_MAKE_BUILD_ARGS)
$(LOCAL_TARGETS): PRIVATE_MAKE_INSTALL_ENV  := $(LOCAL_AUTOTOOLS_MAKE_INSTALL_ENV)
$(LOCAL_TARGETS): PRIVATE_MAKE_INSTALL_ARGS  := $(LOCAL_AUTOTOOLS_MAKE_INSTALL_ARGS)
$(LOCAL_TARGETS): PRIVATE_CMD_UNPACK := $(LOCAL_AUTOTOOLS_CMD_UNPACK)
$(LOCAL_TARGETS): PRIVATE_CMD_CONFIGURE := $(LOCAL_AUTOTOOLS_CMD_CONFIGURE)
$(LOCAL_TARGETS): PRIVATE_CMD_BUILD := $(LOCAL_AUTOTOOLS_CMD_BUILD)
$(LOCAL_TARGETS): PRIVATE_CMD_INSTALL := $(LOCAL_AUTOTOOLS_CMD_INSTALL)
$(LOCAL_TARGETS): PRIVATE_CMD_CLEAN := $(LOCAL_AUTOTOOLS_CMD_CLEAN)
$(LOCAL_TARGETS): PRIVATE_CMD_POST_UNPACK := $(LOCAL_AUTOTOOLS_CMD_POST_UNPACK)
$(LOCAL_TARGETS): PRIVATE_CMD_POST_CONFIGURE := $(LOCAL_AUTOTOOLS_CMD_POST_CONFIGURE)
$(LOCAL_TARGETS): PRIVATE_CMD_POST_BUILD := $(LOCAL_AUTOTOOLS_CMD_POST_BUILD)
$(LOCAL_TARGETS): PRIVATE_CMD_POST_INSTALL := $(LOCAL_AUTOTOOLS_CMD_POST_INSTALL)
$(LOCAL_TARGETS): PRIVATE_CMD_POST_CLEAN := $(LOCAL_AUTOTOOLS_CMD_POST_CLEAN)

