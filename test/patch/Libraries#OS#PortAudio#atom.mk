
LOCAL_PATH := $(call my-dir)

###############################################################################
# PortAudio
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := portaudio
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := ConfigPortAudio.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/include \

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/src/common \
	$(LOCAL_PATH)/Sources/src/hostapi/alsa \
	$(LOCAL_PATH)/Sources/src/hostapi/parrot \
	$(LOCAL_PATH)/Sources/src/os/unix

LOCAL_CFLAGS := \
	-DPA_LITTLE_ENDIAN=1 \
	-DSTDC_HEADERS=1 \
	-DHAVE_SYS_TYPES_H=1 \
	-DHAVE_SYS_STAT_H=1 \
	-DHAVE_STDLIB_H=1 \
	-DHAVE_STRING_H=1 \
	-DHAVE_MEMORY_H=1 \
	-DHAVE_STRINGS_H=1 \
	-DHAVE_INTTYPES_H=1 \
	-DHAVE_STDINT_H=1 \
	-DHAVE_UNISTD_H=1 \
	-DHAVE_DLFCN_H=1 \
	-DHAVE_SYS_SOUNDCARD_H=1 \
	-DHAVE_LINUX_SOUNDCARD_H=1 \
	-DSIZEOF_SHORT=2 \
	-DSIZEOF_INT=4 \
	-DSIZEOF_LONG=4 \
	-DHAVE_CLOCK_GETTIME=1 \
	-DHAVE_NANOSLEEP=1

ifdef CONFIG_PORTAUDIO_HOSTAPI_ALSA
  PORTAUDIO_HOSTAPI := ALSA
else ifdef CONFIG_PORTAUDIO_HOSTAPI_PARROT
  PORTAUDIO_HOSTAPI := PARROT
else
  $(warning PortAudio : No host API defined!)
endif

LOCAL_CFLAGS += -DPA_USE_$(PORTAUDIO_HOSTAPI)=1

ifdef CONFIG_PORTAUDIO_HOSTAPI_PARROT_DISABLE_XRUNS
LOCAL_CFLAGS += -DPA_DISABLE_XRUNS
endif

LOCAL_SRC_FILES := \
	Sources/src/common/pa_allocation.c \
	Sources/src/common/pa_converters.c \
	Sources/src/common/pa_cpuload.c \
	Sources/src/common/pa_dither.c \
	Sources/src/common/pa_debugprint.c \
	Sources/src/common/pa_front.c \
	Sources/src/common/pa_process.c \
	Sources/src/common/pa_skeleton.c \
	Sources/src/common/pa_stream.c \
	Sources/src/common/pa_trace.c \
	Sources/src/os/unix/pa_unix_hostapis.c \
	Sources/src/hostapi/parrot/pa_parrot.c \
	Sources/src/hostapi/parrot/pa_volume.c

ifeq ("$(TARGET_OS)","linux")
LOCAL_SRC_FILES += \
	Sources/src/os/unix/pa_unix_util.c \
	Sources/src/hostapi/parrot/pa_volume_alsa.c \
	Sources/src/hostapi/parrot/pa_parrot_alsa.c
else ifeq ("$(TARGET_OS)","ecos")
LOCAL_SRC_FILES += \
	Sources/src/os/unix/pa_ecos_util.c \
	Sources/src/hostapi/parrot/pa_parrot_ecosaai.c
endif
                 
LOCAL_LIBRARIES := pal-codec pal-core

ifeq ("$(TARGET_OS)","linux")
  LOCAL_LIBRARIES += alsa-lib
endif

include $(BUILD_SHARED_LIBRARY)

