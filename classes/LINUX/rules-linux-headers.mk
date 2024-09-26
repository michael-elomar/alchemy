###############################################################################
## @file classes/LINUX/rules-linux-headers.mk
## @author M. Rabault
## @date 2016/03/20
##
## Rules for linux headers
###############################################################################

_module_msg := $(if $(_mode_host),Host )Linux

include $(BUILD_SYSTEM)/classes/GENERIC/rules.mk

LINUX_HEADERS_CONFIG_FILE := $(call module-get-config,$(LOCAL_MODULE))

$(LINUX_HEADERS_BUILD_DIR)/.config: $(LINUX_HEADERS_CONFIG_FILE)
	@mkdir -p $(LINUX_HEADERS_BUILD_DIR)
	@cp $(LINUX_HEADERS_CONFIG_FILE) $(LINUX_HEADERS_BUILD_DIR)/.config

# Order-only prerequisite to avoid having to rebuild everything because .config
# changed. The UAPI headers don't seem to depend on .config.
$(LINUX_HEADERS_DONE_FILE): | $(LINUX_HEADERS_BUILD_DIR)/.config
ifneq ("$(LINUX_ARCH)","um")
	@mkdir -p $(LINUX_HEADERS_BUILD_DIR)
	@mkdir -p $(TARGET_OUT_STAGING)/$(TARGET_ROOT_DESTDIR)/src/linux-headers
	@echo "Installing linux kernel headers"
	$(Q) $(MAKE) $(LINUX_HEADERS_MAKE_ARGS) headers_install
	@mkdir -p $(TARGET_OUT_STAGING)/$(TARGET_ROOT_DESTDIR)/include/linux
	@cp -r $(TARGET_OUT_STAGING)/$(TARGET_ROOT_DESTDIR)/src/linux-headers/include/* $(TARGET_OUT_STAGING)/$(TARGET_ROOT_DESTDIR)/include
endif
	@echo "Installing linux kernel headers: done"
	@touch $@

HEADERS_TO_CLEAN := $(notdir $(wildcard $(TARGET_OUT_STAGING)/$(TARGET_ROOT_DESTDIR)/src/linux-headers/include/*))

# Custom clean rule. LOCAL_MODULE_FILENAME already deleted by common rule
# make clean may fail, so ignore its error
linux-headers-clean:
	$(Q) if [ -d $(LINUX_HEADERS_BUILD_DIR) ]; then \
		$(MAKE) $(LINUX_MAKE_ARGS) --ignore-errors \
			clean || echo "Ignoring clean errors"; \
	fi
	$(Q) rm -f $(LINUX_HEADERS_DONE_FILE)
	$(Q) rm -rf $(addprefix $(TARGET_OUT_STAGING)/$(TARGET_ROOT_DESTDIR)/include/,$(HEADERS_TO_CLEAN))
	$(Q) rm -rf $(TARGET_OUT_STAGING)/$(TARGET_ROOT_DESTDIR)/src/linux-headers
	$(Q) rm -rf $(LINUX_SDK_DIR)

.PHONY: linux-headers linux-headers-clean
