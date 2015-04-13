###############################################################################
## @file linux/native/packages.mk
## @author Y.M. Morgan
## @date 2012/10/18
##
## This file contains package definition specific to native linux.
###############################################################################

ifeq ("$(TARGET_OS_FLAVOUR)","native")

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := libusb
LOCAL_EXPORT_LDLIBS := -lusb
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libusb_1_0
LOCAL_EXPORT_LDLIBS := -lusb-1.0
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := alsa-lib
LOCAL_EXPORT_LDLIBS := -lasound
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libudev
LOCAL_EXPORT_LDLIBS := -ludev
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := zlib
LOCAL_EXPORT_LDLIBS := -lz
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := avahi
LOCAL_EXPORT_LDLIBS := $(shell pkg-config --libs avahi-client)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := json
LOCAL_EXPORT_CFLAGS := $(shell pkg-config --cflags json)
LOCAL_EXPORT_LDLIBS := $(shell pkg-config --libs json)
include $(BUILD_PREBUILT)

endif
