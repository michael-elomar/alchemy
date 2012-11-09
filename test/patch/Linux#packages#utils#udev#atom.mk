
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := udev

LOCAL_EXPORT_LDLIBS := -ludev

LOCAL_AUTOTOOLS_VERSION := 164
LOCAL_AUTOTOOLS_ARCHIVE := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_DIR := $(LOCAL_MODULE)-$(LOCAL_AUTOTOOLS_VERSION)

# Common patches
LOCAL_AUTOTOOLS_PATCHES := \
	lucie/udevd_init.patch \
	lucie/udevd_skip.patch

# Specific patches
ifeq ("$(TARGET_LIBC)","bionic")
LOCAL_AUTOTOOLS_PATCHES += \
	lucie/bionic-164.patch \
	lucie/bionic-164-uid.patch
else
LOCAL_AUTOTOOLS_PATCHES += \
	lucie/glibc-164.patch
endif

# Configuration variables
ifneq ("$(TARGET_LIBC)","bionic")
ifeq ("$(TARGET_OS_FLAVOUR)","native")
LOCAL_AUTOTOOLS_CONFIGURE_ARGS := \
	--disable-introspection \
	--disable-extras \
	--enable-static \
	--prefix=$(TARGET_OUT_STAGING)/usr \
	--exec-prefix=$(TARGET_OUT_FINAL) \
	--libexecdir=$(TARGET_OUT_FINAL)/lib/udev
else
LOCAL_AUTOTOOLS_CONFIGURE_ARGS := \
	--disable-introspection \
	--disable-extras \
	--prefix=$(TARGET_OUT_STAGING)/usr \
	--exec-prefix=/ \
	--libexecdir=/lib/udev
endif
endif

# Post-configure actions
ifeq ("$(TARGET_LIBC)","bionic")
udev-cmd-post-configure = \
	cp -af $(PRIVATE_PATH)/lucie/bionic.h $(PRIVATE_SRC_DIR)/config.h; \
	echo "\#define ENABLE_LOGGING 1" >> $(PRIVATE_SRC_DIR)/config.h; \
	cp -af $(PRIVATE_PATH)/lucie/Makefile.bionic $(PRIVATE_SRC_DIR)/Makefile; \
	mkdir -p $(PRIVATE_SRC_DIR)/inc/linux; \
	touch $(PRIVATE_SRC_DIR)/inc/linux/bsg.h; \
	cp -af $(PRIVATE_PATH)/lucie/udevd_init.c $(PRIVATE_SRC_DIR)/udev
else ifeq ("$(TARGET_LIBC)","eglibc")
udev-cmd-post-configure = \
	cat $(PRIVATE_PATH)/lucie/eglibc.h >> $(PRIVATE_SRC_DIR)/config.h; \
	mkdir -p $(PRIVATE_SRC_DIR)/libudev/linux; \
	cp -af $(PRIVATE_PATH)/lucie/include/linux/bsg.h $(PRIVATE_SRC_DIR)/libudev/linux/bsg.h; \
	cp -af $(PRIVATE_PATH)/lucie/udevd_init.c $(PRIVATE_SRC_DIR)/udev
else
udev-cmd-post-configure = \
	cp -af $(PRIVATE_PATH)/lucie/udevd_init.c $(PRIVATE_SRC_DIR)/udev
endif

# Installation actions (android libs not built at the same place !)
ifeq ("$(TARGET_LIBC)","bionic")
udev-cmd-install = \
	mkdir -p $(TARGET_OUT_STAGING)/lib; \
	install -p $(PRIVATE_SRC_DIR)/libudev*.so* $(TARGET_OUT_STAGING)/lib; \
	install -p $(PRIVATE_SRC_DIR)/libudev*.a* $(TARGET_OUT_STAGING)/lib; \
	mkdir -p $(TARGET_OUT_STAGING)/lib/udev; \
	install -p $(PRIVATE_SRC_DIR)/extras/usb_id/usb_id $(TARGET_OUT_STAGING)/lib/udev; \
	mkdir -p $(TARGET_OUT_STAGING)/tmp/udev/dev; \
	mkdir -p $(TARGET_OUT_STAGING)/usr/include; \
	install -p $(PRIVATE_SRC_DIR)/libudev/libudev.h $(TARGET_OUT_STAGING)/usr/include; \
	mkdir -p $(TARGET_OUT_STAGING)/sbin; \
	install -p $(addprefix $(PRIVATE_SRC_DIR)/udev/,udevd udevadm udevd_init) $(TARGET_OUT_STAGING)/sbin; \
	install -p $(PRIVATE_PATH)/lucie/udevd.sh $(TARGET_OUT_STAGING)/sbin/udevd.sh;
else
udev-cmd-install = \
	mkdir -p $(TARGET_OUT_STAGING)/lib; \
	install -p $(PRIVATE_SRC_DIR)/libudev/.libs/libudev*.so* $(TARGET_OUT_STAGING)/lib; \
	install -p $(PRIVATE_SRC_DIR)/libudev/.libs/libudev*.a* $(TARGET_OUT_STAGING)/lib; \
	mkdir -p $(TARGET_OUT_STAGING)/lib/udev; \
	install -p $(PRIVATE_SRC_DIR)/extras/usb_id/usb_id $(TARGET_OUT_STAGING)/lib/udev; \
	mkdir -p $(TARGET_OUT_STAGING)/tmp/udev/dev; \
	mkdir -p $(TARGET_OUT_STAGING)/usr/include; \
	install -p $(PRIVATE_SRC_DIR)/libudev/libudev.h $(TARGET_OUT_STAGING)/usr/include; \
	mkdir -p $(TARGET_OUT_STAGING)/sbin; \
	install -p $(addprefix $(PRIVATE_SRC_DIR)/udev/,udevd udevadm udevd_init) $(TARGET_OUT_STAGING)/sbin; \
	install -p $(PRIVATE_PATH)/lucie/udevd.sh $(TARGET_OUT_STAGING)/sbin/udevd.sh;
endif

# Clean actions (as install was not done via standard make, trying default clean actions will fail)
udev-cmd-clean = \
	rm -f $(TARGET_OUT_STAGING)/lib/libudev*.so*; \
	rm -f $(TARGET_OUT_STAGING)/lib/libudev*.a*; \
	rm -f $(TARGET_OUT_STAGING)/lib/udev/usb_id; \
	rm -f $(TARGET_OUT_STAGING)/usr/include/libudev.h; \
	rm -f $(TARGET_OUT_STAGING)/sbin/udevd.sh; \
	rm -f $(TARGET_OUT_STAGING)/sbin/udevd; \
	rm -f $(TARGET_OUT_STAGING)/sbin/udevadm; \
	rm -f $(TARGET_OUT_STAGING)/sbin/udevd_init

# Environment and actions variables
ifeq ("$(TARGET_LIBC)","bionic")
LOCAL_AUTOTOOLS_MAKE_BUILD_ENV := $(AUTOTOOLS_CONFIGURE_ENV)
LOCAL_AUTOTOOLS_CMD_CONFIGURE := udev-cmd-configure
udev-cmd-configure = $(empty)
endif

LOCAL_AUTOTOOLS_CMD_POST_CONFIGURE := udev-cmd-post-configure
LOCAL_AUTOTOOLS_CMD_INSTALL := udev-cmd-install
LOCAL_AUTOTOOLS_CMD_CLEAN := udev-cmd-clean


include $(BUILD_AUTOTOOLS)


