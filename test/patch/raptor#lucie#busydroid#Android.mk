
LOCAL_PATH := $(call my-dir)

# File to copy
BUSYDROID_DIR := $(LOCAL_PATH)/bin
BUSYDROID_FILES := $(patsubst $(BUSYDROID_DIR)/%,%,$(wildcard $(BUSYDROID_DIR)/*))

# Names in the target directory
BUSYDROID_FILES_TARGET := $(addprefix $(TARGET_OUT)/xbin/,$(BUSYDROID_FILES))

$(BUSYDROID_FILES_TARGET):
	@echo "Busydroid: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) cp -af $(BUSYDROID_DIR)/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(BUSYDROID_FILES_TARGET)

