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

# Host/Target module customization
# Prefix is used for variable like TARGET_xxx or LOCAL_xxx
# Suffix is for macros.
ifneq ("$(LOCAL_HOST_MODULE)","")
  mode_host := $(true)
  mode_prefix := HOST_
  mode_suffix := -host
else
  mode_prefix := TARGET_
  mode_suffix :=
  mode_host :=
endif

# Build directory
build_dir := $(call module-get-build-dir,$(LOCAL_MODULE))

# Full path to build module
LOCAL_BUILD_MODULE := $(call module-get-build-filename,$(LOCAL_MODULE))

# Full path to staging module
LOCAL_STAGING_MODULE := $(call module-get-staging-filename,$(LOCAL_MODULE))

# Assemble the list of targets to create PRIVATE_ variables for.
LOCAL_TARGETS := \
	$(LOCAL_BUILD_MODULE) \
	$(LOCAL_MODULE)-clean \
	$(LOCAL_MODULE)-dirclean \
	$(LOCAL_MODULE)-path

ifneq ("$(value LOCAL_CMD_PRE_INSTALL)","")
preinstall_file := $(build_dir)/$(LOCAL_MODULE).preinstall
LOCAL_TARGETS += $(preinstall_file)
endif

###############################################################################
## ARM specific checks.
###############################################################################
ifneq ("$(mode_host)","1")
ifeq ("$(TARGET_ARCH)","arm")

# Make sure LOCAL_ARM_MODE is valid
# If not set, use default mode
LOCAL_ARM_MODE := $(strip $(LOCAL_ARM_MODE))
ifeq ("$(LOCAL_ARM_MODE)","")
  LOCAL_ARM_MODE := $(TARGET_DEFAULT_ARM_MODE)
endif

ifneq ("$(LOCAL_ARM_MODE)","arm")
ifneq ("$(LOCAL_ARM_MODE)","thumb")
  $(error $(LOCAL_PATH): LOCAL_ARM_MODE is not valid : $(LOCAL_ARM_MODE))
endif
endif

# If default mode is not thumb, do not allow thumb, so the only practical use of
# this variable is to allow arm if default is thumb, not the other way around
ifneq ("$(TARGET_DEFAULT_ARM_MODE)","thumb")
  LOCAL_ARM_MODE := $(TARGET_DEFAULT_ARM_MODE)
endif

# Check that -marm or -mthumb is not forced in compilation flags
check-flags-arm-mode := -marm -mthumb
check-flags-arm-mode-message := please use LOCAL_ARM_MODE
$(call check-flags,LOCAL_CFLAGS,$(check-flags-arm-mode),$(check-flags-arm-mode-message))
$(call check-flags,LOCAL_CXXFLAGS,$(check-flags-arm-mode),$(check-flags-arm-mode-message))
$(call check-flags,LOCAL_EXPORT_CFLAGS,$(check-flags-arm-mode),$(check-flags-arm-mode-message))
$(call check-flags,LOCAL_EXPORT_CXXFLAGS,$(check-flags-arm-mode),$(check-flags-arm-mode-message))

endif # ifeq ("$(TARGET_ARCH)","arm")
endif # ifneq ("$(mode_host)","1")

###############################################################################
## Generic checks.
###############################################################################

# Do not put -O0 in flags, use debug setup makefile
check-flags-debug := -O0
check-flags-debug-message := please use custom $(debug-setup-makefile) in top dir
$(call check-flags,LOCAL_CFLAGS,$(check-flags-debug),$(check-flags-debug-message))
$(call check-flags,LOCAL_CXXFLAGS,$(check-flags-debug),$(check-flags-debug-message))
$(call check-flags,LOCAL_EXPORT_CFLAGS,$(check-flags-debug),$(check-flags-debug-message))
$(call check-flags,LOCAL_EXPORT_CXXFLAGS,$(check-flags-debug),$(check-flags-debug-message))

###############################################################################
## Dependencies.
###############################################################################

# Get all modules we depend on (fully recursive)
all_depends := $(call module-get-all-depends,$(LOCAL_MODULE))

# Get libraries used by us and static libraries
all_external_libs := \
	$(call module-get-static-depends,$(LOCAL_MODULE),EXTERNAL_LIBRARIES)
all_static_libs := \
	$(call module-get-static-depends,$(LOCAL_MODULE),STATIC_LIBRARIES)
