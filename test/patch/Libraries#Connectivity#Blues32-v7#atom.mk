
LOCAL_PATH := $(call my-dir)

###############################################################################
# Blues
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := blues
LOCAL_PBUILD_HOOK := 1

# Get the build directory
BLUES_BUILD_DIR := $(call local-get-build-dir)

LOCAL_CONFIG_FILES := \
	Build/Config/ConfigBluesBluetoothSettings.in \
	Build/Config/ConfigBluesModules.in \
	Build/Config/ConfigAudioStreamingSettings.in \
	Build/Config/ConfigBluesTelephonySettings.in \
	Build/Config/ConfigL2CAPSettings.in \
	Build/Config/ConfigRFCOMMSettings.in \
	Build/Config/ConfigOBEXSettings.in \
	Build/Config/ConfigSMSSettings.in \
	Build/Config/ConfigMAPSettings.in \
	Build/Config/ConfigBluesSynchroSettings.in \
	Build/Config/ConfigBluesMiscSettings.in \
	Build/Config/ConfigDirectorySettings.in \
	Build/Config/ConfigBluesVersionInfos.in \
	Build/Config/ConfigBluesVersion.in \
	Build/Config/ConfigDebugSettings.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(BLUES_BUILD_DIR)/include \
	$(LOCAL_PATH) \
	$(LOCAL_PATH)/Sources/Common/Bip \
	$(LOCAL_PATH)/Sources/Common/Buffer \
	$(LOCAL_PATH)/Sources/Common/BTStack \
	$(LOCAL_PATH)/Sources/Common/BTStack/RFCOMM \
	$(LOCAL_PATH)/Sources/Common/BTStack/L2CAP \
	$(LOCAL_PATH)/Sources/Common/BTStack/L2CAP/Tests \
	$(LOCAL_PATH)/Sources/Common/BTStack/SDP \
	$(LOCAL_PATH)/Sources/Common/BTStack/HCI \
	$(LOCAL_PATH)/Sources/Common/BTStack/AMP \
	$(LOCAL_PATH)/Sources/Common/BTStack/OBEX \
	$(LOCAL_PATH)/Sources/Common/BTStack/OBEX/Tests \
	$(LOCAL_PATH)/Sources/Common/BTStack/toremove \
	$(LOCAL_PATH)/Sources/Common/BTStack/Tests \
	$(LOCAL_PATH)/Sources/Common/BTStack/HCI/Broadcom \
	$(LOCAL_PATH)/Sources/Common/BTStack/HCI/CSR \
	$(LOCAL_PATH)/Sources/Common/BTStack/HCI/CSR/Patch \
	$(LOCAL_PATH)/Sources/Common/BTStack/HCI/Ericsson \
	$(LOCAL_PATH)/Sources/Common/BTStack/HCI/Infineon \
	$(LOCAL_PATH)/Sources/Common/BTStack/HCI/Infineon/Patch \
	$(LOCAL_PATH)/Sources/Common/BTStack/HCI/Marvell \
	$(LOCAL_PATH)/Sources/Common/BTStack/HCI/TI \
	$(LOCAL_PATH)/Sources/Common/BTStack/HCI/TI/Patch \
	$(LOCAL_PATH)/Sources/Common/BTStack/HCI/VirtualHCI \
	$(LOCAL_PATH)/Sources/Common/BTTelephony \
	$(LOCAL_PATH)/Sources/Common/BTTelephony/ATDeviceId \
	$(LOCAL_PATH)/Sources/Common/BTTelephony/SAP \
	$(LOCAL_PATH)/Sources/Common/BTTelephony/Tests \
	$(LOCAL_PATH)/Sources/Common/FileSystem \
	$(LOCAL_PATH)/Sources/Common/GPS \
	$(LOCAL_PATH)/Sources/Common/GSMTelephony \
	$(LOCAL_PATH)/Sources/Common/Hid \
	$(LOCAL_PATH)/Sources/Common/Messaging \
	$(LOCAL_PATH)/Sources/Common/Messaging/Tests \
	$(LOCAL_PATH)/Sources/Common/Misc \
	$(LOCAL_PATH)/Sources/Common/Misc/Tests \
	$(LOCAL_PATH)/Sources/Common/Misc/Operators \
	$(LOCAL_PATH)/Sources/Common/Network \
	$(LOCAL_PATH)/Sources/Common/ObjectMngt \
	$(LOCAL_PATH)/Sources/Common/Protocol \
	$(LOCAL_PATH)/Sources/Common/SoftwareUpdate \
	$(LOCAL_PATH)/Sources/Common/Synchro \
	$(LOCAL_PATH)/Sources/Common/Synchro/VParser \
	$(LOCAL_PATH)/Sources/Common/Synchro/Method \
	$(LOCAL_PATH)/Sources/Common/PIM \
	$(LOCAL_PATH)/Sources/Common/RemoteUI \
	$(LOCAL_PATH)/Sources/Common/RemoteUI/Resources \
	$(LOCAL_PATH)/Sources/Common/RemoteUI/Resources/icons \
	$(LOCAL_PATH)/Sources/Common/RemoteUI/Resources/iniparser \
	$(LOCAL_PATH)/Sources/Common/System \
	$(LOCAL_PATH)/Sources/Common/Telematics \
	$(LOCAL_PATH)/Sources/Common/UserMngt \
	$(LOCAL_PATH)/Sources/Common/UserMngt/BLM_USER \
	$(LOCAL_PATH)/Sources/Common/UserMngt/Notification \
	$(LOCAL_PATH)/Sources/Common/UserMngt/ServiceDiscovery \
	$(LOCAL_PATH)/Sources/Common/UserMngt/TaskMngr \
	$(LOCAL_PATH)/Sources/Common/Streaming \
	$(LOCAL_PATH)/Sources/Common/SIMManager \
	$(LOCAL_PATH)/Sources/Common/Tests \
	$(LOCAL_PATH)/Sources/Parrot5/System \
	$(LOCAL_PATH)/Sources/Parrot5/ExtAPI \
	$(LOCAL_PATH)/Sources/SyncML/include \
	$(LOCAL_PATH)/Sources/SyncML/wbxml \
	$(LOCAL_PATH)/Sources/XML

