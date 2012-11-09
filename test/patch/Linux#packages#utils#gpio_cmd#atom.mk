
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := gpio

LOCAL_SRC_FILES := \
	src/gpio.c

include $(BUILD_EXECUTABLE)

