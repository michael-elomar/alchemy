###############################################################################
## @file linux/yocto/setup.mk
## @author A. Bouaziz
## @date 2015/10/29
##
## This file contains package definition specific to yocto
###############################################################################

YOCTO_SDK_DEFAULT_PATHS := /opt/poky* ~/Library/poky* ~/poky*

TARGET_YOCTO_VERSION ?= 1.8

ifndef TARGET_YOKTO_SDK
TARGET_YOKTO_SDK := $(shell shopt -s nullglob ;                                \
                              for path in $(YOCTO_SDK_DEFAULT_PATHS) ; do      \
                              if [ -e $$path/$(TARGET_YOCTO_VERSION) ]; then   \
                                  cd $$path && pwd && break;                   \
                              fi; done)
endif

ifeq ("$(wildcard $(TARGET_YOKTO_SDK))","")
$(error No Yocto SDK found, you need to set your Yocto SDK path in the TARGET_YOKTO_SDK variable)
endif

#file containing env variables
YOCTO_ENV_FILE := $(TARGET_YOKTO_SDK)/$(TARGET_YOCTO_VERSION)/environment-setup-$(TARGET_CPU)-poky-linux-gnueabi

#yocto sdk target/host sysroot
YOCTO_SDK_TARGET_SYSROOT := $(shell . $(YOCTO_ENV_FILE) && echo $$SDKTARGETSYSROOT)
YOCTO_SDK_HOST_SYSROOT := $(shell . $(YOCTO_ENV_FILE) && echo $$OECORE_NATIVE_SYSROOT)

#get cross toolchain path
ifndef TARGET_CROSS
TARGET_CROSS := $(shell . $(YOCTO_ENV_FILE) && which $$CC | sed 's/gcc//')
endif
ifeq ("$(TARGET_CROSS)","")
$(error Failed to detect Yocto target cross, set the target cross path in the TARGET_CROSS variable)
endif

#get cross toolchain flags
TARGET_GLOBAL_CFLAGS += $(shell . $(YOCTO_ENV_FILE) && echo $$CC $$CFLAGS | cut -d ' ' -f2-)
TARGET_GLOBAL_CXXFLAGS += $(shell . $(YOCTO_ENV_FILE) && echo $$CXX $$CXXFLAGS | cut -d ' ' -f2-)
TMP_LDFLAGS := $(shell . $(YOCTO_ENV_FILE) && echo $$LD $$LDFLAGS | cut -d ' ' -f2-)
TARGET_GLOBAL_LDFLAGS += $(TMP_LDFLAGS)
TARGET_GLOBAL_LDFLAGS_SHARED += $(TMP_LDFLAGS)

TARGET_GLOBAL_C_INCLUDES += $(YOCTO_SDK_TARGET_SYSROOT)/usr/include

# Qt variables
QTSDK_QMAKE := $(YOCTO_SDK_HOST_SYSROOT)/usr/bin/qt5/qmake
ifneq ("$(wildcard $(QTSDK_QMAKE))","")
export OE_QMAKE_CC := $(shell . $(YOCTO_ENV_FILE) && which $$CC)
export OE_QMAKE_CXX := $(shell . $(YOCTO_ENV_FILE) && which $$CXX)
export OE_QMAKE_LINK := $(OE_QMAKE_CXX)
export OE_QMAKE_AR := $(shell . $(YOCTO_ENV_FILE) && which $$AR)
export QT_CONF_PATH := $(shell . $(YOCTO_ENV_FILE) && echo $$QT_CONF_PATH)
export OE_QMAKE_LIBDIR_QT := $(shell . $(YOCTO_ENV_FILE) && echo $$OE_QMAKE_LIBDIR_QT)
export OE_QMAKE_INCDIR_QT := $(shell . $(YOCTO_ENV_FILE) && echo $$OE_QMAKE_INCDIR_QT)
export QMAKESPEC := $(shell . $(YOCTO_ENV_FILE) && echo $$QMAKESPEC)

TARGET_GLOBAL_C_INCLUDES += $(OE_QMAKE_INCDIR_QT)
endif
