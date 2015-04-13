###############################################################################
## @file libc.mk
## @author Y.M. Morgan
## @date 2015/04/11
##
## This file contains logic to install libc files from toolchain to staging.
###############################################################################

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libc
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

# File indicating that installation was done
_libc_installed_file := $(call local-get-build-dir)/$(LOCAL_MODULE).installed

# The sysroot of the toolchain
# (after removing trailing '/' it can become empty if it was just '/')
_libc_sysroot := $(patsubst %/,%,$(TOOLCHAIN_LIBC))

# architecture dependent sub-directory
_libc_arch_subdir := $(TOOLCHAIN_TARGET_NAME)

# List of files to be put in /lib
_libc_lib_names := \
	ld \
	libc \
	libcrypt \
	libdl \
	libgcc_s \
	libm \
	libnsl \
	libnss_dns \
	libnss_files \
	libpthread \
	libresolv \
	librt \
	libthread_db \
	libutil \

# List of files to be put in /usr/lib
_libc_usrlib_names := \
	libstdc++

# 'lib' directory, try architecture dependent directory first
_libc_lib_dir := $(wildcard $(_libc_sysroot)/lib/$(_libc_arch_subdir))
ifeq ("$(_libc_lib_dir)","")
  _libc_lib_dir := $(wildcard $(_libc_sysroot)/lib)
endif

# 'usr/lib' directory, try architecture dependent directory first
_libc_usrlib_dir := $(wildcard $(_libc_sysroot)/usr/lib/$(_libc_arch_subdir))
ifeq ("$(_libc_usrlib_dir)","")
  _libc_usrlib_dir := $(wildcard $(_libc_sysroot)/usr/lib)
endif

# 'usr/lib/debug/lib' directory, try architecture dependent directory first
_libc_lib_dbg_dir := $(wildcard $(_libc_sysroot)/usr/lib/debug/lib/$(_libc_arch_subdir))
ifeq ("$(_libc_lib_dbg_dir)","")
  _libc_lib_dbg_dir := $(wildcard $(_libc_sysroot)/usr/lib/debug/lib)
endif

# List of files to be put in /lib
_libc_lib_files :=
$(foreach __f,$(_libc_lib_names), \
	$(eval _libc_lib_files += \
		$(wildcard $(_libc_lib_dir)/$(__f).so*) \
		$(wildcard $(_libc_lib_dir)/$(__f)-*.so) \
	) \
)

# Linker links
_libc_lib_files += $(wildcard $(_libc_lib_dir)/ld-linux*.so*)

# List of files to be put in /usr/lib
_libc_usrlib_files +=
$(foreach __f,$(_libc_usrlib_names), \
	$(eval _libc_usrlib_files += \
		$(wildcard $(_libc_usrlib_dir)/$(__f).so*) \
		$(wildcard $(_libc_usrlib_dir)/$(__f)-*.so) \
	) \
)

# List of files to be put in /usr/lib/debug/lib
_libc_lib_dbg_files :=
$(foreach __f,$(_libc_lib_names), \
	$(eval _libc_lib_dbg_files += \
		$(wildcard $(_libc_lib_dbg_dir)/$(__f)-*.so) \
	) \
)

# Some toolchains, such as recent Linaro toolchains, store GCC support libraries
# (libstdc++, libgcc_s, etc.) outside of the sysroot
ifeq ("$(findstring libstdc++,$(_libc_usrlib_files))","")
  _libc_support_dir_cmd := $(TARGET_CC) $(TARGET_GLOBAL_CFLAGS)
  ifeq ("$(TARGET_ARCH)","arm")
    _libc_support_dir_cmd += $(TARGET_GLOBAL_CFLAGS_$(TARGET_DEFAULT_ARM_MODE))
  endif
  _libc_support_dir_cmd += -print-file-name=libstdc++.a
  _libc_support_dir := $(wildcard $(dir $(shell $(_libc_support_dir_cmd))))
  _libc_lib_files += $(wildcard $(_libc_support_dir)/libgcc_s*.so*)
  _libc_usrlib_files += $(wildcard $(_libc_support_dir)/libstdc++*.so*)
endif

# Remove gdb python file
_libc_lib_files := $(filter-out %.py,$(_libc_lib_files))
_libc_usrlib_files := $(filter-out %.py,$(_libc_usrlib_files))
_libc_lib_dbg_files := $(filter-out %.py,$(_libc_lib_dbg_files))

# Timezone data
_libc_tzdata :=
ifneq ("$(TARGET_INCLUDE_TZDATA)","0")
  _libc_tzdata := $(wildcard $(_libc_sysroot)/usr/share/zoneinfo)
endif

