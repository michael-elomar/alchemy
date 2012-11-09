
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := 88w8688_uap
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

_88W8688_SRC_DIR := $(LOCAL_PATH)
_88W8688_BUILD_DIR := $(call local-get-build-dir)

# TODO : add dedicated build instructions for linux kernel modules
# should work but LINUX_MAKE_ARGS can only be used in commands not anywhere else
# TODO : it seems impossible to have object tree out of source tree for external kernel modules
# only option forseen : copy source in build tree before building
$(_88W8688_BUILD_DIR)/$(LOCAL_MODULE_FILENAME): | linux
	@echo "Building 88w8688_uap kernel module"
	@mkdir -p $(dir $@)
	$(Q) $(MAKE) $(LINUX_MAKE_ARGS) M=$(_88W8688_SRC_DIR)
	$(Q) $(MAKE) $(LINUX_MAKE_ARGS) M=$(_88W8688_SRC_DIR) modules_install
	@touch $@

$(call local-add-module)

