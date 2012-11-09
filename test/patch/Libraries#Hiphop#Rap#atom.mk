
LOCAL_PATH := $(call my-dir)

###############################################################################
# Rap
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := rap
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := Build/ConfigRap.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Include

LOCAL_EXPORT_CFLAGS := \
	-DUSE_RAP

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	Sources/Context/Context.cpp \
	Sources/Context/Device.cpp \
	Sources/Context/DeviceBlues.cpp \
	Sources/Context/DeviceCustom.cpp \
	Sources/Context/DeviceDisco.cpp \
	Sources/Context/ListDevices.cpp \
	Sources/Core/Interface.cpp \
	Sources/Core/Core.cpp \
	Sources/Core/Language.cpp \
	Sources/Core/State.cpp \
	Sources/Core/TaskContext.cpp \
	Sources/Core/TaskEvent.cpp \
	Sources/Core/TaskProcedure.cpp \
	Sources/Core/Result.cpp \
	Sources/Events/EventsCb.cpp \
	Sources/ItemsProvider/ItemsProviderBlues7.cpp \
	Sources/ItemsProvider/ItemsProviderBluesFake.cpp \
	Sources/ItemsProvider/ItemsProviderDisco.cpp \
	Sources/ItemsProvider/ItemsProviderFile.cpp \
	Sources/Prompt/PromptArg.cpp \
	Sources/Prompt/Prompt.cpp \
	Sources/Prompt/PromptsManager.cpp \
	Sources/Utils/CStr.cpp \
	Sources/Utils/Debug.cpp \
	Sources/Utils/RapConfig.cpp \
	Sources/Utils/RegEx.cpp \
	Sources/Wrapper/WrapperBlues7.cpp \
	Sources/Wrapper/WrapperBluesFake.cpp \
	Sources/Wrapper/WrapperDisco.cpp \
	Sources/Wrapper/WrapperGracenote.cpp \
	Sources/VoiceTag/WrapperVoiceTag.cpp

LOCAL_LIBRARIES := \
	disco \
	blues \
	soul \
	soprano \
	tamtam \
	tinyxml \
	pal-utils \
	pal-core

include $(BUILD_SHARED_LIBRARY)

