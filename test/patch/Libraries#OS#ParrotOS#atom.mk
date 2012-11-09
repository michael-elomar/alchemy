
LOCAL_PATH := $(call my-dir)

###############################################################################
# pal-core
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := pal-core
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := ConfigParrotOSSet.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/core/include

LOCAL_EXPORT_CFLAGS := \
	-DPFILE=__FILE__ \
	-DPBUILD \
	-UNDEBUG

ifeq ("$(TARGET_OS)","linux")
  LOCAL_EXPORT_C_INCLUDES += \
    $(LOCAL_PATH)/core/include/linux \
    $(LOCAL_PATH)/core/include/posix \
    $(LOCAL_PATH)/core/include/generic
  LOCAL_EXPORT_CFLAGS += -DPOS_LINUX -DOS_LINUX
else ifeq ("$(TARGET_OS)","ecos")
  LOCAL_EXPORT_C_INCLUDES += \
    $(LOCAL_PATH)/core/include/ecos \
    $(LOCAL_PATH)/core/include/generic
  LOCAL_EXPORT_CFLAGS += -DPOS_ECOS -DOS_ECOS
endif

ifeq ("$(TARGET_LIBC)","eglibc")
  LOCAL_LDLIBS += -lgcc
endif

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/core/include/internal

LOCAL_CFLAGS := \
	-D_BSD_SOURCE \
	-D_XOPEN_SOURCE=600 \
	-DSUP_U32_IS_ATOMIC

LOCAL_SRC_FILES := \
	core/src/common/generic_diag.c \
	core/src/common/generic_directories.c \
	core/src/common/generic_log.c \
	core/src/common/generic_watchdog.c \
	core/src/common/cbuf.c \
	core/src/common/module.c \
	core/src/common/common_init.c \
	core/src/common/priority.c \
	core/src/generic/backtrace.c \
	core/src/generic/generic_workqueue.c \
	core/src/generic/generic_mbox2.c

ifeq ("$(TARGET_OS)","linux")

  LOCAL_SRC_FILES += \
	core/src/generic/generic_flag.c \
	core/src/generic/generic_mbox.c \
	core/src/posix/posix_time.c \
	core/src/posix/posix_sys.c \
	core/src/posix/posix_system.c \
	core/src/posix/posix_cond.c \
	core/src/posix/posix_sem.c \
	core/src/posix/posix_thread.c \
	core/src/posix/posix_main.c \
	core/src/linux/alarm.c
  ifeq ("$(TARGET_LIBC)","bionic")
    LOCAL_EXPORT_CFLAGS += -DPOS_ANDROID
    LOCAL_SRC_FILES += core/src/posix/posix_mutex_android.c
  else
    LOCAL_SRC_FILES += core/src/posix/posix_mutex.c
  endif

else ifeq ("$(TARGET_OS)","ecos")

  LOCAL_SRC_FILES += \
	core/src/ecos/ecos_thread.c \
	core/src/ecos/ecos_mutex.c \
	core/src/ecos/ecos_flag.c \
	core/src/ecos/ecos_cond.c \
	core/src/ecos/ecos_mbox.c \
	core/src/ecos/ecos_time.c \
	core/src/ecos/ecos_hwalarm.c \
	core/src/ecos/ecos_alarm.c \
	core/src/ecos/ecos_sem.c \
	core/src/ecos/ecos_sys.c

endif

# Setup ecos as a library dependecy to get its headers and linker flags
ifeq ("$(TARGET_OS)","ecos")
  LOCAL_LIBRARIES += ecos
endif

LOCAL_WHOLE_STATIC_LIBRARIES := pbuild-hook

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# pal-main
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := pal-main
LOCAL_FORCE_WHOLE_STATIC_LIBRARY := 1

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS := \
	-D_BSD_SOURCE \
	-D_XOPEN_SOURCE=600 \
	-DSUP_U32_IS_ATOMIC

LOCAL_SRC_FILES := \
	pal_main.c

LOCAL_LIBRARIES := pal-core

include $(BUILD_STATIC_LIBRARY)

###############################################################################
# pal-drivers
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := pal-drivers
LOCAL_PBUILD_HOOK := 1

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/drivers/include \

