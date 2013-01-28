###############################################################################
## @file toolchains-packages.mk
## @author Y.M. Morgan
## @date 2012/11/08
##
## This file contains additional packages for toolchains.
###############################################################################

###############################################################################
## Include specific libc packages.
###############################################################################

include $(BUILD_SYSTEM)/toolchains/$(TARGET_LIBC)/$(TARGET_LIBC)-packages.mk
