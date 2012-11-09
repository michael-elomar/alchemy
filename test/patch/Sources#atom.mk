
LOCAL_PATH := $(call my-dir)

###############################################################################
# softat-fc6050w
###############################################################################

ifeq ("$(TARGET_PRODUCT)","fc6050w")

include $(CLEAR_VARS)

LOCAL_MODULE := softat-fc6050w
LOCAL_PBUILD_HOOK := 1

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Startup \
	$(LOCAL_PATH)/HWMngt \
	$(LOCAL_PATH)/HWMngt/Bluetooth \
	$(LOCAL_PATH)/HWMngt/Wifi/88w8688

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	Startup/START_CK505X.c \
	HWMngt/HWMngt_FC6050WLinux.c \
	HWMngt/Bluetooth/HWMngt_BTInfineon.c \
	HWMngt/Bluetooth/HWMngt_BTMarvell.c \
	HWMngt/Wifi/88w8688/HWMngt_88w8688.c \
	HWMngt/Wifi/88w8688/uapcmd.c \
	HWMngt/Wifi/88w8688/uaputl.c \
	HWMngt/Wifi/88w8688/mlanevent.c \
	HWMngt/Wifi/88w8688/wifi_client.c

LOCAL_LIBRARIES := wpa_supplicant alsa-lib softat pal-core pal-main

include $(BUILD_EXECUTABLE)

endif

###############################################################################
# softat-fc61000
###############################################################################

ifeq ("$(TARGET_PRODUCT)","fc6100")

include $(CLEAR_VARS)

LOCAL_MODULE := softat-fc6100
LOCAL_PBUILD_HOOK := 1

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Startup \
	$(LOCAL_PATH)/HWMngt \
	$(LOCAL_PATH)/HWMngt/Bluetooth \
	$(LOCAL_PATH)/HWMngt/Wifi/88w8688

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	Startup/START_CK505X.c \
	HWMngt/HWMngt_OMAP_Raptor.c \
	HWMngt/Bluetooth/HWMngt_BTMarvell.c \
	HWMngt/Wifi/88w8688/HWMngt_88w8688.c \
	HWMngt/Wifi/88w8688/uapcmd.c \
	HWMngt/Wifi/88w8688/uaputl.c \
	HWMngt/Wifi/88w8688/mlanevent.c \
	HWMngt/Wifi/88w8688/wifi_client.c

LOCAL_LIBRARIES := wpa_supplicant softat concertos blues pal-utils pal-drivers pal-core pal-main

include $(BUILD_EXECUTABLE)

endif

###############################################################################
# softat-pclinux
###############################################################################

ifeq ("$(TARGET_PRODUCT)","pclinux")

include $(CLEAR_VARS)

LOCAL_MODULE := softat-pclinux
LOCAL_PBUILD_HOOK := 1

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Startup \
	$(LOCAL_PATH)/HWMngt \
	$(LOCAL_PATH)/HWMngt/Bluetooth \
	$(LOCAL_PATH)/HWMngt/Wifi/88w8688

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	Startup/START_CK505X.c \
	HWMngt/HWMngt_PCLinux.c \
	HWMngt/Bluetooth/HWMngt_BTDongle.c

LOCAL_LIBRARIES := softat concertos blues pal-utils pal-core pal-main

include $(BUILD_EXECUTABLE)

endif

###############################################################################
# softat-fc6000n
###############################################################################

ifeq ("$(TARGET_PRODUCT)","fc6000n")

include $(CLEAR_VARS)

LOCAL_MODULE := softat-fc6000n
LOCAL_PBUILD_HOOK := 1

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Startup \
	$(LOCAL_PATH)/HWMngt \
	$(LOCAL_PATH)/HWMngt/Bluetooth \
	$(LOCAL_PATH)/HWMngt/Wifi/88w8688

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	Startup/START_CK505X.c \
	HWMngt/HWMngt_Generic.c \
	HWMngt/HWMngt_FC6000N.c \
	HWMngt/Bluetooth/HWMngt_BTInfineon.c

LOCAL_LIBRARIES := softat pal-core pal-main

include $(BUILD_EXECUTABLE)

endif

