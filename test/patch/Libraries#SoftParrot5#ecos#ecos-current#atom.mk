
ifeq ("$(TARGET_OS)","ecos")

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := ecos
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

ECOS_CONFIG_FILE := $(TARGET_CONFIG_DIR)/ecos.ecm

ECOS_DIR := $(LOCAL_PATH)
ECOS_BUILD_DIR := $(call local-get-build-dir)
ECOS_DONE_FILE := $(ECOS_BUILD_DIR)/$(LOCAL_MODULE_FILENAME)

ECOS_CONFIG_BIN := $(ECOS_DIR)/tools/bin-linux/ecosconfig
ECOS_CONFIGTOOL_BIN := $(ECOS_DIR)/tools/bin-linux/configtool2
ECOS_REPOSITORY := $(ECOS_DIR)/packages

ECOS_MAKEFILE := $(ECOS_BUILD_DIR)/makefile
ECOS_ECC_FILE := $(ECOS_BUILD_DIR)/ecos.ecc
ECOS_INSTALL_DIR := $(TARGET_OUT_STAGING)/ecos


LOCAL_EXPORT_C_INCLUDES := \
	$(ECOS_INSTALL_DIR)/include \
	$(ECOS_REPOSITORY)

LOCAL_EXPORT_LDLIBS := \
	-L$(ECOS_INSTALL_DIR)/lib \
	-Ttarget.ld 

ECOS_CONFIG= \
	$(ECOS_CONFIG_BIN) \
	--config=$(ECOS_ECC_FILE) \
	--prefix=$(ECOS_INSTALL_DIR) \
	--srcdir=$(ECOS_REPOSITORY)

ifeq ("$(V)","0")
  ECOS_MAKE_ARGS := -s
else
  ECOS_MAKE_ARGS :=
endif

# Generate ecos makefile
$(ECOS_ECC_FILE) $(ECOS_MAKEFILE): $(ECOS_CONFIG_FILE)
	@echo "Importing ecos configuration: $(ECOS_CONFIG_FILE)"
	@mkdir -p $(ECOS_BUILD_DIR)
	@mkdir -p $(ECOS_INSTALL_DIR)
	@cat /dev/null > $(ECOS_ECC_FILE)
	$(Q)cd $(ECOS_BUILD_DIR) && $(ECOS_CONFIG) import $(ECOS_CONFIG_FILE)
	$(Q)cd $(ECOS_BUILD_DIR) && $(ECOS_CONFIG) check
	$(Q)cd $(ECOS_BUILD_DIR) && $(ECOS_CONFIG) resolve
	$(Q)cd $(ECOS_BUILD_DIR) && $(ECOS_CONFIG) tree

# Module main rule
$(ECOS_DONE_FILE): $(ECOS_MAKEFILE)
	@echo "Building ecos"
	$(Q)$(MAKE) $(ECOS_MAKE_ARGS) -C $(ECOS_BUILD_DIR)
	@echo "Building ecos: done"
	@touch $@

# As a special exception, this variable is modified to make sure ecos is build
# before anything happens
TARGET_GLOBAL_PREREQUISITES += $(ECOS_DONE_FILE)

# Custom clean rule. LOCAL_MODULE_FILENAME already deleted by common rule
# make clean may fail, so ignore its error
.PHONY: ecos-clean
ecos-clean:
	$(Q)if [ -d $(ECOS_BUILD_DIR) ]; then \
		$(MAKE) $(ECOS_MAKE_ARGS) -C $(ECOS_BUILD_DIR) clean; \
	fi

# Ecos configuration
.PHONY: ecos-config
ecos-config: $(ECOS_ECC_FILE)
	@echo "Configuring ecos: $(ECOS_CONFIG_FILE)"
	$(Q)cd $(ECOS_BUILD_DIR) && $(ECOS_CONFIGTOOL_BIN) \
		$(ECOS_REPOSITORY) $(ECOS_ECC_FILE)

$(call local-add-module)

endif

