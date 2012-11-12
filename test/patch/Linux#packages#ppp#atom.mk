
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := ppp

LOCAL_AUTOTOOLS_VERSION := 2.4.5
LOCAL_AUTOTOOLS_ARCHIVE := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_DIR := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION)

LOCAL_AUTOTOOLS_PATCHES := \
	commit-3eb9e81.patch

LOCAL_AUTOTOOLS_CMD_POST_CONFIGURE := ppp-cmd-post-configure
LOCAL_AUTOTOOLS_CMD_BUILD := ppp-cmd-build
LOCAL_AUTOTOOLS_CMD_INSTALL := ppp-cmd-install
LOCAL_AUTOTOOLS_CMD_CLEAN := ppp-cmd-clean

ppp-cmd-post-configure = \
	sed -i -e 's/ -DIPX_CHANGE -DHAVE_MMAP//' $(PRIVATE_SRC_DIR)/pppd/Makefile; \
	sed -i -e 's/HAVE_MULTILINK=y/\#HAVE_MULTILINK=y/' $(PRIVATE_SRC_DIR)/pppd/Makefile; \
	sed -i -e 's/FILTER=y/\#FILTER=y/' $(PRIVATE_SRC_DIR)/pppd/Makefile; \
	sed -i -e 's,(INSTALL) -s,(INSTALL) -p,' $(PRIVATE_SRC_DIR)/*/Makefile; \
	sed -i -e 's,(INSTALL) -s,(INSTALL) -p,' $(PRIVATE_SRC_DIR)/pppd/plugins/*/Makefile

ppp-cmd-build = \
	$(AUTOTOOLS_CONFIGURE_ENV) $(AUTOTOOLS_MAKE_ENV) $(MAKE) \
		$(AUTOTOOLS_MAKE_ARGS) -C $(PRIVATE_SRC_DIR) \
		COPTS="$(TARGET_GLOBAL_CFLAGS)"

ppp-cmd-install = \
	$(AUTOTOOLS_CONFIGURE_ENV) $(AUTOTOOLS_MAKE_ENV) $(MAKE) \
		$(AUTOTOOLS_MAKE_ARGS) -C $(PRIVATE_SRC_DIR) \
		DESTDIR=$(TARGET_OUT_STAGING)/usr install

ppp-cmd-clean = \
	if [ -d $(PRIVATE_SRC_DIR) ]; then \
		$(AUTOTOOLS_CONFIGURE_ENV) $(AUTOTOOLS_MAKE_ENV) $(MAKE) \
			$(AUTOTOOLS_MAKE_ARGS) -C $(PRIVATE_SRC_DIR) clean \
		|| echo "Ignoring clean errors"; \
	fi; \
	rm -rf $(TARGET_OUT_STAGING)/usr/include/pppd; \
	rm -rf $(TARGET_OUT_STAGING)/usr/lib/pppd/2.4.5; \
	rm -f $(TARGET_OUT_STAGING)/usr/sbin/chat; \
	rm -f $(TARGET_OUT_STAGING)/usr/sbin/pppoe-discovery; \
	rm -f $(TARGET_OUT_STAGING)/usr/sbin/pppd; \
	rm -f $(TARGET_OUT_STAGING)/usr/sbin/pppstats; \
	rm -f $(TARGET_OUT_STAGING)/usr/sbin/pppdump; \
	rm -f $(TARGET_OUT_STAGING)/usr/share/man/man8/chat.8; \
	rm -f $(TARGET_OUT_STAGING)/usr/share/man/man8/pppd-radius.8; \
	rm -f $(TARGET_OUT_STAGING)/usr/share/man/man8/pppd-radattr.8; \
	rm -f $(TARGET_OUT_STAGING)/usr/share/man/man8/pppd.8; \
	rm -f $(TARGET_OUT_STAGING)/usr/share/man/man8/pppstats.8; \
	rm -f $(TARGET_OUT_STAGING)/usr/share/man/man8/pppdump.8

include $(BUILD_AUTOTOOLS)

