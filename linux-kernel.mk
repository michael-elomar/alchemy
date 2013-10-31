###############################################################################
## @file linux-kernel.mk
## @author Y.M. Morgan
## @date 2013/05/08
##
## Build a linux kernel. Here to avoid duplication in all branches of all
## kernel source trees we have.
###############################################################################

###############################################################################
# Linux kernel.
###############################################################################

ifeq ("$(LOCAL_MODULE)", "linux")

# Override the module name...
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

# General setup
LINUX_ARCH := $(TARGET_ARCH)
LINUX_DIR := $(LOCAL_PATH)
LINUX_BUILD_DIR := $(call local-get-build-dir)
LINUX_HEADERS_DONE_FILE := $(LINUX_BUILD_DIR)/linux-headers.done
LOCAL_DONE_FILES += linux-headers.done

# Linux configuration file or target
LINUX_CONFIG_FILE := $(call module-get-config,$(LOCAL_MODULE))
LINUX_CONFIG_FILE_IS_TARGET := $(false)
ifeq ("$(wildcard $(LINUX_CONFIG_FILE))","")
  ifdef LINUX_DEFAULT_CONFIG_TARGET
    LINUX_CONFIG_FILE := $(LINUX_DEFAULT_CONFIG_TARGET)
    LINUX_CONFIG_FILE_IS_TARGET := $(true)
  else
    ifeq ("$(wildcard $(LINUX_DEFAULT_CONFIG_FILE))","")
      $(error No linux config file found)
    else
      LINUX_CONFIG_FILE := $(LINUX_DEFAULT_CONFIG_FILE)
    endif
  endif
endif

# Make sure this variable is defined (so make --warn-undefined-variables is quiet)
# It can be defined by the user makefile to specify a list of headers to be
# copied from linux source tree (list of absolute path)
# They will be copied in $(TARGET_OUT_STAGING)/usr/include/linux
ifndef LINUX_EXPORTED_HEADERS
  LINUX_EXPORTED_HEADERS :=
endif

# How to build
LINUX_MAKE_ARGS := \
	ARCH="$(LINUX_ARCH)" \
	CC="$(CCACHE) $(TARGET_LINUX_CROSS)gcc" \
	CROSS_COMPILE="$(TARGET_LINUX_CROSS)" \
	-C $(LOCAL_PATH) \
	INSTALL_MOD_PATH="$(TARGET_OUT_STAGING)" \
	INSTALL_MOD_STRIP=1 \
	INSTALL_HDR_PATH="$(TARGET_OUT_STAGING)/usr/src/linux-headers" \
	O="$(LINUX_BUILD_DIR)"

# Headers to be copied in $(TARGET_OUT_STAGING)/usr
LINUX_EXPORTED_HEADERS_OVER := \
	include/linux/media.h \
	include/linux/videodev2.h \
	include/linux/v4l2-common.h \
	include/linux/v4l2-mediabus.h \
	include/linux/v4l2-subdev.h \
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

# Macro to copy a kernel image from boot directory to staging directory
# $1 image file to copy from arch/boot directory
linux-copy-image = \
	if [ -f $(LINUX_BUILD_DIR)/arch/$(LINUX_ARCH)/boot/$1 ]; then \
		mkdir -p $(TARGET_OUT_STAGING)/boot; \
		cp -af $(LINUX_BUILD_DIR)/arch/$(LINUX_ARCH)/boot/$1 $(TARGET_OUT_STAGING)/boot; \
	fi;

# Setup config in build dir
ifneq ("$(LINUX_CONFIG_FILE_IS_TARGET)","")

# Use linux target
linux-setup-config = \
	mkdir -p $(LINUX_BUILD_DIR); \
	$(MAKE) $(LINUX_MAKE_ARGS) $(LINUX_CONFIG_FILE)

# Nothing to do
linux-save-config =

# Rule to create .config
$(LINUX_BUILD_DIR)/.config:
	+$(Q)$(linux-setup-config)

else

