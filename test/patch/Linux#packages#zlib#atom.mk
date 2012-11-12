
# Not with bionic
ifneq ("$(TARGET_LIBC)","bionic")

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := zlib

LOCAL_EXPORT_LDLIBS := -lz

LOCAL_AUTOTOOLS_VERSION := 1.2.3
LOCAL_AUTOTOOLS_ARCHIVE := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION).tar.bz2
LOCAL_AUTOTOOLS_DIR := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION)

LOCAL_AUTOTOOLS_PATCHES :=

# Override install prefix
LOCAL_AUTOTOOLS_MAKE_INSTALL_ARGS := \
	prefix=$(TARGET_OUT_STAGING)/usr

LOCAL_AUTOTOOLS_CMD_CONFIGURE := zlib-cmd-configure
LOCAL_AUTOTOOLS_CMD_POST_CLEAN := zlib-cmd-post-clean

# Not a real configure script, it does not support standard --host option, everything is done
# via environment
zlib-cmd-configure = \
	cd $(PRIVATE_SRC_DIR) && $(AUTOTOOLS_CONFIGURE_ENV) AR="$(TARGET_AR) rcs" \
		./configure \
			--prefix="$(AUTOTOOLS_CONFIGURE_PREFIX)" \
			--shared

zlib-cmd-post-clean = \
	rm -f $(TARGET_OUT_STAGING)/usr/include/zlib.h; \
	rm -f $(TARGET_OUT_STAGING)/usr/include/zconf.h

include $(BUILD_AUTOTOOLS)

endif

