
LOCAL_PATH := $(call my-dir)

###############################################################################
# Buto
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := buto

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/include

LOCAL_EXPORT_CFLAGS :=

LOCAL_LDLIBS := -lgcc

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/src

LOCAL_CFLAGS := \
	-DOS_PATH_SEPARATOR=\'/\'

LOCAL_SRC_FILES := \
	src/stubs.c \
	src/SharedBuffer.cpp \
	src/VectorImpl.cpp \
	src/String8.cpp \
	src/String16.cpp \
	src/StringArray.cpp

LOCAL_LIBRARIES :=

include $(BUILD_SHARED_LIBRARY)

