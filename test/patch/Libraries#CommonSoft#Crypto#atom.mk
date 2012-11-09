
LOCAL_PATH := $(call my-dir)

###############################################################################
# Crypto
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := crypto-parrot

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	tea.c \
	simple.c \
	aes.c \
	base64.c \
	md5.c \
	sha256.c

LOCAL_LIBRARIES :=

include $(BUILD_SHARED_LIBRARY)

