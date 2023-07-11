###############################################################################
## @file targets/linux/yocto/setup.mk
## @author Y.M. Morgan
## @date 2016/03/05
##
## Setup variables for linux/yocto target.
###############################################################################

YOCTO_SDK_DEFAULT_PATHS := \
	/opt/poky* \
	~/Library/poky* \
	~/poky*

ifndef TARGET_YOCTO_SDK
TARGET_YOCTO_VERSION ?= 1.8

TARGET_YOCTO_SDK := \
	$(shell for path in $(wildcard $(YOCTO_SDK_DEFAULT_PATHS)) ; do \
			if [ -e $$path/$(TARGET_YOCTO_VERSION) ]; then \
				cd $$path && pwd && break; \
			fi; \
		done \
	)
endif
ifeq ("$(wildcard $(TARGET_YOCTO_SDK))","")
  $(error No Yocto SDK found, you need to set your Yocto SDK path in the TARGET_YOCTO_SDK variable)
endif

# File containing env variables
YOCTO_ENV_FILE := $(wildcard $(TARGET_YOCTO_SDK)/$(TARGET_YOCTO_VERSION)/environment-setup-*-linux)

# If police hook is enabled, unset LD_PRELOAD and LD_LIBRARY_PATH set by it
# that mess up yocto environment file setup
ifneq ("$(findstring police-hook,$(LD_PRELOAD))","")
    yocto_sanitize_env := unset LD_LIBRARY_PATH; unset LD_PRELOAD;
else
    yocto_sanitize_env :=
endif

# Get a variable from the environment file
# $1: variable name
yocto_get_variable = $(shell $(yocto_sanitize_env) . $(YOCTO_ENV_FILE) && echo $$$1)

# Get cross toolchain path
YOCTO_TOOLCHAIN_PATH := $(shell $(yocto_sanitize_env) . $(YOCTO_ENV_FILE) && which $$CC | sed 's:/[^/]*$$::')
ifneq ("$(findstring Your environment,$(YOCTO_TOOLCHAIN_PATH))","")
    $(info Error in yocto environment from $(YOCTO_ENV_FILE))
    $(error $(YOCTO_TOOLCHAIN_PATH))
endif

# Yocto sdk target/host sysroot
YOCTO_SDK_TARGET_SYSROOT := $(call yocto_get_variable,SDKTARGETSYSROOT)
YOCTO_SDK_HOST_SYSROOT   := $(call yocto_get_variable,OECORE_NATIVE_SYSROOT)

TARGET_CC      := $(YOCTO_TOOLCHAIN_PATH)/$(call yocto_get_variable,CC)
TARGET_CXX     := $(YOCTO_TOOLCHAIN_PATH)/$(call yocto_get_variable,CXX)
TARGET_CPP     := $(YOCTO_TOOLCHAIN_PATH)/$(call yocto_get_variable,CPP)
TARGET_AS      := $(YOCTO_TOOLCHAIN_PATH)/$(call yocto_get_variable,AS)
TARGET_LD      := $(YOCTO_TOOLCHAIN_PATH)/$(call yocto_get_variable,LD)
TARGET_STRIP   := $(YOCTO_TOOLCHAIN_PATH)/$(call yocto_get_variable,STRIP)
TARGET_RANLIB  := $(YOCTO_TOOLCHAIN_PATH)/$(call yocto_get_variable,RANLIB)
TARGET_OBJCOPY := $(YOCTO_TOOLCHAIN_PATH)/$(call yocto_get_variable,OBJCOPY)
TARGET_OBJDUMP := $(YOCTO_TOOLCHAIN_PATH)/$(call yocto_get_variable,OBJDUMP)
TARGET_AR      := $(YOCTO_TOOLCHAIN_PATH)/$(call yocto_get_variable,AR)
TARGET_NM      := $(YOCTO_TOOLCHAIN_PATH)/$(call yocto_get_variable,NM)

# Get cross toolchain flags
# Do not use += to make sure variable are 'simple' and not 'recursive' and avoid
# spawning a shell each time the variable is used
TARGET_GLOBAL_CFLAGS     := $(TARGET_GLOBAL_CFLAGS)     $(call yocto_get_variable,CFLAGS)
TARGET_GLOBAL_CXXFLAGS   := $(TARGET_GLOBAL_CXXFLAGS)   $(call yocto_get_variable,CXXFLAGS)
TARGET_GLOBAL_LDFLAGS    := $(TARGET_GLOBAL_LDFLAGS)    $(call yocto_get_variable,LDFLAGS)
TARGET_GLOBAL_C_INCLUDES := $(TARGET_GLOBAL_C_INCLUDES) $(YOCTO_SDK_TARGET_SYSROOT)/usr/include

# Qt variables
TARGET_QMAKE := $(YOCTO_SDK_HOST_SYSROOT)/usr/bin/qt5/qmake
ifneq ("$(wildcard $(TARGET_QMAKE))","")
export OE_QMAKE_CFLAGS    := $(TARGET_GLOBAL_CFLAGS)
export OE_QMAKE_CXXFLAGS  := $(TARGET_GLOBAL_CXXFLAGS)
export OE_QMAKE_LDFLAGS   := $(TARGET_GLOBAL_LDFLAGS)
export OE_QMAKE_CC        := $(TARGET_CC)
export OE_QMAKE_CXX       := $(TARGET_CXX)
export OE_QMAKE_LINK      := $(TARGET_CXX)
export OE_QMAKE_AR        := $(TARGET_AR)
export OE_QMAKE_STRIP     := $(TARGET_STRIP)
export QT_CONF_PATH       := $(call yocto_get_variable,QT_CONF_PATH)
export OE_QMAKE_LIBDIR_QT := $(call yocto_get_variable,OE_QMAKE_LIBDIR_QT)
export OE_QMAKE_INCDIR_QT := $(call yocto_get_variable,OE_QMAKE_INCDIR_QT)
export QMAKESPEC          := $(call yocto_get_variable,QMAKESPEC)

TARGET_GLOBAL_C_INCLUDES += $(OE_QMAKE_INCDIR_QT)
endif