all_whole_static_libs := \
	$(call module-get-static-depends,$(LOCAL_MODULE),WHOLE_STATIC_LIBRARIES)
all_shared_libs := \
	$(call module-get-static-depends,$(LOCAL_MODULE),SHARED_LIBRARIES)

# List of our dependencies and from static (recursive on static libs)
all_libs := \
	$(all_external_libs) \
	$(all_static_libs) \
	$(all_whole_static_libs) \
	$(all_shared_libs)

# Path of previous variables

all_depends_build_filename := \
	$(foreach __lib,$(all_depends), \
		$(call module-get-build-filename,$(__lib)))

# We use staging dir for linking static/shared libs

all_static_libs_filename := \
	$(foreach __lib,$(all_static_libs), \
		$(call module-get-staging-filename,$(__lib)))

all_whole_static_libs_filename := \
	$(foreach __lib,$(all_whole_static_libs), \
		$(call module-get-staging-filename,$(__lib)))

all_shared_libs_filename := \
	$(foreach __lib,$(all_shared_libs), \
		$(call module-get-staging-filename,$(__lib)))

# all_link_libs_filenames is used for the dependencies at link time
all_link_libs_filenames := \
	$(all_static_libs_filename) \
	$(all_whole_static_libs_filename) \
	$(all_shared_libs_filename)

# Force pbuild hook if a static library needs it
$(foreach __mod,$(all_static_libs) $(all_whole_static_libs), \
	$(if $(__modules.$(__mod).PBUILD_HOOK), \
		$(eval LOCAL_PBUILD_HOOK := 1) \
	) \
)

###############################################################################
## Last revision used management
###############################################################################

ifneq ("$(USE_GIT_REV)","0")

# Include file with revision use for last build. It will define a variable
# if available.
revision_file := $(build_dir)/$(LOCAL_MODULE).revision
-include $(revision_file)

endif

###############################################################################
## Construct prerequisites.
###############################################################################

# List of all prerequisites (ours + dependencies)
all_prerequisites :=

# We need all external libraries as prerequisites.
all_prerequisites += \
	$(foreach __lib,$(all_depends), \
		$(if $(call is-module-external,$(__lib)), \
			$(call module-get-build-filename,$(__lib)) \
		) \
	)

# Remove our build module from the list of global deps to avoid circular chain
all_prerequisites += \
	$(filter-out $(LOCAL_BUILD_MODULE),$(TARGET_GLOBAL_PREREQUISITES)) \
	$(LOCAL_PREREQUISITES) \
	$(LOCAL_EXPORT_PREREQUISITES)

# Make sure autoconf.h file is generated
all_prerequisites += \
	$(call module-get-autoconf,$(LOCAL_MODULE))

# Make sure PRIVATE_XXX variables of prerequisites are correct
# Without this, the first module that needs the prerequisite will force its
# PRIVATE_XXX variables leading to 'interresting' results
LOCAL_TARGETS += \
	$(LOCAL_PREREQUISITES) \
	$(LOCAL_EXPORT_PREREQUISITES)

# Host modules required
# TODO: use staging filename for internal modules
all_prerequisites += \
	$(foreach __mod,$(LOCAL_DEPENDS_HOST_MODULES), \
		$(call module-get-build-filename,$(__mod)))

###############################################################################
## Import of dependencies.
##
## Note: LDLIBS only get ours and import from static dependencies.
## Other import are done on full dependency to make sure that include path
## are propagated even for shared library import.
##
## Note: external modules only import from internal modules, external module
## shall handle by themself import of external stuff (using pkg-config for example)
## we also don't add stuff exported by external module for their own compilation.
###############################################################################

# Get list of exported stuff by our dependencies
ifeq ("$(and $(call is-module-external,$(LOCAL_MODULE)),$(call strneq,$(LOCAL_MODULE_CLASS),QMAKE))","")
  # Internal module or QMAKE module
  imported_CFLAGS        := $(call module-get-listed-export,$(all_depends),CFLAGS)
  imported_CXXFLAGS      := $(call module-get-listed-export,$(all_depends),CXXFLAGS)
  imported_C_INCLUDES    := $(call module-get-listed-export,$(all_depends),C_INCLUDES)
  imported_LDLIBS        := $(call module-get-listed-export,$(all_libs),LDLIBS)

  imported_CFLAGS += $(LOCAL_EXPORT_CFLAGS)
  imported_CXXFLAGS += $(LOCAL_EXPORT_CXXFLAGS)
  imported_C_INCLUDES += $(LOCAL_EXPORT_C_INCLUDES)

  # Do not add exported libs for qmake, they generally refer to the module itself...
  # (only way for alchemy to know what do to with it)
  ifneq ("$(LOCAL_MODULE_CLASS)","QMAKE")
    imported_LDLIBS += $(LOCAL_EXPORT_LDLIBS)
  endif

