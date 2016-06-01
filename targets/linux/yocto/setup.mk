###############################################################################
## @file targets/linux/yocto/setup.mk
## @author Y.M. Morgan
## @date 2016/03/05
##
## Setup variables for linux/yocto target.
###############################################################################

TARGET_LIBC := yocto

YOCTO_SDK_DEFAULT_PATHS := \
	/opt/poky* \
	~/Library/poky* \
	~/poky*

TARGET_YOCTO_VERSION ?= 1.8

ifndef TARGET_YOKTO_SDK
TARGET_YOKTO_SDK := \
	$(shell shopt -s nullglob ; \
		for path in $(YOCTO_SDK_DEFAULT_PATHS) ; do \
			if [ -e $$path/$(TARGET_YOCTO_VERSION) ]; then \
				cd $$path && pwd && break; \
			fi; \
		done \
	)
endif
ifeq ("$(wildcard $(TARGET_YOKTO_SDK))","")
  $(error No Yocto SDK found, you need to set your Yocto SDK path in the TARGET_YOKTO_SDK variable)
endif

# File containing env variables
YOCTO_ENV_FILE := $(TARGET_YOKTO_SDK)/$(TARGET_YOCTO_VERSION)/environment-setup-$(TARGET_CPU)-poky-linux-gnueabi

# Yocto sdk target/host sysroot
YOCTO_SDK_TARGET_SYSROOT := $(shell . $(YOCTO_ENV_FILE) && echo $$SDKTARGETSYSROOT)
YOCTO_SDK_HOST_SYSROOT := $(shell . $(YOCTO_ENV_FILE) && echo $$OECORE_NATIVE_SYSROOT)
