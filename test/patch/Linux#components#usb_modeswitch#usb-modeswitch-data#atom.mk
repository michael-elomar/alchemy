
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := usb-modeswitch-data
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

# Where the module will be 'built'
USB_MODESWITCH_DATA_BUILD_DIR := $(call local-get-build-dir)

# Data files
USB_MODESWITCH_DATA_SRC_DIR := $(LOCAL_PATH)/usb_modeswitch.d
USB_MODESWITCH_DATA_DST_DIR := $(TARGET_OUT_STAGING)/usr/share/usb_modeswitch

# Check db script
USB_MODESWITCH_DATA_CHECKDB := $(LOCAL_PATH)/lucie/checkdb.sh

# udev rules
LOCAL_COPY_FILES := \
	40-usb_modeswitch.rules:lib/udev/rules.d/40-usb_modeswitch.rules

# LOCAL_COPY_FILES can not be used with data files because names contain ':'

# Main rule
$(USB_MODESWITCH_DATA_BUILD_DIR)/$(LOCAL_MODULE_FILENAME): 
	@mkdir -p $(dir $@)
	@mkdir -p $(USB_MODESWITCH_DATA_DST_DIR)
	$(Q)install -p --mode=644 $(USB_MODESWITCH_DATA_SRC_DIR)/* $(USB_MODESWITCH_DATA_DST_DIR)
	@echo Checking usb_modeswitch udev rules consistency
	$(Q) $(USB_MODESWITCH_DATA_CHECKDB) \
		$(TARGET_OUT_STAGING)/lib/udev/rules.d/40-usb_modeswitch.rules \
		$(USB_MODESWITCH_DATA_DST_DIR)
	@touch $@

# Need to add by hand our list to be deleted (LOCAL_COPY_FILES done automatically though)
LOCAL_CLEAN_DIRS += $(USB_MODESWITCH_DATA_DST_DIR)

$(call local-add-module)

