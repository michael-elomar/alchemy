LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libpac

LOCAL_EXPORT_C_INCLUDES := \
	-I$(LOCAL_PATH)

LOCAL_SRC_FILES := \
	libpac.c \
	log.c \
	properties.c

include $(BUILD_SHARED_LIBRARY)

