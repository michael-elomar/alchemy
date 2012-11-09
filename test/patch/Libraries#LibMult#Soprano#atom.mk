
LOCAL_PATH := $(call my-dir)

###############################################################################
# Soprano
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := soprano
LOCAL_PBUILD_HOOK := 1

ifeq ("$(TARGET_OS)","ecos")
  SOPRANO_LIBS_ARCH = arm_ecos
else ifeq ("$(TARGET_ARCH)","arm")
  SOPRANO_LIBS_ARCH = arm_linux
else ifeq ("$(TARGET_ARCH)","x86")
  SOPRANO_LIBS_ARCH = x86_linux
else
  $(warning unsupported architecture)
endif

LOCAL_ARM_MODE := arm

LOCAL_CONFIG_FILES := \
	Build/ConfigSoprano.in \
	Build/ConfigSopranoTTS.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Export

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/asr	\
	$(LOCAL_PATH)/Sources/audio \
	$(LOCAL_PATH)/Sources/config \
	$(LOCAL_PATH)/Sources/context \
	$(LOCAL_PATH)/Sources/debug \
	$(LOCAL_PATH)/Sources/device \
	$(LOCAL_PATH)/Sources/memo \
	$(LOCAL_PATH)/Sources/mngt \
	$(LOCAL_PATH)/Sources/tts \
	$(LOCAL_PATH)/Sources/utils \
	$(LOCAL_PATH)/Sources/usw \
	$(LOCAL_PATH)/Sources/wrapper \
	$(LOCAL_PATH)/Sources/wrapper/tts_parrot \
	$(LOCAL_PATH)/Sources/wrapper/tts_parrot/MultiLTS2 \
	$(LOCAL_PATH)/Sources/wrapper/tts_parrot/OLA \
	$(LOCAL_PATH)/Sources/wrapper/tts_parrot/Prosodie \
	$(LOCAL_PATH)/External/Nuance/Vocon_3200/inc \
	$(LOCAL_PATH)/External/Nuance/MPP/inc \
	$(LOCAL_PATH)/External/Nuance/MNCWR/inc \
	$(LOCAL_PATH)/External/SVOX/inc

LOCAL_SRC_FILES := \
	Sources/asr/asr_api.c \
	Sources/audio/audioin.c \
	Sources/audio/audioout.c \
	Sources/config/config_sqlite.c \
	Sources/config/config_parseXML.cpp \
	Sources/context/context_api.c \
	Sources/debug/debug_api.c \
	Sources/debug/debug_sqlite.c \
	Sources/device/device_api.c \
	Sources/mngt/mngt_api.c \
	Sources/memo/memo_api.c \
	Sources/memo/memo_mngt.c \
	Sources/memo/memo_io.c \
	Sources/tts/tts_api.c \
	Sources/tts/tts_mngr.c \
	Sources/tts/tts_prmpt.c \
	Sources/tts/tts_file.c \
	Sources/utils/utils_debug.c \
	Sources/utils/utils_fifo.c \
	Sources/utils/utils_list.c \
	Sources/utils/utils_toolbox.c \
	Sources/utils/utils_unirecorder.c \
	Sources/utils/utils_timing.c \
	Sources/usw/usw_api.c \
	Sources/wrapper/wrapper_convert.c

# MPP libraries (compilation of MPP is optional)
ifdef CONFIG_SOPRANO_MPP_ENABLE
LOCAL_LDLIBS += \
	-L$(LOCAL_PATH)/External/Nuance/MPP/libs/$(SOPRANO_LIBS_ARCH) \
	-lmpp
LOCAL_CFLAGS += -DSOPRANO_USE_MPP
LOCAL_SRC_FILES += \
	Sources/wrapper/wrapper_mpp.c
endif

# MNCWR libraries (This compilation is optional as it is used only for chinese)
ifdef CONFIG_SOPRANO_MNCWR_ENABLE
LOCAL_LDLIBS += \
	-L$(LOCAL_PATH)/External/Nuance/MNCWR/libs/$(SOPRANO_LIBS_ARCH) \
	-lg2pwrapper \
	-lclm
LOCAL_CFLAGS += -DSOPRANO_USE_MNCWR
LOCAL_SRC_FILES += \
	Sources/wrapper/wrapper_mncwr.c
endif

# VOCON 3200 libraries (only if ASR is enabled in config).
ifdef CONFIG_SOPRANO_ASR_ENABLE
LOCAL_LDLIBS += \
	-L$(LOCAL_PATH)/External/Nuance/Vocon_3200/libs/$(SOPRANO_LIBS_ARCH) \
	-lvocon3200_asr \
	-lvocon3200_pron \
	-lvocon3200_base \
	-lvocon3200_platform \
	-lvocon_ext_heap \
	-lvocon_ext_stream
LOCAL_SRC_FILES += \
	Sources/asr/asr_mngt.c \
	Sources/wrapper/wrapper_voconHeap.c \
	Sources/wrapper/wrapper_voconStream.c \
	Sources/wrapper/wrapper_vocon32.c
