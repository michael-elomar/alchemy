
LOCAL_PATH := $(call my-dir)

###############################################################################
# CKCM
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := ckcm
LOCAL_PBUILD_HOOK := 1

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/ckcm/include

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	ckcm/src/packstr2.c \
	ckcm/src/uart_rt.c \
	ckcm/src/uart_rt_transport.c \
	ckcm/src/uart_rt_usb_rec.c \
	ckcm/src/RemoteUI.c  \
	ckcm/src/sumo.c \
	ckcm/src/Bridge.c \
	ckcm/src/rt_data.c

ifeq ("$(TARGET_OS)","linux")
  LOCAL_SRC_FILES += ckcm/src/server.c
else
  LOCAL_EXPORT_CFLAGS += -DPALCKCM_DISABLE_SERVER
endif

LOCAL_LIBRARIES := pal-utils pal-core

include $(BUILD_SHARED_LIBRARY)