else
  # External module, we only import from internal modules
  imported_CFLAGS        := $(call module-get-listed-export,$(call filter-get-internal-modules,$(all_depends)),CFLAGS)
  imported_CXXFLAGS      := $(call module-get-listed-export,$(call filter-get-internal-modules,$(all_depends)),CXXFLAGS)
  imported_C_INCLUDES    := $(call module-get-listed-export,$(call filter-get-internal-modules,$(all_depends)),C_INCLUDES)
  imported_LDLIBS        := $(call module-get-listed-export,$(call filter-get-internal-modules,$(all_libs)),LDLIBS)
endif

# Add includes of modules listed in LOCAL_DEPENDS_HEADERS
imported_C_INCLUDES += $(call module-get-listed-export,$(LOCAL_DEPENDS_HEADERS),C_INCLUDES)

# Import prerequisites (the one for this module are already in all_prerequisites)
imported_PREREQUISITES := $(call module-get-listed-export,$(all_depends),PREREQUISITES)
all_prerequisites += $(imported_PREREQUISITES)

# The imported/exported compiler flags are prepended to their LOCAL_XXXX value
# (this allows the module to override them).
LOCAL_CFLAGS     := $(strip $(imported_CFLAGS) $(LOCAL_CFLAGS))
LOCAL_CXXFLAGS   := $(strip $(imported_CXXFLAGS) $(LOCAL_CXXFLAGS))

# The imported/exported include directories are appended to their LOCAL_XXX value
# (this allows the module to override them)
LOCAL_C_INCLUDES := $(strip $(LOCAL_C_INCLUDES) $(imported_C_INCLUDES))

# Similarly, you want the imported/exported flags to appear _after_ the LOCAL_LDLIBS
# due to the way Unix linkers work (depending libraries must appear before
# dependees on final link command).
LOCAL_LDLIBS     := $(strip $(LOCAL_LDLIBS) $(imported_LDLIBS))

# Get all autoconf files that we depend on, don't forget to add ourself
# External modules only get internal ones. Mainly because we don't want to break
# build of external modules that already handle external dependencies correctly.
ifeq ("$(call is-module-external,$(LOCAL_MODULE))","")
all_autoconf := $(call module-get-listed-autoconf, \
	$(all_depends) $(LOCAL_MODULE))
else
all_autoconf := $(call module-get-listed-autoconf, \
	$(call filter-get-internal-modules,$(all_depends)) $(LOCAL_MODULE))
endif

# Force their inclusion (space after -include and before comma is important)
LOCAL_CFLAGS += $(addprefix -include ,$(all_autoconf))

# Notify that we build with dependencies
# External modules only get internal ones. Mainly because we don't want to break
# build of external modules that already handle external dependencies correctly.
ifeq ("$(call is-module-external,$(LOCAL_MODULE))","")
LOCAL_CFLAGS += $(foreach __mod,$(all_depends), \
	-DBUILD_$(call module-get-define,$(__mod)))
else
LOCAL_CFLAGS += $(foreach __mod,$(call filter-get-internal-modules,$(all_depends)), \
	-DBUILD_$(call module-get-define,$(__mod)))
endif

# Add debug flags at the end
$(call add-debug-flags)

# Code coverage flags (for internal modules only)
ifeq ("$(call is-module-external,$(LOCAL_MODULE))","")
ifeq ("$(USE_COVERAGE)","1")
  LOCAL_CFLAGS  += -fprofile-arcs -ftest-coverage -O0
  LOCAL_LDFLAGS += -fprofile-arcs -ftest-coverage
  LOCAL_LDFLAGS_SHARED += -fprofile-arcs -ftest-coverage
endif
endif

###############################################################################
## Determine flags that external modules will need to add manually.
## External modules (AUTOTOOLS, CMAKE) only have CFLAGS CXXFLAGS and LDFLAGS.
## Moreover CXXFLAGS does not inherit from CFLAGS so it must contains it.
###############################################################################

