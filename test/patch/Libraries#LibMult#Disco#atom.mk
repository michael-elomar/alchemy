
LOCAL_PATH := $(call my-dir)

###############################################################################
# Disco
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := disco
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := build/ConfigDiscoSet.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/include

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/src \
	$(LOCAL_PATH)/src \
	$(LOCAL_PATH)/src/bsm \
	$(LOCAL_PATH)/src/bsm/pdb \
	$(LOCAL_PATH)/src/bsm/feeder \
	$(LOCAL_PATH)/src/bsm/id3 \
	$(LOCAL_PATH)/src/bsm/ogg \
	$(LOCAL_PATH)/src/bsm/flac \
	$(LOCAL_PATH)/src/bsm/m4a \
	$(LOCAL_PATH)/src/bsm/asf \
	$(LOCAL_PATH)/src/bsm/wav \
	$(LOCAL_PATH)/src/bsm/plist \
	$(LOCAL_PATH)/src/bsm/stream \
	$(LOCAL_PATH)/src/bsm/startlist \
	$(LOCAL_PATH)/src/mtp \
	$(LOCAL_PATH)/src/mtp/pdb \
	$(LOCAL_PATH)/src/mtp/feeder \
	$(LOCAL_PATH)/src/mtp/mtplib \
	$(LOCAL_PATH)/src/mtp/mtplib/pal \
	$(LOCAL_PATH)/src/mtp/mtplib/ecos \
	$(LOCAL_PATH)/src/mtp/plist \
	$(LOCAL_PATH)/src/mtp/stream \
	$(LOCAL_PATH)/src/mtp/startlist \
	$(LOCAL_PATH)/src/utf8 \
	$(LOCAL_PATH)/src/os \
	$(LOCAL_PATH)/src/os/pal \
	$(LOCAL_PATH)/src/dbmng \
	$(LOCAL_PATH)/src/avrcp \
	$(LOCAL_PATH)/src/dcodb \
	$(LOCAL_PATH)/src/dcodb/feeder \
	$(LOCAL_PATH)/src/dcodb/gdi \
	$(LOCAL_PATH)/src/iAP \
	$(LOCAL_PATH)/src/tools

LOCAL_CFLAGS := \
	-DDISCO_DONT_USE_IPOD_MASS_STORAGE

ifdef CONFIG_DISCO_OPT_SOUL_DEPENDENCY
LOCAL_CFLAGS += \
	-DDISCO_OPT_SOUL_DEPENDENCY_TO_REMOVE_LATIN_ACCENT
endif

###############################################################################
###############################################################################

DISCO_SRC_FILES_BSM := \
	src/bsm_dbgmem.c \
	src/bsm/libbsm.c \
	src/bsm/bsm_image.c \
	src/bsm/bsm_tag.c \
	src/bsm/bsm_devinfo.c \
	src/bsm/pdb/bsm_song.c \
	src/bsm/pdb/bsm_file.c \
	src/bsm/pdb/bsm_plist.c \
	src/bsm/pdb/bsm_search.c \
	src/bsm/pdb/bsm_dbcheck.c \
	src/bsm/pdb/bsm_freesize.c \
	src/bsm/feeder/feeder_get.c \
	src/bsm/id3/id3_v1.c \
	src/bsm/id3/id3_v2.c \
	src/bsm/id3/id3tag.c \
	src/bsm/id3/id3_genre.c \
	src/bsm/ogg/bsm_ogg.c \
	src/bsm/flac/bsm_flac.c \
	src/bsm/m4a/m4a.c \
	src/bsm/asf/asf.c \
	src/bsm/wav/wav.c \
	src/bsm/plist/asx.cpp \
	src/bsm/plist/b4s.cpp \
	src/bsm/plist/m3u.c \
	src/bsm/plist/pls.c \
	src/bsm/plist/wpl.c \
	src/bsm/plist/xml.cpp \
	src/bsm/plist/plfile.c \
	src/bsm/stream/bsm_stream.c \
	src/bsm/startlist/bsm_startlist.c

###############################################################################
###############################################################################

DISCO_SRC_FILES_MTP := \
	src/mtp/libmtp.c \
	src/mtp/mtp_host.c \
	src/mtp/mtp_devices.c \
	src/mtp/mtp_devinfo.c \
	src/mtp/mtp_test_ctl.c \
	src/mtp/pdb/mtp_song.c \
	src/mtp/pdb/mtp_file.c \
	src/mtp/pdb/mtp_plist.c \
	src/mtp/pdb/mtp_search.c \
	src/mtp/pdb/mtp_dbcheck.c \
	src/mtp/pdb/mtp_freesize.c \
	src/mtp/feeder/mtp_feeder_get.c \
	src/mtp/plist/mtp_plfile.c \
	src/mtp/plist/mtp_abstractpls.c \
	src/mtp/stream/mtp_stream.c \
	src/mtp/mtplib/buffer.c \
	src/mtp/mtplib/mtp_debug.c \
	src/mtp/mtplib/misc.c \
	src/mtp/mtplib/mtp_api.c \
	src/mtp/mtplib/mtp_datasets.c \
	src/mtp/mtplib/mtp_playback.c \
	src/mtp/mtplib/mtp_result.c \
	src/mtp/mtplib/parsinghelpers.c \
	src/mtp/mtplib/variant.c \
	src/mtp/mtplib/transport.c \
	src/mtp/mtplib/mtp_wchar.c \
	src/mtp/mtplib/mtp_str_const.c \
	src/mtp/startlist/mtp_startlist.c

