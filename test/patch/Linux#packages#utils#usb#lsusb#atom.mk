
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := lsusb

LOCAL_SRC_FILES := \
	src/devtree.c \
	src/lsusb.c \
	src/lsusb-t.c \
	src/names.c \
	src/usbmisc.c

LOCAL_LIBRARIES := libusb_1_0

LOCAL_COPY_FILES := \
	src/usb.ids:etc/usb.ids

include $(BUILD_EXECUTABLE)

