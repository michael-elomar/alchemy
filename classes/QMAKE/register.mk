###############################################################################
## @file classes/QMAKE/register.mk
## @author Y.M. Morgan
## @date 2014/01/08
##
## Register QMAKE modules.
###############################################################################

# Set also LOCAL_MODULE so that everything works correctly
ifneq ("$(LOCAL_HOST_MODULE)","")
  LOCAL_MODULE := $(LOCAL_HOST_MODULE)
endif

LOCAL_MODULE_CLASS := QMAKE

ifeq ("$(LOCAL_QMAKE_PRO_FILE)","")
  LOCAL_QMAKE_PRO_FILE := $(LOCAL_MODULE).pro
endif

LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done
LOCAL_DONE_FILES += $(LOCAL_MODULE).done

# Register in the system
$(module-add)
