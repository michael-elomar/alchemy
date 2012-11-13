
# Linux, not omap3 cpu
# TODO: check other cpu
ifeq ("$(TARGET_OS)","linux")
ifneq ("$(TARGET_CPU)","omap3")

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := linux
LOCAL_MODULE_FILENAME := linux.done

LOCAL_DONE_FILES := linux.done linux-headers.done

LINUX_DIR := $(LOCAL_PATH)
LINUX_BUILD_DIR := $(call local-get-build-dir)
LINUX_ARCH := $(TARGET_ARCH)

ifneq ("$(wildcard $(TARGET_CONFIG_DIR)/linux.config)","")
  LINUX_CONFIG_FILE := $(TARGET_CONFIG_DIR)/linux.config
else
  LINUX_CONFIG_FILE := $(LOCAL_PATH)/lucie/config/kernel_P6.config
endif

LINUX_HEADERS_DONE_FILE := $(LINUX_BUILD_DIR)/linux-headers.done

LINUX_EXPORTED_HEADERS := \
	$(LOCAL_PATH)/drivers/parrot/sound/p6_aai/aai_ioctl.h \
	$(LOCAL_PATH)/drivers/parrot/video/p6fb_ioctl.h \
	$(LOCAL_PATH)/drivers/parrot/char/dmamem_ioctl.h \
	$(LOCAL_PATH)/drivers/parrot/char/pwm/pwm_ioctl.h \
	$(LOCAL_PATH)/drivers/parrot/char/gpio2_ioctl.h

LINUX_EXPORTED_HEADERS_OVER := \
	include/linux/videodev2.h \
	include/linux/i2c-dev.h \
	include/linux/hid.h \
	include/linux/hidraw.h \
	include/linux/hiddev.h \
	include/linux/ethtool.h \
	include/linux/net.h \
	include/linux/uinput.h \
	include/linux/input.h \
	include/linux/watchdog.h \
	include/linux/spi/spidev.h

LINUX_MAKE_ARGS := \
	ARCH=$(LINUX_ARCH) \
	CROSS_COMPILE=$(TARGET_CROSS) \
	-C $(LOCAL_PATH) \
	INSTALL_MOD_PATH=$(TARGET_OUT_STAGING) \
	INSTALL_MOD_STRIP=1 \
	INSTALL_HDR_PATH=$(TARGET_OUT_STAGING)/linux-headers \
	O=$(LINUX_BUILD_DIR)

# Copy config in build dir
$(LINUX_BUILD_DIR)/.config: $(LINUX_CONFIG_FILE)
	@mkdir -p $(dir $@)
	@cp -af $< $@

# Macro to copy a kernel image from boot directory to staging directory
linux-copy-image = \
	if [ -f $(LINUX_BUILD_DIR)/arch/$(LINUX_ARCH)/boot/$1 ]; then \
		cp -af $(LINUX_BUILD_DIR)/arch/$(LINUX_ARCH)/boot/$1 $(TARGET_OUT_STAGING); \
	fi;

# Avoid compiling kernel at same time than header installation by adding a prerequisite
$(LINUX_BUILD_DIR)/$(LOCAL_MODULE_FILENAME): $(LINUX_BUILD_DIR)/.config $(LINUX_HEADERS_DONE_FILE)
	@mkdir -p $(LINUX_BUILD_DIR)/drivers/parrot/nand
	@echo "Checking linux kernel config: $(LINUX_CONFIG_FILE)"
	$(Q)yes "" | $(MAKE) $(LINUX_MAKE_ARGS) oldconfig
	@echo "Building linux kernel"
	$(Q)$(MAKE) $(LINUX_MAKE_ARGS)
	@echo "Installing linux kernel modules"
	$(Q)$(MAKE) $(LINUX_MAKE_ARGS) modules_install
	@echo "Installing linux kernel images"
ifeq ("$(LINUX_ARCH)","arm")
	$(Q)$(MAKE) $(LINUX_MAKE_ARGS) uImage
	$(Q)$(call linux-copy-image,uImage)
endif
	$(Q)$(call linux-copy-image,Image)
	$(Q)$(call linux-copy-image,zImage)
	$(Q)$(call linux-copy-image,bzImage)
	@echo "Linux kernel built"
	@touch $@

# Linux headers
.PHONY: linux-headers
linux-headers: $(LINUX_HEADERS_DONE_FILE)

$(LINUX_HEADERS_DONE_FILE):
	@mkdir -p $(LINUX_BUILD_DIR)
	@mkdir -p $(TARGET_OUT_STAGING)/linux-headers
	@echo "Installing linux kernel headers"
	$(Q)$(MAKE) $(LINUX_MAKE_ARGS) headers_install
	@mkdir -p $(TARGET_OUT_STAGING)/usr/include/linux
	@mkdir -p $(TARGET_OUT_STAGING)/usr/include/linux/spi
	$(Q)$(foreach header,$(LINUX_EXPORTED_HEADERS),\
		install -m 0644 -p -D $(header) \
			$(TARGET_OUT_STAGING)/usr/include/linux/$(notdir $(header)); \
	)
	$(Q)$(foreach header,$(LINUX_EXPORTED_HEADERS_OVER),\
		install -m 0644 -p -D $(TARGET_OUT_STAGING)/linux-headers/$(header) \
			$(TARGET_OUT_STAGING)/usr/$(header); \
	)
	@echo "Installing linux kernel headers: done"
	@touch $@

# As a special exception, this variable is modified to make sure linux headers
# are created before anything happens
ifdef CONFIG_ALCHEMY_BUILD_LINUX
TARGET_GLOBAL_PREREQUISITES += $(LINUX_HEADERS_DONE_FILE)
endif

# Kernel configuration
.PHONY: linux-menuconfig
linux-menuconfig: $(LINUX_BUILD_DIR)/.config
	@echo "Configuring linux kernel: $(LINUX_CONFIG_FILE)"
	$(Q)$(MAKE) $(LINUX_MAKE_ARGS) menuconfig
	@cp -af $(LINUX_BUILD_DIR)/.config $(LINUX_CONFIG_FILE)

.PHONY: linux-xconfig
linux-xconfig: $(LINUX_BUILD_DIR)/.config
	@echo "Configuring linux kernel: $(LINUX_CONFIG_FILE)"
	$(Q)$(MAKE) $(LINUX_MAKE_ARGS) xconfig
	@cp -af $(LINUX_BUILD_DIR)/.config $(LINUX_CONFIG_FILE)

.PHONY: linux-config
linux-config: linux-xconfig

# Custom clean rule. LOCAL_MODULE_FILENAME already deleted by common rule
# make clean may fail, so ignore its error
.PHONY: linux-clean
linux-clean:
	$(Q)if [ -d $(LINUX_BUILD_DIR) ]; then \
		$(MAKE) $(LINUX_MAKE_ARGS) clean || echo "Ignoring clean errors"; \
	fi
	$(Q)rm -rf $(TARGET_OUT_STAGING)/lib/modules
	$(Q)rm -f $(TARGET_OUT_STAGING)/Image
	$(Q)rm -f $(TARGET_OUT_STAGING)/zImage
	$(Q)rm -f $(TARGET_OUT_STAGING)/bzImage
	$(Q)rm -f $(TARGET_OUT_STAGING)/uImage
	$(Q)rm -f $(LINUX_HEADERS_DONE_FILE)

$(call local-add-module)

endif
endif

