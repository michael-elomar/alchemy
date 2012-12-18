###############################################################################
## This makefile handles compatibility with ParrotBuild system.
## - Pal log.
## - Library description.
## - Message builder.
###############################################################################

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := pbuild-hook

LOCAL_SRC_FILES := \
	pbuild-stub.c

include $(BUILD_STATIC_LIBRARY)

###############################################################################
## This part will generate message.xml from a list of known modules using this
## feature.
##
## It makes a lot of assumption both on the internals of the build system
## and the internals of modules.
##
## However, a limited number of modules are handled.
###############################################################################

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
MSGBUILDER_CKCM_MSG_FILES :=
MSGBUILDER_CKCM_CFLAGS := -DNATIVE_COMPILER -I$(LOCAL_PATH)

# ParrotOS in ckcm
ifneq ("$(call is-module-in-build-config,ckcm)","")
MSGBUILDER_CKCM_MSG_FILES += \
	$(__modules.ckcm.PATH)/msgbuilder/msgbuilder.c \
	$(__modules.ckcm.PATH)/ckcm/src/Parrotos_Msgs.ckcm.c
MSGBUILDER_CKCM_CFLAGS += \
	-D_PARROTOS_ \
	-I$(__modules.ckcm.PATH)/ckcm/include
LOCAL_LIBRARIES += ckcm
LOCAL_PREREQUISITES += $(__modules.ckcm.PREREQUISITES)
LOCAL_PREREQUISITES += $(__modules.ckcm.EXPORT_PREREQUISITES)
endif

# Blues
ifneq ("$(call is-module-in-build-config,blues)","")
MSGBUILDER_CKCM_MSG_FILES += \
	$(__modules.blues.PATH)/Sources/Common/System/Blues_Msgs_generated.ckcm.c
MSGBUILDER_CKCM_CFLAGS += \
	-D_BLUES_ \
	-I$(__modules.blues.PATH)/Sources/Common/System \
	-I$(TARGET_OUT_BUILD)/blues/include
LOCAL_LIBRARIES += blues
LOCAL_PREREQUISITES += $(__modules.blues.PREREQUISITES)
LOCAL_PREREQUISITES += $(__modules.blues.EXPORT_PREREQUISITES)
endif

# Concertos
ifneq ("$(call is-module-in-build-config,concertos)","")
MSGBUILDER_CKCM_MSG_FILES += \
	$(__modules.concertos.PATH)/Build/Concertos_Msgs.ckcm.c
MSGBUILDER_CKCM_CFLAGS += \
	-D_CONCERTOS_ \
	-I$(__modules.concertos.PATH)/Include \
	-I$(__modules.concertos.PATH)/Sources \
	-I$(__modules.concertos.PATH)/Build
LOCAL_LIBRARIES += concertos
LOCAL_PREREQUISITES += $(__modules.concertos.PREREQUISITES)
LOCAL_PREREQUISITES += $(__modules.concertos.EXPORT_PREREQUISITES)
endif

# SoftAT
ifneq ("$(call is-module-in-build-config,softat)","")
MSGBUILDER_CKCM_MSG_FILES += \
	$(__modules.softat.PATH)/Sources/System/SYST_CK505X_Msgs.ckcm.c
MSGBUILDER_CKCM_CFLAGS += \
	-D_CK5050_ \
	-I$(__modules.softat.PATH)/Sources/System \
	-I$(TARGET_OUT_BUILD)/softat
LOCAL_LIBRARIES += softat
LOCAL_PREREQUISITES += $(__modules.softat.PREREQUISITES)
LOCAL_PREREQUISITES += $(__modules.softat.EXPORT_PREREQUISITES)
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

