LOCAL_PATH := $(call my-dir)

PLF_FLAGS := \
	-I/usr/local/share/plf/include

###############################################################################
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := libpinst

LOCAL_C_INCLUDES := \
	-I$(LOCAL_PATH)/include

LOCAL_CFLAGS := $(PLF_FLAGS)

LOCAL_COPY_FILES := \
	tools/libpinst.h:usr/include/libpinst.h

LOCAL_SRC_FILES := \
	tools/libpinst.c

LOCAL_LIBRARIES := libubi

include $(BUILD_STATIC_LIBRARY)

###############################################################################
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := pinst_trigger

LOCAL_SRC_FILES := \
	tools/pinst_trigger.c

LOCAL_LIBRARIES := libpinst

include $(BUILD_EXECUTABLE)

###############################################################################
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := pinst_version

LOCAL_SRC_FILES := \
	tools/pinst_version.c

LOCAL_LIBRARIES := libpinst

include $(BUILD_EXECUTABLE)

###############################################################################
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := ubi_check

LOCAL_SRC_FILES := \
	tools/ubi_check.c

LOCAL_LIBRARIES := libpinst

include $(BUILD_EXECUTABLE)

