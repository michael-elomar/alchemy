###############################################################################
## @file linux/native/packages.mk
## @author Y.M. Morgan
## @date 2012/10/18
##
## This file contains package definition specific to native linux.
###############################################################################

LOCAL_PATH := $(call my-dir)

###############################################################################
# In native mode, use some module from the host machine.
###############################################################################

ifeq ("$(TARGET_OS_FLAVOUR)","native")

include $(CLEAR_VARS)
LOCAL_MODULE := libusb
LOCAL_EXPORT_LDLIBS := -lusb
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libusb_1_0
LOCAL_EXPORT_LDLIBS := -lusb-1.0
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := alsa-lib
LOCAL_EXPORT_LDLIBS := -lasound
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libudev
LOCAL_EXPORT_LDLIBS := -ludev
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := zlib
LOCAL_EXPORT_LDLIBS := -lz
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := avahi
LOCAL_EXPORT_LDLIBS := $(shell pkg-config --libs avahi-client)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := json
LOCAL_EXPORT_CFLAGS := $(shell pkg-config --cflags json)
LOCAL_EXPORT_LDLIBS := $(shell pkg-config --libs json)
include $(BUILD_PREBUILT)

endif

###############################################################################
# In native-chroot mode, copy libc to staging directory.
###############################################################################
ifeq ("$(TARGET_OS_FLAVOUR)","native-chroot")

include $(CLEAR_VARS)

LOCAL_MODULE := toolchain-libc
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

# File indicating that installation was done
toolchain_libc_installed_file := $(call local-get-build-dir)/$(LOCAL_MODULE).installed

# Assume a multi-arch compatible system
ifeq ("$(TARGET_ARCH)","x64")
  toolchain_libc_arch_dir := x86_64-linux-gnu
else ifeq ("$(TARGET_ARCH)","x86")
  toolchain_libc_arch_dir := i386-linux-gnu
else
  $(error Invalid TARGET_ARCH: $(TARGET_ARCH))
endif

toolchain_libc_lib_dir := /lib/$(toolchain_libc_arch_dir)
toolchain_libc_usrlib_dir := /usr/lib/$(toolchain_libc_arch_dir)
toolchain_libc_dbg_dir := /usr/lib/debug/lib/$(toolchain_libc_arch_dir)

# Fallback to legacy hierarchy
ifeq ("$(wildcard $(toolchain_libc_lib_dir))","")
  toolchain_libc_lib_dir := /lib
endif
ifeq ("$(wildcard $(toolchain_libc_usrlib_dir))","")
  toolchain_libc_usrlib_dir := /usr/lib
endif
ifeq ("$(wildcard $(toolchain_libc_dbg_dir))","")
  toolchain_libc_dbg_dir := /usr/lib/debug/lib
endif

$(info toolchain_libc_lib_dir=$(toolchain_libc_lib_dir))
$(info toolchain_libc_usrlib_dir=$(toolchain_libc_usrlib_dir))
$(info toolchain_libc_dbg_dir=$(toolchain_libc_dbg_dir))

toolchain_libc_lib_files :=
toolchain_libc_usrlib_files :=
toolchain_libc_dbg_files :=

# List of files to be put in /lib
toolchain_libc_lib_names := ld ld-linux libgcc_s libc libpthread libm librt libdl \
	libutil libcrypt libresolv libnss_files libthread_db
$(foreach __f,$(toolchain_libc_lib_names), \
	$(eval toolchain_libc_lib_files += \
		$(wildcard $(toolchain_libc_lib_dir)/$(__f).so*) \
		$(wildcard $(toolchain_libc_lib_dir)/$(__f)-*.so) \
	) \
	$(eval toolchain_libc_dbg_files += \
		$(wildcard $(toolchain_libc_dbg_dir)/$(__f)-*.so) \
	) \
)

# List of files to be put in /usr/lib
toolchain_libc_usrlib_names := libstdc++
$(foreach __f,$(toolchain_libc_usrlib_names), \
	$(eval toolchain_libc_usrlib_files += \
		$(wildcard $(toolchain_libc_usrlib_dir)/$(__f).so*) \
		$(wildcard $(toolchain_libc_usrlib_dir)/$(__f)-*.so) \
	) \
	$(eval toolchain_libc_dbg_files += \
		$(wildcard $(toolchain_libc_dbg_dir)/$(__f)-*.so) \
	) \
)

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
	@mkdir -p $(TARGET_OUT_STAGING)/usr/lib/debug/lib
	$(foreach __f,$(toolchain_libc_dbg_files), \
		$(Q) cp -af $(__f) $(TARGET_OUT_STAGING)/usr/lib/debug/lib/$(notdir $(__f))$(endl) \
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
.PHONY: toolchain-libc-clean
toolchain-libc-clean:
	$(foreach __f,$(toolchain_libc_lib_files), \
		$(Q) rm -f $(TARGET_OUT_STAGING)/lib/$(notdir $(__f))$(endl) \
	)
	$(foreach __f,$(toolchain_libc_usrlib_files), \
		$(Q) rm -f $(TARGET_OUT_STAGING)/usr/lib/$(notdir $(__f))$(endl) \
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

endif
