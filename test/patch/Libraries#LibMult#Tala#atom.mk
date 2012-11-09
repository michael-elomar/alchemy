
LOCAL_PATH := $(call my-dir)

###############################################################################
# Tala
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := tala
LOCAL_PBUILD_HOOK := 1

LOCAL_ARM_MODE := arm

LOCAL_CONFIG_FILES := build/ConfigTala.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/include \

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/src/core \
	$(LOCAL_PATH)/src/core/channel \
	$(LOCAL_PATH)/src/core/demux \
	$(LOCAL_PATH)/src/core/device \
	$(LOCAL_PATH)/src/core/interface \
	$(LOCAL_PATH)/src/core/provider \
	$(LOCAL_PATH)/src/drc \
	$(LOCAL_PATH)/src/format \
	$(LOCAL_PATH)/src/hw \
	$(LOCAL_PATH)/src/streamer \
	$(LOCAL_PATH)/src/streamer/resamp \
	$(LOCAL_PATH)/src/streamer/driftcomp \
	$(LOCAL_PATH)/src/utils \
	$(LOCAL_PATH)/src/volume \
	$(LOCAL_PATH)/src/volume/loudness \
	$(LOCAL_PATH)/src/volume/mixvol \
	$(LOCAL_PATH)/src/volume/volfader \
	$(LOCAL_PATH)/src/volume/volmaster \
	$(LOCAL_PATH)/src/xml

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	src/core/server.c \
	src/core/tala.c \
	src/core/channel/chan_callback.c \
	src/core/channel/chan_drive.c \
	src/core/channel/chan_list.c \
	src/core/channel/chan_manager.c \
	src/core/channel/chan_old.c \
	src/core/channel/channel.c \
	src/core/channel/plop.c \
	src/core/demux/demux.c \
	src/core/device/osdev.c \
	src/core/device/videv.c \
	src/core/device/videv_route.c \
	src/core/interface/file_interface.c \
	src/core/interface/pa_interface.c \
	src/core/interface/soft_interface.c \
	src/core/provider/mixer.c \
	src/core/provider/provider.c \
	src/core/provider/prov_utils.c \
	src/drc/clipper.c \
	src/drc/drc.c \
	src/drc/limiter.c \
	src/format/format.c \
	src/format/format_proc16.c \
	src/format/format_proc1632.c \
	src/format/format_proc32.c \
	src/format/format_proc3216.c \
	src/hw/audio_switch.c \
	src/streamer/streamer_ctl.c \
	src/streamer/streamer_io.c \
	src/streamer/driftcomp/driftcomp.c \
	src/streamer/resamp/bli.c \
	src/streamer/resamp/bli_filter.c \
	src/streamer/resamp/bli_firtab.c \
	src/streamer/resamp/fdr.c \
	src/streamer/resamp/fr_firtab.c \
	src/streamer/resamp/fur.c \
	src/streamer/resamp/resamp.c \
	src/utils/tala_debug.c \
	src/utils/tala_fifo.c \
	src/utils/tala_list.c \
	src/utils/tala_mutex.c          \
	src/volume/volmaster_int.c \
	src/volume/volume.c \
	src/volume/volume_16.c \
	src/volume/volume_32.c \
	src/volume/volume_api.c \
	src/volume/volume_table.c \
	src/volume/loudness/loudness.c \
	src/volume/loudness/loudness_filter.c \
	src/volume/loudness/loudness_tables.c \
	src/volume/mixvol/mixvol.c \
	src/volume/mixvol/mixvol_api.c \
	src/volume/volfader/volfader.c \
	src/volume/volmaster/volmaster.c \
	src/volume/volmaster/volmaster_api.c \
	src/volume/volmaster/volstage_pa.c \
	src/xml/TalaConfStructure.c \
    src/xml/TalaXMLVolume.cpp \
    src/xml/TalaXMLProduct.cpp \
    src/xml/TalaXMLOsDevice.cpp \
    src/xml/TalaXMLVirtualDevice.cpp \
    src/xml/TalaXML.cpp \
    src/drc/limiter_arm9e.S \
    src/streamer/resamp/bli_filter_arm9e.S \
    src/streamer/resamp/fdr_filter_arm9e.S \
    src/streamer/resamp/fur_filter_arm9e.S \
    src/utils/tala_math_arm9e.S \
    src/volume/vol32_arm9e.S

# TODO: check cpu as well
ifeq ("$(TARGET_OS)","ecos")
  LOCAL_SRC_FILES += src/hw/ecos_hwp6.c
else ifeq ("$(TARGET_OS)","linux")
  LOCAL_SRC_FILES += src/hw/linux_hwp6.c
endif

LOCAL_LIBRARIES := alsa-lib tinyxml portaudio pal-utils pal-core

include $(BUILD_SHARED_LIBRARY)

