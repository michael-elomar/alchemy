
LOCAL_PATH := $(call my-dir)

###############################################################################
# Soul
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := soul
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := Build/ConfigSoulSet.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/Export

LOCAL_EXPORT_CFLAGS := \
	-DUSE_SOUL

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Sources \
	$(LOCAL_PATH)/Sources/Charset \
	$(LOCAL_PATH)/Sources/Task

LOCAL_CFLAGS :=

ifdef CONFIG_SOUL_OPT_LATIN_IPOD_SORTING_FIX
LOCAL_CFLAGS += -DSOUL_OPT_ENABLE_LATIN_IPOD_SORTING_FCTS
endif

LOCAL_SRC_FILES := \
	Sources/Charset/SOUL_Charset.c \
	Sources/Charset/SOUL_Charset_GB2312Conv.c \
	Sources/Charset/SOUL_Charset_GB18030Conv.c \
	Sources/Charset/SOUL_Charset_KS_C_5601_1987.c \
	Sources/Charset/SOUL_Charset_ShiftJISConv.c \
	Sources/Charset/SOUL_Charset_UTF8Sort.c \
	Sources/Charset/SOUL_Charset_UTF8Mngt.c \
	Sources/Charset/SOUL_Charset_SortingArrays.c \
	Sources/Charset/SOUL_Charset_8859_5Conv.c \
	Sources/Charset/SOUL_Charset_8859_6Conv.c \
	Sources/Charset/SOUL_Charset_8859_7Conv.c \
	Sources/Charset/SOUL_Charset_8859_8Conv.c \
	Sources/Charset/SOUL_Charset_8859_9Conv.c \
	Sources/Charset/SOUL_Charset_UTF8CaseFolding.c \
	Sources/Task/SOUL_Task.c \
	Sources/SOUL_os.c \
	Sources/SOUL_Mngt.c \
	Sources/SOUL_String.c \
	Sources/SOUL_ResourceMngt.c \
	Sources/SOUL_AudioMngt.c \
	Sources/SOUL_TextMngt.c \
	Sources/SOUL_FilesMngt.c \
	Sources/SOUL_IO.c \
	Sources/Charset/SOUL_Charset_SortingArray_PinYin.c \
	Sources/Charset/SOUL_Charset_UTF8StrArray_PinYin.c

LOCAL_LIBRARIES := pal-utils pal-core

include $(BUILD_SHARED_LIBRARY)

