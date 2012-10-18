###############################################################################
## @file native-setup.mk
## @author Y.M. Morgan
## @date 2012/10/18
##
## This file contains additional setup for native linux.
###############################################################################

# Update flags based on architecture
# 64-bit requires -fPIC to build shared libraries
ifeq ("$(TARGET_ARCH)","x64")
  TARGET_GLOBAL_CFLAGS += -m64 -fPIC
  TARGET_GLOBAL_LDFLAGS += -m64
  TARGET_GLOBAL_LDFLAGS_SHARED += -m64
else
  TARGET_GLOBAL_CFLAGS += -m32
  TARGET_GLOBAL_LDFLAGS += -m32
  TARGET_GLOBAL_LDFLAGS_SHARED += -m32
endif

TARGET_GLOBAL_LDLIBS += -lpthread -lrt
TARGET_GLOBAL_LDLIBS_SHARED += -lpthread -lrt

