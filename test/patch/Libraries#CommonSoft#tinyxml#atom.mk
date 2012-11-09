
LOCAL_PATH := $(call my-dir)

###############################################################################
# TiniXml
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tinyxml

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	tinystr.cpp \
	tinyxml.cpp \
	tinyxmlerror.cpp \
	tinyxmlparser.cpp

LOCAL_LIBRARIES :=

include $(BUILD_SHARED_LIBRARY)

