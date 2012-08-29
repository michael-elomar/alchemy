###############################################################################
## @file shared.mk
## @author Y.M. Morgan
## @date 2011/05/14
##
## Build a shared library.
###############################################################################

# check if we want to force static libraries
ifeq ("$(TARGET_FORCE_STATIC_LIBRARIES)","1")
LOCAL_MODULE_CLASS := STATIC_LIBRARY
LOCAL_EXPORT_LDLIBS += $(LOCAL_LDLIBS)
suffix := $(TARGET_STATIC_LIB_SUFFIX)
else
LOCAL_MODULE_CLASS := SHARED_LIBRARY
suffix := $(TARGET_SHARED_LIB_SUFFIX)
endif

ifeq ("$(LOCAL_DESTDIR)","")
LOCAL_DESTDIR := usr/lib
endif

ifeq ("$(LOCAL_MODULE_FILENAME)","")
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE)$(suffix)
endif

$(local-add-module)