LOCAL_EXPORT_CFLAGS := \
	-DUSE_BLUES

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	blues-stub.c \
	Sources/Common/Buffer/Bt_bufpool.c \
	Sources/Common/Buffer/Bt_buf.c \
	Sources/Common/Buffer/Bt_buf_debug.c \
	Sources/Common/BTStack/L2CAP/Bt_L2CAP.c \
	Sources/Common/BTStack/L2CAP/Bt_L2CAP_Sender.c \
	Sources/Common/BTStack/L2CAP/Bt_L2CAP_ERTR.c \
	Sources/Common/BTStack/L2CAP/Bt_L2CAP_AmpSwitch.c \
	Sources/Common/BTStack/L2CAP/Tests/Bt_L2CAP_testing.c \
	Sources/Common/BTStack/HCI/Bt_HCI.c \
	Sources/Common/BTStack/HCI/Bt_HCI_Specific.c \
	Sources/Common/BTStack/HCI/Broadcom/Bt_HCI_Broadcom.c \
	Sources/Common/BTStack/HCI/CSR/Bt_HCI_CSR.c \
	Sources/Common/BTStack/HCI/Ericsson/Bt_HCI_Ericsson.c \
	Sources/Common/BTStack/HCI/Infineon/Bt_HCI_Infineon.c \
	Sources/Common/BTStack/HCI/Marvell/Bt_HCI_Marvell.c \
	Sources/Common/BTStack/HCI/TI/Bt_HCI_TI.c \
	Sources/Common/BTStack/HCI/VirtualHCI/Bt_HCI_VirtHCI.c \
	Sources/Common/BTStack/HCI/Bt_HCI_Interface.c \
	Sources/Common/BTStack/HCI/Bt_HCI_3_0.c \
	Sources/Common/BTStack/HCI/Bt_ModuleBoot.c \
	Sources/Common/BTStack/AMP/Bt_A2MP.c \
	Sources/Common/BTStack/AMP/Bt_PAL_3_0.c \
	Sources/Common/BTStack/OBEX/Bt_OBEX_API.c \
	Sources/Common/BTStack/OBEX/Bt_OBEX_RFCOMM.c \
	Sources/Common/BTStack/OBEX/Bt_OBEX_L2CAP.c \
	Sources/Common/BTStack/OBEX/Bt_OBEX_SDP.c \
	Sources/Common/BTStack/OBEX/Bt_OBEX_Internal.c \
	Sources/Common/BTStack/OBEX/Bt_OBEX_Auth.c \
	Sources/Common/BTStack/OBEX/Bt_OBEX_Client.c \
	Sources/Common/BTStack/OBEX/Bt_OBEX_Server.c \
	Sources/Common/BTStack/OBEX/Bt_OBEX_Header.c \
	Sources/Common/BTStack/OBEX/Bt_OBEX_Debug.c \
	Sources/Common/BTStack/OBEX/Bt_OBEX_Packet.c \
	Sources/Common/BTStack/OBEX/Bt_OBEX_Job.c \
	Sources/Common/BTStack/OBEX/Bt_OBEX_Event.c \
	Sources/Common/BTStack/OBEX/BLM_OBEX.c \
	Sources/Common/BTStack/OBEX/Tests/BLM_OBEX_Test.c \
	Sources/Common/BTStack/Bt_Utils.c \
	Sources/Common/BTStack/Bt_QoS.c \
	Sources/Common/BTStack/RFCOMM/Bt_RFCOMM.c \
	Sources/Common/BTStack/SDP/Bt_SDP.c \
	Sources/Common/BTStack/SDP/Bt_SDP_Service.c \
	Sources/Common/BTStack/SDP/Bt_SDP_Parser.c \
	Sources/Common/BTStack/Tests/Bt_TestSuite.c \
	Sources/Common/BTTelephony/BLP_HandsFree_0_96.c \
	Sources/Common/BTTelephony/BLP_HandsFree_1_00.c \
	Sources/Common/BTTelephony/BLP_Headset.c \
	Sources/Common/BTTelephony/BLT_Telephony_Mngr.c \
	Sources/Common/BTTelephony/BLT_Telephony.c \
	Sources/Common/BTTelephony/BLT_Audiogateway.c \
	Sources/Common/BTTelephony/BLM_CallMngt.c \
	Sources/Common/BTTelephony/ATDeviceId/BLM_Device_Id.c \
	Sources/Common/BTTelephony/ATDeviceId/BLM_Device_Id_XML.c \
	Sources/Common/BTTelephony/SAP/BLP_SAP.c \
	Sources/Common/BTTelephony/Tests/BLT_Telephony_Test.c \
	Sources/Common/BTTelephony/Tests/BLT_SAP_Test.c \
	Sources/Common/FileSystem/BLM_FS_PhoneBook.c \
	Sources/Common/FileSystem/BLM_FS_Root.c \
	Sources/Common/FileSystem/BLM_FS_Pffs.c \
	Sources/Common/Misc/BLM_Custom_AT.c \
	Sources/Common/Misc/BLM_Debug.c \
	Sources/Common/Misc/BLM_MEAccess_Knl.c \
	Sources/Common/Misc/Operators/BLM_Operators.c \
	Sources/Common/Misc/BLM_utility.c \
	Sources/Common/Misc/BLP_FTP.c \
	Sources/Common/Misc/BLP_FTP_Client.c \
	Sources/Common/Misc/Tests/BLP_FTP_Client_Test.c \
	Sources/Common/Misc/BLM_Job.c \
	Sources/Common/Misc/BLM_PIP.c \
	Sources/Common/Misc/BLM_Files_Management.c \
	Sources/Common/Misc/BLM_MimeTypes.c \
	Sources/Common/Misc/BLM_FILE.c \
	Sources/Common/ObjectMngt/EXTI_Settings.c \
	Sources/Common/ObjectMngt/MemStgs.c \
	Sources/Common/ObjectMngt/mul_user.c \
	Sources/Common/ObjectMngt/BLM_ObjectsVersions.c \
	Sources/Common/ObjectMngt/BLM_ObjectTime.c \
	Sources/Common/ObjectMngt/BLM_ObjectIrMC.c \
	Sources/Common/Protocol/Uart_Bt.c \
	Sources/Common/Protocol/Uart_Bt_AT.c \
	Sources/Common/Protocol/uart_rt.c \
	Sources/Common/Protocol/Uart_Shared_AT.c \
	Sources/Common/Protocol/Bt_hcidump_tcp.c \
	Sources/Common/Protocol/Bt_hcidump_file.c \
	Sources/Common/Protocol/Blues_Log.c \
	Sources/Common/SoftwareUpdate/Bt_WinFOB.c \
	Sources/Common/SoftwareUpdate/Bt_IpUpdate.c \
	Sources/Common/Synchro/VParser/BLM_VCommon.c \
	Sources/Common/Synchro/VParser/BLM_VPropManager.c \
	Sources/Common/Synchro/VParser/BLM_VParser.c \
	Sources/Common/Synchro/VParser/BLM_VCard.c \
	Sources/Common/Synchro/VParser/BLM_VCalendar.c \
	Sources/Common/Synchro/VParser/BLM_ICalendar.c \
	Sources/Common/Synchro/VParser/BLM_VNote.c \
	Sources/Common/Synchro/VParser/BLM_IrMCDeviceInfo.c \
	Sources/Common/Synchro/VParser/BLM_IrMCInfoLog.c \
	Sources/Common/Synchro/VParser/BLM_IrMCChangeLog.c \
	Sources/Common/Synchro/VParser/BLM_IrMCChangeCounter.c \
	Sources/Common/Synchro/VParser/BLM_VSyncSettings.c \
	Sources/Common/Synchro/Method/BLM_ObexSync.c \
	Sources/Common/Synchro/Method/BLP_PBAP.c \
	Sources/Common/Synchro/Method/BLM_ATSync.c \
	Sources/Common/Synchro/Method/BLM_NokiaSync.c \
	Sources/Common/Synchro/Method/BLP_SyncML.c \
	Sources/Common/Synchro/Method/BLP_IrMCSync.c \
	Sources/Common/Synchro/Method/BLP_ObjectPush.c \
	Sources/Common/Synchro/Method/BLM_APPSync.c \
	Sources/Common/Synchro/Method/BLM_InternalCallHistorySync.c \
	Sources/Common/Synchro/BLT_Sync.c \
	Sources/Common/Synchro/BLM_Sync_API.c \
	Sources/Common/Synchro/BLM_Sync_Settings.c \
	Sources/Common/Synchro/BLM_Sync_MethodManager.c \
	Sources/Common/Synchro/BLT_Sync_ContactHandler.c \
	Sources/Common/Synchro/BLM_Sync_Performance.c \
	Sources/Common/Synchro/Bt_cardparser.c \
	Sources/Common/System/OS_Messages_generated.c \
	Sources/Common/System/Blues_Stop.c \
	Sources/Common/UserMngt/BLT_Pair_UserMngt.c \
	Sources/Common/UserMngt/BLT_PUM_MasterTable.c \
	Sources/Common/UserMngt/BLT_UserMngt_CMD.c \
	Sources/Common/UserMngt/BLT_UserMngt_EVT_BT_ACL.c \
	Sources/Common/UserMngt/BLT_UserMngt_EVT_BT.c \
	Sources/Common/UserMngt/BLT_UserMngt_EVT_BT_Pairing.c \
	Sources/Common/UserMngt/BLT_UserMngt_Init.c \
	Sources/Common/UserMngt/BLT_UserMngt_Cfg.c \
	Sources/Common/UserMngt/BLM_USER/BLM_USER.c \
	Sources/Common/UserMngt/Notification/BLT_PUM_Notification.c \
	Sources/Common/UserMngt/ServiceDiscovery/BLT_UserMngt_ServiceDiscovery.c \
	Sources/Common/UserMngt/TaskMngr/BLM_USER_TaskMngr.c \
	Sources/Common/Streaming/BLP_A2DP.c \
	Sources/Common/Streaming/BLP_AVDTP.c \
	Sources/Common/Streaming/BLM_AVDTP.c \
	Sources/Common/Streaming/BLP_AVRCP.c \
	Sources/Common/Streaming/BLT_Streaming.c \
	Sources/Common/Streaming/BLP_AVRCP_AC.c \
	Sources/Common/Streaming/BLP_AVRCP_Target.c \
	Sources/Common/Streaming/BLP_AVRCP_Target_FS.c \
	Sources/Common/Streaming/BLP_AVRCP_BWChannel.c \
	Sources/Common/Streaming/BLP_PVSP.c \
	Sources/Parrot5/System/Packstr2.c \
	Sources/Parrot5/System/Supervis.c \
	Sources/Parrot5/System/Uart_P5.c \
	Sources/Parrot5/ExtAPI/BLM_API.c \
	Sources/Parrot5/ExtAPI/BLT_API.c \
	Sources/Parrot5/ExtAPI/BLM_P4AB.c \
	Sources/Common/Messaging/BLM_SMS_pdu.c \
	Sources/Common/Messaging/BLM_SMS.c \
	Sources/Common/Messaging/BLT_SMS.c \
	Sources/Common/Messaging/BLT_MAP.c \
	Sources/Common/Messaging/BLP_MAP.c \
	Sources/Common/Messaging/BLP_MAP_MNS.c \
	Sources/Common/Messaging/BLM_MAP.c \
	Sources/Common/Messaging/BLM_MAP_SMS.c \
	Sources/Common/Messaging/BLM_MAP_MIME.c \
	Sources/Common/Messaging/BLM_MAP_DB.c \
	Sources/Common/Messaging/BLM_MAP_XML.c \
	Sources/Common/Messaging/BLM_MAP_Helpers.c \
	Sources/Common/Network/BLT_Network.c \
	Sources/Common/Network/BLP_BNEP.c \
	Sources/Common/Network/BLM_IP.c \
	Sources/Common/Network/Tests/BLT_Network_Test.c \
	Sources/SyncML/syncml.c \
	Sources/SyncML/syncml_encoder.c \
	Sources/SyncML/opaque.c \
	Sources/SyncML/wbxml/wbxml.tab.c \
	Sources/SyncML/wbxml/wbxml_lexer.c \
	Sources/SyncML/wbxml/wbxml_tag_decoder.c \
	Sources/Common/Messaging/Tests/BLT_MAP_Test.c \
	Sources/Common/Messaging/mime.c \
	Sources/Common/Messaging/decode.c \
	Sources/Common/Hid/BLP_HID.c \
	Sources/Common/Hid/libusbhid/descr.c \
	Sources/Common/Hid/libusbhid/parse.c \
	Sources/Common/Hid/libusbhid/data.c \
	Sources/Common/Hid/bthid/kbd.c \
	Sources/Common/PIM/BLM_PIM_Core.c \
	Sources/Common/PIM/BLM_PIM_DB_Init.c \
	Sources/Common/PIM/BLM_PIM_DB_Insertion.c \
	Sources/Common/PIM/BLM_PIM_DB_Extraction.c \
	Sources/Common/PIM/BLM_PIM_DB_Tools.c \
	Sources/Common/PIM/BLM_PIM_DB_Settings.c \
	Sources/Common/PIM/BLM_PIM_API_Private.c \
	Sources/Common/PIM/BLM_PIM_API.c \
	Sources/Common/PIM/BLM_PIM_Sql.c \
	Sources/Common/PIM/BLM_PIM_States.c \
	Sources/Common/PIM/BLM_PIM_Search.c \
	Sources/Common/PIM/BLM_PIM_Jobs.c \
	Sources/Common/PIM/BLM_PIM_Tests.c \
	Sources/Common/PIM/BLM_PIM_Debug.c \
	Sources/Common/Bip/BLM_BIP_XmlParser.c \
	Sources/Common/Bip/BLP_BIP_Initiator.c \
	Sources/Common/Bip/BLP_BIP.c \
	Sources/Common/Bip/BLP_BIP_Responder.c \
	Sources/Common/Bip/Tests/BLM_BIP_Responder_Test.c \
	Sources/Common/Bip/Tests/BLM_BIP_Initiator_Test.c \
	Sources/Common/Streaming/BLM_AVRCP_CoverArt.c \
	Sources/Common/Streaming/BLM_AVRCP_Browsing.c \
	Sources/Common/Streaming/BLM_AVRCP_Items.c \
	Sources/Common/RemoteUI/Resources/BLM_RUI_MiscUtils.c \
	Sources/Common/RemoteUI/Resources/BLM_RUI_GlobalIcons.c \
	Sources/Common/RemoteUI/Resources/BLM_RUI_FileChooser.c \
	Sources/Common/RemoteUI/Resources/BLM_RUI_TextDialog.c \
	Sources/Common/RemoteUI/Resources/BLM_RUI_ShiftGraph.c \
	Sources/Common/RemoteUI/Resources/BLM_RUI_Settings.c \
	Sources/Common/RemoteUI/Resources/BLM_RUI_CheckList.c \
	Sources/Common/RemoteUI/Resources/iniparser/iniparser.c \
	Sources/Common/RemoteUI/Resources/iniparser/dictionary.c \
	Sources/Common/RemoteUI/BLM_RUI.c \
	Sources/Common/RemoteUI/BLM_RUI_Pairing.c \
	Sources/Common/RemoteUI/BLM_RUI_User.c \
	Sources/Common/RemoteUI/BLM_RUI_User_Inquiry.c \
	Sources/Common/RemoteUI/BLM_RUI_User_Settings.c \
	Sources/Common/RemoteUI/BLM_RUI_Sync.c \
	Sources/Common/RemoteUI/BLM_RUI_PIM.c \
	Sources/Common/RemoteUI/BLM_RUI_PIM_Search.c \
	Sources/Common/RemoteUI/BLM_RUI_PIM_Update.c \
	Sources/Common/RemoteUI/BLM_RUI_Streaming.c \
	Sources/Common/RemoteUI/BLM_RUI_Streaming_Browsing.c \
	Sources/Common/RemoteUI/BLM_RUI_Streaming_CustomBWcommand.c \
	Sources/Common/RemoteUI/BLM_RUI_RFCOMM.c \
	Sources/Common/RemoteUI/BLM_RUI_HCI.c \
	Sources/Common/RemoteUI/BLM_RUI_Telephony.c \
	Sources/Common/RemoteUI/BLM_RUI_FTP_Client.c \
	Sources/Common/RemoteUI/BLM_RUI_TestSuite.c \
	Sources/Common/RemoteUI/BLM_RUI_L2CAP.c \
	Sources/Common/RemoteUI/BLM_RUI_OPP.c \
	Sources/Common/RemoteUI/BLM_RUI_MAP.c \
	Sources/Common/RemoteUI/BLM_RUI_FileReceive.c \
	Sources/Common/BTStack/Bt_SCO.c \
	Sources/XML/xml_parser.c \
	Sources/XML/xml_tree.c \

