
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libubi

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/include

LOCAL_COPY_FILES := \
	src/ubi.h:usr/include/parrot_ubi.h

LOCAL_SRC_FILES := \
	src/ubi.c

LOCAL_EXPORT_PREREQUISITES := \
	$(TARGET_OUT_STAGING)/usr/include/parrot_ubi.h

include $(BUILD_STATIC_LIBRARY)

