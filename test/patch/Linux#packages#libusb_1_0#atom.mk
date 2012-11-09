
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libusb_1_0

LOCAL_EXPORT_LDLIBS := -lusb-1.0

LOCAL_AUTOTOOLS_VERSION := 1.0.8
LOCAL_AUTOTOOLS_ARCHIVE := libusb-$(LOCAL_AUTOTOOLS_VERSION).tar.bz2
LOCAL_AUTOTOOLS_DIR := libusb-$(LOCAL_AUTOTOOLS_VERSION)

ifeq ("$(TARGET_LIBC)","bionic")
LOCAL_AUTOTOOLS_PATCHES := \
	libusb-1.0.8.raptor.patch \
	libusb-1.0.8.raptor01.patch
else
LOCAL_AUTOTOOLS_PATCHES :=
endif

LOCAL_AUTOTOOLS_CONFIGURE_ENV :=

LOCAL_AUTOTOOLS_CONFIGURE_ARGS :=

LOCAL_AUTOTOOLS_MAKE_BUILD_ENV := \
	$(AUTOTOOLS_CONFIGURE_ENV)

ifeq ("$(TARGET_LIBC)","bionic")
LOCAL_AUTOTOOLS_MAKE_BUILD_ARGS := \
	CROSS=$(TARGET_CROSS) \
	CFLAGS+="-include config.h -I. -Ilibusb"
else
LOCAL_AUTOTOOLS_MAKE_BUILD_ARGS :=
endif

LOCAL_AUTOTOOLS_MAKE_INSTALL_ENV := \
	$(AUTOTOOLS_CONFIGURE_ENV)

ifeq ("$(TARGET_LIBC)","bionic")
LOCAL_AUTOTOOLS_MAKE_INSTALL_ARGS := \
	DESTDIR=$(TARGET_OUT_STAGING)/usr \
	CROSS=$(TARGET_CROSS)
else
LOCAL_AUTOTOOLS_MAKE_INSTALL_ARGS :=
endif

LOCAL_AUTOTOOLS_CMD_POST_CONFIGURE := libusb_1_0-cmd-post-configure
LOCAL_AUTOTOOLS_CMD_POST_CLEAN := libusb_1_0-cmd-post-clean

ifeq ("$(TARGET_LIBC)","bionic")
libusb_1_0-cmd-post-configure = \
	cp -af $(PRIVATE_PATH)/Makefile_raptor $(PRIVATE_SRC_DIR)/Makefile
else
libusb_1_0-cmd-post-configure =
endif

libusb_1_0-cmd-post-clean = \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/libusb-1.0.so; \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/libusb-1.0.a; \
	rm -f $(TARGET_OUT_STAGING)/usr/include/libusb-1.0/libusb.h

include $(BUILD_AUTOTOOLS)

