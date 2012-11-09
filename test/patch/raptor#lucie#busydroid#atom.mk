
# Use Android.mk instead because the strip operation fails with soslim
# and I don't want to add an exeception in Alchemy for that
ifdef SKIP_THAT

ifeq ("$(TARGET_OS_FLAVOUR)","android")

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := busydroid
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

BUSYDROID_DIR := $(LOCAL_PATH)/bin
BUSYDROID_FILES := $(patsubst $(BUSYDROID_DIR)/%,%,$(wildcard $(BUSYDROID_DIR)/*))

$(LINUX_BUILD_DIR)/$(LOCAL_MODULE_FILENAME): $(addprefix $(TARGET_OUT_STAGING)/usr/bin/,$(BUSYDROID_FILES))
	@touch $@

LOCAL_COPY_FILES := \
	$(foreach __f,$(BUSYDROID_FILES), \
		bin/$(__f):usr/bin/$(__f) \
	)

$(call local-add-module)

endif

endif

