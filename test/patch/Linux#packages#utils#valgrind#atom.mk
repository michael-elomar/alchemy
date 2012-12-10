
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := valgrind
LOCAL_DESCRIPTION := Tool for debugging and profiling Linux programs

LOCAL_AUTOTOOLS_VERSION := 3.6.1
LOCAL_AUTOTOOLS_ARCHIVE := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION).tar.bz2
LOCAL_AUTOTOOLS_SUBDIR := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION)

LOCAL_AUTOTOOLS_PATCHES := \
	lucie/valgrind.patch \
	lucie/valgrind-3.6.1-extern.patch \

ifeq ("$(TARGET_ARCH)","arm")

# Only armv7 supported
# TODO: check the TARGET_CPU variable for compatibility
LOCAL_AUTOTOOLS_CONFIGURE_ARGS := \
	--host=armv7-unknown-linux

endif

include $(BUILD_AUTOTOOLS)

