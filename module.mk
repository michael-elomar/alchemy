###############################################################################
## @file module.mk
## @author Y.M. Morgan
## @date 2012/04/17
##
## Build a module.
###############################################################################

# Bring back all LOCAL_XXX variables defined by LOCAL_MODULE
$(call module-restore-locals,$(LOCAL_MODULE))

ifneq ("$(V)","0")
$(info Generating rules for $(LOCAL_MODULE))
endif

# Do we need to copy build module to staging/final dir
copy_to_staging := 0
copy_to_final := 0

# Intermediate/Build directory
build_dir := $(TARGET_OUT_BUILD)/$(LOCAL_MODULE)

# Full path to build module
LOCAL_BUILD_MODULE := $(call module-get-build-filename,$(LOCAL_MODULE))

# Full path to staging module
LOCAL_STAGING_MODULE := $(call module-get-staging-filename,$(LOCAL_MODULE))

# Assemble the list of targets to create PRIVATE_ variables for.
LOCAL_TARGETS := \
	$(LOCAL_BUILD_MODULE) \
	$(LOCAL_MODULE)-clean \
	$(LOCAL_MODULE)-dirclean \
	$(LOCAL_MODULE)-path \
	$(LOCAL_MODULE)-pre-install

# Get all modules we depend on
all_depends := $(call module-get-all-depends,$(LOCAL_MODULE))

###############################################################################
## Construct prerequisites.
###############################################################################

# List of all prerequisites (ours + dependencies)
all_prerequisites :=

## Determine external libraries that are needed as prerequisites.
$(foreach __lib,$(all_depends), \
	$(if $(call is-module-external,$(__lib)), \
		$(eval all_prerequisites += \
			$(call module-get-build-filename,$(__lib)) \
		) \
	) \
)

# Remove our build module from the list of global deps to avoid circular chain
all_prerequisites += \
	$(filter-out $(LOCAL_BUILD_MODULE),$(TARGET_GLOBAL_PREREQUISITES)) \
	$(LOCAL_PREREQUISITES) \
	$(LOCAL_EXPORT_PREREQUISITES)

# Make sure PRIVATE_XXX variables of prerequisites are correct
# Without this, the first module that needs the prerequisite will force its
# PRIVATE_XXX variables leading to 'interresting' results
LOCAL_TARGETS += \
	$(LOCAL_PREREQUISITES) \
	$(LOCAL_EXPORT_PREREQUISITES)

###############################################################################
## Skip some stuff to improve scanning.
###############################################################################

# Skip parsing dependencies if requested
skip_include_deps := 0
ifneq ("$(SKIP_DEPS_AND_CHECKS)","0")
  skip_include_deps := 1
endif

# Skip external checks if requested
skip_ext_checks := 1
ifeq ("$(SKIP_EXT_DEPS_AND_CHECKS)","0")
  skip_ext_checks := 0
endif

# If we are explicitely building this module, do not skip external checks
ifneq ("$(call is-module-in-make-goals,$(LOCAL_MODULE))","")
  skip_ext_checks := 0
endif

###############################################################################
## External checks : module built externaly may have other dependencies.
###############################################################################

# Update list of 'done' files with module file name
# Using sort ensure there is no duplicates in the list
ifeq ("$(patsubst %.done,1,$(LOCAL_MODULE_FILENAME))","1")
  LOCAL_DONE_FILES := $(sort $(LOCAL_DONE_FILES) $(LOCAL_MODULE_FILENAME))
endif

# Macro to delete one 'done' file
# $1 : file to delete
delete-one-done-file = \
	$(if $(wildcard $1), \
		$(if $(call strneq,$(V),0), \
			$(info Deleting $(call path-from-top,$1)) \
		) \
		$(shell rm -f $1) \
	)

# Macro to delete all 'done' files registered in module
# Also check if the module file name is a 'done' file
delete-all-done-files = \
	$(foreach __f,$(LOCAL_DONE_FILES),\
		$(call delete-one-done-file, \
			$(call module-get-build-dir,$(LOCAL_MODULE))/$(__f) \
		) \
	)

