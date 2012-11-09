
LOCAL_PATH := $(call my-dir)

###############################################################################
# Concertos
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := concertos
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := Build/ConfigConcertos.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Include

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Sources

LOCAL_CFLAGS := \
	-Ddynamic_cast=static_cast

LOCAL_SRC_FILES := \
	Sources/Api/ArtworkRef.cpp								\
	Sources/Api/Codec.cpp									\
	Sources/Api/Commands.cpp								\
	Sources/Api/Concertos_Core.cpp							\
	Sources/Api/Concertos_Effects.cpp						\
	Sources/Api/Concertos_MediaContext.cpp					\
	Sources/Api/Concertos_MediaPlayer.cpp					\
	Sources/Api/Concertos_MediaSink.cpp						\
	Sources/Api/Concertos_MediaSource.cpp					\
	Sources/Api/BrowsingMediaContext.cpp					\
	Sources/Api/MediaContext.cpp							\
	Sources/Api/MediaEngine.cpp								\
	Sources/Api/MediaProvider.cpp							\
	Sources/Api/MediaSink.cpp								\
	Sources/Api/MediaSinkProvider.cpp						\
	Sources/Api/MediaSource.cpp								\
	Sources/Api/MessageRef.cpp								\
	Sources/Api/CustomEventRef.cpp							\
	Sources/Api/MetadataRef.cpp								\
	Sources/Core/CommandParser.cpp							\
	Sources/Core/Controller.cpp								\
	Sources/Core/CustomEventHandler.cpp						\
	Sources/Core/Effect.cpp									\
	Sources/Core/MediaEngineState.cpp						\
	Sources/Core/MediaSinkState.cpp							\
	Sources/Core/MediaSourceState.cpp						\
	Sources/Core/Notifications.cpp							\
	Sources/Core/PersistentContext.cpp						\
	Sources/Core/Player.cpp									\
	Sources/Core/PlayState.cpp								\
	Sources/Core/SingletonManager.cpp						\
	Sources/Core/SinkManager.cpp							\
	Sources/Core/SourceStack.cpp							\
	Sources/Core/TamTamSession.cpp							\
	Sources/Effects/CarSpatialization.cpp					\
	Sources/Effects/Equalizer.cpp							\
	Sources/Effects/Limiter.cpp								\
	Sources/Effects/Spatialization.cpp						\
	Sources/Effects/StereoWidening.cpp						\
	Sources/Effects/VirtualBass.cpp							\
	Sources/Infra/DeviceManager.cpp							\
	Sources/Infra/BluetoothCommon.cpp						\
	Sources/Infra/Configuration.cpp							\
	Sources/Infra/ExclusionManager.cpp						\
	Sources/Infra/PfdApi.cpp								\
	Sources/Infra/SystemMonitor.cpp							\
	Sources/MediaSinks/Bluetooth/BluetoothSink.cpp			\
	Sources/MediaSinks/Bluetooth/BluetoothSinkProvider.cpp	\
	Sources/MediaSources/Bluetooth/AvrcpSession.cpp			\
	Sources/MediaSources/Bluetooth/DiscoBtRemoteCtrl.cpp	\
	Sources/MediaSources/Bluetooth/BluetoothConfiguration.cpp\
	Sources/MediaSources/Bluetooth/BluetoothEngine.cpp		\
	Sources/MediaSources/Bluetooth/BluetoothProvider.cpp	\
	Sources/MediaSources/Bluetooth/BluetoothSource.cpp		\
	Sources/MediaSources/Bluetooth/PlayCommandAggregator.cpp\
	Sources/MediaSources/File/FileConfiguration.cpp			\
	Sources/MediaSources/File/FileMediaEngine.cpp			\
	Sources/MediaSources/File/FileMediaProvider.cpp			\
	Sources/MediaSources/File/FileMediaSource.cpp			\
	Sources/MediaSources/File/FileMediaContext.cpp			\
	Sources/MediaSources/File/FileMountThread.cpp			\
	Sources/MediaSources/File/FilePlaybackQueue.cpp			\
	Sources/MediaSources/File/FilePlaylist.cpp				\
	Sources/MediaSources/iPod/IpodSource.cpp				\
	Sources/MediaSources/iPod/IpodUSBProvider.cpp			\
	Sources/MediaSources/iPod/IpodBTProvider.cpp			\
	Sources/MediaSources/iPod/IpodGenericEngine.cpp			\
	Sources/MediaSources/iPod/IpodGenericProvider.cpp		\
	Sources/MediaSources/iPod/IpodUSBEngine.cpp				\
	Sources/MediaSources/iPod/IpodBTEngine.cpp				\
	Sources/MediaSources/iPod/IpodThreadMail.cpp			\
	Sources/MediaSources/iPod/IpodThread.cpp				\
	Sources/MediaSources/iPod/IpodVolumeSync.cpp			\
	Sources/MediaSources/iPod/IpodUARTEngine.cpp			\
	Sources/MediaSources/iPod/IpodUARTProvider.cpp			\
	Sources/MediaSources/Java/JavaSourceList.cpp			\
	Sources/MediaSources/LineIn/LineInAudioInput.cpp		\
	Sources/MediaSources/LineIn/LineInEngine.cpp			\
	Sources/MediaSources/LineIn/LineInProvider.cpp			\
	Sources/MediaSources/LineIn/LineInSource.cpp			\
	Sources/MediaSources/LocalFolder.cpp					\
	Sources/MediaSources/Mtp.cpp							\
	Sources/MediaSources/Pandora/PandoraSPPProvider.cpp		\
	Sources/MediaSources/Pandora/PandoraSPPEngine.cpp		\
	Sources/MediaSources/Pandora/PandoraSearchResult.cpp	\
	Sources/MediaSources/Pandora/PandoraComm.cpp			\
	Sources/MediaSources/Pandora/PandoraCommIFSPP.cpp		\
	Sources/MediaSources/Pandora/PandoraCommands.cpp		\
	Sources/MediaSources/Pandora/PandoraSource.cpp			\
	Sources/MediaSources/Pandora/PandoraGenericProvider.cpp	\
	Sources/MediaSources/Pandora/PandoraStation.cpp			\
	Sources/MediaSources/Pandora/PandoraContext.cpp			\
	Sources/MediaSources/Pandora/PandoraGenreCat.cpp		\
	Sources/MediaSources/Samba.cpp							\
	Sources/MediaSources/SDCard.cpp							\
	Sources/MediaSources/Usb.cpp							\
	Sources/Utils/MTL_Debug.c								\
	Sources/Utils/MTL_DynArray.c							\
	Sources/Utils/MTL_List.c								\
	Sources/Utils/MTL_HashTable.c							\
	Sources/Utils/MTL_MsgBus.cpp							\
	Sources/Utils/Memory.cpp								\
	Sources/Utils/rand31-park-miller-carta.cpp