# $1 : xml file
# $2 : xsl file
# $3 : output file
# $4 : param name
# $5 : param value
ifneq ("$(shell which xalan)","")
blues-xml-transform = xalan -q -in $1 -xsl $2 -param $4 $5 > $3
else ifneq ("$(shell which xsltproc)","")
blues-xml-transform = xsltproc -param $4 $5 $2 $1 > $3
else
$(error xalan or xsltproc required)
endif

###############################################################################
# Rules to generate sdp file from xml.
###############################################################################

BLUES_SDP_XML_FILE := $(LOCAL_PATH)/Sources/Common/BTStack/SDP/Bt_SDP.xml
BLUES_SDP_XSL_FILE := $(LOCAL_PATH)/Build/sdp.xsl
BLUES_SDP_GENERATED := $(BLUES_BUILD_DIR)/include/Bt_SDP_generated.h

# Need to use a specific variable because LOCAL_PATH is not avialble in rule command
BLUES_SDP_M4_DIR := $(LOCAL_PATH)/Build

# Xsl requires strings between '', use "" to quote that in shell
$(BLUES_SDP_GENERATED): $(BLUES_SDP_XML_FILE)
	@echo "Generating Blues SDP file..."
	@mkdir -p $(dir $@)
	$(Q)$(call blues-xml-transform,$(BLUES_SDP_XML_FILE),$(BLUES_SDP_XSL_FILE), \
		$@.tmp,service,"'ALL'")
