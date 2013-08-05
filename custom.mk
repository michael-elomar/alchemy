###############################################################################
## @file custom.mk
## @author Y.M. Morgan
## @date 2012/12/07
##
## Handle modules using custom rules.
###############################################################################

# Set also LOCAL_MODULE so that everything works correctly
ifneq ("$(LOCAL_HOST_MODULE)","")
  LOCAL_MODULE := $(LOCAL_HOST_MODULE)
endif

LOCAL_MODULE_CLASS := CUSTOM

ifeq ("$(LOCAL_MODULE_FILENAME)","")
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done
endif

$(module-add)
