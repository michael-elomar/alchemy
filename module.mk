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

# Do we need to copy build module to staging dir
copy_to_staging := 0

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
	$(LOCAL_MODULE)-pre-install

# Get external libraries used by static libraries
LOCAL_EXTERNAL_LIBRARIES := \
	$(call module-get-static-depends,$(LOCAL_MODULE),EXTERNAL_LIBRARIES)

# List of external libraries that we need to depend on
all_external_libraries := \
	$(foreach lib,$(LOCAL_EXTERNAL_LIBRARIES), \
		$(call module-get-build-filename,$(lib)))

# List of all prerequisites (ours + dependencies)
# Remove our build module from the list of global deps to avoid circular chain
all_prerequisites := \
	$(filter-out $(LOCAL_BUILD_MODULE),$(TARGET_GLOBAL_PREREQUISITES)) \
	$(LOCAL_PREREQUISITES) \
	$(LOCAL_EXPORT_PREREQUISITES) \
	$(all_external_libraries)

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

# Clean module
.PHONY: $(LOCAL_MODULE)-clean
$(LOCAL_MODULE)-clean: $(LOCAL_MODULE)-clean-common

# Common part, delete registered files and directories
.PHONY: $(LOCAL_MODULE)-clean-common
$(LOCAL_MODULE)-clean-common:
	@echo "Clean: $(PRIVATE_MODULE)"
	$(Q)$(if $(PRIVATE_CLEAN_FILES),rm -f $(PRIVATE_CLEAN_FILES))
	$(Q)$(if $(PRIVATE_CLEAN_DIRS),rm -rf $(PRIVATE_CLEAN_DIRS))

# Clean + delete the build directory
.PHONY: $(LOCAL_MODULE)-dirclean
$(LOCAL_MODULE)-dirclean: $(LOCAL_MODULE)-clean
	$(Q)rm -rf $(PRIVATE_BUILD_DIR)

###############################################################################
## autoconf.h file generation.
###############################################################################

autoconf_file := $(call module-get-autoconf,$(LOCAL_MODULE))
ifneq ("$(autoconf_file)","")

# autoconf.h file depends on module config
$(autoconf_file): $(call __get-module-config,$(LOCAL_MODULE))
	@$(call generate-autoconf-file,$<,$@)

# Don't forget to clean autoconf.h file
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(autoconf_file)

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

endif

###############################################################################
## Executable.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","EXECUTABLE")

include $(BUILD_SYSTEM)/binary-rules.mk

$(LOCAL_BUILD_MODULE): $(all_objects) $(all_libraries)
	$(transform-o-to-executable)

copy_to_staging := 1

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
## Files to copy.
###############################################################################

ifneq ("$(LOCAL_COPY_FILES)","")

# List of all destination files
all_copy_files :=

# Generate a rule to copy all files
$(foreach __pair,$(LOCAL_COPY_FILES), \
	$(eval __pair2 := $(subst :,$(space),$(__pair))) \
	$(eval __src := $(addprefix $(LOCAL_PATH)/,$(word 1,$(__pair2)))) \
	$(eval __dst := $(addprefix $(TARGET_OUT_STAGING)/,$(word 2,$(__pair2)))) \
	$(eval all_copy_files += $(__dst)) \
	$(eval $(call copy-one-file,$(__src),$(__dst))) \
)

# Add files to be copied as pre-requisites
$(LOCAL_BUILD_MODULE): $(all_copy_files)

# Add rule to delete copied files during clean
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(all_copy_files)

endif

###############################################################################
## Prerequisites.
###############################################################################

# Make sure all prerequisites files are generated first
# But do NOT force recompilation (order only)
$(LOCAL_BUILD_MODULE): | $(all_prerequisites)

###############################################################################
## Copy to staging dir
###############################################################################

ifeq ("$(copy_to_staging)","1")
$(LOCAL_MODULE): $(LOCAL_STAGING_MODULE)
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(LOCAL_STAGING_MODULE)
$(eval $(call copy-one-file,$(LOCAL_BUILD_MODULE),$(LOCAL_STAGING_MODULE)))
endif

###############################################################################
## Pre-install customization
###############################################################################

.PHONY: $(LOCAL_MODULE)-pre-install
$(LOCAL_MODULE)-pre-install:
	+$(Q)$(if $(PRIVATE_CMD_PRE_INSTALL), $(call $(PRIVATE_CMD_PRE_INSTALL)))

$(LOCAL_TARGETS): PRIVATE_CMD_PRE_INSTALL := $(LOCAL_CMD_PRE_INSTALL)

# If a copy in staging is done do it before otherwise we can only hook before
# build module is done...
ifeq ("$(copy_to_staging)","1")
$(LOCAL_STAGING_MODULE): $(LOCAL_MODULE)-pre-install
else
$(LOCAL_BUILD_MODULE): $(LOCAL_MODULE)-pre-install
endif