#	$(Q)xalan -q -in $(BLUES_SDP_XML_FILE) -xsl $(BLUES_SDP_XSL_FILE) \
#		-param service "'ALL'" > $@.tmp
	$(Q)m4 -I $(BLUES_SDP_M4_DIR) < $@.tmp > $@

###############################################################################
# Rules to generate msg file from xml.
###############################################################################

BLUES_MSG_XML_FILE := $(LOCAL_PATH)/Sources/Common/System/Bt_Blues_Msg.xml
BLUES_MSG_XSL_FILE := $(LOCAL_PATH)/Build/Blues_Msg.xsl
BLUES_MSG_DOX_H_GENERATED := $(LOCAL_PATH)/Sources/Common/System/Blues_Msgs_generated.dox.h
BLUES_MSG_C_GENERATED := $(LOCAL_PATH)/Sources/Common/System/Blues_Msgs_generated.ckcm.c
BLUES_MSG_OS_C_GENERATED := $(LOCAL_PATH)/Sources/Common/System/OS_Messages_generated.c
BLUES_MSG_H_GENERATED := $(BLUES_BUILD_DIR)/include/Blues_Msgs_generated.h

# Xsl requires strings between '', use "" to quote that in shell
$(BLUES_MSG_H_GENERATED): $(BLUES_MSG_XML_FILE) $(BLUES_MSG_XSL_FILE)
	@echo "Generating Blues MSG files..."
	@mkdir -p $(dir $@)
	$(Q)$(call blues-xml-transform,$(BLUES_MSG_XML_FILE),$(BLUES_MSG_XSL_FILE), \
		$(BLUES_MSG_DOX_H_GENERATED),modetogen,"'enumlist'")
	$(Q)$(call blues-xml-transform,$(BLUES_MSG_XML_FILE),$(BLUES_MSG_XSL_FILE), \
		$(BLUES_MSG_C_GENERATED),modetogen,"'OsMsgtablelist'")
	$(Q)$(call blues-xml-transform,$(BLUES_MSG_XML_FILE),$(BLUES_MSG_XSL_FILE), \
		$(BLUES_MSG_OS_C_GENERATED),modetogen,"'Classtablelist'")
