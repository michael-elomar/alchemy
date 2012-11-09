
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := util-linux-ng

LOCAL_AUTOTOOLS_VERSION := 2.17.1
LOCAL_AUTOTOOLS_ARCHIVE := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_DIR := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION)

ifeq ("$(TARGET_LIBC)","bionic")

LOCAL_AUTOTOOLS_PATCHES := \
	lucie/raptor.diff \

LOCAL_AUTOTOOLS_MAKE_BUILD_ENV := \
	$(AUTOTOOLS_CONFIGURE_ENV)

LOCAL_AUTOTOOLS_MAKE_BUILD_ARGS := \
	RAPTOR_DIR=$(RAPTOR_DIR) \
	BUILD_DIR=. \
	INSTALL_DIR=$(TARGET_OUT_STAGING) \
	TARGET_DIR=$(TARGET_OUT_STAGING) \
	build

LOCAL_AUTOTOOLS_CMD_CONFIGURE := ulng-cmd-configure
LOCAL_AUTOTOOLS_CMD_POST_CONFIGURE := ulng-cmd-post-configure
LOCAL_AUTOTOOLS_CMD_INSTALL := ulng-cmd-install
LOCAL_AUTOTOOLS_CMD_POST_CLEAN := ulng-cmd-post-clean

ulng-cmd-configure = $(empty)

ulng-cmd-post-configure = \
	cp -af $(PRIVATE_PATH)/config.h $(PRIVATE_SRC_DIR); \
	date=$$(grep LIBBLKID_DATE $(PRIVATE_SRC_DIR)/config.h | cut -f3 -d' '); \
	sed "s;^\#define BLKID_DATE.*;\#define BLKID_DATE $$date;" \
		$(PRIVATE_SRC_DIR)/shlibs/blkid/src/blkid.h.in > \
		$(PRIVATE_SRC_DIR)/shlibs/blkid/src/blkid.h; \
	vers=$$(grep LIBBLKID_VERSION $(PRIVATE_SRC_DIR)/config.h | cut -f3 -d' '); \
	sed -i "s;^\#define BLKID_VERSION.*;\#define BLKID_VERSION $$date;" \
		$(PRIVATE_SRC_DIR)/shlibs/blkid/src/blkid.h; \
	cp -af $(PRIVATE_PATH)/lucie/raptor_Makefile $(PRIVATE_SRC_DIR)/Makefile

ulng-cmd-install = \
	install -p -m755 -d $(TARGET_OUT_STAGING)/sbin; \
	install -p -m755 $(PRIVATE_SRC_DIR)/blkid-ng $(TARGET_OUT_STAGING)/sbin

ulng-cmd-post-clean = \
	rm -f $(TARGET_OUT_STAGING)/lib/libuuid.a; \
	rm -f $(TARGET_OUT_STAGING)/lib/libblkid.a; \
	rm -rf $(TARGET_OUT_STAGING)/include/uuid; \
	rm -rf $(TARGET_OUT_STAGING)/include/blkid; \
	rm -f $(TARGET_OUT_STAGING)/sbin/blkid-ng

else

LOCAL_AUTOTOOLS_CONFIGURE_ARGS := \
	--disable-rpath \
	--disable-uuidd \
	--disable-agetty \
	--disable-cramfs \
	--disable-switch_root \
	--disable-pivot_root \
	--disable-fallocate \
	--disable-unshare \
	--disable-rename \
	--disable-wall \
	--without-ncurses

LOCAL_AUTOTOOLS_CMD_BUILD := ulng-cmd-build
LOCAL_AUTOTOOLS_CMD_INSTALL := ulng-cmd-install
LOCAL_AUTOTOOLS_CMD_CLEAN := ulng-cmd-clean

ulng-cmd-build = \
	$(AUTOTOOLS_MAKE_ENV) $(MAKE) $(AUTOTOOLS_MAKE_ARGS) \
		-C $(PRIVATE_SRC_DIR)/shlibs; \
	$(AUTOTOOLS_MAKE_ENV) $(MAKE) $(AUTOTOOLS_MAKE_ARGS) \
		-C $(PRIVATE_SRC_DIR)/misc-utils blkid

ulng-cmd-install = \
	$(AUTOTOOLS_MAKE_ENV) $(MAKE) $(AUTOTOOLS_MAKE_ARGS) \
		-C $(PRIVATE_SRC_DIR)/shlibs install; \
	$(AUTOTOOLS_MAKE_ENV) $(MAKE) $(AUTOTOOLS_MAKE_ARGS) \
		-C $(PRIVATE_SRC_DIR)/misc-utils blkid install; \
	install -p -m755 -d $(TARGET_OUT_STAGING)/sbin; \
	install -p -m755 $(PRIVATE_SRC_DIR)/misc-utils/.libs/blkid $(TARGET_OUT_STAGING)/sbin/blkid-ng

ulng-cmd-clean = \
	if [ -d $(PRIVATE_SRC_DIR) ]; then \
		$(AUTOTOOLS_MAKE_ENV) $(MAKE) $(AUTOTOOLS_MAKE_ARGS) \
			-C $(PRIVATE_SRC_DIR)/shlibs uninstall || true; \
		$(AUTOTOOLS_MAKE_ENV) $(MAKE) $(AUTOTOOLS_MAKE_ARGS) \
			-C $(PRIVATE_SRC_DIR)/shlibs clean || true; \
		$(AUTOTOOLS_MAKE_ENV) $(MAKE) $(AUTOTOOLS_MAKE_ARGS) \
			-C $(PRIVATE_SRC_DIR)/misc-utils uninstall || true; \
		$(AUTOTOOLS_MAKE_ENV) $(MAKE) $(AUTOTOOLS_MAKE_ARGS) \
			-C $(PRIVATE_SRC_DIR)/misc-utils clean || true; \
	fi; \
	rm -f $(TARGET_OUT_STAGING)/sbin/blkid-ng

endif

include $(BUILD_AUTOTOOLS)

