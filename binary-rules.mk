###############################################################################
## @file binary-rules.mk
## @author Y.M. Morgan
## @date 2011/05/14
##
## Generate rules for building an executable or library.
###############################################################################

# Prepend some directories in include list
LOCAL_C_INCLUDES := $(build_dir) $(LOCAL_PATH) $(LOCAL_C_INCLUDES)

# TODO : remove this when all libraries have removed their dependencies toward
# config.h and autoconf.h
# force unsigned char always (default on arm, but not on PC_Linux)
ifneq ("$(strip $(LOCAL_PBUILD_HOOK))","")
  LOCAL_C_INCLUDES += $(BUILD_SYSTEM)/pbuild-hook
  LOCAL_CFLAGS += -funsigned-char
endif

###############################################################################
## ARM specific checks.
###############################################################################
ifeq ("$(TARGET_ARCH)","arm")

# Make sure LOCAL_ARM_MODE is valid
# If not set, use default mode
# Convert to upper case for further use
LOCAL_ARM_MODE := $(strip $(LOCAL_ARM_MODE))
ifeq ("$(LOCAL_ARM_MODE)","")
  LOCAL_ARM_MODE := $(TARGET_DEFAULT_ARM_MODE)
endif
ifneq ("$(LOCAL_ARM_MODE)","arm")
ifneq ("$(LOCAL_ARM_MODE)","thumb")
  $(error $(LOCAL_PATH): LOCAL_ARM_MODE is not valid : $(LOCAL_ARM_MODE))
endif
endif

# Check that -marm or -mthumb is not forced in compilation flags
check-flags-arm-mode := -marm -mthumb
check-flags-arm-mode-message := please use LOCAL_ARM_MODE
$(call check-flags,LOCAL_CFLAGS,$(check-flags-arm-mode),$(check-flags-arm-mode-message))
$(call check-flags,LOCAL_CPPFLAGS,$(check-flags-arm-mode),$(check-flags-arm-mode-message))
$(call check-flags,LOCAL_EXPORT_CFLAGS,$(check-flags-arm-mode),$(check-flags-arm-mode-message))
$(call check-flags,LOCAL_EXPORT_CPPFLAGS,$(check-flags-arm-mode),$(check-flags-arm-mode-message))

endif

###############################################################################
## Generic checks.
###############################################################################

# Do not put -O0 in flags, use debug setup makefil
check-flags-debug := -O0
check-flags-debug-message := please use custom $(debug-setup-makefile) in top dir
$(call check-flags,LOCAL_CFLAGS,$(check-flags-debug),$(check-flags-debug-message))
$(call check-flags,LOCAL_CPPFLAGS,$(check-flags-debug),$(check-flags-debug-message))
$(call check-flags,LOCAL_EXPORT_CFLAGS,$(check-flags-debug),$(check-flags-debug-message))
$(call check-flags,LOCAL_EXPORT_CPPFLAGS,$(check-flags-debug),$(check-flags-debug-message))


###############################################################################
## List of sources, objects and libraries.
###############################################################################

cpp_sources := $(filter %.cpp,$(LOCAL_SRC_FILES))
cpp_objects := $(addprefix $(build_dir)/obj/,$(cpp_sources:.cpp=.o))

cxx_sources := $(filter %.cxx,$(LOCAL_SRC_FILES))
cxx_objects := $(addprefix $(build_dir)/obj/,$(cxx_sources:.cxx=.o))

cc_sources := $(filter %.cc,$(LOCAL_SRC_FILES))
cc_objects := $(addprefix $(build_dir)/obj/,$(cc_sources:.cc=.o))

c_sources := $(filter %.c,$(LOCAL_SRC_FILES))
c_objects := $(addprefix $(build_dir)/obj/,$(c_sources:.c=.o))

s_sources := $(filter %.s,$(LOCAL_SRC_FILES))
s_objects := $(addprefix $(build_dir)/obj/,$(s_sources:.s=.o))

S_sources := $(filter %.S,$(LOCAL_SRC_FILES))
S_objects := $(addprefix $(build_dir)/obj/,$(S_sources:.S=.o))

all_objects := \
	$(cpp_objects) \
	$(cxx_objects) \
	$(cc_objects) \
	$(c_objects) \
	$(s_objects) \
	$(S_objects)

# Get libraries used by us and static libraries
LOCAL_EXTERNAL_LIBRARIES := \
	$(call module-get-static-depends,$(LOCAL_MODULE),EXTERNAL_LIBRARIES)
LOCAL_STATIC_LIBRARIES := \
	$(call module-get-static-depends,$(LOCAL_MODULE),STATIC_LIBRARIES)
LOCAL_WHOLE_STATIC_LIBRARIES := \
	$(call module-get-static-depends,$(LOCAL_MODULE),WHOLE_STATIC_LIBRARIES)
LOCAL_SHARED_LIBRARIES := \
	$(call module-get-static-depends,$(LOCAL_MODULE),SHARED_LIBRARIES)

# Get path
all_static_libraries := \
	$(foreach lib,$(LOCAL_STATIC_LIBRARIES), \
		$(call module-get-staging-filename,$(lib)))

