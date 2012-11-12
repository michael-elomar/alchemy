
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := ltrace

LOCAL_LIBRARIES := libelf

LOCAL_AUTOTOOLS_VERSION := 0.5-3.1
LOCAL_AUTOTOOLS_ARCHIVE := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_DIR := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION)

LOCAL_AUTOTOOLS_PATCHES := \
	lucie/ltrace_configure.patch

# Get architecture as ltrace wants it
ifeq ("$(TARGET_ARCH)","x86")
  LTRACE_ARCH := i386
else ifeq ("$(TARGET_ARCH)","x64")
  LTRACE_ARCH := x86_64
else
  LTRACE_ARCH := $(TARGET_ARCH)
endif

LOCAL_AUTOTOOLS_MAKE_BUILD_ARGS := \
	ARCH=$(LTRACE_ARCH)

LOCAL_AUTOTOOLS_MAKE_INSTALL_ARGS := \
	ARCH=$(LTRACE_ARCH)

LOCAL_AUTOTOOLS_CMD_POST_CONFIGURE := ltrace-cmd-post-configure

ltrace-cmd-post-configure = \
	sed -s 's/-o root -g root//' -i $(PRIVATE_SRC_DIR)/Makefile

include $(BUILD_AUTOTOOLS)

