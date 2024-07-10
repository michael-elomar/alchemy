###############################################################################
## @file targets/darwin/iphonesimulator/setup.mk
## @author Y.M. Morgan
## @date 2016/03/05
##
## Setup variables for darwin/iphonesimulator target.
###############################################################################

TARGET_ARCH ?= $(HOST_ARCH)
TARGET_FORCE_STATIC := 1

TARGET_IPHONE_VERSION ?= 8.2
APPLE_SDK := iphonesimulator
APPLE_MINVERSION := -miphonesimulator-version-min=$(TARGET_IPHONE_VERSION)
