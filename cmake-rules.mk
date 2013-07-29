###############################################################################
## @file cmake-rules.mk
## @author Y.M. Morgan
## @date 2013/07/24
##
## Build a module using cmake.
###############################################################################

ifeq ("$(CMAKE)","")
  $(error $(LOCAL_MODULE): cmake not found)
endif

###############################################################################
## Add compilation/debug flags.
###############################################################################

# Compilation flags
__cmake-add_CFLAGS := $(LOCAL_CFLAGS) $(call normalize-c-includes,$(LOCAL_C_INCLUDES))
__cmake-add_CXXFLAGS := $(__cmake-add_CFLAGS) $(LOCAL_CXXFLAGS)
__cmake-add_LDFLAGS := $(LOCAL_LDFLAGS)

# Debug flags
__cmake-debug_CFLAGS := $(call module-get-debug-flags,$(LOCAL_MODULE),CFLAGS)
__cmake-debug_CXXFLAGS := $(call module-get-debug-flags,$(LOCAL_MODULE),CXXFLAGS)
__cmake-debug_LDFLAGS := $(call module-get-debug-flags,$(LOCAL_MODULE),LDFLAGS)

# Print debug messages
ifneq ("$(__cmake-debug_CFLAGS)","")
  $(info Debug: Adding '$(__cmake-debug_CFLAGS)' to '$(LOCAL_MODULE)' CFLAGS and CXXFLAGS)
  __cmake-add_CFLAGS += $(__cmake-debug_CFLAGS)
  __cmake-add_CXXFLAGS += $(__cmake-debug_CFLAGS)
endif

ifneq ("$(__cmake-debug_CXXFLAGS)","")
  $(info Debug: Adding '$(__cmake-debug_CXXFLAGS)' to '$(LOCAL_MODULE)' CXXFLAGS)
  __cmake-add_CXXFLAGS += $(__cmake-debug_CXXFLAGS)
endif

ifneq ("$(__cmake-debug_LDFLAGS)","")
  $(info Debug: Adding '$(__cmake-debug_LDFLAGS)' to '$(LOCAL_MODULE)' LDFLAGS)
  __cmake-add_LDFLAGS += $(__cmake-debug_LDFLAGS)
endif

# Add flags in arguments (ALCHEMY_EXTRA are added by the toolchain file)
ifneq ("$(__cmake-add_CFLAGS)","")
  LOCAL_CMAKE_CONFIGURE_ARGS += -DALCHEMY_EXTRA_C_FLAGS="$(__cmake-add_CFLAGS)"
endif

ifneq ("$(__cmake-add_CXXFLAGS)","")
  LOCAL_CMAKE_CONFIGURE_ARGS += -DALCHEMY_EXTRA_CXX_FLAGS="$(__cmake-add_CXXFLAGS)"
endif

ifneq ("$(__cmake-add_LDFLAGS)","")
  LOCAL_CMAKE_CONFIGURE_ARGS += -DALCHEMY_EXTRA_EXE_LINKER_FLAGS="$(__cmake-add_LDFLAGS)"
  LOCAL_CMAKE_CONFIGURE_ARGS += -DALCHEMY_EXTRA_SHARED_LINKER_FLAGS="$(__cmake-add_LDFLAGS)"
endif

###############################################################################
## Default commands
###############################################################################

# This file is included several times, define macros only once
# (mainly to improve perf)
ifndef __cmake-macros

define __cmake-default-cmd-configure
	@mkdir -p $(PRIVATE_OBJ_DIR)
	$(Q) cd $(PRIVATE_OBJ_DIR) && rm -f CMakeCache.txt && \
		$(CMAKE) $(PRIVATE_SRC_DIR) \
			-DCMAKE_TOOLCHAIN_FILE="$(CMAKE_TOOLCHAIN_FILE)" \
			$(CMAKE_CONFIGURE_ARGS) $(PRIVATE_CONFIGURE_ARGS)
endef

define __cmake-default-cmd-build
	$(Q) $(MAKE) -C $(PRIVATE_OBJ_DIR) \
		$(CMAKE_MAKE_ARGS) $(PRIVATE_MAKE_BUILD_ARGS)
endef

define __cmake-default-cmd-install
	$(Q) $(MAKE) -C $(PRIVATE_OBJ_DIR) \
		$(CMAKE_MAKE_ARGS) $(PRIVATE_MAKE_INSTALL_ARGS) install
endef

# Force success for command in case "uninstall" or "clean" is not supported
# or Makefile not present
define __cmake-default-cmd-clean
	$(Q) if [ -f $(PRIVATE_OBJ_DIR)/Makefile ]; then \
		$(MAKE) --keep-going --ignore-errors -C $(PRIVATE_OBJ_DIR) \
			$(CMAKE_MAKE_ARGS) $(PRIVATE_MAKE_INSTALL_ARGS) \
			uninstall || echo "Ignoring uninstall errors"; \
		$(MAKE) --keep-going --ignore-errors -C $(PRIVATE_OBJ_DIR) \
			$(CMAKE_MAKE_ARGS) \
			clean || echo "Ignoring clean errors"; \
	fi;
endef

endif # ifndef __cmake-macros

###############################################################################
###############################################################################

# Build out of source tree (even for unpacked archives)
generic-build-out-of-src := 1

include $(BUILD_SYSTEM)/generic-rules.mk

# Generate cmake toolchain file before configuring
$(configured_file): $(CMAKE_TOOLCHAIN_FILE)

# Setup commands
$(LOCAL_TARGETS): PRIVATE_MSG := CMake
$(LOCAL_TARGETS): PRIVATE_CMD_PREFIX := CMAKE
$(LOCAL_TARGETS): PRIVATE_DEFAULT_CMD_CONFIGURE := __cmake-default-cmd-configure
$(LOCAL_TARGETS): PRIVATE_DEFAULT_CMD_BUILD := __cmake-default-cmd-build
$(LOCAL_TARGETS): PRIVATE_DEFAULT_CMD_INSTALL := __cmake-default-cmd-install
$(LOCAL_TARGETS): PRIVATE_DEFAULT_CMD_CLEAN := __cmake-default-cmd-clean


# Variables needed by default commands
$(LOCAL_TARGETS): PRIVATE_CONFIGURE_ARGS := $(LOCAL_CMAKE_CONFIGURE_ARGS)
$(LOCAL_TARGETS): PRIVATE_MAKE_BUILD_ARGS := $(LOCAL_CMAKE_MAKE_BUILD_ARGS)
$(LOCAL_TARGETS): PRIVATE_MAKE_INSTALL_ARGS := $(LOCAL_CMAKE_MAKE_INSTALL_ARGS)

# Macros of this file have been defined
__cmake-macros := 1
