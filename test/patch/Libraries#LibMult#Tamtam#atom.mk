
LOCAL_PATH := $(call my-dir)

###############################################################################
# Tamtam
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tamtam
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := Build/ConfigTamtam.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Export

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Sources

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	Sources/tamtam_rule.c \
	Sources/tamtam_attenuation.c \
	Sources/tamtam_vdlist.c \
	Sources/tamtam_generic.c \
	Sources/tamtam_list.c \
	Sources/utils/MTL_List.c \
	Sources/tamtam_client.cpp \
	Sources/session_def.cpp \
	Sources/session_state.cpp \
	Sources/tamtam_init.cpp \
	Sources/tamtam_config.cpp \
	Sources/tamtam_request.cpp \
	Sources/message_handler.cpp \
	Sources/tamtam_core.cpp

LOCAL_LIBRARIES := tinyxml tala pal-core

include $(BUILD_SHARED_LIBRARY)