ifdef CONFIG_DISCO_ENABLE_MTP
ifdef CONFIG_DISCO_WMDRM_10_NETWORK_DEVICE_RECEIVER_SUPPORT
DISCO_SRC_FILES_MTP := \
	src/mtp/mtp_wmdrm_ndr.c
endif
endif

###############################################################################
###############################################################################

DISCO_SRC_FILES_IPOD_IAP := \
	src/iAP/iPod_iAP_api.c \
	src/iAP/iPod_iAP_acid.c

ifdef CONFIG_DISCO_ENABLE_GRACENOTE
ifdef CONFIG_DISCO_OPT_PARTIAL_SYNC
ifdef CONFIG_DISCO_ENABLE_IPOD_IAP
DISCO_SRC_FILES_IPOD_IAP += \
	src/iAP/iPod_iAP_db.c \
	src/iAP/iPod_iAP_song.c
endif
endif
endif

###############################################################################
###############################################################################

DISCO_SRC_FILES_DBMNG := \
	src/dbmng/disco_dbmng.c

###############################################################################
###############################################################################

DISCO_SRC_FILES_DCODB := \
	src/dcodb/dcodb_cache.c \
	src/dcodb/dcodb_db.c \
	src/dcodb/dcodb_dbsize.c \
	src/dcodb/dcodb_dirlist.c \
	src/dcodb/dcodb_file.c \
	src/dcodb/dcodb_filelist.c \
	src/dcodb/dcodb_id.c \
	src/dcodb/dcodb_init.c \
	src/dcodb/dcodb_item_search.c \
	src/dcodb/dcodb_list.c \
	src/dcodb/dcodb_list_inval.c \
	src/dcodb/dcodb_path.c \
	src/dcodb/dcodb_plistlist.c \
	src/dcodb/dcodb_sort.c \
	src/dcodb/dcodb_sort_dirfilter.c \
	src/dcodb/dcodb_status.c \
	src/dcodb/dcodb_store.c \
	src/dcodb/dcodb_store_xfer.c \
	src/dcodb/dcodb_string.c \
	src/dcodb/dcodb_stab.c \
	src/dcodb/dcodb_plist.c \
	src/dcodb/dcodb_song.c \
	src/dcodb/feeder/dcodb_feeder.c \
	src/dcodb/feeder/dcodb_feeder_get.c \
	src/dcodb/feeder/dcodb_feeder_set.c \
	src/dcodb/dcodb_tag.c \
	src/dcodb/dcodb_info.c

###############################################################################
###############################################################################
DISCO_SRC_FILES_AVRCP := \
	src/avrcp/libavrcp.c \
	src/avrcp/libavrcp_reception.c \
	src/avrcp/libavrcp_device_mngt.c \
	src/avrcp/libavrcp_api.c \
	src/avrcp/libavrcp_control.c \
	src/avrcp/libavrcp_status.c \
	src/avrcp/libavrcp_notify.c \
	src/avrcp/libavrcp_browsing.c

###############################################################################
###############################################################################

LOCAL_SRC_FILES := \
	src/libdisco.c \
	src/os/pal/disco_pal_core.c \
	src/disco_stream.c \
	src/disco_id.c \
	src/disco_err.c \
	src/disco_search_uid.c \
	src/disco_store.c \
	src/disco_item_search.c \
	src/disco_test_ctl.c \
	src/utf8/utf8.c \
	src/utf8/disco_find_charset.c \
	src/utf8/disco_htmlchar.c \
	src/tools/disco_tools_mem.c \
	src/os/pal/disco_pal_fs.c

LOCAL_SRC_FILES += \
	$(DISCO_SRC_FILES_DCODB) \
	$(DISCO_SRC_FILES_DBMNG)

ifdef CONFIG_DISCO_ENABLE_MTP
LOCAL_SRC_FILES += \
	src/mtp/mtplib/pal/pal_transport_usb.c
endif

ifdef CONFIG_DISCO_ENABLE_BSM
LOCAL_SRC_FILES += \
	$(DISCO_SRC_FILES_BSM)   
else
LOCAL_CFLAGS += \
	-DDISCO_DONT_USE_BSM
endif

ifdef CONFIG_DISCO_ENABLE_MTP
LOCAL_SRC_FILES += \
	$(DISCO_SRC_FILES_MTP)     
else
LOCAL_CFLAGS += \
	-DDISCO_DONT_USE_MTP
endif