# If not skipping checks of of module built externally, delete 'done' files
ifeq ("$(skip_ext_checks)","0")
$(delete-all-done-files)
endif

###############################################################################
## Rule-specific variable definitions.
###############################################################################

$(LOCAL_TARGETS): PRIVATE_PATH := $(LOCAL_PATH)
$(LOCAL_TARGETS): PRIVATE_MODULE := $(LOCAL_MODULE)
$(LOCAL_TARGETS): PRIVATE_BUILD_DIR := $(build_dir)
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES := $(LOCAL_CLEAN_FILES) $(LOCAL_BUILD_MODULE)
$(LOCAL_TARGETS): PRIVATE_CLEAN_DIRS := $(LOCAL_CLEAN_DIRS)

###############################################################################
## General rules.
###############################################################################

# Short hand to build module
.PHONY: $(LOCAL_MODULE)
$(LOCAL_MODULE): $(LOCAL_BUILD_MODULE)

# Add direct dependencies. Mainly used for copy to staging/final dir to get
# everything built for the module
$(LOCAL_MODULE): $(call module-get-depends,$(LOCAL_MODULE))

# Clean module
.PHONY: $(LOCAL_MODULE)-clean
$(LOCAL_MODULE)-clean: $(LOCAL_MODULE)-clean-common

# Common part, delete registered files and directories
# Note: the foreach generates a separate command for each file/dir thanks to
# the $(endl) macro that insert a new line during expansion.
.PHONY: $(LOCAL_MODULE)-clean-common
$(LOCAL_MODULE)-clean-common:
	@echo "Clean: $(PRIVATE_MODULE)"
	$(foreach __f,$(PRIVATE_CLEAN_FILES),$(Q)rm -f $(__f)$(endl))
	$(foreach __d,$(PRIVATE_CLEAN_DIRS),$(Q)rm -rf $(__d)$(endl))

# Clean + delete the build directory
.PHONY: $(LOCAL_MODULE)-dirclean
$(LOCAL_MODULE)-dirclean: $(LOCAL_MODULE)-clean
	$(Q)rm -rf $(PRIVATE_BUILD_DIR)
	+$(call macro-exec-cmd,CMD_POST_DIRCLEAN,empty)

# Display the path of the module
.PHONY: $(LOCAL_MODULE)-path
$(LOCAL_MODULE)-path:
	@echo "$(PRIVATE_MODULE): $(PRIVATE_PATH)"

# If the user makefile is modified, this will trigger a check of the module
# Prebuilt modules migth not be defined in an user makefile so skip this for them
ifneq ("$(LOCAL_MODULE_CLASS)","PREBUILT")
$(LOCAL_BUILD_MODULE): $(LOCAL_PATH)/$(USER_MAKEFILE_NAME)
endif

###############################################################################
## Configuration file management.
###############################################################################

config_file := $(call __get-module-config,$(LOCAL_MODULE))
autoconf_file := $(call module-get-autoconf,$(LOCAL_MODULE))
ifneq ("$(autoconf_file)","")

# autoconf.h file depends on module config
$(autoconf_file): $(config_file)
	@$(call generate-autoconf-file,$<,$@)

# Don't forget to clean autoconf.h file
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(autoconf_file)

endif

###############################################################################
## Archive extraction + patches.
## Partially redundant with autotools rules.
###############################################################################
ifneq ("$(LOCAL_ARCHIVE)","")

archive_file := $(LOCAL_PATH)/$(LOCAL_ARCHIVE)
patches := $(strip $(LOCAL_ARCHIVE_PATCHES))
unpacked_file := $(build_dir)/$(LOCAL_MODULE).unpacked
unpack_dir := $(build_dir)

# Generated files to be compiled will also depends on 'unpacked_file' in
# binary-rules.mk
all_prerequisites += $(unpacked_file)

define __archive-default-unpack
	$(Q) tar -C $(PRIVATE_ARCHIVE_UNPACK_DIR) -xf $(PRIVATE_ARCHIVE)
