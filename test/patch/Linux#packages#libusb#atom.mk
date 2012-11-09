
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libusb

LOCAL_EXPORT_LDLIBS := -lusb

LOCAL_AUTOTOOLS_VERSION := 0.1.12
LOCAL_AUTOTOOLS_ARCHIVE := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_DIR := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION)

LOCAL_AUTOTOOLS_PATCHES := \
	libusb-0.1.12-nocpp.patch \
	libusb-0.1.12-raptor.patch

LOCAL_AUTOTOOLS_CONFIGURE_ENV := \
	ac_cv_header_regex_h=no

LOCAL_AUTOTOOLS_CONFIGURE_ARGS := \
	--disable-debug \
	--disable-build-docs

ifeq ("$(TARGET_LIBC)","bionic")
LOCAL_AUTOTOOLS_MAKE_BUILD_ENV := \
	$(AUTOTOOLS_CONFIGURE_ENV)

LOCAL_AUTOTOOLS_MAKE_BUILD_ARGS := \
	CROSS=$(TARGET_CROSS)

LOCAL_AUTOTOOLS_MAKE_INSTALL_ENV := \
	$(AUTOTOOLS_CONFIGURE_ENV)

LOCAL_AUTOTOOLS_MAKE_INSTALL_ARGS := \
	DESTDIR=$(TARGET_OUT_STAGING)/usr \
	CROSS=$(TARGET_CROSS)

LOCAL_AUTOTOOLS_CMD_POST_CONFIGURE := libusb-cmd-post-configure

libusb-cmd-post-configure = \
	cp -af $(PRIVATE_PATH)/Makefile_raptor $(PRIVATE_SRC_DIR)/Makefile

endif

LOCAL_AUTOTOOLS_CMD_POST_CLEAN := libusb-cmd-post-clean

libusb-cmd-post-clean = \
	rm -f $(TARGET_OUT_STAGING)/usr/bin/libusb-config \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/pkgconfig/libusb.pc \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/libusb.so; \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/libusb.la; \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/libusb.a; \
	rm -f $(TARGET_OUT_STAGING)/usr/include/usb.h

include $(BUILD_AUTOTOOLS)