#	$(Q)xalan -q -in $(BLUES_MSG_XML_FILE) -xsl $(BLUES_MSG_XSL_FILE) \
#		-param modetogen "'enumlist'" > $(BLUES_MSG_DOX_H_GENERATED)
#	$(Q)xalan -q -in $(BLUES_MSG_XML_FILE) -xsl $(BLUES_MSG_XSL_FILE) \
#		-param modetogen "'OsMsgtablelist'" > $(BLUES_MSG_C_GENERATED)
#	$(Q)xalan -q -in $(BLUES_MSG_XML_FILE) -xsl $(BLUES_MSG_XSL_FILE) \
#		-param modetogen "'Classtablelist'" > $(BLUES_MSG_OS_C_GENERATED)
	$(Q)cp -af $(BLUES_MSG_DOX_H_GENERATED) $(BLUES_MSG_H_GENERATED)

###############################################################################
# Rules to generate encrypted behaviour file.
###############################################################################

BLUES_BEHAVIOR_SRC_FILE := $(LOCAL_PATH)/Sources/Common/BTTelephony/ATDeviceId/behaviour.xml
BLUES_ENCRYPTION_SCRIPT := $(LOCAL_PATH)/Sources/Common/BTTelephony/ATDeviceId/encrypt_behavior.sh
BLUES_BEHAVIOR_ENCRYPTED_FILE := $(BLUES_BUILD_DIR)/include/encrypted_behavior.h
BLUES_ENCRYPT_AESKEY := $(CONFIG_BLUES_ENCRYPT_KEY)

