###############################################################################
## @file executable.mk
## @author Y.M. Morgan
## @date 2011/05/14
##
## Build an executable.
###############################################################################

# Set also LOCAL_MODULE so that everything works correctly
ifneq ("$(LOCAL_HOST_MODULE)","")
  LOCAL_MODULE := $(LOCAL_HOST_MODULE)
endif

LOCAL_MODULE_CLASS := EXECUTABLE

ifeq ("$(LOCAL_DESTDIR)","")
LOCAL_DESTDIR := usr/bin
endif

ifeq ("$(LOCAL_MODULE_FILENAME)","")
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE)$(TARGET_EXE_SUFFIX)
endif

$(module-add)
