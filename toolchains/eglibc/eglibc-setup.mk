###############################################################################
## @file eglibc-setup.mk
## @author Y.M. Morgan
## @date 2012/11/05
##
## This file contains additional setup for eglibc.
###############################################################################

ifndef TARGET_CROSS
  TARGET_CROSS="/opt/arm-2009q1/bin/arm-none-linux-gnueabi-"
endif

# Assume everybody will wants this
TARGET_GLOBAL_LDLIBS += -lpthread -lrt
TARGET_GLOBAL_LDLIBS_SHARED += -lpthread -lrt

