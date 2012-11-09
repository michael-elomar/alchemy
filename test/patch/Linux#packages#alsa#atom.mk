
LOCAL_PATH := $(call my-dir)

# Linux, Not with bionic
ifeq ("$(TARGET_OS)","linux")
ifneq ("$(TARGET_LIBC)","bionic")

###############################################################################
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := alsa-lib

LOCAL_EXPORT_LDLIBS := -lasound

LOCAL_AUTOTOOLS_VERSION := 1.0.19
LOCAL_AUTOTOOLS_ARCHIVE := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION).tar.bz2
LOCAL_AUTOTOOLS_DIR := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION)

LOCAL_AUTOTOOLS_PATCHES := \
	lucie/alsa-lib-1.0.19_pluginlist.patch \
	lucie/alsa-lib-dis_wordexp.patch

LOCAL_AUTOTOOLS_CONFIGURE_ENV :=

LOCAL_AUTOTOOLS_CONFIGURE_ARGS := \
	--disable-aload \
	--disable-seq \
	--disable-instr \
	--disable-alisp \
	--disable-python \
	--with-pcm-plugins='file hw' \
	--disable-rawmidi \
	--without-versioned \
	--with-debug \
	--enable-symbolic-functions

LOCAL_AUTOTOOLS_CMD_POST_CLEAN := alsa-lib-cmd-post-clean

alsa-lib-cmd-post-clean = \
	rm -f $(TARGET_OUT_STAGING)/usr/include/sys/asoundlib.h

include $(BUILD_AUTOTOOLS)

endif
endif

