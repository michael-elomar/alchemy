
LOCAL_PATH := $(call my-dir)

###############################################################################
# SoftAT
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := softat
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := Build/ConfigCK5050Set.in
$(call load-config)

SOFTAT_BUILD_DIR := $(call local-get-build-dir)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Export \
	$(LOCAL_PATH)/Sources \
	$(LOCAL_PATH)/Sources/AudioMngt \
	$(LOCAL_PATH)/Sources/EXTI \
	$(LOCAL_PATH)/Sources/HSTI \
	$(LOCAL_PATH)/Sources/HSTI/Requests \
	$(LOCAL_PATH)/Sources/HSTI/Requests/ReqNADI \
	$(LOCAL_PATH)/Sources/HSTI/Requests/ReqNERI \
	$(LOCAL_PATH)/Sources/HSTI/Requests/ReqMMI \
	$(LOCAL_PATH)/Sources/HSTI/Requests/ReqSIVR \
	$(LOCAL_PATH)/Sources/HSTI/Requests/ReqUPNP \
	$(LOCAL_PATH)/Sources/HSTI/Generated \
	$(LOCAL_PATH)/Sources/HSTI/Mapping \
	$(LOCAL_PATH)/Sources/NERI \
	$(LOCAL_PATH)/Sources/NERI/Device \
	$(LOCAL_PATH)/Sources/NERI/Device/PAN \
	$(LOCAL_PATH)/Sources/NERI/Device/WIFI \
	$(LOCAL_PATH)/Sources/NERI/Interface \
	$(LOCAL_PATH)/Sources/NERI/Core \
	$(LOCAL_PATH)/Sources/NERI/NATRule \
	$(LOCAL_PATH)/Sources/NADI \
	$(LOCAL_PATH)/Sources/NADI/Core \
	$(LOCAL_PATH)/Sources/NADI/Device \
	$(LOCAL_PATH)/Sources/NADI/Dongle3G \
	$(LOCAL_PATH)/Sources/NADI/GsmModem \
	$(LOCAL_PATH)/Sources/NADI/Dun \
	$(LOCAL_PATH)/Sources/Misc \
	$(LOCAL_PATH)/Sources/Protocol \
	$(LOCAL_PATH)/Sources/Protocol/Transport \
	$(LOCAL_PATH)/Sources/Startup \
	$(LOCAL_PATH)/Sources/System \
	$(LOCAL_PATH)/Sources/Task \
	$(LOCAL_PATH)/Sources/MMI \
	$(LOCAL_PATH)/Sources/SIVR \
	$(LOCAL_PATH)/Sources/RAPI \
	$(LOCAL_PATH)/Sources/VH \
	$(LOCAL_PATH)/Sources/DEVI \
	$(LOCAL_PATH)/Sources/UPNPI \
	$(LOCAL_PATH)/Sources/Utils \
	$(LOCAL_PATH)/Sources/WIFI \
	$(LOCAL_PATH)/Sources/RADI

LOCAL_EXPORT_CFLAGS := \
	-DUSE_BLUES_V7 \
	-DUSE_CK5050 \
	-DCK5050_MODEL_NAME=Unknown