ifdef CONFIG_DISCO_ENABLE_IPOD_IAP
LOCAL_SRC_FILES += \
	$(DISCO_SRC_FILES_IPOD_IAP)
else
LOCAL_CFLAGS += \
	-DDISCO_DONT_USE_IAP
endif

ifdef CONFIG_DISCO_ENABLE_AVRCP
LOCAL_SRC_FILES += \
	$(DISCO_SRC_FILES_AVRCP)
endif

###############################################################################
###############################################################################

ifdef CONFIG_DISCO_ENABLE_GRACENOTE

ifndef CONFIG_DISCO_OPT_GRACENOTE_RECO_TEST
  LOCAL_LDLIBS += -L$(LOCAL_PATH)/external/gracenote/lib
  ifeq ("$(TARGET_ARCH)","arm")
    LOCAL_LDLIBS += -lemmslib_arm
  else ifeq ("$(TARGET_ARCH)","x86")
    LOCAL_LDLIBS += -lemmslib_i386
  else
    $(error unsupported architecture)
  endif
endif

LOCAL_C_INCLUDES += \
	$(LOCAL_PATH)/external/gracenote \
	$(LOCAL_PATH)/external/gracenote/include \
	$(LOCAL_PATH)/external/gracenote/abstract_layer \
	$(LOCAL_PATH)/external/gracenote/abstract_layer/include \
	$(LOCAL_PATH)/external/gracenote/abstract_layer/linux \
	$(LOCAL_PATH)/external/gracenote/abstract_layer/memmgr \
	$(LOCAL_PATH)/external/gracenote/abstract_layer/shared

ifdef CONFIG_DISCO_OPT_GRACENOTE_RECO_TEST
LOCAL_CFLAGS += \
	-DDISCO_OPT_GRACENOTE_TEST
endif

DISCO_SRC_FILES_GRACENOTE_GDI := \
	src/dcodb/dcodb_trans.c \
	src/dcodb/dcodb_orth.c \
	src/dcodb/gdi/dcodb_gdi.c \
	src/dcodb/gdi/dcodb_gdi_speech.c \
	src/dcodb/gdi/dcodb_path_parser.c \
	src/disco_gn_lookup.c \

ifndef CONFIG_DISCO_OPT_GRACENOTE_RECO_TEST
DISCO_SRC_FILES_GRACENOTE_GDI += \
	src/dcodb/gdi/dcodb_gdi_validation.c
endif

LOCAL_SRC_FILES += \
	$(DISCO_SRC_FILES_GRACENOTE_GDI)

endif

###############################################################################
###############################################################################

LOCAL_LIBRARIES := \
	soul \
	blues \
	tala \
	acid \
	tinyxml \
	pal-utils \
	pal-devs \
	pal-drivers \
	pal-core

ifdef CONFIG_DISCO_ENABLE_GRACENOTE
LOCAL_LIBRARIES += disco-gn-abstract_layer
endif

ifeq ("$(TARGET_OS)","linux")
LOCAL_LIBRARIES += libusb
endif

include $(BUILD_SHARED_LIBRARY)

###############################################################################
###############################################################################

ifdef CONFIG_DISCO_ENABLE_GRACENOTE

include $(CLEAR_VARS)

LOCAL_MODULE := disco-gn-abstract_layer
LOCAL_FORCE_WHOLE_STATIC_LIBRARY := 1

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/external/gracenote \
	$(LOCAL_PATH)/external/gracenote/include \
	$(LOCAL_PATH)/external/gracenote/abstract_layer \
	$(LOCAL_PATH)/external/gracenote/abstract_layer/include \
	$(LOCAL_PATH)/external/gracenote/abstract_layer/linux \
	$(LOCAL_PATH)/external/gracenote/abstract_layer/memmgr \
	$(LOCAL_PATH)/external/gracenote/abstract_layer/shared

LOCAL_SRC_FILES := \
	external/gracenote/abstract_layer/shared/gn_abs_version.c \
	external/gracenote/abstract_layer/linux/gn_abs_version_platspec.c \
	external/gracenote/abstract_layer/linux/gn_bdfs.c \
	external/gracenote/abstract_layer/linux/gn_string.c \
	external/gracenote/abstract_layer/linux/gn_math.c \
	external/gracenote/abstract_layer/linux/gn_time.c \
	external/gracenote/abstract_layer/linux/gn_comm_native.c \
	external/gracenote/abstract_layer/linux/gn_ctype.c \
	external/gracenote/abstract_layer/linux/gn_wctype.c \
	external/gracenote/abstract_layer/linux/gn_device_id.c \
	external/gracenote/abstract_layer/linux/gn_dvdfs.c \
	external/gracenote/abstract_layer/linux/gn_stdio.c \
	external/gracenote/abstract_layer/linux/gn_fs.c \
	external/gracenote/abstract_layer/linux/gn_stdlib.c \
	external/gracenote/abstract_layer/linux/gn_memory.c \

include $(BUILD_STATIC_LIBRARY)

endif

