
LOCAL_PATH := $(call my-dir)

###############################################################################
# UniRecorder
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := unirecorder
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := Build/ConfigUniRecorder.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Export

LOCAL_EXPORT_CFLAGS := \
	-DBUILD_UR

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	Sources/UniRecorder.cpp \

ifdef CONFIG_UR_ENABLE_RECORDER
LOCAL_SRC_FILES += \
	Sources/UR_fifo.cpp \
	Sources/UR_thread.cpp \
	Sources/UR_remoteInterface.cpp
endif

LOCAL_LIBRARIES := ckcm pal-core

include $(BUILD_SHARED_LIBRARY)

