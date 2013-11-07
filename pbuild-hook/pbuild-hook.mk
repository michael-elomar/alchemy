###############################################################################
## This makefile handles compatibility with ParrotBuild system.
###############################################################################

LOCAL_PATH := $(call my-dir)

# We don't have any atom.mk but internally the build system will add a dependency
# ont it, make it happy
$(LOCAL_PATH)/$(USER_MAKEFILE_NAME):

###############################################################################
## Fake module to generate autoconf-merge.h file correctly.
## If this module is found in the dependencies of a module being built all
## modules using a config.in file will be have their rules loaded as well.
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := autoconf-merge
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

# Module .done file
$(call local-get-build-dir)/$(LOCAL_MODULE_FILENAME):
	@mkdir -p $(dir $@)
	@touch $@

include $(BUILD_CUSTOM)

###############################################################################
## This part will generate message.xml from a list of known modules using this
## feature.
##
## It makes a lot of assumption both on the internals of the build system
## and the internals of modules.
##
## However, a limited number of modules are handled.
##
## Note: dependency on the library is required so that PRIVATE_XXX variables
## are correctly propagated.
###############################################################################

# This requires at least the ckcm module to exist
ifneq ("$(call is-module-registered,ckcm)","")

# Skip if ckcm is from a sdk
ifeq ("$(__modules.ckcm.SDK)","")

# Make sure the module is not already registered as part of a sdk
ifeq ("$(call is-module-registered,msgbuilder)","")

include $(CLEAR_VARS)

LOCAL_MODULE := msgbuilder
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

# Build directory
MSGBUILDER_BUILD_DIR := $(call local-get-build-dir)

# Xml file to generate
MSGBUILDER_XML_FILE := $(TARGET_OUT_BUILD)/messages.xml

# Host executable that will create the xml file
MSGBUILDER_BIN := $(MSGBUILDER_BUILD_DIR)/msgbuilder

# Object files
MSGBUILDER_OBJ :=

# Source files and flags to create the msgbuilder host executable
MSGBUILDER_CKCM_MSG_FILES := $(__modules.ckcm.PATH)/msgbuilder/msgbuilder.c
MSGBUILDER_CKCM_CFLAGS := -DNATIVE_COMPILER -DTARGET_PRODUCT=$(TARGET_PRODUCT) -I$(LOCAL_PATH)

# ParrotOS in ckcm
ifneq ("$(call is-module-registered,ckcm)","")
ifneq ("$(call is-module-in-build-config,ckcm)","")
ifeq ("$(__modules.ckcm.SDK)","")
MSGBUILDER_CKCM_MSG_FILES += \
	$(__modules.ckcm.PATH)/ckcm/src/Parrotos_Msgs.ckcm.c
MSGBUILDER_CKCM_CFLAGS += \
	-D_PARROTOS_ \
	-I$(__modules.ckcm.PATH)/ckcm/include
LOCAL_CONDITONAL_LIBRARIES += OPTIONAL:ckcm
LOCAL_PREREQUISITES += $(__modules.ckcm.PREREQUISITES)
LOCAL_PREREQUISITES += $(__modules.ckcm.EXPORT_PREREQUISITES)
endif
endif
endif

# Blues
ifneq ("$(call is-module-registered,blues)","")
ifneq ("$(call is-module-in-build-config,blues)","")
ifeq ("$(__modules.blues.SDK)","")

# FIXME: remove first part of block when blues has integrated the modifications
# and when everyone will use this blues version
ifeq ("$(findstring Blues_Msgs_generated.ckcm.c,$(__modules.blues.PREREQUISITES))","")

MSGBUILDER_CKCM_MSG_FILES += \
	$(__modules.blues.PATH)/Sources/Common/System/Blues_Msgs_generated.ckcm.c
MSGBUILDER_CKCM_CFLAGS += \
	-D_BLUES_ \
	-I$(__modules.blues.PATH)/Sources/Common/System \
	-I$(TARGET_OUT_BUILD)/blues/include
LOCAL_CONDITONAL_LIBRARIES += OPTIONAL:blues
LOCAL_PREREQUISITES += $(__modules.blues.PREREQUISITES)
LOCAL_PREREQUISITES += $(__modules.blues.EXPORT_PREREQUISITES)

else

# No need to import blues prerequisites, internally generated file already have them.
# Adding it here would cause cyclic dependency within 'make'.
MSGBUILDER_CKCM_MSG_FILES += \
	$(TARGET_OUT_BUILD)/blues/Blues_Msgs_generated.ckcm.c