# Export directory is put here first so that config.h is found here first
LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Export

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	Sources/EXTI/EXTI_FileSystemUpdate.c \
	Sources/EXTI/EXTI_Update.c \
	Sources/HSTI/HSTI_Main.c \
	Sources/AudioMngt/AM_AudioTask_source.c \
	Sources/AudioMngt/AM_AudioTask.c \
	Sources/AudioMngt/AM_Comm.c \
	Sources/AudioMngt/AM_DTMF.c \
	Sources/AudioMngt/AM_Ring.c \
	Sources/AudioMngt/AM_Filters.c \
	Sources/AudioMngt/AM_Record.c \
	Sources/AudioMngt/AM_Volume.c \
	Sources/AudioMngt/AM_Loopback.c \
	Sources/AudioMngt/AM_SourceActivity.c \
	Sources/BLI/OBEXAuth/BLI_Obex.c \
	Sources/BLI/Core/BLI_Device.c \
	Sources/BLI/Core/BLI_Inquiry.c \
	Sources/BLI/Core/BLI_DID.c \
	Sources/BLI/Core/BLI_SpecialBehaviours.c \
	Sources/BLI/PIM/BLI_DB.c \
	Sources/BLI/PIM/PIM_DirtyInterface.c \
	Sources/BLI/HFP/SMS/BLI_SMS.c \
	Sources/BLI/HFP/SMS/BLI_SMS_Task.c \
	Sources/BLI/Streaming/BLI_Streaming_ContentProt.c \
	Sources/System/SYST_messages.c \
	Sources/System/SYST_CK505X.c \
	Sources/System/SYST_HWMngt.c \
	Sources/System/SYST_FileManagement.c \
	Sources/System/SYST_P4Mutex.c \
	Sources/MMI/MMI.c \
	Sources/MMI/MMI_Source.c \
	Sources/MMI/MMI_Base.c \
	Sources/MMI/MMI_Browsing.c \
	Sources/MMI/MMI_Player.c \
	Sources/MMI/MMI_Effect.c \
	Sources/MMI/MMI_Metadata.c \
	Sources/MMI/MMI_Image.c \
	Sources/MMI/MMI_Event.c \
	Sources/HFS/PROT_hfs.c \
	Sources/HFS/PROT_hfs_target.c \
	Sources/HSTI/Requests/ReqMMI/HSTI_ReqMMI_Source.c \
	Sources/HSTI/Requests/ReqMMI/HSTI_ReqMMI_Browsing.c \
	Sources/HSTI/Requests/ReqMMI/HSTI_ReqMMI_Player.c \
	Sources/HSTI/Requests/ReqMMI/HSTI_ReqMMI_ContentProt.c \
	Sources/HSTI/Requests/ReqUPNP/HSTI_ReqUPNP_Browsing.c \
	Sources/HSTI/Requests/ReqUPNP/HSTI_Req_Upnp.c \
	Sources/HSTI/Requests/ReqBTTest/HSTI_Req_TestMarvell.c \
	Sources/HSTI/Requests/ReqBTTest/HSTI_Req_TestInfineon.c \
	Sources/HSTI/Requests/ReqBTTest/HSTI_Req_TestTi.c \
	Sources/HSTI/Requests/HSTI_Req_Main.c \
	Sources/HSTI/Requests/HSTI_Req_Bluetooth.c \
	Sources/HSTI/Requests/HSTI_Req_Test.c \
	Sources/HSTI/Requests/HSTI_Req_Services.c \
	Sources/HSTI/Requests/HSTI_Req_Phone.c \
	Sources/HSTI/Requests/HSTI_Req_Audio.c \
	Sources/HSTI/Requests/HSTI_Req_Settings.c \
	Sources/HSTI/Requests/HSTI_Req_Update.c \
	Sources/HSTI/Requests/HSTI_Req_SMS.c \
	Sources/HSTI/Requests/HSTI_Req_BTInquiry.c \
	Sources/HSTI/Requests/HSTI_Req_BTDevices.c \
	Sources/HSTI/Requests/HSTI_Req_Wifi.c \
	Sources/HSTI/Requests/HSTI_Req_Browsing.c \
    Sources/HSTI/Requests/HSTI_Req_Devices.c \
	Sources/HSTI/Requests/HSTI_Req_Reco.c \
	Sources/HSTI/Requests/HSTI_Req_Obex.c \
	Sources/HSTI/Requests/HSTI_Req_Rap.c \
	Sources/HSTI/Requests/HSTI_Req_Hardware.c \
    Sources/HSTI/Requests/HSTI_Req_Radi.c \
    Sources/HSTI/Requests/HSTI_Req_Internal.c \
    Sources/HSTI/Requests/HSTI_Req_BTAutoconnection.c \
	Sources/GAFS/TASK_GAFS.c \
	Sources/DEVI/Devi.c \
    Sources/DEVI/Devi_Juba.c \
    Sources/DEVI/Devi_Acid.c \
    Sources/DEVI/Devi_Acid_Coproc.c \
    Sources/DEVI/Devi_Client.c \
    Sources/DEVI/Devi_Property.c \
    Sources/DEVI/Devi_Devpath.c \
	Sources/RAPI/RAPI_MMIEvent.c \
	Sources/UPNPI/Upnp_Browsing.c \
	Sources/UPNPI/Upnp_Priv.c \
	Sources/UPNPI/Upnp_Controller.c \
    Sources/UPNPI/Upnp_Streaming.c \
    Sources/UPNPI/Upnp_Context.c \
    Sources/UPNPI/Upnp_Bridge.c \
    Sources/WIFI/Wifi_Tools.c \
    Sources/RADI/Radi.c \
    Sources/RADI/Radi_IDTag.c \
    Sources/RADI/Radi_Applis.c \
	Sources/RAPI/RAPI_Wrapper.cpp \
	Sources/RAPI/RAPI_Observer.cpp \
	Sources/Protocol/Transport/PROT_Transport.cpp \
	Sources/HSTI/Requests/HSTI_Req_CallMngt.cpp \
	Sources/HSTI/Requests/HSTI_Req_Map.cpp \
	Sources/HSTI/Requests/HSTI_Req_Phonebook.cpp \
	Sources/HSTI/Requests/HSTI_Req_Log.cpp \
	Sources/BLI/PIM/PIM_Interface.cpp \
	Sources/BLI/PIM/PIM_SyncManager.cpp \
	Sources/BLI/PIM/PIM_SyncDevice.cpp \
	Sources/BLI/PIM/PIM_SyncDeviceList.cpp \
	Sources/BLI/PIM/PIM_SyncProfile.cpp \
	Sources/BLI/PIM/PIM_PimManager.cpp \
	Sources/BLI/PIM/PIM_WrapperBlues.cpp \
	Sources/BLI/PIM/PIM_Calendar.cpp \
	Sources/HSTI/Requests/HSTI_Req_Uuid.cpp \
	Sources/BLI/MAPI/MAPI_Instance.cpp \
	Sources/BLI/MAPI/MAPI_InstanceMngr.cpp \
	Sources/BLI/MAPI/MAPI_StartUser.cpp \
	Sources/BLI/MAPI/MAPI_CacheMngr.cpp \
	Sources/BLI/MAPI/MAPI_WindowMngr.cpp \
	Sources/BLI/MAPI/MAPI_FolderMngr.cpp \
	Sources/BLI/MAPI/MAPI_MessageMngr.cpp \
	Sources/BLI/MAPI/MAPI_MessageListThread.cpp \
	Sources/BLI/MAPI/MAPI_Interface.cpp \
	Sources/BLI/MAPI/MAPI_DB.cpp \
	Sources/HSTI/Requests/ReqNADI/HSTI_ReqNADI.cpp \
	Sources/HSTI/Requests/ReqNERI/HSTI_ReqNERI.cpp \
	Sources/NADI/Core/NADI_External.cpp \
	Sources/NADI/Core/NADI_Module.cpp \
	Sources/NADI/Device/NADI_Device.cpp \
	Sources/NADI/Device/NADI_DeviceManager.cpp \
	Sources/NADI/Dongle3G/NADI_Dongle3G.cpp \
	Sources/NADI/Dongle3G/NADI_Dongle3GCore.cpp \
	Sources/NADI/GsmModem/NADI_GsmModem.cpp \
	Sources/NADI/GsmModem/NADI_GsmModemCore.cpp \
	Sources/NADI/Dun/NADI_Dun.cpp \
	Sources/NADI/Dun/NADI_DunCore.cpp \
	Sources/NERI/Device/NERI_Device.cpp \
	Sources/NERI/Device/NERI_DeviceManager.cpp \
	Sources/NERI/Device/PAN/NERI_PANDevice.cpp \
	Sources/NERI/Device/PAN/NERI_PANDeviceManager.cpp \
	Sources/NERI/Device/WIFI/NERI_WifiDevice.cpp \
	Sources/NERI/Device/WIFI/NERI_WifiDeviceManager.cpp \
	Sources/NERI/Interface/NERI_Interface.cpp \
	Sources/NERI/Interface/NERI_InterfaceManager.cpp \
	Sources/NERI/Core/NERI_Module.cpp \
	Sources/NERI/Core/NERI_InterfaceObserver.cpp \
	Sources/NERI/Core/NERI_Config.cpp \
	Sources/NERI/NATRule/NERI_NATRule.cpp \
	Sources/NERI/NATRule/NERI_NATRuleManager.cpp \
	Sources/Utils/Thread.cpp \
	Sources/Utils/EvtModule.cpp \
	Sources/Utils/IniFile.cpp \
	Sources/Utils/Executor.cpp \
	Sources/Task/TASK_SAP.cpp \
	Sources/Task/TASK_AT.cpp \
    Sources/WIFI/Wifi_Device.cpp \
    Sources/WIFI/Wifi.cpp \
    Sources/WIFI/Wifi_Config.c \
	Sources/System/SYST_Settings.cpp \
	Sources/System/SYST_Management.cpp \
	Sources/System/SYST_Tools.cpp \
	Sources/System/Core/CKCMInitializer.cpp \
	Sources/System/Core/SoftAtMngt.cpp \
	Sources/System/Core/Component.cpp \
	Sources/System/Core/Library.cpp \
	Sources/System/Core/Module.cpp \
	Sources/System/Libraries/AudioBinder.cpp \
	Sources/System/Libraries/Blues.cpp \
	Sources/System/Libraries/Concertos.cpp \
	Sources/System/Libraries/Disco.cpp \
	Sources/System/Libraries/ParrotDb.cpp \
	Sources/System/Libraries/Soul.cpp \
	Sources/System/Libraries/Tala.cpp \
	Sources/System/Libraries/Tango.cpp \
	Sources/System/Libraries/Tamtam.cpp \
	Sources/System/Libraries/UniRecorder.cpp \
	Sources/System/Libraries/Wifi.cpp \
	Sources/BLI/Core/BLI_Module.cpp \
	Sources/BLI/Core/BLI_ModuleEvtMain.cpp \
	Sources/BLI/Core/BLI_ModuleInterface.cpp \
	Sources/BLI/Core/BLI_Services.cpp \
	Sources/BLI/Core/BLI_CoreEvtModule.cpp \
	Sources/BLI/Core/BLI_CoreEvtModuleFiltered.cpp \
	Sources/BLI/Core/BLI_BaseDevice.cpp \
	Sources/BLI/Core/BLI_BaseDeviceList.cpp \
	Sources/BLI/Core/BLI_DataPort.cpp \
	Sources/BLI/Core/BLI_HCIDump.cpp \
	Sources/BLI/Core/BLI_IProfile.cpp \
	Sources/BLI/Core/BLI_PairedDevice.cpp \
	Sources/BLI/Core/BLI_PairedDeviceList.cpp \
	Sources/BLI/Core/BLI_Pairing.cpp \
	Sources/BLI/Core/BLI_ProfileManager.cpp \
	Sources/BLI/Core/BLI_SubmoduleManager.cpp \
	Sources/BLI/Core/BLI_RemoteDevice.cpp \
	Sources/BLI/Core/BLI_RemoteDeviceList.cpp \
	Sources/BLI/Core/BLI_BaseSettings.cpp \
	Sources/BLI/Core/BLI_Settings.cpp \
	Sources/BLI/Core/BLI_UserSettings.cpp \
	Sources/BLI/Core/BLI_UUID.cpp \
	Sources/BLI/Core/BLI_BtAddr.cpp \
	Sources/BLI/Core/BLI_WrapperBlues.cpp \
	Sources/BLI/DUN/BLI_DunClient.cpp \
	Sources/BLI/DUN/BLI_DunProfile.cpp \
	Sources/BLI/DUN/BLI_DunProfileInterface.cpp \
	Sources/BLI/HID/BLI_HID_Host.cpp \
	Sources/BLI/HID/BLI_HID_Device.cpp \
	Sources/BLI/HFP/BLI_HfpProfile.cpp \
	Sources/BLI/HFP/BLI_HfpProfileInterface.cpp \
	Sources/BLI/HFP/BLI_Hfp_Settings.cpp \
	Sources/BLI/HFP/BLI_Hfp_Internals.cpp \
	Sources/BLI/HFP/BLI_Hfp_LegacyInterface.cpp \
	Sources/BLI/HFP/BLI_Hfp_Ringtone.cpp \
	Sources/BLI/RFCOMMCommon/BLI_RfcommConnection.cpp \
	Sources/BLI/RFCOMMCommon/BLI_RfcommGenericClient.cpp \
	Sources/BLI/RFCOMMCommon/BLI_RfcommGateway.cpp \
	Sources/BLI/RFCOMMCommon/BLI_RfcommGenericServer.cpp \
	Sources/BLI/RFCOMMCommon/BLI_RfcommParam.cpp \
	Sources/BLI/RFCOMMProfile/BLI_RfcommProfile.cpp \
	Sources/BLI/RFCOMMProfile/BLI_RfcommProfileInterface.cpp \
	Sources/BLI/RFCOMMProfile/BLI_RfcommClient.cpp \
	Sources/BLI/RFCOMMProfile/BLI_RfcommServer.cpp \
	Sources/BLI/ParrotSPP/BLI_ParrotSppClient.cpp \
	Sources/BLI/ParrotSPP/BLI_ParrotSppServer.cpp \
	Sources/BLI/ParrotSPP/BLI_ParrotSppProfile.cpp \
	Sources/BLI/ParrotSPP/BLI_ParrotSppProfileInterface.cpp \
	Sources/BLI/ParrotSPP/BLI_ParrotSppProfileParam.cpp \
	Sources/BLI/SDP/BLI_ISDPTools.cpp \
	Sources/BLI/SDP/BLI_SDPTools.cpp \
	Sources/BLI/SDP/BLI_SDPParser.cpp \
	Sources/BLI/Streaming/BLI_Streaming.cpp \
	Sources/BLI/Streaming/BLI_StreamingProfile.cpp \
	Sources/BLI/Autoconnection/AutoconnectionModule.cpp \
	Sources/BLI/Autoconnection/BLI_Autoconnection_API.cpp \
	Sources/BLI/Autoconnection/ChronologicalTry.cpp \
	Sources/BLI/Autoconnection/DeviceMngr.cpp \
	Sources/BLI/Autoconnection/IBtService.cpp \
	Sources/BLI/Autoconnection/ServiceInfo.cpp \
	Sources/BLI/Autoconnection/StandardBtService.cpp \
	Sources/BLI/Autoconnection/MAPService.cpp \
	Sources/BLI/Autoconnection/HFPService.cpp \
	Sources/BLI/PAN/BLI_PAN_PCapSaver.cpp \
	Sources/BLI/PAN/BLI_PAN_Profile.cpp \
	Sources/BLI/PAN/BLI_PAN_Protocol.cpp \
	Sources/BLI/OPP/BLI_OppManager.cpp \
	Sources/BLI/OPP/BLI_OppProfile.cpp \
	Sources/BLI/SAP/BLI_SapProfile.cpp \
	Sources/AudioMngt/AM_Module.cpp \
	Sources/AudioMngt/AM_Settings.cpp \
    Sources/UPNPI/Upnp_Config.c \
	Sources/UPNPI/Upnp_Module.cpp \
	Sources/UPNPI/Upnp_Download.cpp \
	Sources/UPNPI/Upnp_Transfer.cpp \
    Sources/UPNPI/Upnp_Streaming_Port.cpp \
    Sources/DEVI/Devi_Module.cpp \
    Sources/DEVI/Devi_Config.c \
	Sources/MMI/MMI_Config.c \
	Sources/MMI/MMI_Module.cpp \
	Sources/MMI/MMI_Settings.cpp \
    Sources/RADI/Radi_Module.cpp \
    Sources/RADI/Radi_Config.c \
    Sources/RADI/Radi_Appli_Port.cpp \
    Sources/HFS/HFS_Module.cpp \
    Sources/HFS/TASK_HFS.cpp \
    Sources/GAFS/GAFS_Module.cpp \
   	Sources/RAPI/RAPI_Module.cpp

