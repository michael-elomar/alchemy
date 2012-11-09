
LOCAL_PATH := $(call my-dir)

###############################################################################
# Acid
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := acid
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := Build/ConfigACIDSet.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Export

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Sources \
	$(LOCAL_PATH)/Sources/hw/bluetooth \
	$(LOCAL_PATH)/Sources/hw/plugin \
	$(LOCAL_PATH)/Sources/hw/usb \
	$(LOCAL_PATH)/Sources/hw/coprocessor \
	$(LOCAL_PATH)/Sources/lingo \
	$(LOCAL_PATH)/Sources/utils \
	$(LOCAL_PATH)/Sources/services \
	$(LOCAL_PATH)/Sources/services/ipodout \
	$(LOCAL_PATH)/Sources/services/music

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	Sources/libacid.c \
	Sources/hw/bluetooth/blues.c \
	Sources/hw/plugin/plugin.c \
	Sources/hw/uart/uart.c \
	Sources/hw/usb/usb.c \
	Sources/hw/coprocessor/iPod_Coprocessor_API.c \
	Sources/hw/coprocessor/acid_pal_i2c.c \
	Sources/hw/coprocessor/acid_pal_gpio.c \
	Sources/hw/coprocessor/acid_cp_layer.c \
	Sources/hw/coprocessor/acid_hw_coproc.c \
	Sources/services/common.c \
	Sources/services/custom_app.c \
	Sources/services/devman.c \
	Sources/services/ipodout/ipodout.c \
	Sources/services/music/music.c \
	Sources/services/digital_audio.c \
	Sources/services/tagging.cpp \
	Sources/utils/acid_pal_core.c \
	Sources/utils/acid_pal_uart.c \

ifeq ("$(TARGET_OS)","linux")
LOCAL_SRC_FILES += \
	Sources/hw/usb/usb_ipod.c
endif

ACID_LINGO_SRC_FILES := \
	Sources/lingo/iPod_Send_Msg.c \
	Sources/lingo/iPod_Authentication.c \
	Sources/lingo/iPod_Check_Msg.c \
	Sources/lingo/iPod_Create_Msg.c \
	Sources/lingo/iPod_General_Lingo.c \
	Sources/lingo/iPod_General_Lingo_Rx.c \
	Sources/lingo/iPod_iAP_Commands.c \
	Sources/lingo/iPod_iAP_GL_Commands.c \
	Sources/lingo/iPod_Interpret_Msg.c \
	Sources/lingo/iPod_Receive_Msg.c \
	Sources/lingo/iPod_Settings.c \
	Sources/lingo/iPod_Translate_Msg.c \
	Sources/lingo/iPod_Digital_Audio_Lingo.c \
	Sources/lingo/iPod_Digital_Audio_Lingo_Rx.c \
	Sources/lingo/iPod_iAP_DA_Commands.c

ACID_MUSIC_SRC_FILES := \
	Sources/services/music/acid_convert_image.c \
	Sources/services/music/music_cache.c \
	Sources/lingo/iPod_Display_Remote_Lingo.c \
	Sources/lingo/iPod_Display_Remote_Lingo_Rx.c \
	Sources/lingo/iPod_Extended_Interface_Lingo.c \
	Sources/lingo/iPod_Extended_Interface_Lingo_Rx.c \
	Sources/lingo/iPod_iAP_DR_Commands.c \
	Sources/lingo/iPod_iAP_EI_Commands.c \
	Sources/lingo/iPod_iAP_SR_Commands.c \
	Sources/lingo/iPod_Simple_Remote_Lingo.c \
	Sources/lingo/iPod_Simple_Remote_Lingo_Rx.c

ACID_IPOD_OUT_SRC_FILES := \
	Sources/lingo/iPod_Ipod_Out_Lingo.c \
	Sources/lingo/iPod_Ipod_Out_Lingo_Rx.c \
	Sources/lingo/iPod_iAP_IO_Commands.c

ACID_STORAGE_SRC_FILES := \
	Sources/lingo/iPod_Storage_Lingo.c \
	Sources/lingo/iPod_Storage_Lingo_Rx.c \
	Sources/lingo/iPod_iAP_ST_Commands.c


LOCAL_SRC_FILES += $(ACID_LINGO_SRC_FILES)
LOCAL_SRC_FILES += $(ACID_MUSIC_SRC_FILES)
LOCAL_SRC_FILES += $(ACID_IPOD_OUT_SRC_FILES)
LOCAL_SRC_FILES += $(ACID_STORAGE_SRC_FILES)

LOCAL_LIBRARIES := tinyxml pal-drivers pal-devs pal-utils pal-core

ifeq ("$(TARGET_OS)","linux")
LOCAL_LIBRARIES += pal-juba
endif

include $(BUILD_SHARED_LIBRARY)

