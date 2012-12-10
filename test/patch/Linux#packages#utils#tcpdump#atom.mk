
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := tcpdump
LOCAL_DESCRIPTION := Tool for network monitoring and data acquisition

LOCAL_LIBRARIES := libpcap

LOCAL_AUTOTOOLS_VERSION := 4.1.1
LOCAL_AUTOTOOLS_ARCHIVE := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_SUBDIR := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION)

LOCAL_AUTOTOOLS_PATCHES := \
	lucie/tcpdump-4.1.1-configure.patch

LOCAL_AUTOTOOLS_CONFIGURE_ARGS := \
	--disable-ipv6 \
	--without-crypto \
	ac_cv_linux_vers=2

include $(BUILD_AUTOTOOLS)

