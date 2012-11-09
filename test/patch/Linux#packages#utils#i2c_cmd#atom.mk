
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := i2c_cmd

LOCAL_SRC_FILES := \
	src/i2c_cmd.c

include $(BUILD_EXECUTABLE)

