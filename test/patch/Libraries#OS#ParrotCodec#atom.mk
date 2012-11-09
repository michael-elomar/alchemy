LOCAL_PATH := $(call my-dir)

###############################################################################
# pal-codec
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := pal-codec
LOCAL_PBUILD_HOOK := 1

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/codec \
	$(LOCAL_PATH)/devs/common \
	$(LOCAL_PATH)/devs/i2c \
	$(LOCAL_PATH)/devs/usb

LOCAL_EXPORT_CFLAGS :=

# TODO : we only need headers but we can't add portaudio in LOCAL_LIBRARIES
# because portaudio already uses us. We are a kind of plugin and we only
# need some structure. 
LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/../PortAudio/Sources/include

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	devs/common/alsa_devs.c \
	devs/i2c/ak4346_codec.c \
	devs/i2c/cs4245.c \
	devs/i2c/p6i_codec.c \
	devs/i2c/p6mu_codec.c \
	devs/i2c/tas5706.c \
	devs/i2c/tda7562_codec.c \
	devs/i2c/tps65023.c \
	devs/i2c/wau8822.c \
	devs/i2c/wm8594.c \
	devs/i2c/wm8960.c \
	devs/i2c/wm8973.c \
	devs/usb/pnx0161.c \
	codec/pal_codec.c \
	codec/pal_volumes.c \
	codec/products/fc6100_common.c \
	codec/products/fc6100_volumes.c \
	codec/products/fidji_volumes.c \
	codec/products/mki2_volumes.c \
	codec/products/rnb4_volumes.c \
	codec/products/rnb5_volumes.c \
	codec/products/safir_volumes.c

LOCAL_LIBRARIES := pal-devs pal-core

ifeq ("$(TARGET_OS)","linux")
  LOCAL_LIBRARIES += alsa-lib
endif

include $(BUILD_SHARED_LIBRARY)

