###############################################################################
## @file autotools.mk
## @author Y.M. Morgan
## @date 2012/07/13
##
## Handle modules using autotools.
###############################################################################

LOCAL_MODULE_CLASS := AUTOTOOLS

ifeq ("$(LOCAL_DESTDIR)","")
LOCAL_DESTDIR := usr
endif

ifeq ("$(LOCAL_MODULE_FILENAME)","")
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done
endif

$(local-add-module)
