###############################################################################
## @file toolchains/darwin/selection.mk
## @author Y.M. Morgan
## @date 2016/03/05
##
## Setup toolchain variables.
###############################################################################

ifeq ("$(TARGET_ARCH)","x64")
  APPLE_ARCH := -arch x86_64
  TARGET_TOOLCHAIN_TRIPLET := x86_64-apple-darwin
else ifeq ("$(TARGET_ARCH)","x86")
  APPLE_ARCH := -arch i386
  TARGET_TOOLCHAIN_TRIPLET := i386-apple-darwin
else ifeq ("$(TARGET_ARCH)","arm")
  ifeq ("$(call check-version,$(TARGET_IPHONE_VERSION),11.0)","")
    APPLE_ARCH := -arch armv7 -arch arm64
  else
    APPLE_ARCH := -arch arm64
  endif
  TARGET_TOOLCHAIN_TRIPLET := arm-apple-darwin
endif

TARGET_CROSS ?=

TARGET_CC ?= $(call gen_xcrun_wrapper,$(APPLE_SDK),clang)
TARGET_CXX ?= $(call gen_xcrun_wrapper,$(APPLE_SDK),clang++)
TARGET_AS ?= $(call gen_xcrun_wrapper,$(APPLE_SDK),as)
TARGET_AR ?= $(call gen_xcrun_wrapper,$(APPLE_SDK),ar)
TARGET_LD ?= $(call gen_xcrun_wrapper,$(APPLE_SDK),ld)
# Do *not* provide "cpp" as the preprocessor as it fails to pre-process some
# Apple-provided headers (as of macOS Ventura) :
# `echo "#include <AvailabilityInternal.h>" | cpp - >/dev/null`
# fails while
# `echo "#include <AvailabilityInternal.h>" | clang -E - >/dev/null`
# works correclty
# Moreover, some headers checks the target architecture, and fail to
# preprocess if clang -E is not given the proper -arch flag, so we also include
# it here.
TARGET_CPP ?= $(call gen_xcrun_wrapper,$(APPLE_SDK),clang -E $(APPLE_ARCH))
TARGET_NM ?= $(call gen_xcrun_wrapper,$(APPLE_SDK),nm)
TARGET_STRIP ?= $(call gen_xcrun_wrapper,$(APPLE_SDK),strip)
TARGET_RANLIB ?= $(call gen_xcrun_wrapper,$(APPLE_SDK),ranlib)
TARGET_OBJDUMP ?= $(call gen_xcrun_wrapper,$(APPLE_SDK),objdump)

#TODO: use lipo wrapper....
TARGET_OBJCOPY ?= $(TARGET_CROSS)objcopy
