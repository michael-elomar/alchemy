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
  src_dir := $(unpack_dir)/$(LOCAL_AUTOTOOLS_DIR)
else
  src_dir := $(LOCAL_PATH)
endif

# Patched to apply
patches := $(strip $(LOCAL_AUTOTOOLS_PATCHES))

# Where the package will be configured and built
ifneq ("$(archive_file)","")
  obj_dir := $(src_dir)
else
  obj_dir := $(build_dir)/obj
endif

# Delete some aditionnal 'done' files if a skip of external checks is not done
ifeq ("$(skip_ext_checks)","0")
$(call delete-one-done-file,$(built_file))
$(call delete-one-done-file,$(installed_file))
endif

###############################################################################
## Default commands
###############################################################################

__default-unpack = \
	tar -C $(PRIVATE_UNPACK_DIR) -xf $(PRIVATE_ARCHIVE)

__default-configure = \
	cd $(PRIVATE_OBJ_DIR) && \
		$(AUTOTOOLS_CONFIGURE_ENV) $(PRIVATE_CONFIGURE_ENV) $(PRIVATE_SRC_DIR)/configure \
		$(AUTOTOOLS_CONFIGURE_ARGS) $(PRIVATE_CONFIGURE_ARGS)

__default-make-build = \
	$(AUTOTOOLS_MAKE_ENV) $(PRIVATE_MAKE_BUILD_ENV) $(MAKE) -C $(PRIVATE_OBJ_DIR) \
		$(AUTOTOOLS_MAKE_ARGS) $(PRIVATE_MAKE_BUILD_ARGS)

__default-make-install = \
	$(AUTOTOOLS_MAKE_ENV) $(PRIVATE_MAKE_INSTALL_ENV) $(MAKE) -C $(PRIVATE_OBJ_DIR) \
		$(AUTOTOOLS_MAKE_ARGS) $(PRIVATE_MAKE_INSTALL_ARGS) install

# Force success for command in case "uninstall" or "clean" is not supported
# or Makefile not present
__default-clean = \
	if [ -d $(PRIVATE_OBJ_DIR) ]; then \
		$(AUTOTOOLS_MAKE_ENV) $(PRIVATE_MAKE_INSTALL_ENV) $(MAKE) \
			-C $(PRIVATE_OBJ_DIR) $(AUTOTOOLS_MAKE_ARGS) $(PRIVATE_MAKE_INSTALL_ARGS) \
			uninstall || echo "Ignoring uninstall errors"; \
		$(AUTOTOOLS_MAKE_ENV) $(PRIVATE_MAKE_INSTALL_ENV) $(MAKE) \
			-C $(PRIVATE_OBJ_DIR) $(AUTOTOOLS_MAKE_ARGS) \
			clean || echo "Ignoring clean errors"; \
	fi;

__apply-patches = \
	$(BUILD_SYSTEM)/scripts/apply-patches.sh $(PRIVATE_SRC_DIR) $(PRIVATE_PATH) $(PRIVATE_PATCHES)

# Patch libtool to make it work properly for cross-compilation.
# Modify the libdir in .la files installed in staging dir so that they reference the staging dir
# and not the final dir. Do this only if dest dir is not empty (in native build staging dir
# is the final dir specified in configure script).
# Use -rpath-link instead of -rpath to avoid hardcoding host path in binaries.
__libtool_patch = \
	$(Q)for f in `find $(PRIVATE_OBJ_DIR) -name libtool -o -name ltmain.sh`; do \
		echo "Patching $$f"; \
		$(if $(AUTOTOOLS_INSTALL_DESTDIR), \
			sed -i -e "s|^libdir='\$$install_libdir'|libdir='\$${install_libdir:\+$(TARGET_OUT_STAGING)\$$install_libdir}'|1" $$f; \
		) \
		sed -i -e "s|{wl}-rpath|{wl}-rpath-link|1" $$f; \
		sed -i -e "s|{wl}--rpath|{wl}-rpath-link|1" $$f; \
	done

#		sed -i -e "s|runpath_var=LD_RUN_PATH|runpath_var=|1" $$f; \
#		sed -i -e "s|need_relink=yes|need_relink=no|1" $$f; \

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
## Note : use '+' to make sure sub-make is properly managed, this avoid the message :
## warning: jobserver unavailable: using -j1.  Add `+' to parent make rule.
###############################################################################

# Make sure all prerequisites files are generated first
# But do NOT force recompilation (order only)
$(unpacked_file): | $(all_prerequisites)

# Unpack + patch
$(unpacked_file): $(archive_file) $(addprefix $(LOCAL_PATH)/,$(patches))
ifneq ("$(archive_file)","")
	@echo "Unpacking $(call path-from-top,$<)"
	@mkdir -p $(PRIVATE_UNPACK_DIR)
	+$(Q)$(call $(PRIVATE_CMD_UNPACK))
	+$(Q)$(if $(PRIVATE_PATCHES), $(call __apply-patches))
	+$(Q)$(if $(PRIVATE_CMD_POST_UNPACK), $(call $(PRIVATE_CMD_POST_UNPACK)))
endif
	@mkdir -p $(dir $@)
	@touch $@

# Configuration
$(configured_file): $(unpacked_file)
	@echo "Configuring $(PRIVATE_MODULE)"
	@mkdir -p $(PRIVATE_OBJ_DIR)
	+$(Q)$(call $(PRIVATE_CMD_CONFIGURE))
	+$(Q)$(if $(PRIVATE_CMD_POST_CONFIGURE), $(call $(PRIVATE_CMD_POST_CONFIGURE)))
	$(__libtool_patch)
	@mkdir -p $(dir $@)
	@touch $@

# Build
$(built_file): $(configured_file)
	@echo "Building $(PRIVATE_MODULE)"
	@mkdir -p $(PRIVATE_OBJ_DIR)
	+$(Q)$(call $(PRIVATE_CMD_BUILD))
	+$(Q)$(if $(PRIVATE_CMD_POST_BUILD), $(call $(PRIVATE_CMD_POST_BUILD)))
	@mkdir -p $(dir $@)
	@touch $@

# Installation
$(installed_file): $(built_file)
	@echo "Installing $(PRIVATE_MODULE)"
	+$(Q)$(call $(PRIVATE_CMD_INSTALL))
	+$(Q)$(if $(PRIVATE_CMD_POST_INSTALL), $(call $(PRIVATE_CMD_POST_INSTALL)))
	@mkdir -p $(dir $@)
	@touch $@

# Done
$(LOCAL_BUILD_MODULE): $(installed_file)
	@mkdir -p $(dir $@)
	@touch $@

# clean targets additional commands
$(LOCAL_MODULE)-clean:
	+$(Q)$(call $(PRIVATE_CMD_CLEAN))
	+$(Q)$(if $(PRIVATE_CMD_POST_CLEAN), $(call $(PRIVATE_CMD_POST_CLEAN)))

###############################################################################
## Rule-specific variable definitions.
###############################################################################

# clean targets additional variables
# To NOT put build dir in PRIVATE_CLEAN_DIRS
# we need to call some makefiles during our custom clean
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(installed_file)
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(built_file)

$(LOCAL_TARGETS): PRIVATE_ARCHIVE := $(archive_file)
$(LOCAL_TARGETS): PRIVATE_UNPACK_DIR := $(unpack_dir)
$(LOCAL_TARGETS): PRIVATE_SRC_DIR := $(src_dir)
$(LOCAL_TARGETS): PRIVATE_OBJ_DIR := $(obj_dir)
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

