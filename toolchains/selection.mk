###############################################################################
## @file toolchains/selection.mk
## @author Y.M. Morgan
## @date 2016/03/05
##
## Setup toolchain variables.
###############################################################################

HOST_USE_CLANG ?= $(USE_CLANG)
TARGET_USE_CLANG ?= $(USE_CLANG)

# If the host is darwin, use the toolchain from the macosx SDK
# Use xcrun directly so it automatically provides the good sysroot to the tools
ifeq ("$(HOST_OS)","darwin")
  DARWIN_TOOLCHAIN_PATH := $(TARGET_OUT)/toolchain
  gen_xcrun_wrapper = $(shell FPATH=$(DARWIN_TOOLCHAIN_PATH)/xcrun_$1_$(subst $(space),_,$2)_wrapper;\
    if ! test -f $$FPATH; then\
     mkdir -p $$(dirname $$FPATH);\
     echo -e $(hash)!/bin/sh\\\nxcrun --sdk $1 $2 \$$\* > $$FPATH;\
     chmod +x $$FPATH;\
    fi;\
    echo $$FPATH)

  HOST_CC ?= $(call gen_xcrun_wrapper,macosx,clang)
  HOST_CXX ?= $(call gen_xcrun_wrapper,macosx,clang++)
  HOST_AS ?= $(call gen_xcrun_wrapper,macosx,as)
  HOST_AR ?= $(call gen_xcrun_wrapper,macosx,ar)
  HOST_LD ?= $(call gen_xcrun_wrapper,macosx,ld)
  # Do *not* provide "cpp" as the preprocessor as it fails to pre-process some
  # Apple-provided headers (as of macOS Ventura) :
  # `echo "#include <AvailabilityInternal.h>" | cpp - >/dev/null`
  # fails while
  # `echo "#include <AvailabilityInternal.h>" | clang -E - >/dev/null`
  # works correclty
  HOST_CPP ?= $(call gen_xcrun_wrapper,macosx,clang -E)
  HOST_NM ?= $(call gen_xcrun_wrapper,macosx,nm)
  HOST_STRIP ?= $(call gen_xcrun_wrapper,macosx,strip)
  HOST_RANLIB ?= $(call gen_xcrun_wrapper,macosx,ranlib)
  HOST_OBJDUMP ?= $(call gen_xcrun_wrapper,macosx,objdump)
endif

ifneq ("$(HOST_USE_CLANG)","1")
  HOST_CC ?= cc
  HOST_CXX ?= c++
  HOST_AS ?= as
  HOST_FC ?= gfortran
  HOST_AR ?= ar
  HOST_LD ?= ld
  HOST_CPP ?= cpp
  HOST_NM ?= nm
  HOST_STRIP ?= strip
  HOST_RANLIB ?= ranlib
  HOST_OBJCOPY ?= objcopy
  HOST_OBJDUMP ?= objdump
  HOST_WINDRES ?= windres
else
  HOST_CC ?= clang
  HOST_CXX ?= clang++
  HOST_AS ?= llvm-as
  HOST_FC ?= gfortran
  HOST_AR ?= ar
  HOST_LD ?= ld.lld
  HOST_CPP ?= cpp
  HOST_NM ?= llvm-nm
  HOST_STRIP ?= strip
  HOST_RANLIB ?= llvm-ranlib
  HOST_OBJCOPY ?= objcopy
  HOST_OBJDUMP ?= llvm-objdump
  HOST_WINDRES ?= windres
endif

# Select correct toolchain
-include $(BUILD_SYSTEM)/toolchains/$(TARGET_OS)/selection.mk

TARGET_CROSS ?=