ifeq ("$(TARGET_OS)","linux")
LOCAL_EXPORT_C_INCLUDES += \
	$(LOCAL_PATH)/drivers/include/linux \
	$(LOCAL_PATH)/drivers/include/posix
else ifeq ("$(TARGET_OS)","ecos")
LOCAL_EXPORT_C_INCLUDES += \
	$(LOCAL_PATH)/drivers/include/ecos
endif

LOCAL_EXPORT_CFLAGS :=

ifeq ("$(TARGET_LIBC)","eglibc")
  LOCAL_LDLIBS += -lgcc
endif

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/core/include/internal

LOCAL_CFLAGS := \
	-D_BSD_SOURCE \
	-D_XOPEN_SOURCE=600 \
	-DSUP_U32_IS_ATOMIC

ifeq ("$(TARGET_OS)","linux")

LOCAL_SRC_FILES := \
	drivers/src/posix/linux_uart.c \
	drivers/src/linux/linux_uart_bt.c \
	drivers/src/posix/linux_uart_tcp.c \
	drivers/src/posix/linux_uart_unix.c \
	drivers/src/linux/usbc.c \
	drivers/src/linux/fs.c \
	drivers/src/linux/wdog.c \
	drivers/src/linux/netif.c \
	drivers/src/linux/product_hw_info.c \
	drivers/src/linux/i2c.c \
	drivers/src/linux/spi.c \
	drivers/src/linux/pnxi2c.c \
	drivers/src/linux/pnxgpio.c \
	drivers/src/linux/pnxwdog.c \
	drivers/src/linux/pnxuart.c \
	drivers/src/linux/bnep.c \
	drivers/src/linux/ppp.c \
	drivers/src/linux/mqueue.c \
	drivers/src/linux/eth.c \
	drivers/src/linux/sread.c \
	drivers/src/linux/hid.c

ifneq ("$(TARGET_OS_FLAVOUR)","native")
LOCAL_SRC_FILES += \
	drivers/src/linux/button.c \
	drivers/src/linux/gpio.c \
	drivers/src/linux/pwm.c
endif

else ifeq ("$(TARGET_OS)","ecos")

LOCAL_SRC_FILES := \
	drivers/src/ecos/ecos_uart.c \
	drivers/src/ecos/spi.c \
	drivers/src/ecos/i2c.c \
	drivers/src/ecos/gpio.c \
	drivers/src/ecos/bnep.c \
	drivers/src/ecos/usbc.c \
	drivers/src/ecos/fs.c \
	drivers/src/ecos/button.c

endif

LOCAL_LIBRARIES := pal-core

ifdef CONFIG_PAL_UART_BTUSB_DRIVER
LOCAL_LIBRARIES += libusb_1_0
endif

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# pal-devs
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := pal-devs
LOCAL_PBUILD_HOOK := 1

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/devs/i2c \
	$(LOCAL_PATH)/devs/usb

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/core/include/internal

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	devs/i2c/ad7995.c \
	devs/i2c/eeprom.c \
	devs/i2c/ipod_coproc.c \
	devs/i2c/p6mu_adc.c \
	devs/usb/ipod.c \
	devs/usb/mtp.c

LOCAL_LIBRARIES := pal-drivers pal-core

ifeq ("$(TARGET_OS)","linux")
  LOCAL_LIBRARIES += libusb alsa-lib
endif

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# pal-utils
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := pal-utils
LOCAL_PBUILD_HOOK := 1

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/utils/include

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/core/include/internal

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	utils/src/crc.c \
	utils/src/pal_lang.c \
	utils/src/strlcat.c \
	utils/src/strlcpy.c \
	utils/src/strnlen.c \
	utils/src/supervis.c \
	utils/src/timers.c \
	utils/src/uart.c \

LOCAL_LIBRARIES := pal-drivers pal-core

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# pal-juba
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := pal-juba
LOCAL_PBUILD_HOOK := 1

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/juba/include

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/core/include/internal \
	$(LOCAL_PATH)/utils/include \

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	juba/src/client.c

LOCAL_LIBRARIES := udev pal-core

ifeq ("$(TARGET_LIBC)","bionic")
LOCAL_LIBRARIES += libcutils
endif

include $(BUILD_SHARED_LIBRARY)