# Compilation flags
__external-add_CFLAGS := $(LOCAL_CFLAGS) $(call normalize-c-includes,$(LOCAL_C_INCLUDES))
__external-add_CXXFLAGS := $(__external-add_CFLAGS) $(LOCAL_CXXFLAGS)

# Linker flags
__external-add_LDFLAGS :=

# Whole static libraries
# As one unique -Wl option otherwise libtool make a terrible mess with it
# (it splits -Wl otions from -l options making encapsulation useless)
# With -l: to force using the given path
ifneq ("$(strip $(all_whole_static_libs_filename))","")
__external-add_LDFLAGS += -Wl,--whole-archive
$(foreach __lib,$(all_whole_static_libs_filename), \
	$(eval __external-add_LDFLAGS := $(__external-add_LDFLAGS),-l:$(notdir $(__lib))) \
)
__external-add_LDFLAGS := $(__external-add_LDFLAGS),--no-whole-archive
endif

# Static libraries
# With -l: to force using the given path
ifneq ("$(strip $(all_static_libs_filename))","")
$(foreach __lib,$(all_static_libs_filename), \
	$(eval __external-add_LDFLAGS := $(__external-add_LDFLAGS),-l:$(notdir $(__lib))) \
)
endif

# Shared libraries
# As one unique -Wl option otherwise libtool make a terrible mess with it
# (it splits -Wl otions from -l options making encapsulation useless)
# With -l: to force using the given path
ifneq ("$(strip $(all_shared_libs_filename))","")
__external-add_LDFLAGS += -Wl,--as-needed
$(foreach __lib,$(all_shared_libs_filename), \
	$(eval __external-add_LDFLAGS := $(__external-add_LDFLAGS),-l:$(notdir $(__lib))) \
)
__external-add_LDFLAGS := $(__external-add_LDFLAGS),--no-as-needed
endif

# Add local defined flags and libs
__external-add_LDFLAGS += $(LOCAL_LDFLAGS) $(LOCAL_LDLIBS)

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

# If revision of last build is not the same, do not skip external checks
# FIXME: modules dependending on this one will not be forced to be checked.
ifneq ("$(USE_GIT_REV)","0")
ifneq ("$(call module-check-revision-changed,$(LOCAL_MODULE))","")
  ifneq ("$(V)","0")
    $(info $(LOCAL_MODULE): revision has changed since last build)
  endif
  skip_ext_checks := 0
endif
endif

###############################################################################
## External checks : module built externaly may have other dependencies.
###############################################################################

# Update list of 'done' files with module file name
# Using sort ensures there is no duplicates in the list
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
$(LOCAL_TARGETS): PRIVATE_MODE := $(mode_prefix)

# This is for police hooks
$(LOCAL_TARGETS): export MODULE_NAME := $(LOCAL_MODULE)

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

ifneq ("$(USE_GIT_REV)","0")

# Generate the file containing the revision used in last build.
# Do not do that on a target with the name of the file to avoid reparsing
# everything when a change is made. Moreover, we want the file to be created
# AFTER module is built, not BEFORE (at time of inclusion of generated file).
$(LOCAL_MODULE): | $(LOCAL_MODULE)-gen-last-rev

.PHONY: $(LOCAL_MODULE)-gen-last-rev
$(LOCAL_MODULE)-gen-last-rev: PRIVATE_MODULE := $(LOCAL_MODULE)
$(LOCAL_MODULE)-gen-last-rev: PRIVATE_REV_FILE := $(revision_file)
$(LOCAL_MODULE)-gen-last-rev: $(LOCAL_BUILD_MODULE)
	@$(call generate-last-revision-file,$(PRIVATE_MODULE),$(PRIVATE_REV_FILE))

endif

# This will force to recheck this module if one of its dependencies is changed.
$(LOCAL_BUILD_MODULE): $(all_depends_build_filename)

# This explicit rule avoids dependency error when the module has nothing to build
# (prebuilt, sdk, custom...)
$(LOCAL_BUILD_MODULE):

###############################################################################
## Configuration file management.
###############################################################################

config_file := $(call module-get-config,$(LOCAL_MODULE))
autoconf_file := $(call module-get-autoconf,$(LOCAL_MODULE))
ifneq ("$(autoconf_file)","")

