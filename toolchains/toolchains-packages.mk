###############################################################################
## @file toolchains-packages.mk
## @author Y.M. Morgan
## @date 2012/11/08
##
## This file contains additional packages for toolchains.
###############################################################################

# Include os specific packages
include $(BUILD_SYSTEM)/toolchains/$(TARGET_OS)/packages.mk
