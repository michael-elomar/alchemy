
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libpcap

LOCAL_AUTOTOOLS_VERSION := 1.1.1
LOCAL_AUTOTOOLS_ARCHIVE := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_DIR := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION)

LOCAL_AUTOTOOLS_CONFIGURE_ARGS := \
	--sysconfdir=/etc \
	--disable-yydebug \
	--with-pcap=linux \
	ac_cv_linux_vers=2 \
	ac_cv_header_linux_wireless_h=yes

include $(BUILD_AUTOTOOLS)