all_whole_static_libraries := \
	$(foreach lib,$(LOCAL_WHOLE_STATIC_LIBRARIES), \
		$(call module-get-staging-filename,$(lib)))

all_shared_libraries := \
	$(foreach lib,$(LOCAL_SHARED_LIBRARIES), \
		$(call module-get-staging-filename,$(lib)))

# all_libraries is used for the dependencies at link time
# external libraries are used as prerequisites in module.mk
all_libraries := \
	$(all_static_libraries) \
	$(all_whole_static_libraries) \
	$(all_shared_libraries)

# List of our dependencies and from static
LOCAL_LIBRARIES := \
	$(LOCAL_EXTERNAL_LIBRARIES) \
	$(LOCAL_STATIC_LIBRARIES) \
	$(LOCAL_WHOLE_STATIC_LIBRARIES) \
	$(LOCAL_SHARED_LIBRARIES)

###############################################################################
## Import of dependencies.
###############################################################################

# Get list of exported stuff by our dependencies
# Note: LDLIBS only get ours and import from static dependencies.
# Other import are done on full dependency to make sure that include path
# are propagated even for shared library import
imported_CFLAGS        := $(call module-get-listed-export,$(all_depends),CFLAGS)
imported_CPPFLAGS      := $(call module-get-listed-export,$(all_depends),CPPFLAGS)
imported_C_INCLUDES    := $(call module-get-listed-export,$(all_depends),C_INCLUDES)
imported_LDLIBS        := $(call module-get-listed-export,$(LOCAL_LIBRARIES),LDLIBS)
imported_PREREQUISITES := $(call module-get-listed-export,$(all_depends),PREREQUISITES)

# The imported/exported compiler flags are prepended to their LOCAL_XXXX value
# (this allows the module to override them).
LOCAL_CFLAGS     := $(strip $(imported_CFLAGS) $(LOCAL_EXPORT_CFLAGS) $(LOCAL_CFLAGS))
LOCAL_CPPFLAGS   := $(strip $(imported_CPPFLAGS) $(LOCAL_EXPORT_CPPFLAGS) $(LOCAL_CPPFLAGS))

# The imported/exported include directories are appended to their LOCAL_XXX value
# (this allows the module to override them)
LOCAL_C_INCLUDES := $(strip $(LOCAL_C_INCLUDES) $(LOCAL_EXPORT_C_INCLUDES) $(imported_C_INCLUDES))

# Similarly, you want the imported/exported flags to appear _after_ the LOCAL_LDLIBS
# due to the way Unix linkers work (depending libraries must appear before
# dependees on final link command).
LOCAL_LDLIBS     := $(strip $(LOCAL_LDLIBS) $(LOCAL_EXPORT_LDLIBS) $(imported_LDLIBS))

# Get all autoconf files that we depend on, don't forget to add ourself
all_autoconf := \
	$(call module-get-listed-autoconf,$(all_depends)) \
	$(call module-get-autoconf,$(LOCAL_MODULE))

# Force their inclusion (space after -include and before comma is important)
LOCAL_CFLAGS += $(addprefix -include ,$(all_autoconf))

# Inport prerequisites
all_prerequisites += $(imported_PREREQUISITES)

# All autoconf files are prerequisites
all_prerequisites += $(all_autoconf)

# Notify that we build with dependencies
LOCAL_CFLAGS += $(foreach __mod,$(all_depends), \
	-DBUILD_$(call get-define,$(__mod)))

# User makefile is an internal dependencies
all_internal_depends := $(LOCAL_PATH)/$(USER_MAKEFILE_NAME)

###############################################################################
## Add debug flags.
###############################################################################

debug_CFLAGS := $(call module-get-debug-flags,$(LOCAL_MODULE),CFLAGS)
debug_CPPFLAGS := $(call module-get-debug-flags,$(LOCAL_MODULE),CPPFLAGS)
debug_LDFLAGS := $(call module-get-debug-flags,$(LOCAL_MODULE),LDFLAGS)

ifneq ("$(debug_CFLAGS)","")
  ifneq ("$(V)","0")
    $(info Adding '$(debug_CFLAGS)' to '$(LOCAL_MODULE)' CFLAGS)
  endif
  LOCAL_CFLAGS += $(debug_CFLAGS)
endif

ifneq ("$(debug_CPPFLAGS)","")
  ifneq ("$(V)","0")
    $(info Adding '$(debug_CPPFLAGS)' to '$(LOCAL_MODULE)' CPPFLAGS)
  endif
  LOCAL_CPPFLAGS += $(debug_CPPFLAGS)
endif

ifneq ("$(debug_LDFLAGS)","")
  ifneq ("$(V)","0")
    $(info Adding '$(debug_LDFLAGS)' to '$(LOCAL_MODULE)' LDFLAGS)
  endif
  LOCAL_LDFLAGS += $(debug_LDFLAGS)
endif

###############################################################################
## Actual rules.
###############################################################################

# cpp files
ifneq ("$(strip $(cpp_objects))","")
$(cpp_objects): $(build_dir)/obj/%.o: $(LOCAL_PATH)/%.cpp
	$(transform-cpp-to-o)