endef

define __archive-apply-patches
	$(Q) $(BUILD_SYSTEM)/scripts/apply-patches.sh \
		$(PRIVATE_ARCHIVE_UNPACK_DIR)/$(PRIVATE_ARCHIVE_SUBDIR) \
		$(PRIVATE_PATH) \
		$(PRIVATE_ARCHIVE_PATCHES)
endef

$(unpacked_file): $(archive_file) $(addprefix $(LOCAL_PATH)/,$(patches))
	$(call print-banner2,Archive,$(PRIVATE_MODULE),Unpacking $(call path-from-top,$<))
	@mkdir -p $(PRIVATE_ARCHIVE_UNPACK_DIR)
	+$(call macro-exec-cmd,ARCHIVE_CMD_UNPACK,__archive-default-unpack)
	+$(if $(PRIVATE_ARCHIVE_PATCHES),$(__archive-apply-patches))
	+$(call macro-exec-cmd,ARCHIVE_CMD_POST_UNPACK,empty)
	@mkdir -p $(dir $@)
	@touch $@

$(LOCAL_TARGETS): PRIVATE_ARCHIVE := $(archive_file)
$(LOCAL_TARGETS): PRIVATE_ARCHIVE_UNPACK_DIR := $(unpack_dir)
$(LOCAL_TARGETS): PRIVATE_ARCHIVE_SUBDIR := $(LOCAL_ARCHIVE_SUBDIR)
$(LOCAL_TARGETS): PRIVATE_ARCHIVE_PATCHES := $(patches)

endif

###############################################################################
## Static library.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","STATIC_LIBRARY")

include $(BUILD_SYSTEM)/binary-rules.mk

$(LOCAL_BUILD_MODULE): $(all_objects)
	$(transform-o-to-static-lib)

copy_to_staging := 1

endif

###############################################################################
## Shared library.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","SHARED_LIBRARY")

include $(BUILD_SYSTEM)/binary-rules.mk

$(LOCAL_BUILD_MODULE): $(all_objects) $(all_libraries)
	$(transform-o-to-shared-lib)

copy_to_staging := 1
copy_to_final := 1

endif

###############################################################################
## Executable.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","EXECUTABLE")

include $(BUILD_SYSTEM)/binary-rules.mk

$(LOCAL_BUILD_MODULE): $(all_objects) $(all_libraries)
	$(transform-o-to-executable)

copy_to_staging := 1
copy_to_final := 1

endif

###############################################################################
## Autotools.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","AUTOTOOLS")

include $(BUILD_SYSTEM)/autotools-rules.mk

endif

###############################################################################
## Prebuilt.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","PREBUILT")

$(LOCAL_BUILD_MODULE):
	@mkdir -p $(dir $@)
	@touch $@

endif

###############################################################################
## Custom.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","CUSTOM")

# This makes sure that if the user makefile did not made an explicit rule
# there will be no error
$(LOCAL_BUILD_MODULE):

endif

###############################################################################
## Files to copy.
###############################################################################

ifneq ("$(LOCAL_COPY_FILES)","")

# List of all source/destination files
all_copy_files_src :=
all_copy_files_dst :=

# Generate a rule to copy all files
# Handle relative/absolute paths
# Handle directory only for destination
$(foreach __pair,$(LOCAL_COPY_FILES), \
	$(eval __pair2 := $(subst :,$(space),$(__pair))) \
	$(eval __w1 := $(word 1,$(__pair2))) \
	$(eval __w2 := $(word 2,$(__pair2))) \
	$(eval __src := $(call copy-get-src-path,$(__w1))) \
	$(eval __dst := $(call copy-get-dst-path,$(__w2))) \
	$(if $(call is-path-dir,$(__dst)), \
		$(eval __dst := $(__dst)$(notdir $(__src))) \
	) \
	$(eval all_copy_files_src += $(__src)) \
	$(eval all_copy_files_dst += $(__dst)) \
	$(eval $(call copy-one-file,$(__src),$(__dst))) \
)

