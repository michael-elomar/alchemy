
LOCAL_PATH := $(call my-dir)

# Not with bionic
ifneq ("$(TARGET_LIBC)","bionic")

include $(CLEAR_VARS)

LOCAL_MODULE := libcrypto

LOCAL_EXPORT_LDLIBS := -lcrypto -lssl

LOCAL_AUTOTOOLS_VERSION := 0.9.8i
LOCAL_AUTOTOOLS_ARCHIVE := openssl-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_DIR := openssl-$(LOCAL_AUTOTOOLS_VERSION)

LOCAL_AUTOTOOLS_PATCHES := \
	lucie/openssl-0.9.8i-parallel-build.patch \
	lucie/openssl-0.9.8i-tls-extensions.patch

LOCAL_AUTOTOOLS_MAKE_BUILD_ENV := \
	$(AUTOTOOLS_CONFIGURE_ENV)

LOCAL_AUTOTOOLS_MAKE_BUILD_ARGS := \
	CC=$(TARGET_CC)

# Used for clean internally also
LOCAL_AUTOTOOLS_MAKE_INSTALL_ENV := \
	$(AUTOTOOLS_CONFIGURE_ENV)

# Used for clean internally also
LOCAL_AUTOTOOLS_MAKE_INSTALL_ARGS := \
	CC=$(TARGET_CC) \
	INSTALL_PREFIX=$(AUTOTOOLS_INSTALL_DESTDIR)

LOCAL_AUTOTOOLS_CMD_CONFIGURE := openssl-cmd-configure
LOCAL_AUTOTOOLS_CMD_INSTALL := openssl-cmd-install
LOCAL_AUTOTOOLS_CMD_POST_CLEAN := openssl-cmd-post-clean

# TODO : do we really need to specify this ?
#ifeq ("$(TARGET_OS_FLAVOUR)","native")
#  OPENSSLDIR := $(TARGET_OUT_STAGING)/usr/local/openssl
#else
#  OPENSSLDIR := /usr/local/openssl
#endif

openssl-cmd-configure = \
	cd $(PRIVATE_SRC_DIR) && $(AUTOTOOLS_CONFIGURE_ENV) \
		./Configure linux-generic32 -DL_ENDIAN $(TARGET_GLOBAL_CFLAGS) shared \
		--prefix=$(AUTOTOOLS_CONFIGURE_PREFIX)

#		--openssldir=$(OPENSSLDIR)

openssl-cmd-install = \
	$(AUTOTOOLS_MAKE_ENV) $(AUTOTOOLS_CONFIGURE_ENV) $(MAKE) $(AUTOTOOLS_MAKE_ARGS) \
		-C $(PRIVATE_SRC_DIR) \
		CC=$(TARGET_CC) \
		INSTALL_PREFIX=$(AUTOTOOLS_INSTALL_DESTDIR) \
		install_sw

openssl-cmd-post-clean = \
	rm -f $(TARGET_OUT_STAGING)/usr/bin/openssl; \
	rm -f $(TARGET_OUT_STAGING)/usr/bin/c_rehash; \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/libssl*.a*; \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/libssl*.so*; \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/libcrypto*.a*; \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/libcrypto*.so*; \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/engines/*.so; \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/pkgconfig/libcrypto.pc; \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/pkgconfig/libssl.pc; \
	rm -f $(TARGET_OUT_STAGING)/usr/lib/pkgconfig/openssl.pc; \
	rm -rf $(TARGET_OUT_STAGING)/usr/include/openssl \
	rm -rf $(TARGET_OUT_STAGING)/usr/local/openssl

include $(BUILD_AUTOTOOLS)

endif

