###############################################################################
## @file cmake.mk
## @author Y.M. Morgan
## @date 2013/07/24
##
## Handle modules using cmake.
###############################################################################

LOCAL_MODULE_CLASS := CMAKE

LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done
LOCAL_DONE_FILES := $(LOCAL_MODULE).done

$(module-add)