else
LOCAL_SRC_FILES += \
	Sources/asr/asr_mngt_stub.c \
	Sources/wrapper/wrapper_vocon32_stub.c
endif

# SVOX libraries (only if SVOX enabled in config).
ifdef CONFIG_SOPRANO_TTSENGINE_SVOX
LOCAL_LDLIBS += \
	-L$(LOCAL_PATH)/External/SVOX/libs/$(SOPRANO_LIBS_ARCH)/production \
	-lsvox
LOCAL_SRC_FILES += \
	Sources/wrapper/wrapper_svox.c
endif

# TTS Parrot
ifndef CONFIG_SOPRANO_TTSENGINE_PARROT

LOCAL_CFLAGS += -DDONT_USE_TTS_PARROT

else

LOCAL_CFLAGS += -DSOPRANO_USE_TTS_PARROT

LOCAL_SRC_FILES += \
	Sources/wrapper/tts_parrot/MultiLTS2/languedec.c \
	Sources/wrapper/tts_parrot/MultiLTS2/ltshash.c \
	Sources/wrapper/tts_parrot/MultiLTS2/lts_interface.c \
	Sources/wrapper/tts_parrot/MultiLTS2/ltstool.c \
	Sources/wrapper/tts_parrot/MultiLTS2/phone.c \
	Sources/wrapper/tts_parrot/MultiLTS2/pretraite.c \
	Sources/wrapper/tts_parrot/MultiLTS2/syllabetxt.c \
	Sources/wrapper/tts_parrot/OLA/concat.c \
	Sources/wrapper/tts_parrot/OLA/data.c \
	Sources/wrapper/tts_parrot/OLA/hash.c \
	Sources/wrapper/tts_parrot/OLA/mot.c \
	Sources/wrapper/tts_parrot/OLA/ola.c \
	Sources/wrapper/tts_parrot/OLA/ola_interface.c \
	Sources/wrapper/tts_parrot/OLA/tool.c \
	Sources/wrapper/tts_parrot/OLA/speex_decoder.c \
	Sources/wrapper/tts_parrot/OLA/flac_decoder.c \
	Sources/wrapper/tts_parrot/Prosodie/praat.c \
	Sources/wrapper/tts_parrot/Prosodie/proso.c \
	Sources/wrapper/tts_parrot/Prosodie/prosodie_interface.c \
	Sources/wrapper/tts_parrot/Prosodie/prosolang.c \
	Sources/wrapper/tts_parrot/Prosodie/prosotool.c \
	Sources/wrapper/tts_parrot/Prosodie/syllabe.c \
	Sources/wrapper/tts_parrot/TTS_interface.c \
	Sources/wrapper/wrapper_tts_parrot.c

ifdef CONFIG_TTS_PARROT_FR
LOCAL_CFLAGS += -DTTS_FR
LOCAL_SRC_FILES += \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.Rules.c \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.SiglEp.c
endif

ifdef CONFIG_TTS_PARROT_EN
LOCAL_CFLAGS += -DTTS_EN
LOCAL_SRC_FILES += \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.RulesEN.c \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.SiglEpEN.c
endif

ifdef CONFIG_TTS_PARROT_SP
LOCAL_CFLAGS += -DTTS_SP
LOCAL_SRC_FILES += \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.RulesSP.c \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.SiglEpSP.c
endif

ifdef CONFIG_TTS_PARROT_IT
LOCAL_CFLAGS += -DTTS_IT
LOCAL_SRC_FILES += \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.RulesIT.c \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.SiglEpIT.c
endif

ifdef CONFIG_TTS_PARROT_GE
LOCAL_CFLAGS += -DTTS_GE
LOCAL_SRC_FILES += \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.RulesGE.c \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.SiglEpGE.c
endif

ifdef CONFIG_TTS_PARROT_NL
LOCAL_CFLAGS += -DTTS_NL
LOCAL_SRC_FILES += \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.RulesNL.c \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.SiglEpNL.c
endif

ifdef CONFIG_TTS_PARROT_PT
LOCAL_CFLAGS += -DTTS_PT
LOCAL_SRC_FILES += \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.RulesPT.c \
    Sources/wrapper/tts_parrot/MultiLTS2/lex.SiglEpPT.c
endif

endif

LOCAL_LIBRARIES := \
	tinyxml \
	tala \
	unirecorder \
	parrotdb \
	soul \
	tango-core \
	tango-wav \
	tango-speex \
	tango-flac \
	pal-utils \
	pal-core

ifdef CONFIG_SOPRANO_TTSENGINE_SVOX
LOCAL_LIBRARIES += soprano-svox-stub
endif

include $(BUILD_SHARED_LIBRARY)

###############################################################################
###############################################################################

ifdef CONFIG_SOPRANO_TTSENGINE_SVOX

include $(CLEAR_VARS)

LOCAL_MODULE := soprano-svox-stub
LOCAL_FORCE_WHOLE_STATIC_LIBRARY := 1

LOCAL_SRC_FILES := \
	svox-stub.c

include $(BUILD_STATIC_LIBRARY)

endif

