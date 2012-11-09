LOCAL_PATH := $(call my-dir)

###############################################################################
# HSTI generator
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := hsti-generator
LOCAL_MODULE_FILENAME := hsti-generator.done

LOCAL_CONFIG_FILES := ConfigHSTIGenerator.in
$(call load-config)

# Module build directory and 'done' file
HSTI_GENERATOR_BUILD_DIR := $(call local-get-build-dir)
HSTI_GENERATOR_DONE_FILE := $(HSTI_GENERATOR_BUILD_DIR)/$(LOCAL_MODULE_FILENAME)

# Where we are (to be used in rules because LOCAL_PATH is not available then)
HSTI_GENERATOR_DIR := $(LOCAL_PATH)

###############################################################################
# Setup variables.
###############################################################################

# done files are alseo used in sub-makefile and python scripts
HSTI_GENERATOR_DIR_CUSTOM := $(HSTI_GENERATOR_BUILD_DIR)/custom
HSTI_GENERATOR_DIR_FULL := $(HSTI_GENERATOR_BUILD_DIR)/full
HSTI_GENERATOR_DIR_JAVA := $(HSTI_GENERATOR_BUILD_DIR)/java
HSTI_GENERATOR_DONE_FILE_CUSTOM := $(HSTI_GENERATOR_DIR_CUSTOM)/HSTI_Generated.done
HSTI_GENERATOR_DONE_FILE_FULL := $(HSTI_GENERATOR_DIR_FULL)/HSTI_Generated.done
HSTI_GENERATOR_DONE_FILE_JAVA := $(HSTI_GENERATOR_DIR_JAVA)/Generated.done

# Common environment variables for generator
HSTI_GENERATOR_ENV_COMMON := \
	CONFIG_HW='' \
	CONFIG_SW='' \
	VERSION=''

# Main ATSpec directory (mandatory option)
HSTI_GENERATOR_ENV_COMMON += \
	HSTI_MAIN_ATSPEC_DIR="$(addprefix $(TOP_DIR)/,$(call remove-quotes,$(CONFIG_HSTI_GENERATOR_MAIN_ATSPEC_DIR)))"

# Extra ATSpec directories (optional option)
ifdef CONFIG_HSTI_GENERATOR_USE_EXTRA_ATSPEC_DIRS
HSTI_GENERATOR_ENV_COMMON += \
	HSTI_EXTRA_ATSPEC_DIR="$(addprefix $(TOP_DIR)/,$(call remove-quotes,$(CONFIG_HSTI_GENERATOR_EXTRA_ATSPEC_DIRS)))"
endif

# Extra ATParam files (optional option)
ifdef CONFIG_HSTI_GENERATOR_USE_EXTRA_ATPARAM_FILES
HSTI_GENERATOR_ENV_COMMON += \
	HSTI_EXTRA_ATPARAM_FILE="$(addprefix $(TOP_DIR)/,$(call remove-quotes,$(CONFIG_HSTI_GENERATOR_EXTRA_ATPARAM_FILES)))"
endif

# Multi target (optional option)
ifdef CONFIG_HSTI_GENERATOR_USE_MULTI_TARGET
HSTI_GENERATOR_ENV_COMMON += \
	HSTI_MULTI_TARGET="$(call remove-quotes,$(CONFIG_HSTI_GENERATOR_MULTI_TARGET))"
endif


HSTI_GENERATOR_ENV_CUSTOM := \
	$(HSTI_GENERATOR_ENV_COMMON) \
	PARROT_AUTOCONF_FILE="$(AUTOCONF_MERGE_FILE)"

HSTI_GENERATOR_ENV_FULL := \
	$(HSTI_GENERATOR_ENV_COMMON) \
	PARROT_AUTOCONF_FILE="NONE"

HSTI_GENERATOR_ENV_JAVA := \
	$(HSTI_GENERATOR_ENV_COMMON) \
	PARROT_AUTOCONF_FILE="NONE"

###############################################################################
# Rules
###############################################################################

$(HSTI_GENERATOR_DONE_FILE_CUSTOM): | hsti-generator-c-custom
$(HSTI_GENERATOR_DONE_FILE_FULL): | hsti-generator-c-full
$(HSTI_GENERATOR_DONE_FILE_JAVA): | hsti-generator-java

.PHONY: hsti-generator-c-custom
hsti-generator-c-custom: $(AUTOCONF_MERGE_FILE)
	@$(MAKE) --no-print-directory $(HSTI_GENERATOR_ENV_CUSTOM) \
		"HSTI_GENERATED_DIR=$(HSTI_GENERATOR_DIR_CUSTOM)" \
		-C $(HSTI_GENERATOR_DIR) hsti-c
	@mkdir -p $(HSTI_GENERATOR_DIR_FULL)
	@cp -au $(HSTI_GENERATOR_DONE_FILE_CUSTOM) $(HSTI_GENERATOR_DONE_FILE)

.PHONY: hsti-generator-c-full
hsti-generator-c-full:
	@$(MAKE) --no-print-directory $(HSTI_GENERATOR_ENV_FULL) \
		"HSTI_GENERATED_DIR=$(HSTI_GENERATOR_DIR_FULL)" \
		-C $(HSTI_GENERATOR_DIR) hsti-c
	@cp -au $(HSTI_GENERATOR_DONE_FILE_FULL) $(HSTI_GENERATOR_DONE_FILE)

.PHONY: hsti-generator-java
hsti-generator-java:
	@$(MAKE) --no-print-directory $(HSTI_GENERATOR_ENV_JAVA) \
		"HSTI_GENERATED_DIR=$(HSTI_GENERATOR_DIR_JAVA)" \
		-C $(HSTI_GENERATOR_DIR) hsti-java
	@cp -au $(HSTI_GENERATOR_DONE_FILE_JAVA) $(HSTI_GENERATOR_DONE_FILE)

###############################################################################
# Build system registration.
###############################################################################

LOCAL_EXPORT_PREREQUISITES := \
	$(HSTI_GENERATOR_DONE_FILE_CUSTOM) \
	$(HSTI_GENERATOR_DONE_FILE_FULL) \
	$(HSTI_GENERATOR_DONE_FILE_JAVA)

LOCAL_EXPORT_C_INCLUDES := \
	$(HSTI_GENERATOR_DIR_CUSTOM)

# Module dependencies
.PHONY: $(LOCAL_MODULE)
$(LOCAL_MODULE): $(HSTI_GENERATOR_DONE_FILE)
$(HSTI_GENERATOR_DONE_FILE): $(HSTI_GENERATOR_DONE_FILE_CUSTOM)
$(HSTI_GENERATOR_DONE_FILE): $(HSTI_GENERATOR_DONE_FILE_FULL)
$(HSTI_GENERATOR_DONE_FILE): $(HSTI_GENERATOR_DONE_FILE_JAVA)

# Extra clean variables
LOCAL_CLEAN_DIRS += $(HSTI_GENERATOR_BUILD_DIR)

$(call local-add-module)