# Use a file
linux-setup-config = \
	mkdir -p $(LINUX_BUILD_DIR); \
	cp -af $(LINUX_CONFIG_FILE) $(LINUX_BUILD_DIR)/.config

linux-save-config = \
	cp -af $(LINUX_BUILD_DIR)/.config $(LINUX_CONFIG_FILE)

# Rule to create .config
$(LINUX_BUILD_DIR)/.config: $(LINUX_CONFIG_FILE)
	+$(Q)$(linux-setup-config)

endif

# Avoid compiling kernel at same time than header installation by adding a prerequisite
$(LINUX_BUILD_DIR)/$(LOCAL_MODULE_FILENAME): $(LINUX_BUILD_DIR)/.config $(LINUX_HEADERS_DONE_FILE)
	@mkdir -p $(LINUX_BUILD_DIR)/drivers/parrot/nand
	@echo "Checking linux kernel config: $(LINUX_CONFIG_FILE)"
	$(Q)yes "" 2>/dev/null | $(MAKE) $(LINUX_MAKE_ARGS) oldconfig
	@echo "Building linux kernel"
	$(Q)$(MAKE) $(LINUX_MAKE_ARGS)
	@echo "Installing linux kernel modules"
	$(Q)rm -rf $(TARGET_OUT_STAGING)/lib/modules
	$(Q)$(MAKE) $(LINUX_MAKE_ARGS) modules_install
	$(Q)rm -f  $(TARGET_OUT_STAGING)/lib/modules/*/build
	$(Q)rm -f  $(TARGET_OUT_STAGING)/lib/modules/*/source
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
# Order-only dependency on config to avoid parallel execution of linux makefile
.PHONY: linux-headers
linux-headers: $(LINUX_HEADERS_DONE_FILE)
$(LINUX_HEADERS_DONE_FILE): | $(LINUX_BUILD_DIR)/.config
	@mkdir -p $(LINUX_BUILD_DIR)
	@mkdir -p $(TARGET_OUT_STAGING)/usr/src/linux-headers
	@echo "Installing linux kernel headers"
	$(Q)$(MAKE) $(LINUX_MAKE_ARGS) headers_install
	@mkdir -p $(TARGET_OUT_STAGING)/usr/include/linux
	@mkdir -p $(TARGET_OUT_STAGING)/usr/include/linux/spi
	$(Q)$(foreach header,$(LINUX_EXPORTED_HEADERS),\
		install -m 0644 -p -D $(header) \
			$(TARGET_OUT_STAGING)/usr/include/linux/$(notdir $(header)); \
	)
	$(Q)$(foreach header,$(LINUX_EXPORTED_HEADERS_OVER),\
		if [ -f $(TARGET_OUT_STAGING)/usr/src/linux-headers/$(header) ]; then \
			install -m 0644 -p -D $(TARGET_OUT_STAGING)/usr/src/linux-headers/$(header) \
				$(TARGET_OUT_STAGING)/usr/$(header); \
		fi; \
	)
	@echo "Installing linux kernel headers: done"
	@touch $@

# As a special exception, this variable is modified to make sure linux headers
# are created before anything happens
ifndef ("$(call is-module-in-build-config,$(LOCAL_MODULE))","")
  TARGET_GLOBAL_PREREQUISITES += $(LINUX_HEADERS_DONE_FILE)
endif

# Kernel configuration
.PHONY: linux-menuconfig
linux-menuconfig: $(LINUX_BUILD_DIR)/.config
	@echo "Configuring linux kernel: $(LINUX_CONFIG_FILE)"
	$(Q)$(MAKE) $(LINUX_MAKE_ARGS) menuconfig
	$(Q)$(linux-save-config)

.PHONY: linux-xconfig
linux-xconfig: $(LINUX_BUILD_DIR)/.config
	@echo "Configuring linux kernel: $(LINUX_CONFIG_FILE)"
	$(Q)$(MAKE) $(LINUX_MAKE_ARGS) xconfig
	$(Q)$(linux-save-config)

.PHONY: linux-config
linux-config: linux-xconfig

