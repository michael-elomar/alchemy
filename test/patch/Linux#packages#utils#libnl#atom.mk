
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libnl

LOCAL_AUTOTOOLS_VERSION := 3.2.7
LOCAL_AUTOTOOLS_ARCHIVE := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_DIR := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION)

LOCAL_AUTOTOOLS_PATCHES := \
	lucie/0001-don-t-include-linux-if.h-which-conflicts-with-net-if.patch

LOCAL_AUTOTOOLS_CONFIGURE_ARGS := \
	--sysconfdir=/etc \
	--disable-cli

include $(BUILD_AUTOTOOLS)

