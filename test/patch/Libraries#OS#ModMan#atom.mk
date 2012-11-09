
LOCAL_PATH := $(call my-dir)

###############################################################################
# Modman
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := modman
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := ConfigModMan.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/include

LOCAL_SRC_FILES := \
	src/modman.c \
	src/modman_chat.c \
	src/modman_data.c \
	src/modman_db.c \
	src/modman_juba.c \
	src/modman_juba_modem.c \
	src/modman_blackberry.c \
	src/modman_engine.c \
	src/modman_modem.c \
	src/modman_network.c \
	src/modman_os.c \
	src/modman_ppp.c \
	src/modman_states.c \
	src/modman_timer.c \
	src/modman_device.c \
	src/modman_at.c \
	src/modman_utility.c

LOCAL_LIBRARIES := \
	libcrypto \
	pal-juba pal-utils pal-drivers pal-core

ifeq ("$(TARGET_LIBC)","bionic")
LOCAL_LIBRARIES += libcutils
endif

include $(BUILD_SHARED_LIBRARY)

###############################################################################
## Modman data
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := modman-data
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

# Where the module will be 'built'
MODMAN_DATA_BUILD_DIR := $(call local-get-build-dir)

LOCAL_COPY_FILES := \
	extra/ip-up:etc/ppp/ip-up \
	extra/ip-down:etc/ppp/ip-down \
	extra/40-ujuba-modem.rules:lib/udev/rules.d/40-ujuba-modem.rules \
	extra/40-ujuba-blackberry.rules:lib/udev/rules.d/40-ujuba-blackberry.rules

# Data files
MODMAN_DATA_SRC_DIR := $(LOCAL_PATH)/db
MODMAN_DATA_DST_DIR := $(TARGET_OUT_STAGING)/usr/share/modman_db
MODMAN_DATA_DONE_FILE :=

# LOCAL_COPY_FILES can not be used with data files because names contain ':'

# Main rule
$(MODMAN_DATA_BUILD_DIR)/$(LOCAL_MODULE_FILENAME):
	@mkdir -p $(dir $@)
	@mkdir -p $(MODMAN_DATA_DST_DIR)
	$(Q)install -p --mode=644 $(MODMAN_DATA_SRC_DIR)/* $(MODMAN_DATA_DST_DIR)
	@touch $@

# Need to add by hand our list to be deleted (LOCAL_COPY_FILES done automatically though)
LOCAL_CLEAN_DIRS += $(MODMAN_DATA_DST_DIR)

$(call local-add-module)