# Custom clean rule. LOCAL_MODULE_FILENAME already deleted by common rule
# make clean may fail, so ignore its error
.PHONY: linux-clean
linux-clean:
	$(Q)if [ -d $(LINUX_BUILD_DIR) ]; then \
		$(MAKE) $(LINUX_MAKE_ARGS) --ignore-errors \
			clean || echo "Ignoring clean errors"; \
	fi
	$(Q)rm -rf $(TARGET_OUT_STAGING)/lib/modules
	$(Q)rm -f $(TARGET_OUT_STAGING)/boot/Image
	$(Q)rm -f $(TARGET_OUT_STAGING)/boot/zImage
	$(Q)rm -f $(TARGET_OUT_STAGING)/boot/bzImage
	$(Q)rm -f $(TARGET_OUT_STAGING)/boot/uImage
	$(Q)rm -f $(LINUX_HEADERS_DONE_FILE)
	$(Q)rm -rf $(TARGET_OUT_STAGING)/usr/src/linux-headers
	$(Q)$(foreach header,$(LINUX_EXPORTED_HEADERS),\
		rm -f $(TARGET_OUT_STAGING)/usr/include/linux/$(notdir $(header)); \
	)
	$(Q)$(foreach header,$(LINUX_EXPORTED_HEADERS_OVER),\
		rm -f $(TARGET_OUT_STAGING)/usr/$(header); \
	)

# Default rule to invoke kernel specific targets (like cscope, tags, help ...)
# Do NOT put a dependency for this pattern rule to avoid subtle troubles.
# For example, depending on linux config file will trigger this rule for this
# makefile (named linux-kernel.mk) that matches the pattern.
# The macro linux-setup-config is called to make sure it is really there...
.PHONY: linux-%
linux-%:
	@$(linux-setup-config)
	@echo "Building linux kernel $* target with $(LINUX_CONFIG_FILE)"
	$(Q)$(MAKE) $(LINUX_MAKE_ARGS) $*
	$(Q)$(linux-save-config)

# Register as a custom build in the system
include $(BUILD_CUSTOM)

endif

###############################################################################
## The 'perf' tool is in the kernel source tree
###############################################################################

ifeq ("$(LOCAL_MODULE)", "perf")

# Override the module name...
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

# General setup
PERF_BUILD_DIR := $(call local-get-build-dir)
PERF_MAKE_ENV := \
	LDFLAGS="$(TARGET_GLOBAL_LDFLAGS)" \
	EXTRA_CFLAGS="$(TARGET_GLOBAL_CFLAGS) $(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES))"

PERF_MAKE_ARGS := \
	NO_DWARF=1 \
	NO_NEWT=1 \
	NO_DEMANGLE=1

# Build rule
$(PERF_BUILD_DIR)/$(LOCAL_MODULE_FILENAME):
	@mkdir -p $(dir $@)
	$(Q) $(PERF_MAKE_ENV) $(MAKE) $(PERF_MAKE_ARGS) \
		ARCH=$(LINUX_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
		O=$(PERF_BUILD_DIR) -C $(PRIVATE_PATH)/tools/perf
	$(Q) mkdir -p $(TARGET_OUT_STAGING)/usr/bin
	$(Q) install -p $(PERF_BUILD_DIR)/perf $(TARGET_OUT_STAGING)/usr/bin
	@touch $@

# Clean rule
.PHONY: perf-clean
perf-clean:
	$(Q)if [ -d $(LINUX_BUILD_DIR) ]; then \
		$(PERF_MAKE_ENV) $(MAKE) $(PERF_MAKE_ARGS) \
			ARCH=$(LINUX_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
			O=$(PERF_BUILD_DIR) -C $(PRIVATE_PATH)/tools/perf --ignore-errors \
			clean || echo "Ignoring clean errors"; \
	fi
	$(Q) rm -f $(TARGET_OUT_STAGING)/usr/bin/perf

LOCAL_LIBRARIES := libelf

# Register as a custom build in the system
include $(BUILD_CUSTOM)

endif

