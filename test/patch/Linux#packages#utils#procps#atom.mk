
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := procps

LOCAL_AUTOTOOLS_VERSION := 3.2.8
LOCAL_AUTOTOOLS_ARCHIVE := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_DIR := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION)

LOCAL_AUTOTOOLS_PATCHES := \
	lucie/procps-mips-define-pagesize.patch \
	lucie/procps-remove-index.patch

LOCAL_AUTOTOOLS_MAKE_BUILD_ENV := \
	$(AUTOTOOLS_CONFIGURE_ENV)

LOCAL_AUTOTOOLS_MAKE_BUILD_ARGS := \
	vmstat

LOCAL_AUTOTOOLS_CMD_CONFIGURE := procps-cmd-configure
LOCAL_AUTOTOOLS_CMD_INSTALL := procps-cmd-install
LOCAL_AUTOTOOLS_CMD_POST_CLEAN := procps-cmd-post-clean

procps-cmd-configure = $(empty)

procps-cmd-install = \
	install -p $(PRIVATE_SRC_DIR)/proc/libproc-3.2.8.so $(TARGET_OUT_STAGING)/usr/lib; \
	install -p $(PRIVATE_SRC_DIR)/vmstat $(TARGET_OUT_STAGING)/usr/bin/vmstat

procps-cmd-post-clean = \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/libproc-3.2.8.so; \
	rm -f $(TARGET_OUT_STAGING)/usr/bin/vmstat

include $(BUILD_AUTOTOOLS)

