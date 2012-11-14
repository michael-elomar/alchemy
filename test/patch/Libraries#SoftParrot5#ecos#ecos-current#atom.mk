
ifeq ("$(TARGET_OS)","ecos")

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := ecos
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

LOCAL_DONE_FILES := $(LOCAL_MODULE).done $(LOCAL_MODULE)-installed.done

ECOS_CONFIG_FILE := $(TARGET_CONFIG_DIR)/ecos.ecm

ECOS_DIR := $(LOCAL_PATH)
ECOS_BUILD_DIR := $(call local-get-build-dir)
ECOS_DONE_FILE := $(ECOS_BUILD_DIR)/$(LOCAL_MODULE_FILENAME)

ECOS_CONFIG_BIN := $(ECOS_DIR)/tools/bin-linux/ecosconfig
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

# Generate ecos makefile
$(ECOS_MAKEFILE): $(ECOS_CONFIG_FILE)
	@mkdir -p $(ECOS_BUILD_DIR)
	@mkdir -p $(ECOS_INSTALL_DIR)
	@cat /dev/null > $(ECOS_ECC_FILE)
	$(Q)cd $(ECOS_BUILD_DIR) && $(ECOS_CONFIG) import $(ECOS_CONFIG_FILE)
	$(Q)cd $(ECOS_BUILD_DIR) && $(ECOS_CONFIG) check
	$(Q)cd $(ECOS_BUILD_DIR) && $(ECOS_CONFIG) resolve
	$(Q)cd $(ECOS_BUILD_DIR) && $(ECOS_CONFIG) tree

ifeq ("$(V)","0")
  ECOS_MAKE_ARGS := -s
else
  ECOS_MAKE_ARGS :=
endif

# Build ecos
.PHONY: ecos-build
ecos-build: $(ECOS_MAKEFILE)
	@echo "Building ecos"
	$(Q)cd $(ECOS_BUILD_DIR) && $(MAKE) $(ECOS_MAKE_ARGS)
	@echo "Building ecos: done"

# Module main rule
$(ECOS_DONE_FILE): | ecos-build
	@touch $@

# As a special exception, this variable is modified to make sure ecos is build
# before anything happens
TARGET_GLOBAL_PREREQUISITES += $(ECOS_DONE_FILE)

# Additional clean variables
LOCAL_CLEAN_DIRS +=$(ECOS_BUILD_DIR) $(ECOS_INSTALL_DIR)
LOCAL_CLEAN_FILES += $(ECOS_ECC_FILE)

$(call local-add-module)

endif