MSGBUILDER_CKCM_CFLAGS += \
	-D_BLUES_ \
	-I$(__modules.blues.PATH)/Sources/Common/System \
	-I$(TARGET_OUT_BUILD)/blues/include
LOCAL_CONDITONAL_LIBRARIES += OPTIONAL:blues

endif

endif
endif
endif

# Concertos
ifneq ("$(call is-module-registered,concertos)","")
ifneq ("$(call is-module-in-build-config,concertos)","")
ifeq ("$(__modules.concertos.SDK)","")
MSGBUILDER_CKCM_MSG_FILES += \
	$(__modules.concertos.PATH)/Build/Concertos_Msgs.ckcm.c
MSGBUILDER_CKCM_CFLAGS += \
	-D_CONCERTOS_ \
	-I$(__modules.concertos.PATH)/Include \
	-I$(__modules.concertos.PATH)/Sources \
	-I$(__modules.concertos.PATH)/Build
LOCAL_CONDITONAL_LIBRARIES += OPTIONAL:concertos
LOCAL_PREREQUISITES += $(__modules.concertos.PREREQUISITES)
LOCAL_PREREQUISITES += $(__modules.concertos.EXPORT_PREREQUISITES)
endif
endif
endif

# SoftAT
ifneq ("$(call is-module-registered,softat)","")
ifneq ("$(call is-module-in-build-config,softat)","")
ifeq ("$(__modules.softat.SDK)","")
MSGBUILDER_CKCM_MSG_FILES += \
	$(__modules.softat.PATH)/Sources/System/SYST_CK505X_Msgs.ckcm.c
MSGBUILDER_CKCM_CFLAGS += \
	-D_CK5050_ \
	-I$(__modules.softat.PATH)/Sources/System \
	-I$(TARGET_OUT_BUILD)/softat
LOCAL_CONDITONAL_LIBRARIES += OPTIONAL:softat
LOCAL_PREREQUISITES += $(__modules.softat.PREREQUISITES)
LOCAL_PREREQUISITES += $(__modules.softat.EXPORT_PREREQUISITES)
endif
endif
endif

# Compile one file
# $1 : source file
# $2 : object file
# Note: need to escape with $$ all references to automatic variables ($@, $<)
#       as well as all macros using them.
define msgbuilder-compile
$(2): $(1)
	$$(call print-banner1,"Host C",msgbuilder,$$(call path-from-top,$$<))
	@mkdir -p $$(dir $$@)
	$(Q)$(HOST_CC) $(MSGBUILDER_CKCM_CFLAGS) \
		-c -MMD -MP -o $$@ $$(call path-from-top,$$<)
MSGBUILDER_OBJ += $(2)
-include $(2:.o=.d)
endef

# Generate compilation rules
$(foreach __f,$(MSGBUILDER_CKCM_MSG_FILES), \
	$(eval $(call msgbuilder-compile, \
		$(__f), \
		$(MSGBUILDER_BUILD_DIR)/obj/$(notdir $(__f:.c=.o)) \
	)) \
)

# Prerequistes order-only dependency
$(MSGBUILDER_CKCM_MSG_FILES): | $(LOCAL_PREREQUISITES)

# Generate the host executable
$(MSGBUILDER_BIN): $(MSGBUILDER_OBJ)
	$(call print-banner2,"Host Executable",msgbuilder,$(call path-from-top,$@))
	@mkdir -p $(dir $@)
	$(Q)$(HOST_CC) -o $@ $(MSGBUILDER_OBJ)

# Generate the xml file
$(MSGBUILDER_XML_FILE): $(MSGBUILDER_BIN)
	@echo "Msgbuilder: $(call path-from-top,$@)"
	@mkdir -p $(dir $@)
	$(Q)$(MSGBUILDER_BIN) $(MSGBUILDER_XML_FILE)

# This will trigger the generation of the xml file
$(MSGBUILDER_BUILD_DIR)/$(LOCAL_MODULE_FILENAME): $(MSGBUILDER_XML_FILE)
	@mkdir -p $(dir $@)
	@touch $@

# Files to clean
LOCAL_CLEAN_FILES := \
	$(MSGBUILDER_BIN) \
	$(MSGBUILDER_OBJ) \
	$(MSGBUILDER_OBJ:.o=.d) \
	$(MSGBUILDER_XML_FILE)

include $(BUILD_CUSTOM)

endif # ifeq ("$(call is-module-registered,msgbuilder)","")

endif # ifeq ("$(__modules.ckcm.SDK)","")

endif # ifneq ("$(call is-module-registered,ckcm)","")
