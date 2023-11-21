###############################################################################
## @file targets/darwin/native/packages.mk
## @author Y.M. Morgan
## @date 2016/03/05
##
## Additional packages for darwin/native target.
###############################################################################

LOCAL_PATH := $(call my-dir)

$(call register-prebuilt-pkg-config-module,libpng,libpng)