# Locale data
_libc_gconv :=
ifneq ("$(TARGET_INCLUDE_GCONV)","0")
  _libc_gconv := $(wildcard $(_libc_sysroot)/usr/lib/$(_libc_arch_subdir)/gconv)
  ifeq ("$(_libc_gconv)","")
    _libc_gconv := $(wildcard $(_libc_sysroot)/usr/lib/gconv)
  endif
endif

# ldd
_libc_ldd := $(wildcard $(_libc_sysroot)/usr/bin/ldd)

# Install rule
# use $(endl) to separate commands on separate lines
$(_libc_installed_file):
	@mkdir -p $(dir $@)
	$(if $(_libc_lib_files), \
		@mkdir -p $(TARGET_OUT_STAGING)/lib$(endl) \
		$(foreach __f,$(_libc_lib_files), \
			$(Q) cp -af $(__f) $(TARGET_OUT_STAGING)/lib/$(notdir $(__f))$(endl) \
		) \
	)
	$(if $(_libc_usrlib_files), \
		@mkdir -p $(TARGET_OUT_STAGING)/usr/lib$(endl) \
		$(foreach __f,$(_libc_usrlib_files), \
			$(Q) cp -af $(__f) $(TARGET_OUT_STAGING)/usr/lib/$(notdir $(__f))$(endl) \
		) \
	)
	$(if $(_libc_lib_dbg_files), \
		@mkdir -p $(TARGET_OUT_STAGING)/usr/lib/debug/lib$(endl) \
		$(foreach __f,$(_libc_lib_dbg_files), \
			$(Q) cp -af $(__f) $(TARGET_OUT_STAGING)/usr/lib/debug/lib/$(notdir $(__f))$(endl) \
		) \
	)
	$(if $(_libc_tzdata), \
		@mkdir -p $(TARGET_OUT_STAGING)/usr/share/zoneinfo$(endl) \
		$(Q) cp -Raf $(_libc_tzdata)/* $(TARGET_OUT_STAGING)/usr/share/zoneinfo$(endl) \
	)
	$(if $(_libc_gconv), \
		@mkdir -p $(TARGET_OUT_STAGING)/usr/lib/gconv$(endl) \
		$(Q) cp -Raf $(_libc_gconv)/* $(TARGET_OUT_STAGING)/usr/lib/gconv$(endl) \
	)
	$(if $(_libc_ldd), \
		@mkdir -p $(TARGET_OUT_STAGING)/usr/bin$(endl) \
		$(Q) cp -af $(_libc_ldd) $(TARGET_OUT_STAGING)/usr/bin$(endl) \
		$(Q) sed -i -e 's|^\#! */bin/bash$$|\#!/bin/sh|' $(TARGET_OUT_STAGING)/usr/bin/ldd$(endl) \
	)
# Link /lib64 -> /lib
ifeq ("$(TARGET_ARCH)","x64")
	$(Q) ln -sf lib $(TARGET_OUT_STAGING)/lib64
endif
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
.PHONY: libc-clean
libc-clean:
	$(foreach __f,$(_libc_lib_files), \
		$(Q) rm -f $(TARGET_OUT_STAGING)/lib/$(notdir $(__f))$(endl) \
	)
	$(foreach __f,$(_libc_usrlib_files), \
		$(Q) rm -f $(TARGET_OUT_STAGING)/usr/lib/$(notdir $(__f))$(endl) \
	)
	$(foreach __f,$(_libc_dbg_files), \
		$(Q) rm -f $(TARGET_OUT_STAGING)/usr/lib/debug/lib/$(notdir $(__f))$(endl) \
	)
# Link /lib64 -> /lib
ifeq ("$(TARGET_ARCH)","x64")
	$(Q) rm -f $(TARGET_OUT_STAGING)/lib64
endif
	$(Q) rm -rf $(TARGET_OUT_STAGING)/usr/share/zoneinfo
	$(Q) rm -rf $(TARGET_OUT_STAGING)/usr/lib/gconv
	$(Q) rm -f $(TARGET_OUT_STAGING)/usr/bin/ldd
	$(Q) rm -f $(TARGET_OUT_STAGING)/usr/bin/gdbserver

# Register 'installed' file in build system
$(call local-get-build-dir)/$(LOCAL_MODULE_FILENAME): $(_libc_installed_file)
LOCAL_DONE_FILES += $(LOCAL_MODULE).installed
LOCAL_CLEAN_FILES += $(_libc_installed_file)
LOCAL_CUSTOM_TARGETS += $(_libc_installed_file)

# Make sure this is the first module built
TARGET_GLOBAL_PREREQUISITES += $(call local-get-build-dir)/$(LOCAL_MODULE_FILENAME)

# Prebuilt so it is always enabled and does not appear in config
include $(BUILD_PREBUILT)
