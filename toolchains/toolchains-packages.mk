###############################################################################
## @file toolchains-packages.mk
## @author Y.M. Morgan
## @date 2012/11/08
##
## This file contains additional packages for toolchains.
###############################################################################

# When a sdk is used, assume we are not building a full system, so no installation
# of libc files is done in staging directory
ifeq ("$(TARGET_SDK_DIRS)","")
ifneq ("$(TOOLCHAIN_LIBC)","")
include $(BUILD_SYSTEM)/toolchains/libc.mk
endif
endif

# Include os specific packages
include $(BUILD_SYSTEM)/toolchains/$(TARGET_OS)/packages.mk
