
LOCAL_PATH := $(call my-dir)

# Only with linux/android
ifeq ("$(TARGET_OS)","linux")
ifeq ("$(TARGET_OS_FLAVOUR)","android")

###############################################################################
# AudioBinder
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := audiobinder
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := build/ConfigAudioBinder.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	-I$(LOCAL_PATH)/include

LOCAL_SRC_FILES := \
	src/core.cpp \
	src/itf_binder.cpp \
	src/itf_libparrot.c \

LOCAL_LIBRARIES := \
	libaudio \
	libutils \
	liblog \
	libbinder \
	tamtam \
	tala \
	pal-core

include $(BUILD_SHARED_LIBRARY)

endif
endif

