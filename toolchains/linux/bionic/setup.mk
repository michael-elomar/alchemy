###############################################################################
## @file linux/bionic/setup.mk
## @author Y.M. Morgan
## @date 2012/10/18
##
## This file contains additional setup for bionic (android).
###############################################################################

# Flags shall be given through environment as they are very, very android
# specific and hard to extract.

TARGET_GLOBAL_C_INCLUDES += \
	$(BUILD_SYSTEM)/toolchains/bionic/include