ifeq ("$(LOCAL_SDK)","")

# autoconf.h file depends on module config
$(autoconf_file): $(config_file)
	@$(call generate-autoconf-file,$<,$@)

else

# Copy autoconf file from sdk location
autoconf_file_sdk := $(LOCAL_SDK)/usr/include/$(LOCAL_MODULE)/autoconf-$(LOCAL_MODULE).h
$(eval $(call copy-one-file,$(autoconf_file_sdk),$(autoconf_file)))

endif # ifeq ("$(LOCAL_SDK)","")

# Don't forget to clean autoconf.h file
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(autoconf_file)

endif # ifneq ("$(autoconf_file)","")

###############################################################################
## Archive extraction + patches.
## Do this step if there is no archive but there is a post unpack command.
## This is to handle cases where a pre-configure step is needed but no
## real archive to unpack. And because there is no pre-cmd variables at the
## moment.
###############################################################################
ifneq ("$(or $(LOCAL_ARCHIVE),$(value LOCAL_ARCHIVE_CMD_POST_UNPACK))","")

# Full path to archive file (can be empty if we only want post unpack command)
ifneq ("$(strip $(LOCAL_ARCHIVE))","")
  archive_file := $(LOCAL_PATH)/$(LOCAL_ARCHIVE)
else
  archive_file :=
endif

# Name of files indicating steps done
# Using version allow to switch without having some dependencies troubles
ifneq ("$(LOCAL_ARCHIVE_VERSION)","")
  unpacked_file := $(build_dir)/$(LOCAL_MODULE)-$(LOCAL_ARCHIVE_VERSION).unpacked
else
  unpacked_file := $(build_dir)/$(LOCAL_MODULE).unpacked
endif

# Where to unpack
unpack_dir := $(build_dir)

# Patches to apply
patches := $(strip $(LOCAL_ARCHIVE_PATCHES))

# Generated files to be compiled will also depends on 'unpacked_file' in
# binary-rules.mk
all_prerequisites += $(unpacked_file)

define __archive-default-unpack
	$(Q) $(if $(patsubst %.zip,,$(PRIVATE_ARCHIVE)), \
		tar -C $(PRIVATE_ARCHIVE_UNPACK_DIR) -xf $(PRIVATE_ARCHIVE), \
		unzip -oq -d $(PRIVATE_ARCHIVE_UNPACK_DIR) $(PRIVATE_ARCHIVE) \
	)
endef

define __archive-apply-patches
	$(Q) $(BUILD_SYSTEM)/scripts/apply-patches.sh \
		$(PRIVATE_ARCHIVE_UNPACK_DIR)/$(PRIVATE_ARCHIVE_SUBDIR) \
		$(PRIVATE_PATH) \
		$(PRIVATE_ARCHIVE_PATCHES)
endef

$(unpacked_file): $(archive_file) $(addprefix $(LOCAL_PATH)/,$(patches))
ifneq ("$(archive_file)","")
	$(call print-banner2,Archive,$(PRIVATE_MODULE),Unpacking $(call path-from-top,$<))
	@mkdir -p $(PRIVATE_ARCHIVE_UNPACK_DIR)
	+$(call macro-exec-cmd,ARCHIVE_CMD_UNPACK,__archive-default-unpack)
	+$(if $(PRIVATE_ARCHIVE_PATCHES),$(__archive-apply-patches))
	$(call copy-license-files,$(PRIVATE_PATH),$(PRIVATE_ARCHIVE_UNPACK_DIR)/$(PRIVATE_ARCHIVE_SUBDIR))
endif
	+$(call macro-exec-cmd,ARCHIVE_CMD_POST_UNPACK,empty)
	@mkdir -p $(dir $@)
	@touch $@

$(LOCAL_TARGETS): PRIVATE_ARCHIVE := $(archive_file)
$(LOCAL_TARGETS): PRIVATE_ARCHIVE_UNPACK_DIR := $(unpack_dir)
$(LOCAL_TARGETS): PRIVATE_ARCHIVE_SUBDIR := $(LOCAL_ARCHIVE_SUBDIR)
$(LOCAL_TARGETS): PRIVATE_ARCHIVE_PATCHES := $(patches)

endif

###############################################################################
## Documentation generation rules.
###############################################################################

.PHONY: $(LOCAL_MODULE)-doc

