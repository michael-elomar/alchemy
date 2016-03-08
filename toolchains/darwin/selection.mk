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
  APPLE_ARCH := -arch armv7 -arch arm64
  TARGET_TOOLCHAIN_TRIPLET := arm-apple-darwin
endif

USE_CLANG := 1
TARGET_CROSS ?=
TARGET_CC := $(shell xcrun --find --sdk $(APPLE_SDK) clang)
TARGET_CXX := $(shell xcrun --find --sdk $(APPLE_SDK) clang++)
TARGET_AS := $(shell xcrun --find --sdk $(APPLE_SDK) as)
TARGET_AR := $(BUILD_SYSTEM)/scripts/darwin-ar $(shell xcrun --find --sdk $(APPLE_SDK) ar)
TARGET_LD := $(shell xcrun --find --sdk $(APPLE_SDK) ld)
TARGET_NM := $(shell xcrun --find --sdk $(APPLE_SDK) nm)
TARGET_STRIP := $(shell xcrun --find --sdk $(APPLE_SDK) strip)
TARGET_CPP := $(shell xcrun --find --sdk $(APPLE_SDK) cpp)
TARGET_RANLIB := $(shell xcrun --find --sdk $(APPLE_SDK) ranlib)
TARGET_OBJCOPY := $(TARGET_CROSS)objcopy	#TODO: use lipo wrapper....
TARGET_OBJDUMP := $(TARGET_CROSS)objdump	#TODO: use otool wrapper....