ifneq ("$(skip_include_deps)","1")
-include $(cpp_objects:%.o=%.d)
endif
endif

# cxx files
ifneq ("$(strip $(cxx_objects))","")
$(cxx_objects): $(build_dir)/obj/%.o: $(LOCAL_PATH)/%.cxx
	$(transform-cpp-to-o)
ifneq ("$(skip_include_deps)","1")
-include $(cxx_objects:%.o=%.d)
endif
endif

# cc files
ifneq ("$(strip $(cc_objects))","")
$(cc_objects): $(build_dir)/obj/%.o: $(LOCAL_PATH)/%.cc
	$(transform-cpp-to-o)
ifneq ("$(skip_include_deps)","1")
-include $(cc_objects:%.o=%.d)
endif
endif

# c files
ifneq ("$(strip $(c_objects))","")
$(c_objects): $(build_dir)/obj/%.o: $(LOCAL_PATH)/%.c
	$(transform-c-to-o)
ifneq ("$(skip_include_deps)","1")
-include $(c_objects:%.o=%.d)
endif
endif

# s files
# There is NO dependency files for raw asm code...
ifneq ("$(strip $(s_objects))","")
$(s_objects): $(build_dir)/obj/%.o: $(LOCAL_PATH)/%.s
	$(transform-s-to-o)
endif

# S files
# There is dependency files for asm code...
ifneq ("$(strip $(S_objects))","")
$(S_objects): $(build_dir)/obj/%.o: $(LOCAL_PATH)/%.S
	$(transform-s-to-o)
ifneq ("$(skip_include_deps)","1")
-include $(S_objects:%.o=%.d)
endif
endif

# Make sure all prerequisites files are generated first
# But do NOT force recompilation (order only)
ifneq ("$(all_prerequisites)","")
$(all_objects): | $(all_prerequisites)
endif

# Force recompilation if internal dependencies are changes
$(all_objects): $(all_internal_depends)

# Clean objects
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(build_dir)/$(LOCAL_MODULE).map
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(all_objects)
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(all_objects:%.o=%.d)

###############################################################################
## Precompiled headers.
###############################################################################

LOCAL_PRECOMPILED_FILE := $(strip $(LOCAL_PRECOMPILED_FILE))
ifneq ("$(LOCAL_PRECOMPILED_FILE)","")

gch_file := $(build_dir)/$(LOCAL_PRECOMPILED_FILE).gch

# All objects will depends on the precompiled file
$(all_objects): $(gch_file)

# Make sure all prerequisites files are generated first
# But do NOT force recompilation (order only)
ifneq ("$(all_prerequisites)","")
$(gch_file): | $(all_prerequisites)
endif

# Force recompilation if internal dependencies are changes
$(gch_file): $(all_internal_depends)

# Generate the precompiled file
$(gch_file): $(LOCAL_PATH)/$(LOCAL_PRECOMPILED_FILE)
	$(transform-h-to-gch)
ifneq ("$(skip_include_deps)","1")
-include $(gch_file:%.gch=%.d)
endif

# Clean precompiled header
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(gch_file)
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(gch_file:%.gch=%.d)

endif

###############################################################################
## Rule-specific variable definitions.
###############################################################################

# Mode to display
mode :=
ifeq ("$(TARGET_ARCH)","arm")
  mode := $(LOCAL_ARM_MODE)
else
  mode := $(TARGET_ARCH)
endif

# Force pbuild hook if a static library needs it
$(foreach __mod,$(LOCAL_STATIC_LIBRARIES) $(LOCAL_WHOLE_STATIC_LIBRARIES), \
	$(if $(__modules.$(__mod).PBUILD_HOOK), \
		$(eval LOCAL_PBUILD_HOOK := 1) \
	) \
)

$(LOCAL_TARGETS): PRIVATE_CFLAGS := $(LOCAL_CFLAGS)
$(LOCAL_TARGETS): PRIVATE_C_INCLUDES := $(LOCAL_C_INCLUDES)
$(LOCAL_TARGETS): PRIVATE_CPPFLAGS := $(LOCAL_CPPFLAGS)
$(LOCAL_TARGETS): PRIVATE_ARFLAGS := $(LOCAL_ARFLAGS)
$(LOCAL_TARGETS): PRIVATE_LDFLAGS := $(LOCAL_LDFLAGS)
$(LOCAL_TARGETS): PRIVATE_LDLIBS := $(LOCAL_LDLIBS)
$(LOCAL_TARGETS): PRIVATE_MODE := $(mode)
$(LOCAL_TARGETS): PRIVATE_PBUILD_HOOK := $(LOCAL_PBUILD_HOOK)
$(LOCAL_TARGETS): PRIVATE_ALL_SHARED_LIBRARIES := $(all_shared_libraries)
$(LOCAL_TARGETS): PRIVATE_ALL_STATIC_LIBRARIES := $(all_static_libraries)
$(LOCAL_TARGETS): PRIVATE_ALL_WHOLE_STATIC_LIBRARIES := $(all_whole_static_libraries)
$(LOCAL_TARGETS): PRIVATE_ALL_OBJECTS := $(all_objects)

