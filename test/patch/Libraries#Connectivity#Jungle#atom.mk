
LOCAL_PATH := $(call my-dir)

###############################################################################
# Concertos
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := jungle
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := Build/ConfigUpnpSet.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/api

LOCAL_EXPORT_CFLAGS := \
	-DUSE_UPNP

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Sources/api \
	$(LOCAL_PATH)/Sources/device \
	$(LOCAL_PATH)/Sources/ixml \
	$(LOCAL_PATH)/Sources/threadutil \
	$(LOCAL_PATH)/Sources/upnp \
	$(LOCAL_PATH)/Sources/upnp/api \
	$(LOCAL_PATH)/Sources/upnp/gena \
	$(LOCAL_PATH)/Sources/upnp/network \
	$(LOCAL_PATH)/Sources/upnp/soap \
	$(LOCAL_PATH)/Sources/upnp/ssdp \
	$(LOCAL_PATH)/Sources/upnp/tools \
	$(LOCAL_PATH)/Sources/upnp/urlconfig \
	$(LOCAL_PATH)/Sources/upnp/uuid \
	$(LOCAL_PATH)/Sources/shoutcast

LOCAL_CFLAGS := \
	-D_GNU_SOURCE \
	-DTRACE=0 \
	-DSITE_TYPEDEFS

LOCAL_SRC_FILES := \
	Sources/device/upnp_avfmt.c \
	Sources/device/upnp_avfmt_mp3.c \
	Sources/device/upnp_avfmt_wma.c \
	Sources/device/upnp_avfmt_lpcm.c \
	Sources/device/upnp_avfmt_sbc.c \
	Sources/device/upnp_avfmt_tools.c \
	Sources/device/upnp_dev_tools.c \
	Sources/ixml/attr.c \
	Sources/ixml/document.c \
	Sources/ixml/element.c \
	Sources/ixml/ixml.c \
	Sources/ixml/ixmlmembuf.c \
	Sources/ixml/ixmlparser.c \
	Sources/ixml/namedNodeMap.c \
	Sources/ixml/node.c \
	Sources/ixml/nodeList.c \
	Sources/threadutil/FreeList.c \
	Sources/threadutil/iasnprintf.c \
	Sources/threadutil/ithread.c \
	Sources/threadutil/LinkedList.c \
	Sources/threadutil/ThreadPool.c \
	Sources/threadutil/TimerThread.c \
	Sources/upnp/api/upnpapi.c \
	Sources/upnp/api/upnpdebug.c \
	Sources/upnp/api/upnpmedia.c \
	Sources/upnp/api/upnptools.c \
	Sources/upnp/gena/gena_callback2.c \
	Sources/upnp/gena/gena_ctrlpt.c \
	Sources/upnp/gena/gena_device.c \
	Sources/upnp/network/client_table.c \
	Sources/upnp/network/httpparser.c \
	Sources/upnp/network/httpreadwrite.c \
	Sources/upnp/network/membuffer.c \
	Sources/upnp/network/miniserver.c \
	Sources/upnp/network/service_table.c \
	Sources/upnp/network/sock.c \
	Sources/upnp/network/upnp_timeout.c \
	Sources/upnp/network/uri.c \
	Sources/upnp/network/webclient.c \
	Sources/upnp/network/webserver.c \
	Sources/upnp/network/rtpserver.c \
	Sources/upnp/soap/soap_common.c \
	Sources/upnp/soap/soap_ctrlpt.c \
	Sources/upnp/soap/soap_device.c \
	Sources/upnp/ssdp/ssdp_ctrlpt.c \
	Sources/upnp/ssdp/ssdp_device.c \
	Sources/upnp/ssdp/ssdp_server.c \
	Sources/upnp/tools/auth.c \
	Sources/upnp/tools/parsetools.c \
	Sources/upnp/tools/statcodes.c \
	Sources/upnp/tools/strintmap.c \
	Sources/upnp/tools/util.c \
	Sources/upnp/urlconfig/urlconfig.c \
	Sources/upnp/uuid/sysdep.c \
	Sources/upnp/uuid/uuid.c \
	Sources/shoutcast/shoutcast.c \
	Sources/api/upnp_bot_playfold.c \
	Sources/api/upnp_ctrl_web.c \
	Sources/api/upnp_ctrl_api.c \
	Sources/api/upnp_dn_api.c \
	Sources/device/upnp_ctrl_client.c \
	Sources/device/upnp_ctrl_cmdline.c \
	Sources/device/upnp_ctrl_rdr.c \
	Sources/device/upnp_ctrl_tree.c \
	Sources/device/upnp_ctrl_core.c \
	Sources/device/upnp_ctrl_actions.c \
	Sources/device/upnp_tools_fsdesc.c \
	Sources/api/upnp_rdr_api.c \
	Sources/device/upnp_rdr_core.c \
	Sources/device/upnp_serv_avtransp.c \
	Sources/device/upnp_serv_conmgt.c \
	Sources/device/upnp_serv_renctrl.c \
	Sources/device/upnp_serv_vscrx.c

LOCAL_LIBRARIES := pal-utils pal-core

include $(BUILD_SHARED_LIBRARY)