ifeq ("$(TARGET_OS_FLAVOUR)","android")
ifdef CONFIG_CONCERTOS_USE_JAVA_SOURCE
LOCAL_SRC_FILES += \
	Sources/MediaSources/Java/Exception.cpp \
	Sources/MediaSources/Java/IActivityManager.cpp \
	Sources/MediaSources/Java/IMediaEngineApi.cpp \
	Sources/MediaSources/Java/IMediaEngineCb.cpp \
	Sources/MediaSources/Java/IMediaProviderApi.cpp \
	Sources/MediaSources/Java/IMediaProviderCb.cpp \
	Sources/MediaSources/Java/IMediaSource.cpp \
	Sources/MediaSources/Java/JavaMediaContext.cpp \
	Sources/MediaSources/Java/JavaMediaEngine.cpp \
	Sources/MediaSources/Java/JavaMediaProvider.cpp \
	Sources/MediaSources/Java/JavaMediaSource.cpp \
	Sources/MediaSources/Java/ParcelHelper.cpp
endif
endif

LOCAL_LIBRARIES := \
	disco \
	acid \
	blues \
	settings \
	tinyxml \
	tamtam \
	tango-core \
	pal-utils \
	pal-core

ifeq ("$(TARGET_OS)","linux")
  LOCAL_LIBRARIES += pal-juba
  ifeq ("$(TARGET_OS_FLAVOUR)","android")
    LOCAL_LIBRARIES += libutils libcutils libbinder
  endif
endif

ifneq ("$(TARGET_OS)","ecos")
LOCAL_SRC_FILES += \
	Sources/MediaSources/UPnP/UpnpMediaContext.cpp \
	Sources/MediaSources/UPnP/UpnpMediaSource.cpp \
	Sources/MediaSources/UPnP/UpnpMediaEngine.cpp \
	Sources/MediaSources/UPnP/UpnpMediaProvider.cpp \
	Sources/MediaSources/UPnP/UpnpConfiguration.cpp \
	Sources/MediaSources/UPnP/UpnpMediaItem.cpp
LOCAL_LIBRARIES += jungle
endif

include $(BUILD_SHARED_LIBRARY)

