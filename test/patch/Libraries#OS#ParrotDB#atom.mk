
LOCAL_PATH := $(call my-dir)

###############################################################################
# ParrotDB
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := parrotdb
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := Build/ConfigParrotDB.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/include \
	$(LOCAL_PATH)/include/sqlite3

LOCAL_EXPORT_CFLAGS :=

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS := \
	-D__USE_ANSI_C__ \
	-DSQLITE_THREADSAFE=1 \
	-DSQLITE_THREAD_OVERRIDE_LOCK=0 \
	-DSQLITE_OMIT_LOAD_EXTENSION=1 \
	-DSQLITE_ENABLE_UPDATE_DELETE_LIMIT

ifeq ("$(TARGET_OS)","linux")
  LOCAL_CFLAGS += -DSQLITE_OS_UNIX=1
else ifeq ("$(TARGET_OS)","ecos")
  LOCAL_CFLAGS += -DSQLITE_OS_OTHER=1 -DSQLITE_MUTEX_APPDEF=1 -D__ECOS__
endif


LOCAL_SRC_FILES := \
	src/sqlite/sqlite3_tools.c \
	src/flamenco/flamenco_db.c \
	src/flamenco/flamenco_versions.c \
	src/flamenco/flamenco_training.c \
	src/sqlite/sqlite3.c

LOCAL_LIBRARIES := pal-utils pal-core

include $(BUILD_SHARED_LIBRARY)

