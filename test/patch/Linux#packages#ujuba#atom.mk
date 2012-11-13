LOCAL_PATH := $(call my-dir)

###############################################################################
# libujuba
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := libujuba

LOCAL_EXPORT_C_INCLUDES  := -I$(LOCAL_PATH)/src

LOCAL_SRC_FILES := \
	src/ujuba.c \
	src/ujuba_daemon.c \

LOCAL_LIBRARIES := libpac udev

ifeq ("$(TARGET_LIBC)","bionic")
LOCAL_LIBRARIES += liblog libcutils
endif

include $(BUILD_STATIC_LIBRARY)

###############################################################################
# ujuba_cifs
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := ujuba_cifs
LOCAL_DESTDIR := lib/udev

LOCAL_SRC_FILES := \
	src/ujuba_cifs/ujuba_cifs.c

LOCAL_LIBRARIES := libujuba

include $(BUILD_EXECUTABLE)

###############################################################################
# ujuba_firmware
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := ujuba_firmware
LOCAL_DESTDIR := lib/udev

LOCAL_SRC_FILES := \
	src/ujuba_firmware/ujuba_firmware.c

LOCAL_LIBRARIES := libujuba

include $(BUILD_EXECUTABLE)

###############################################################################
# ujuba_modem
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := ujuba_modem
LOCAL_DESTDIR := lib/udev

LOCAL_SRC_FILES := \
	src/ujuba_modem/ujuba_modem.c

LOCAL_LIBRARIES := libujuba

include $(BUILD_EXECUTABLE)

###############################################################################
# ujuba_rnb4_hub
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := ujuba_rnb4_hub
LOCAL_DESTDIR := lib/udev

LOCAL_SRC_FILES := \
	src/ujuba_rnb4_hub/ujuba_rnb4_hub.c

LOCAL_LIBRARIES := libujuba

include $(BUILD_EXECUTABLE)

###############################################################################
# ujuba_rndis (not present on this branch ?)
###############################################################################

#include $(CLEAR_VARS)

#LOCAL_MODULE := ujuba_rndis
#LOCAL_DESTDIR := lib/udev

#LOCAL_SRC_FILES := \
#	src/ujuba_rndis/ujuba_rndis.c

#LOCAL_LIBRARIES := libujuba

#include $(BUILD_EXECUTABLE)

###############################################################################
# ujuba_storage
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := ujuba_storage
LOCAL_DESTDIR := lib/udev

LOCAL_SRC_FILES := \
	src/ujuba_storage/ujuba_storage.c \
	src/ujuba_storage/ujuba_storage_disk.c \
	src/ujuba_storage/ujuba_storage_external.c \
	src/ujuba_storage/ujuba_storage_metadata.c \
	src/ujuba_storage/ujuba_storage_mmc.c \
	src/ujuba_storage/ujuba_storage_mountd.c \
	src/ujuba_storage/ujuba_storage_usb.c \
	src/ujuba_storage/ujuba_storage_utils.c \
	src/ujuba_storage/ujuba_storage_volume.c

LOCAL_LIBRARIES := libujuba

include $(BUILD_EXECUTABLE)

###############################################################################
# ujuba_usb
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := ujuba_usb
LOCAL_DESTDIR := lib/udev

LOCAL_SRC_FILES := \
	src/ujuba_usb/ujuba_usb.c

LOCAL_LIBRARIES := libujuba

include $(BUILD_EXECUTABLE)

###############################################################################
# ujuba_rules
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := ujuba_rules
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

UJUBA_RULES_BUILD_DIR := $(call local-get-build-dir)

# Get all .rules files
LOCAL_COPY_FILES := \
	$(foreach __f,$(wildcard $(LOCAL_PATH)/src/ujuba_*/*.rules), \
		$(eval __f2 := $(patsubst $(LOCAL_PATH)/%,%,$(__f))) \
		$(__f2):$(addprefix lib/udev/rules.d/,$(notdir $(__f2))) \
	)

$(UJUBA_RULES_BUILD_DIR)/$(LOCAL_MODULE_FILENAME):
	@mkdir -p $(dir $@)
	@touch $@

$(call local-add-module)