#compute encryption type
ifdef CONFIG_BLUES_ENCRYPT_BEHAVIOR
  BLUES_ENCRYPTION_TYPE := 1
else
  BLUES_ENCRYPTION_TYPE := 0
endif

$(BLUES_BEHAVIOR_ENCRYPTED_FILE): $(BLUES_BEHAVIOR_SRC_FILE) $(BLUES_ENCRYPTION_SCRIPT)
	@echo "Generating Blues encrypted behavior file..."
	@mkdir -p $(dir $@)
	@$(BLUES_ENCRYPTION_SCRIPT) \
		$(BLUES_BEHAVIOR_SRC_FILE) \
		$(BLUES_BEHAVIOR_ENCRYPTED_FILE) \
		$(BLUES_ENCRYPTION_TYPE) \
		$(BLUES_ENCRYPT_AESKEY)

###############################################################################
###############################################################################

# Msg file is used externally
LOCAL_EXPORT_PREREQUISITES := \
	$(BLUES_MSG_H_GENERATED)

# Sdp file is only use internally
# Encrypted behaviour file is only use internally
LOCAL_PREREQUISITES := \
	$(BLUES_SDP_GENERATED) \
	$(BLUES_BEHAVIOR_ENCRYPTED_FILE)

LOCAL_LIBRARIES := \
	ckcm \
	soul \
	parrotdb \
	crypto-parrot \
	pal-utils \
	pal-drivers \
	pal-core

include $(BUILD_SHARED_LIBRARY)

