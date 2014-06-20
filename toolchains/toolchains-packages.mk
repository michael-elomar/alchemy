###############################################################################
## @file toolchains-packages.mk
## @author Y.M. Morgan
## @date 2012/11/08
##
## This file contains additional packages for toolchains.
###############################################################################

LOCAL_PATH := $(call my-dir)

###############################################################################
## Rules to install libc files in the staging directory.
###############################################################################

# When a sdk is used, assume we are not building a full system, so no installation
# of libs files is done in staging directory
ifeq ("$(TARGET_SDK_DIRS)","")
ifneq ("$(TOOLCHAIN_LIBC)","")

include $(CLEAR_VARS)

LOCAL_MODULE := toolchain-libc
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

# File indicating that installation was done
toolchain_libc_installed_file := $(call local-get-build-dir)/$(LOCAL_MODULE).installed

# Get the path of a libc file in the staging directory.
# $1 : path of the libc file in the toolchain directory.
toolchain_libc_get_staging_path = \
	$(subst $(TOOLCHAIN_LIBC),$(TARGET_OUT_STAGING),$1)

# List of source files
toolchain_libc_src_files := \
	$(wildcard $(TOOLCHAIN_LIBC)/lib/*.so*) \
	$(wildcard $(TOOLCHAIN_LIBC)/usr/lib/libstdc++*.so*) \
	$(wildcard $(TOOLCHAIN_LIBC)/usr/bin/ldd)

# List of source directories
toolchain_libc_src_dirs :=

# Timezone data
ifneq ("$(TARGET_INCLUDE_TZDATA)","0")
  toolchain_libc_src_dirs += $(TOOLCHAIN_LIBC)/usr/share/zoneinfo
endif

# Locale data
ifneq ("$(TARGET_INCLUDE_GCONV)","0")
  toolchain_libc_src_dirs += $(TOOLCHAIN_LIBC)/usr/lib/gconv
endif

# Include gdbserver only if requested (GPLv3)
ifneq ("$(TARGET_INCLUDE_GDBSERVER)","0")
ifneq ("$(TOOLCHAIN_GDBSERVER)","")
  toolchain_libc_src_files += $(TOOLCHAIN_GDBSERVER)
endif
endif

# Install rule
# use $(endl) to separate commands on separate lines
$(toolchain_libc_installed_file):
	@mkdir -p $(dir $@)
	$(foreach __f,$(toolchain_libc_src_files), \
		@mkdir -p $(dir $(call toolchain_libc_get_staging_path,$(__f)))$(endl) \
		$(Q) cp -af $(__f) $(call toolchain_libc_get_staging_path,$(__f))$(endl) \
	)
	$(foreach __d,$(toolchain_libc_src_dirs), \
		@mkdir -p $(call toolchain_libc_get_staging_path,$(__d))$(endl) \
		$(Q) cp -Raf $(__d)/* $(call toolchain_libc_get_staging_path,$(__d))$(endl) \
	)
	$(Q) if [ -f $(TARGET_OUT_STAGING)/usr/bin/ldd ]; then \
		sed -i -e 's|^\#! */bin/bash$$|\#!/bin/sh|' $(TARGET_OUT_STAGING)/usr/bin/ldd; \
	fi
	@touch $@

# Clean rule
# use $(endl) to separate commands on separate lines
.PHONY: toolchain-libc-clean
toolchain-libc-clean:
	$(foreach __f,$(toolchain_libc_src_files), \
		$(Q) rm -f $(call toolchain_libc_get_staging_path,$(__f))$(endl) \
	)
	$(foreach __d,$(toolchain_libc_src_dirs), \
		$(Q) rm -rf $(call toolchain_libc_get_staging_path,$(__d))$(endl) \
	)
	@rm -f $(toolchain_libc_installed_file)

# Register 'installed' file in build system
$(call local-get-build-dir)/$(LOCAL_MODULE_FILENAME): $(toolchain_libc_installed_file)
LOCAL_DONE_FILES += $(LOCAL_MODULE).installed
LOCAL_CLEAN_FILES += $(toolchain_libc_installed_file)
LOCAL_CUSTOM_TARGETS += $(toolchain_libc_installed_file)

# Make sure this is the first module built
TARGET_GLOBAL_PREREQUISITES += $(toolchain_libc_installed_file)

# Prebuilt so it is always enabled and does not appear in config
include $(BUILD_PREBUILT)

endif # ifneq ("$(TOOLCHAIN_LIBC)","")
endif # ifeq ("$(TARGET_SDK_DIRS)","")

###############################################################################
## Include specific libc packages.
###############################################################################

include $(BUILD_SYSTEM)/toolchains/$(TARGET_LIBC)/$(TARGET_LIBC)-packages.mk
