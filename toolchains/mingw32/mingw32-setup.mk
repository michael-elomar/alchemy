###############################################################################
## @file mingw32-setup.mk
## @author Y.M. Morgan
## @date 2015/04/04
##
## This file contains additional setup for mingw32.
###############################################################################

ifndef TARGET_CROSS
  TARGET_CROSS := /opt/i686-pc-mingw32/bin/i686-pc-mingw32-
endif

ifeq ("$(TARGET_ARCH)","x64")
  TARGET_GLOBAL_CFLAGS += -m64 -fPIC
  TARGET_GLOBAL_LDFLAGS += -m64
  TARGET_GLOBAL_LDFLAGS_SHARED += -m64
endif

ifeq ("$(TARGET_ARCH)","x86")
  TARGET_GLOBAL_CFLAGS += -m32
  TARGET_GLOBAL_LDFLAGS += -m32
  TARGET_GLOBAL_LDFLAGS_SHARED += -m32
endif