# Define target variables because we don't inherit from 'standard' targets
$(LOCAL_MODULE)-doc: PRIVATE_MODULE := $(LOCAL_MODULE)
$(LOCAL_MODULE)-doc: PRIVATE_PATH := $(LOCAL_PATH)
$(LOCAL_MODULE)-doc: PRIVATE_DESCRIPTION := $(LOCAL_DESCRIPTION)
$(LOCAL_MODULE)-doc: PRIVATE_DOC_DIR := $(TARGET_OUT_DOC)/$(LOCAL_MODULE)

ifneq ("$(LOCAL_DOXYFILE)","")

# If a doxyfile has been defined by the user, we use it
# Check if the input paths are absolute and if not, correct them
doc_input := \$(shell egrep '^INPUT *=' $(LOCAL_DOXYFILE) | sed 's/^INPUT *=//g')
doc_input += $(LOCAL_DOXYGEN_INPUT)
doc_input := $(foreach __path,$(doc_input), \
	$(if $(call is-path-absolute,$(path)), \
		$(__path),$(addprefix $(LOCAL_PATH)/,$(__path)) \
	))

# Use the doxyfile, but override output to out/doc and input with absolute paths
$(LOCAL_MODULE)-doc: PRIVATE_INPUT := $(doc_input)
$(LOCAL_MODULE)-doc:
	@echo "$(PRIVATE_MODULE): Generating doxygen documentation from $^"
	@rm -rf $(PRIVATE_DOC_DIR)
	@mkdir -p $(PRIVATE_DOC_DIR)
	@( \
		cat $^; \
		echo 'PROJECT_NAME=$(PRIVATE_MODULE)'; \
		echo 'PROJECT_BRIEF="$(PRIVATE_DESCRIPTION)"'; \
		echo 'INPUT=$(PRIVATE_INPUT)'; \
		echo 'OUTPUT_DIRECTORY=$(PRIVATE_DOC_DIR)'; \
	) | doxygen - > $(PRIVATE_DOC_DIR)/doxygen.log
else

# Use LOCAL_PATH and other input
doc_input := $(LOCAL_PATH) $(LOCAL_DOXYGEN_INPUT)
doc_input := $(foreach __path,$(doc_input), \
	$(if $(call is-path-absolute,$(path)), \
		$(__path),$(addprefix $(LOCAL_PATH)/,$(__path)) \
	))

# If no doxyfile has been defined by the user, we generate one on the fly from
# a template created by doxygen which tries to document all and for all
# languages
# We disable warnings because they are plenty in this case
$(LOCAL_MODULE)-doc: PRIVATE_INPUT := $(doc_input)
$(LOCAL_MODULE)-doc:
	@echo "$(PRIVATE_MODULE): Generating doxygen documentation from generated doxyfile"
	@rm -rf $(PRIVATE_DOC_DIR)
	@mkdir -p $(PRIVATE_DOC_DIR)
	@( \
		doxygen -g -; \
		echo 'PROJECT_NAME=$(PRIVATE_MODULE)'; \
		echo 'PROJECT_BRIEF="$(PRIVATE_DESCRIPTION)"'; \
		echo 'EXTRACT_ALL=YES'; \
		echo 'GENERATE_LATEX=NO'; \
		echo 'WARNINGS=NO'; \
		echo 'WARN_IF_DOC_ERROR=NO'; \
		echo 'RECURSIVE=YES'; \
		echo 'INPUT=$(PRIVATE_INPUT)'; \
		echo 'EXCLUDE_PATTERNS=.git out sdk'; \
		echo 'OUTPUT_DIRECTORY=$(PRIVATE_DOC_DIR)'; \
	) | doxygen - > $(PRIVATE_DOC_DIR)/doxygen.log

endif

###############################################################################
## Code check rules.
###############################################################################

# Original data before import
codecheck_src_files := $(addprefix $(LOCAL_PATH)/,$(__modules.$(LOCAL_MODULE).SRC_FILES))
codecheck_c_includes := $(__modules.$(LOCAL_MODULE).C_INCLUDES)
codecheck_c_includes += $(__modules.$(LOCAL_MODULE).EXPORT_C_INCLUDES)
codecheck_c_includes += $(LOCAL_PATH)

