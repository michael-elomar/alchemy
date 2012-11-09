LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := mqueue

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	src/main.c \
	src/posix_mqueue.c

include $(BUILD_EXECUTABLE)

