
LOCAL_PATH := $(call my-dir)

# Not with bionic
ifneq ("$(TARGET_LIBC)","bionic")

###############################################################################
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := wpa_supplicant

LOCAL_EXPORT_LDLIBS := -lwpa_cli

LOCAL_AUTOTOOLS_VERSION := 0.6.9
LOCAL_AUTOTOOLS_ARCHIVE := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_DIR := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION)

LOCAL_AUTOTOOLS_CMD_CONFIGURE := wpa_supplicant-cmd-configure
LOCAL_AUTOTOOLS_CMD_BUILD := wpa_supplicant-cmd-build
LOCAL_AUTOTOOLS_CMD_INSTALL := wpa_supplicant-cmd-install
LOCAL_AUTOTOOLS_CMD_CLEAN := wpa_supplicant-cmd-clean

wpa_supplicant-cmd-configure = \
	$(BUILD_SYSTEM)/scripts/apply-patches.sh $(PRIVATE_SRC_DIR)/wpa_supplicant $(PRIVATE_PATH)/lucie \*.patch; \
	cp -af $(PRIVATE_PATH)/config $(PRIVATE_SRC_DIR)/wpa_supplicant/.config

# Use AUTOTOOLS_CONFIGURE_ENV because no real configure has been done
wpa_supplicant-cmd-build = \
	$(AUTOTOOLS_CONFIGURE_ENV) $(MAKE) $(AUTOTOOLS_MAKE_ARGS) \
		-C $(PRIVATE_SRC_DIR)/wpa_supplicant \
		CC=$(TARGET_CC)

# Use AUTOTOOLS_CONFIGURE_ENV because no real configure has been done
wpa_supplicant-cmd-install = \
	$(AUTOTOOLS_CONFIGURE_ENV) $(MAKE) $(AUTOTOOLS_MAKE_ARGS) \
		-C $(PRIVATE_SRC_DIR)/wpa_supplicant \
		CC=$(TARGET_CC) DESTDIR=$(TARGET_OUT_STAGING) BINDIR=/usr/sbin install

wpa_supplicant-cmd-clean = \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/libwpa_cli.so; \
	rm -f $(TARGET_OUT_STAGING)/usr/sbin/wpa_cli; \
	rm -f $(TARGET_OUT_STAGING)/usr/sbin/wpa_passphrase; \
	rm -f $(TARGET_OUT_STAGING)/usr/sbin/wpa_supplicant

LOCAL_LIBRARIES := libcrypto

include $(BUILD_AUTOTOOLS)

endif

