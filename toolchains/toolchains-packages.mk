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

# List of files to be put in /lib
toolchain_libc_lib_files :=
ifneq ("$(wildcard $(TOOLCHAIN_LIBC)/lib/$(TOOLCHAIN_TARGET_NAME))","")
  toolchain_libc_lib_files += $(wildcard $(TOOLCHAIN_LIBC)/lib/$(TOOLCHAIN_TARGET_NAME)/*.so*)
else
  toolchain_libc_lib_files += $(wildcard $(TOOLCHAIN_LIBC)/lib/*.so*)
endif

# List of files to be put in /usr/lib
toolchain_libc_usrlib_files :=
ifneq ("$(wildcard $(TOOLCHAIN_LIBC)/usr/lib/$(TOOLCHAIN_TARGET_NAME))","")
  toolchain_libc_usrlib_files += $(wildcard $(TOOLCHAIN_LIBC)/usr/lib/$(TOOLCHAIN_TARGET_NAME)/libstdc++*.so*)
else
  toolchain_libc_usrlib_files += $(wildcard $(TOOLCHAIN_LIBC)/usr/lib/libstdc++*.so*)
endif

# Some toolchains, such as recent Linaro toolchains, store GCC support libraries
# (libstdc++, libgcc_s, etc.) outside of the sysroot
ifeq ("$(strip $(toolchain_libc_usrlib_files))","")
  toolchain_libc_support_dir_cmd := $(TARGET_CC) $(TARGET_GLOBAL_CFLAGS)
  ifeq ("$(TARGET_ARCH)","arm")
    toolchain_libc_support_dir_cmd += $(TARGET_GLOBAL_CFLAGS_$(TARGET_DEFAULT_ARM_MODE))
  endif
  toolchain_libc_support_dir_cmd += -print-file-name=libstdc++.a
  toolchain_libc_support_dir := $(wildcard $(dir $(shell $(toolchain_libc_support_dir_cmd))))
  toolchain_libc_lib_files += $(wildcard $(toolchain_libc_support_dir)/libgcc_s*.so*)
  toolchain_libc_usrlib_files += $(wildcard $(toolchain_libc_support_dir)/libstdc++*.so*)
endif

# ldd
toolchain_libc_ldd :=
ifneq ("$(wildcard $(TOOLCHAIN_LIBC)/usr/bin/ldd)","")
  toolchain_libc_ldd := $(wildcard $(TOOLCHAIN_LIBC)/usr/bin/ldd)
endif

# Timezone data
toolchain_libc_tzdata :=
ifneq ("$(TARGET_INCLUDE_TZDATA)","0")
  ifneq ("$(wildcard $(TOOLCHAIN_LIBC)/usr/share/zoneinfo)","")
    toolchain_libc_tzdata := $(wildcard $(TOOLCHAIN_LIBC)/usr/share/zoneinfo)
  endif
endif

# Locale data
toolchain_libc_gconv :=
ifneq ("$(TARGET_INCLUDE_GCONV)","0")
  ifneq ("$(wildcard $(TOOLCHAIN_LIBC)/usr/lib/gconv)","")
    toolchain_libc_gconv := $(wildcard $(TOOLCHAIN_LIBC)/usr/lib/gconv)
  else ifneq ("$(wildcard $(TOOLCHAIN_LIBC)/usr/lib/$(TOOLCHAIN_TARGET_NAME)/gconv)","")
    toolchain_libc_gconv := $(wildcard $(TOOLCHAIN_LIBC)/usr/lib/$(TOOLCHAIN_TARGET_NAME)/gconv)
  endif
endif

# Install rule
# use $(endl) to separate commands on separate lines
$(toolchain_libc_installed_file):
	@mkdir -p $(dir $@)
	@mkdir -p $(TARGET_OUT_STAGING)/lib
	$(foreach __f,$(toolchain_libc_lib_files), \
		$(Q) cp -af $(__f) $(TARGET_OUT_STAGING)/lib/$(notdir $(__f))$(endl) \
	)
	@mkdir -p $(TARGET_OUT_STAGING)/usr/lib
	$(foreach __f,$(toolchain_libc_usrlib_files), \
		$(Q) cp -af $(__f) $(TARGET_OUT_STAGING)/usr/lib/$(notdir $(__f))$(endl) \
	)
	$(if $(toolchain_libc_ldd), \
		@mkdir -p $(TARGET_OUT_STAGING)/usr/bin$(endl) \
		$(Q) cp -af $(toolchain_libc_ldd) $(TARGET_OUT_STAGING)/usr/bin$(endl) \
		$(Q) sed -i -e 's|^\#! */bin/bash$$|\#!/bin/sh|' $(TARGET_OUT_STAGING)/usr/bin/ldd$(endl) \
	)
	$(if $(toolchain_libc_tzdata), \
		@mkdir -p $(TARGET_OUT_STAGING)/usr/share/zoneinfo$(endl) \
		$(Q) cp -Raf $(toolchain_libc_tzdata)/* $(TARGET_OUT_STAGING)/usr/share/zoneinfo$(endl) \
	)
	$(if $(toolchain_libc_gconv), \
		@mkdir -p $(TARGET_OUT_STAGING)/usr/usr/lib/gconv$(endl) \
		$(Q) cp -Raf $(toolchain_libc_gconv)/* $(TARGET_OUT_STAGING)/usr/usr/lib/gconv$(endl) \
	)
# Include gdbserver only if requested (GPLv3)
ifneq ("$(TARGET_INCLUDE_GDBSERVER)","0")
ifneq ("$(TOOLCHAIN_GDBSERVER)","")
	@mkdir -p $(TARGET_OUT_STAGING)/usr/bin
	$(Q) cp -af $(TOOLCHAIN_GDBSERVER) $(TARGET_OUT_STAGING)/usr/bin/gdbserver
endif
endif
	@touch $@

# Clean rule
# use $(endl) to separate commands on separate lines
.PHONY: toolchain-libc-clean
toolchain-libc-clean:
	$(foreach __f,$(toolchain_libc_lib_files), \
		$(Q) rm -f $(TARGET_OUT_STAGING)/lib/$(notdir $(__f))$(endl) \
	)
	$(foreach __f,$(toolchain_libc_usrlib_files), \
		$(Q) rm -f $(TARGET_OUT_STAGING)/usr/lib/$(notdir $(__f))$(endl) \
	)
	$(Q) rm -rf $(TARGET_OUT_STAGING)/usr/share/zoneinfo
	$(Q) rm -rf $(TARGET_OUT_STAGING)/usr/usr/lib/gconv
	$(Q) rm -f $(TARGET_OUT_STAGING)/usr/bin/gdbserver
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
