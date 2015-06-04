###############################################################################
## @file native-packages.mk
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

include $(CLEAR_VARS)
LOCAL_MODULE := glib
LOCAL_EXPORT_CFLAGS := $(shell pkg-config --cflags glib-2.0 gobject-2.0 gio-2.0)
LOCAL_EXPORT_LDLIBS := $(shell pkg-config --libs glib-2.0 gobject-2.0 gio-2.0)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := opengl
LOCAL_EXPORT_CFLAGS := $(shell pkg-config --cflags glesv2)
LOCAL_EXPORT_LDLIBS := $(shell pkg-config --libs glesv2)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libjpeg-turbo
LOCAL_EXPORT_LDLIBS := -ljpeg
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libtiff
LOCAL_EXPORT_LDLIBS := -ltiff
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libpng
LOCAL_EXPORT_CFLAGS := $(shell pkg-config --cflags libpng)
LOCAL_EXPORT_LDLIBS := $(shell pkg-config --libs libpng)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := opencv
LOCAL_EXPORT_LDLIBS := -lopencv_flann -lopencv_core -lopencv_imgproc    \
	-lopencv_calib3d -lopencv_contrib -lopencv_features2d -lopencv_gpu  \
	-lopencv_highgui -lopencv_legacy -lopencv_ml -lopencv_objdetect     \
	-lopencv_ocl -lopencv_photo -lopencv_stitching -lopencv_superres 	\
	-lopencv_ts -lopencv_video -lopencv_videostab

include $(BUILD_PREBUILT)

endif
