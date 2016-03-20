###############################################################################
## @file classes/PYTHON_EXTENSION/register.mk
## @author Y.M. Morgan
## @date 2014/07/31
##
## Register PYTHON_EXTENSION modules.
###############################################################################

# Set also LOCAL_MODULE so that everything works correctly
ifneq ("$(LOCAL_HOST_MODULE)","")
  LOCAL_MODULE := $(LOCAL_HOST_MODULE)
endif

LOCAL_MODULE_CLASS := PYTHON_EXTENSION

LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done
LOCAL_DONE_FILES += $(LOCAL_MODULE).done

# Register in the system
$(module-add)
