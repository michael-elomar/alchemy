
LOCAL_PATH := $(call my-dir)

###############################################################################
# Settings
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := settings

LOCAL_CONFIG_FILES := ConfigSettings.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES := 

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	Settings.c \
	SettingsBuf.c

LOCAL_LIBRARIES := pal-utils pal-core

include $(BUILD_SHARED_LIBRARY)

