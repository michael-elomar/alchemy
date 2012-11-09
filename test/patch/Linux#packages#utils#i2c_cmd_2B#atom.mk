
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := i2c_cmd_2B

LOCAL_SRC_FILES := \
	src/i2c_cmd_2B.c

include $(BUILD_EXECUTABLE)

