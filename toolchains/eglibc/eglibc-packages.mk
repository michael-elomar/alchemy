###############################################################################
## @file eglibc-setup.mk
## @author Y.M. Morgan
## @date 2012/11/05
##
## This file contains package definition specific to eglibc.
###############################################################################
LOCAL_PATH := $(call my-dir)
ifeq ("$(TARGET_COMPILER_PATH)","/opt/arm-2012.03")
include $(LOCAL_PATH)/arm-2012.03/atom.mk
endif