###############################################################################
# Version rules.
###############################################################################

HIPHOP_TAG := $(shell cd $(LOCAL_PATH) && git describe --tags --match hiphop-*)
HIPHOP_VERSION_MAJOR := $(shell echo $(HIPHOP_TAG) | sed s/hiphop-*// | cut -d'.' -f1)
HIPHOP_VERSION_MINOR := $(shell echo $(HIPHOP_TAG) | sed s/hiphop-*// | cut -d'.' -f2)
HIPHOP_VERSION_REV := $(shell echo $(HIPHOP_TAG) | sed s/hiphop-*// | cut -d'.' -f3 | cut -d'-' -f1)

# Shall be defined externally to override
ifndef APPL_MAJOR_VERSION_NUMBER
  APPL_MAJOR_VERSION_NUMBER := $(HIPHOP_VERSION_MAJOR)
  APPL_MINOR_VERSION_NUMBER := $(HIPHOP_VERSION_MINOR)
  APPL_MODIF_VERSION_NUMBER := $(HIPHOP_VERSION_REV)
  APPL_EXTENDED_VERSION_INFO := "HIPHOP"
endif

CGMREX_FIELD_VERSION := \
	$(shell printf "%d.%02d.%d" \
	$(APPL_MAJOR_VERSION_NUMBER) \
	$(APPL_MINOR_VERSION_NUMBER) \
	$(APPL_MODIF_VERSION_NUMBER) )

# add extended version information
ifdef APPL_EXTENDED_VERSION_INFO
CGMREX_FIELD_VERSION += $(APPL_EXTENDED_VERSION_INFO)
endif

ifndef CGMREX_FIELD_CUSTOMER
CGMREX_FIELD_CUSTOMER := 0
endif

ifndef CGMREX_FIELD_CHECKSUM
CGMREX_FIELD_CHECKSUM := 0
endif

CGMREX_FIELD_DATE := $(shell LC_TIME="en_GB" date "+%b %d %Y")
CGMREX_FIELD_TIME := $(shell LC_TIME="en_GB" date "+%H:%M:%S")

CGMREX_WITHOUT_CHECKSUM := \
	$(shell printf "%s,%s,%s,%s" \
	"\'$(CGMREX_FIELD_VERSION)\'" \
	"$(CGMREX_FIELD_CUSTOMER)" \
	"\'$(CGMREX_FIELD_DATE)\'" \
	"\'$(CGMREX_FIELD_TIME)\'" )

CGMREX_WITH_CHECKSUM := \
	$(shell printf "%s,%08X" \
	"$(CGMREX_WITHOUT_CHECKSUM)" \
	$(CGMREX_FIELD_CHECKSUM) )

# TODO : handle dependency on git tag to detect changes
$(SOFTAT_BUILD_DIR)/version_ck5050.h:
	@mkdir -p $(dir $@)
	@rm -f $@
	@touch $@
	@echo "// WARNING THIS FILE IS GENERATED, DO NOT MODIFY IT" >> $@
	@echo "#define HIPHOP_VERSION_MAJOR $(HIPHOP_VERSION_MAJOR)" >> $@
	@echo "#define HIPHOP_VERSION_MINOR $(HIPHOP_VERSION_MINOR)" >> $@
	@echo "#define HIPHOP_VERSION_REV $(HIPHOP_VERSION_REV)" >> $@
	@echo "#define MAJ_VERSION_NUMBER $(APPL_MAJOR_VERSION_NUMBER)" >> $@
	@echo "#define MIN_VERSION_NUMBER $(APPL_MINOR_VERSION_NUMBER)" >> $@
	@echo "#define MOD_VERSION_NUMBER $(APPL_MODIF_VERSION_NUMBER)" >> $@
	@echo "#define EXT_VERSION_INFO   \"$(APPL_EXTENDED_VERSION_INFO)\"" >> $@

.PHONY: cgmrex
cgmrex:
	@mkdir -p $(SOFTAT_BUILD_DIR)
	@echo CGMREX=$(CGMREX_WITH_CHECKSUM)
	@echo "+CGMREX:"$(CGMREX_WITH_CHECKSUM) > $(SOFTAT_BUILD_DIR)/CGMREX.txt

# Force recompilation of file displaying version using CGMREX define
$(SOFTAT_BUILD_DIR)/obj/Sources/HSTI/Requests/HSTI_Req_Main.o: cgmrex

# Make sure version file is compiled first
LOCAL_PREREQUISITES += \
	$(SOFTAT_BUILD_DIR)/version_ck5050.h

# Only HSTI_Req_Main.c shall use this define
LOCAL_CFLAGS += \
	-DCGMREX_FORMAT_WITHOUT_CKSUM="\"$(CGMREX_WITHOUT_CHECKSUM)\""

###############################################################################
## Autogenerate HIPHOP_ConfigRead.h and HIPHOP_ConfigRead.cpp
## Only depends on .h, the cpp is generated at the same time.
###############################################################################

# Those file names are hardcoded in source code and python script as well
SOFTAT_CONFIG_READ_D := $(SOFTAT_BUILD_DIR)/HIPHOP_ConfigRead.d
SOFTAT_CONFIG_READ_DONE := $(SOFTAT_BUILD_DIR)/HIPHOP_ConfigRead.done
-include $(SOFTAT_CONFIG_READ_D)

# TODO : update script so that we don't have to change current directory
# also put it Build directory and not in HSTIGenerator
$(SOFTAT_CONFIG_READ_DONE): $(AUTOCONF_MERGE_FILE)
	@mkdir -p $(dir $@)
	$(Q)cd $(PRIVATE_PATH)/Build && \
		$(PRIVATE_PATH)/../HSTIGenerator/Ck5050ini_Generate.py \
		-a $(AUTOCONF_MERGE_FILE) \
		$(PRIVATE_PATH)/SoftATini \
		$(SOFTAT_BUILD_DIR)
	@touch $@

LOCAL_PREREQUISITES += \
	$(SOFTAT_CONFIG_READ_DONE)

###############################################################################
## Autogenerate lib_custom.c
###############################################################################

# This file name is hardcoded in source code as well
SOFTAT_LIB_CUSTOM_C := $(SOFTAT_BUILD_DIR)/lib_custom.c
SOFTAT_LIB_CUSTOM_SED_FILES :=
ifdef CK5050_CONFIG_DIR
  SOFTAT_LIB_CUSTOM_SED_FILES += $(wildcard $(CK5050_CONFIG_DIR)/*.sed)
endif

$(SOFTAT_LIB_CUSTOM_C): $(SOFTAT_LIB_CUSTOM_SED_FILES)
	@mkdir -p $(dir $@)
	$(Q)$(PRIVATE_PATH)/Build/gen_lib_custom.sh \
		$(SOFTAT_LIB_CUSTOM_SED_FILES) > $@

LOCAL_PREREQUISITES += \
	$(SOFTAT_LIB_CUSTOM_C)

###############################################################################
###############################################################################

LOCAL_LIBRARIES := \
	buto \
	acid \
	hstilib \
	ckcm \
	blues \
	disco \
	tango-core \
	tala \
	tamtam \
	rap \
	settings \
	soul \
	concertos \
	unirecorder \
	crypto-parrot \
	parrotdb \
	pal-drivers \
	pal-utils \
	pal-core

ifeq ("$(TARGET_OS)","linux")
  LOCAL_LIBRARIES += modman jungle pal-juba
  ifeq ("$(TARGET_OS_FLAVOUR)","android")
    LOCAL_LIBRARIES += audiobinder
  endif
endif

include $(BUILD_SHARED_LIBRARY)

