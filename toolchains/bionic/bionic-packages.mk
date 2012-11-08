###############################################################################
## @file bionic-packages.mk
## @author Y.M. Morgan
## @date 2012/10/18
##
## This file contains package definition specific to bionic (android).
###############################################################################

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := liblog
LOCAL_EXPORT_LDLIBS := -llog
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libutils
LOCAL_EXPORT_LDLIBS := -lutils
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libcutils
LOCAL_EXPORT_LDLIBS := -lcutils
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := zlib
LOCAL_EXPORT_LDLIBS := -lz
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libbinder
LOCAL_EXPORT_LDLIBS := -lbinder
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libaudio
LOCAL_EXPORT_LDLIBS := -laudio
LOCAL_EXPORT_C_INCLUDES := \
	$(RAPTOR_DIR)/hardware/parrot/libaudio/include \
	$(RAPTOR_DIR)/hardware/libhardware_legacy/include
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := alsa-lib
LOCAL_MODULE_CLASS := PREBUILT
LOCAL_EXPORT_LDLIBS := -lasound
LOCAL_EXPORT_C_INCLUDES := $(RAPTOR_DIR)/external/alsa-lib/include
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libcrypto
LOCAL_EXPORT_LDLIBS := -lcrypto
LOCAL_EXPORT_C_INCLUDES := $(RAPTOR_DIR)/external/openssl/include
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libssl
LOCAL_EXPORT_LDLIBS := -lssl
LOCAL_EXPORT_C_INCLUDES := $(RAPTOR_DIR)/external/openssl/include
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := wpa_supplicant
LOCAL_EXPORT_LDLIBS := -lwpa_client
include $(BUILD_PREBUILT)