ifeq ("$(TARGET_OS)-$(TARGET_OS_FLAVOUR)","$(HOST_OS)-native")
  TARGET_CC ?= $(HOST_CC)
  TARGET_CXX ?= $(HOST_CXX)
  TARGET_AS ?= $(HOST_AS)
  TARGET_FC ?= $(HOST_FC)
  TARGET_AR ?= $(HOST_AR)
  TARGET_LD ?= $(HOST_LD)
  TARGET_CPP ?= $(HOST_CPP)
  TARGET_NM ?= $(HOST_NM)
  TARGET_STRIP ?= $(HOST_STRIP)
  TARGET_RANLIB ?= $(HOST_RANLIB)
  TARGET_OBJCOPY ?= $(HOST_OBJCOPY)
  TARGET_OBJDUMP ?= $(HOST_OBJDUMP)
  TARGET_WINDRES ?= $(HOST_WINDRES)
  TARGET_LLVM ?= $(HOST_LLVM)
else
  ifneq ("$(TARGET_USE_CLANG)","1")
    TARGET_CC ?= $(TARGET_CROSS)gcc
    TARGET_CXX ?= $(TARGET_CROSS)g++
  else
    TARGET_CC ?= $(TARGET_CROSS)clang
    TARGET_CXX ?= $(TARGET_CROSS)clang++
    ifneq ("$(wildcard $(TARGET_CROSS)clang-cpp)","")
      TARGET_CPP ?= $(TARGET_CROSS)clang-cpp
    endif
  endif
  TARGET_AS ?= $(TARGET_CROSS)as
  TARGET_FC ?= $(TARGET_CROSS)gfortran
  TARGET_AR ?= $(TARGET_CROSS)ar
  TARGET_LD ?= $(TARGET_CROSS)ld
  TARGET_NM ?= $(TARGET_CROSS)nm
  TARGET_STRIP ?= $(TARGET_CROSS)strip
  TARGET_CPP ?= $(TARGET_CROSS)cpp
  TARGET_RANLIB ?= $(TARGET_CROSS)ranlib
  TARGET_OBJCOPY ?= $(TARGET_CROSS)objcopy
  TARGET_OBJDUMP ?= $(TARGET_CROSS)objdump
  TARGET_WINDRES ?= $(TARGET_CROSS)windres
  TARGET_LLVM ?= $(TARGET_CROSS)llvm-
endif

ifeq ("$(TARGET_NOSTRIP_FINAL)","2")
  #strip only debug info but keep symbol table for symbol resolving on target
  #this usefull for tools like perf
  TARGET_STRIP := $(TARGET_STRIP) --strip-debug
endif

# Nvidia cuda compiler
TARGET_NVCC ?=

# Determine compiler path
TARGET_CC_PATH := $(shell which $(TARGET_CC) 2>/dev/null)
ifeq ("$(TARGET_CC_PATH)","")
  $(error Unable to find compiler: $(TARGET_CC))
endif

# TODO: remove when not used anymore
TARGET_COMPILER_PATH := $(shell PARAM="$(TARGET_CC)";echo $${PARAM%/bin*})

# HOST_CC flavour
ifeq ("$(shell $(HOST_CC) --version | grep -qi clang; echo $$?)","0")
  HOST_CC_FLAVOUR := clang
else
  HOST_CC_FLAVOUR := gcc
endif

# TARGET_CC flavour
ifeq ("$(shell $(TARGET_CC) --version | grep -qi clang; echo $$?)","0")
  TARGET_CC_FLAVOUR := clang
else
  TARGET_CC_FLAVOUR := gcc
endif

# Determine compilers version
ifeq ("$(HOST_CC_FLAVOUR)","clang")
  HOST_CC_VERSION := $(shell $(HOST_CC) --version | head -1 | \
		grep -o -E '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
else
  HOST_CC_VERSION := $(shell $(HOST_CC) -dumpversion)
endif

ifeq ("$(TARGET_CC_FLAVOUR)","clang")
  ifneq ("$(and $(TARGET_LLVM),$(wildcard $(TARGET_LLVM)config))","")
    TARGET_CC_VERSION := $(shell $(TARGET_LLVM)config --version)
  else
    TARGET_CC_VERSION := $(shell $(TARGET_CC) --version | head -1 | \
                 grep -o -E '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  endif
else
  TARGET_CC_VERSION := $(shell $(TARGET_CC) -dumpversion)
endif