# Add an order-only dependency between sources and prerequisites
all_copy_files_prerequisites := \
	$(filter-out $(all_copy_files_src) $(all_copy_files_dst),$(all_prerequisites))
$(foreach __src,$(all_copy_files_src), \
	$(eval $(__src): | $(all_copy_files_prerequisites)) \
)

# Add files to be copied as a dependency
$(LOCAL_BUILD_MODULE): $(all_copy_files_dst)

# Add rule to delete copied files during clean
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(all_copy_files_dst)

endif

###############################################################################
## Links to create.
###############################################################################

ifneq ("$(LOCAL_CREATE_LINKS)","")

# List of all links
all_create_links :=

# Generate a rule to create links
$(foreach __pair,$(LOCAL_CREATE_LINKS), \
	$(eval __pair2 := $(subst :,$(space),$(__pair))) \
	$(eval __w1 := $(word 1,$(__pair2))) \
	$(eval __w2 := $(word 2,$(__pair2))) \
	$(eval __name := $(TARGET_OUT_STAGING)/$(__w1)) \
	$(eval __target := $(__w2)) \
	$(eval all_create_links += $(__name)) \
	$(eval $(call create-one-link,$(__name),$(__target))) \
)

# Add links to be created as a dependency
$(LOCAL_BUILD_MODULE): $(all_create_links)

# Add rule to delete created links during clean
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(all_create_links)

endif

###############################################################################
## Prerequisites.
###############################################################################

# Make sure all prerequisites files are generated first
# But do NOT force recompilation (order only)
$(LOCAL_BUILD_MODULE): | $(all_prerequisites)

###############################################################################
## Copy to staging/final dir
###############################################################################

ifeq ("$(copy_to_staging)","1")

$(LOCAL_MODULE): $(LOCAL_STAGING_MODULE)
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(LOCAL_STAGING_MODULE)
$(eval $(call copy-one-file,$(LOCAL_BUILD_MODULE),$(LOCAL_STAGING_MODULE)))

# If final directory exists, also copy file in it
# TODO: maybe add a setting to disable this feature ?
# TODO: add to clean list ?
ifeq ("$(copy_to_final)","1")

ifneq ("$(wildcard $(TARGET_OUT_FINAL))","")

LOCAL_FINAL_MODULE := $(LOCAL_STAGING_MODULE:$(TARGET_OUT_STAGING)/%=$(TARGET_OUT_FINAL)/%)
$(LOCAL_MODULE): $(LOCAL_FINAL_MODULE)

# Strip if needed, otherwise simply copy
ifeq ("$(TARGET_NOSTRIP_FINAL)","1")
$(eval $(call copy-one-file,$(LOCAL_STAGING_MODULE),$(LOCAL_FINAL_MODULE)))
else
$(LOCAL_FINAL_MODULE): $(LOCAL_STAGING_MODULE)
	@echo "Strip: $(call path-from-top,$<) => $(call path-from-top,$@)"
	@mkdir -p $(dir $@)
	$(Q)$(TARGET_STRIP) -o $@ $<
endif

endif # ifneq ("$(wildcard $(TARGET_OUT_FINAL))","")

endif # ifeq ("$(copy_to_final)","1")

endif # ifeq ("$(copy_to_staging)","1")

###############################################################################
## Pre-install customization
###############################################################################

ifneq ("$(value LOCAL_CMD_PRE_INSTALL)","")

.PHONY: $(LOCAL_MODULE)-pre-install
$(LOCAL_MODULE)-pre-install:
	+$(call macro-exec-cmd,CMD_PRE_INSTALL,empty)

# If a copy in staging is done do it before otherwise we can only hook before
# build module is done...
# Order only prerequiqites to avoid recompilation...
ifeq ("$(copy_to_staging)","1")
$(LOCAL_STAGING_MODULE): | $(LOCAL_MODULE)-pre-install
else
$(LOCAL_BUILD_MODULE): | $(LOCAL_MODULE)-pre-install
endif

endif