# Search for include files in directories with source files
codecheck_c_includes += $(sort $(foreach __src,$(codecheck_src_files),$(dir $(__src))))
codecheck_c_includes := $(sort $(abspath $(codecheck_c_includes)))

# Checkpatch is only for c files
codecheck_files := $(filter %.c,$(codecheck_src_files))
codecheck_files += $(foreach __inc,$(codecheck_c_includes),$(wildcard $(__inc)/*.h))

codecheck_files := $(sort $(codecheck_files))

.PHONY: $(LOCAL_MODULE)-codecheck
$(LOCAL_MODULE)-codecheck:
	@for f in $(PRIVATE_CODECHECK_FILES); do \
		echo "$(PRIVATE_MODULE): Checking file $${f#$(TOP_DIR)/}"; \
		$(BUILD_SYSTEM)/scripts/checkpatch.pl \
			--no-tree --no-summary --terse --show-types -f \
			--ignore SPLIT_STRING \
			$(PRIVATE_CODECHECK_ARGS) $$f \
		|| true; \
	done

# Define target variables because we don't inherit from 'standard' targets
$(LOCAL_MODULE)-codecheck: PRIVATE_MODULE := $(LOCAL_MODULE)
$(LOCAL_MODULE)-codecheck: PRIVATE_CODECHECK_FILES := $(codecheck_files)
$(LOCAL_MODULE)-codecheck: PRIVATE_CODECHECK_ARGS := $(LOCAL_CODECHECK_ARGS)

###############################################################################
## Static library.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","STATIC_LIBRARY")
ifeq ("$(LOCAL_SDK)","")

include $(BUILD_SYSTEM)/binary-rules.mk

$(LOCAL_BUILD_MODULE): $(all_objects)
	$(transform-o-to-static-lib)
	$(call copy-license-files,$(PRIVATE_PATH),$(PRIVATE_BUILD_DIR))

copy_to_staging := 1

endif
endif

###############################################################################
## Shared library.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","SHARED_LIBRARY")
ifeq ("$(LOCAL_SDK)","")

include $(BUILD_SYSTEM)/binary-rules.mk

$(LOCAL_BUILD_MODULE): $(all_objects) $(all_link_libs_filenames)
	$(transform-o-to-shared-lib)
ifneq ("$(TARGET_ADD_DEPENDS_SECTION)","0")
	$(add-depends-section)
endif
ifneq ("$(TARGET_ADD_BUILDID_SECTION)","0")
	$(add-buildid-section)
endif
	$(call copy-license-files,$(PRIVATE_PATH),$(PRIVATE_BUILD_DIR))

copy_to_staging := 1
copy_to_final := 1

endif
endif

###############################################################################
## Executable.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","EXECUTABLE")

include $(BUILD_SYSTEM)/binary-rules.mk

$(LOCAL_BUILD_MODULE): $(all_objects) $(all_link_libs_filenames)
	$(transform-o-to-executable)
ifneq ("$(TARGET_ADD_DEPENDS_SECTION)","0")
	$(add-depends-section)
endif
ifneq ("$(TARGET_ADD_BUILDID_SECTION)","0")
	$(add-buildid-section)
endif
	$(call copy-license-files,$(PRIVATE_PATH),$(PRIVATE_BUILD_DIR))

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
## CMake.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","CMAKE")

include $(BUILD_SYSTEM)/cmake-rules.mk

endif

###############################################################################
## QMake.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","QMAKE")

include $(BUILD_SYSTEM)/qmake-rules.mk

endif

###############################################################################
## Prebuilt.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","PREBUILT")

# Simply 'touch' the 'done' file
$(LOCAL_BUILD_MODULE):
	@mkdir -p $(dir $@)
	@touch $@

endif

###############################################################################
## Custom.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","CUSTOM")

# This makes sure that the done file will be created. However this may trigger
# a rebuilt of some modules in a new execution of the build because this rule
# is executed at any time, and there is no build order associated.
$(LOCAL_MODULE):
	@( \
		done_file=$(call module-get-build-filename,$@); \
		if [ ! -f "$${done_file}" ]; then \
			if [ "$(__modules.$@.check-done-file-created)" != "" ]; then \
				echo "warning: custom module '$@' did not create $${done_file}"; \
			fi; \
			mkdir -p $$(dirname $${done_file}); \
			touch $${done_file}; \
		fi; \
	)

endif

###############################################################################
## Meta package.
###############################################################################

ifeq ("$(LOCAL_MODULE_CLASS)","META_PACKAGE")

# Add a meta package dependency
# $1 : module name
# $2 : dependency name
define __meta-package-dep
$1: $2
$1-clean: $2-clean
$1-dirclean: $2-dirclean
endef

# Add deps for build, clean, dirclean
$(foreach __mod,$(call module-get-config-depends,$(LOCAL_MODULE)), \
	$(eval $(call __meta-package-dep,$(LOCAL_MODULE),$(__mod))) \
)

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
	$(eval __dst := $(call copy-get-dst-path$(mode_suffix),$(__w2))) \
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
	$(if $(filter $(__src),$(all_prerequisites)),$(empty), \
		$(eval $(__src): | $(all_copy_files_prerequisites)) \
	) \
)

# Add files to be copied as an order-only dependency (does not force rebuild)
$(LOCAL_BUILD_MODULE): | $(all_copy_files_dst)

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
	$(eval __name := $($(mode_prefix)OUT_STAGING)/$(__w1)) \
	$(eval __target := $(__w2)) \
	$(eval all_create_links += $(__name)) \
	$(eval $(call create-one-link,$(__name),$(__target))) \
)

# Add links to be created as an order-only dependency (does not force rebuild)
$(LOCAL_BUILD_MODULE): | $(all_create_links)

# Add rule to delete created links during clean
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(all_create_links)

endif

###############################################################################
## Prerequisites.
###############################################################################

# Make sure all prerequisites files are generated first
# But do NOT force recompilation (order only)
$(LOCAL_BUILD_MODULE): | $(all_prerequisites)

# Prerequisites that are not ours
all_external_prerequisites := $(filter-out \
	$(LOCAL_CUSTOM_TARGETS) \
	$(LOCAL_PREREQUISITES) \
	$(LOCAL_EXPORT_PREREQUISITES), $(all_prerequisites))

# Same thing for custom targets of the module (but excludes the ones of the module)
$(LOCAL_CUSTOM_TARGETS): | $(all_external_prerequisites)
$(LOCAL_PREREQUISITES): | $(all_external_prerequisites)
$(LOCAL_EXPORT_PREREQUISITES): | $(all_external_prerequisites)

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

ifneq ("$(mode_host)","1")
ifneq ("$(wildcard $(TARGET_OUT_FINAL))","")

LOCAL_FINAL_MODULE := $(LOCAL_STAGING_MODULE:$(TARGET_OUT_STAGING)/%=$(TARGET_OUT_FINAL)/%)
$(LOCAL_MODULE): $(LOCAL_FINAL_MODULE)

# Strip if needed, otherwise simply copy
ifeq ("$(TARGET_NOSTRIP_FINAL)","1")
$(eval $(call copy-one-file,$(LOCAL_STAGING_MODULE),$(LOCAL_FINAL_MODULE)))
else ifneq ("$(filter $(TARGET_STRIP_FILTER),$(LOCAL_MODULE_FILENAME))","")
$(eval $(call copy-one-file,$(LOCAL_STAGING_MODULE),$(LOCAL_FINAL_MODULE)))
else
$(LOCAL_FINAL_MODULE): $(LOCAL_STAGING_MODULE)
	@echo "Strip: $(call path-from-top,$<) => $(call path-from-top,$@)"
	@mkdir -p $(dir $@)
	$(Q)$(TARGET_STRIP) -o $@ $<
endif

endif # ifneq ("$(wildcard $(TARGET_OUT_FINAL))","")
endif # ifneq ("$(mode_host)","1")

endif # ifeq ("$(copy_to_final)","1")

endif # ifeq ("$(copy_to_staging)","1")

###############################################################################
## Pre-install customization
###############################################################################

ifneq ("$(value LOCAL_CMD_PRE_INSTALL)","")

$(preinstall_file):
	+$(call macro-exec-cmd,CMD_PRE_INSTALL,empty)
	@mkdir -p $(dir $@)
	@touch $@

$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(preinstall_file)

# If a copy in staging is done do it before. Otherwise we can only hook before
# build module is done...
# Order only prerequiqites to avoid recompilation...
ifeq ("$(copy_to_staging)","1")
$(LOCAL_STAGING_MODULE): | $(preinstall_file)
else
$(LOCAL_BUILD_MODULE): | $(preinstall_file)
endif

endif
