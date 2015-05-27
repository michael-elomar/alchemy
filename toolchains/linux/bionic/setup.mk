###############################################################################
## @file linux/bionic/setup.mk
## @author Y.M. Morgan
## @date 2012/10/18
##
## This file contains additional setup for bionic (android).
###############################################################################

ifndef USE_ALCHEMY_ANDROID_SDK

ANDROID_NDK_DEFAULT_PATHS=/opt/android-ndk-* /opt/android/ndk-* ~/Library/Android/android-ndk-* ~/android-ndk-*
ANDROID_SDK_DEFAULT_PATHS=/opt/android-sdk* /opt/android/sdk* ~/Library/Android/sdk* ~/Library/Android/android-sdk* ~/android-sdk*

# Configuration options
TARGET_ANDROID_APILEVEL?=17

TARGET_ANDROID_SDK ?= $(shell shopt -s nullglob ;                                                   \
                              for path in $(ANDROID_SDK_DEFAULT_PATHS) ; do                         \
                              if [ -e $$path/platforms/android-$(TARGET_ANDROID_APILEVEL) ]; then   \
                                  cd $$path && pwd && break;                                        \
                              fi; done)
ifeq ("$(wildcard $(TARGET_ANDROID_SDK))","")
$(error No Android SDK found, use Alchemy-raptor package or set your Android SDK path in the TARGET_ANDROID_SDK variable)
endif

TARGET_ANDROID_NDK ?= $(shell shopt -s nullglob ;                                                   \
                              for path in $(ANDROID_NDK_DEFAULT_PATHS) ; do                         \
                              if [ -e $$path/platforms/android-$(TARGET_ANDROID_APILEVEL) ]; then   \
                                  cd $$path && pwd && break;                                        \
                              fi; done)
ifeq ("$(wildcard $(TARGET_ANDROID_NDK))","")
$(error No Android NDK found, use Alchemy-raptor package or set your Android NDK path in the TARGET_ANDROID_NDK variable)
endif

TARGET_ANDROID_TOOLCHAIN ?= $(shell . $(TARGET_ANDROID_NDK)/build/tools/dev-defaults.sh &&          \
                                    echo $$(get_default_toolchain_name_for_arch $(TARGET_ARCH)))
ifeq ("$(TARGET_ANDROID_TOOLCHAIN)","")
$(error Failed to detect Android toolchain, set the name of the toolchain in the TARGET_ANDROID_TOOLCHAIN variable)
endif

# Install the android toolchain in output folder
# NOTE: We must copy the toolchain here, before toolchains-setup.mk verifies the compiler is properly setup
ANDROID_TOOLCHAIN_PATH=$(TARGET_OUT)/toolchain
ANDROID_TOOLCHAIN_OPTIONS =                         \
	--platform=android-$(TARGET_ANDROID_APILEVEL)   \
	--arch=$(TARGET_ARCH)                           \
	--install-dir=$(ANDROID_TOOLCHAIN_PATH)	        \
	--toolchain=$(TARGET_ANDROID_TOOLCHAIN)	        \
#	-–stl=libcxx

ANDROID_TOOLCHAIN_TOKEN = $(ANDROID_TOOLCHAIN_PATH)/$(TARGET_ANDROID_TOOLCHAIN).android-$(TARGET_ANDROID_APILEVEL)
ifeq ("$(wildcard $(ANDROID_TOOLCHAIN_TOKEN))","")
$(info Installing Android-$(TARGET_ANDROID_APILEVEL) toolchain $(TARGET_ANDROID_TOOLCHAIN) from NDK)
$(shell if [ -e $(ANDROID_TOOLCHAIN_PATH) ] ; then rm -rf $(ANDROID_TOOLCHAIN_PATH); fi ; \
        $(TARGET_ANDROID_NDK)/build/tools/make-standalone-toolchain.sh $(ANDROID_TOOLCHAIN_OPTIONS) && \
            touch $(ANDROID_TOOLCHAIN_TOKEN))
endif

TARGET_CROSS = $(ANDROID_TOOLCHAIN_PATH)/bin/$(shell echo $(TARGET_ANDROID_TOOLCHAIN) | sed 's/\(.*\)-[0-9].[0-9]/\1/')-

ifeq ("$(TARGET_ARCH)","arm")
  TARGET_DEFAULT_LIB_DESTDIR := libs/armeabi-v7a
else ifeq ("$(TARGET_ARCH)","arm64")
  TARGET_DEFAULT_LIB_DESTDIR := libs/arm64-v8a
else ifeq ("$(TARGET_ARCH)","x86")
  TARGET_DEFAULT_LIB_DESTDIR := libs/x86
else ifeq ("$(TARGET_ARCH)","x64")
  TARGET_DEFAULT_LIB_DESTDIR := libs/x86-64
else ifeq ("$(TARGET_ARCH)","mips")
  TARGET_DEFAULT_LIB_DESTDIR := libs/mips
else ifeq ("$(TARGET_ARCH)","mips64")
  TARGET_DEFAULT_LIB_DESTDIR := libs/mips64
endif

else # USE_ALCHEMY_ANDROID_SDK

# Flags shall be given through environment as they are very, very android
# specific and hard to extract.

TARGET_GLOBAL_C_INCLUDES += \
	$(BUILD_SYSTEM)/toolchains/bionic/include

endif
