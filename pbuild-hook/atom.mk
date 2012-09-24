
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := pbuild-hook

LOCAL_SRC_FILES := \
	pbuild-stub.c

include $(BUILD_STATIC_LIBRARY)

