###############################################################################
## @file cmake-setup.mk
## @author Y.M. Morgan
## @date 2013/07/24
###############################################################################

###############################################################################
## Variables used for cmake.
###############################################################################

CMAKE := $(shell which cmake)

CMAKE_TOOLCHAIN_FILE := $(TARGET_OUT_BUILD)/toolchainfile.cmake

CMAKE_C_FLAGS := \
	$(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES)) \
	$(TARGET_GLOBAL_CFLAGS)

CMAKE_CXX_FLAGS := \
	$(CMAKE_C_FLAGS) \
	$(TARGET_GLOBAL_CXXFLAGS)

CMAKE_EXE_LINKER_FLAGS := \
	$(TARGET_GLOBAL_LDFLAGS) $(TARGET_GLOBAL_LDLIBS)

CMAKE_SHARED_LINKER_FLAGS := \
	$(TARGET_GLOBAL_LDFLAGS_SHARED) $(TARGET_GLOBAL_LDLIBS_SHARED)

CMAKE_CONFIGURE_ARGS := \
	-DCMAKE_INSTALL_PREFIX="$(TARGET_AUTOTOOLS_CONFIGURE_PREFIX)" \

CMAKE_MAKE_ARGS := \
	DESTDIR="$(TARGET_AUTOTOOLS_INSTALL_DESTDIR)"

# Quiet/Verbose flags
ifeq ("$(V)","0")
  CMAKE_MAKE_ARGS += -s --no-print-directory
else
  CMAKE_MAKE_ARGS += VERBOSE=1
endif

###############################################################################
## Generation of toolchain file.
###############################################################################

define cmake-gen-toolchain-file
	echo "set(CMAKE_SYSTEM_NAME Linux)"; \
	echo "set(CMAKE_C_COMPILER \"$(TARGET_CC)\")"; \
	echo "set(CMAKE_CXX_COMPILER \"$(TARGET_CXX)\")"; \
	echo "set(CMAKE_AR \"$(TARGET_AR)\" CACHE FILEPATH "Archiver")"; \
	echo "set(CMAKE_LINKER \"$(TARGET_LD)\")"; \
	echo "set(CMAKE_C_FLAGS \
		\"$(CMAKE_C_FLAGS) \$${ALCHEMY_EXTRA_C_FLAGS}\" \
		CACHE STRING \"C_FLAGS\" FORCE)"; \
	echo "set(CMAKE_CXX_FLAGS \
		\"$(CMAKE_CXX_FLAGS) \$${ALCHEMY_EXTRA_CXX_FLAGS}\" \
		CACHE STRING \"CXX_FLAGS\" FORCE)"; \
	echo "set(CMAKE_EXE_LINKER_FLAGS \
		\"$(CMAKE_EXE_LINKER_FLAGS) \$${ALCHEMY_EXTRA_EXE_LINKER_FLAGS}\" \
		CACHE STRING \"EXE_LINKER_FLAGS\" FORCE)"; \
	echo "set(CMAKE_SHARED_LINKER_FLAGS \
		\"$(CMAKE_SHARED_LINKER_FLAGS) \$${ALCHEMY_EXTRA_SHARED_LINKER_FLAGS}\" \
		CACHE STRING \"SHARED_LINKER_FLAGS\" FORCE)"; \
	echo "set(CMAKE_INSTALL_SO_NO_EXE 0)"; \
	echo "set(CMAKE_FIND_ROOT_PATH \"$(TARGET_OUT_STAGING)\")"; \
	echo "set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)"; \
	echo "set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)"; \
	echo "set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)"; \
	echo "set(CMAKE_COLOR_MAKEFILE OFF CACHE BOOL \"COLOR_MAKEFILE\" FORCE)";
endef

# Regenerate the toolchain file if toolchain setup makefiles are updated
$(CMAKE_TOOLCHAIN_FILE): $(BUILD_SYSTEM)/cmake-setup.mk
$(CMAKE_TOOLCHAIN_FILE): $(BUILD_SYSTEM)/toolchains/*.mk
$(CMAKE_TOOLCHAIN_FILE): $(BUILD_SYSTEM)/toolchains/*/*.mk

$(CMAKE_TOOLCHAIN_FILE):
	@mkdir -p $(dir $@)
	@($(cmake-gen-toolchain-file)) > $@

.PHONY: cmake-toolchain-file-clean
cmake-toolchain-file-clean:
	$(Q) rm -f $(CMAKE_TOOLCHAIN_FILE)

clean: cmake-toolchain-file-clean
dirclean: cmake-toolchain-file-clean
clobber: cmake-toolchain-file-clean
