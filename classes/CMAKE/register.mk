###############################################################################
## @file classes/CMAKE/register.mk
## @author Y.M. Morgan
## @date 2013/07/24
##
## Register CMAKE modules.
###############################################################################

# Set also LOCAL_MODULE so that everything works correctly
ifneq ("$(LOCAL_HOST_MODULE)","")
  LOCAL_MODULE := $(LOCAL_HOST_MODULE)
endif

LOCAL_MODULE_CLASS := CMAKE

LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done
LOCAL_DONE_FILES += $(LOCAL_MODULE).done

# Compatiblity
$(call macro-copy,LOCAL_CMD_CONFIGURE,LOCAL_CMAKE_CMD_CONFIGURE)
$(call macro-copy,LOCAL_CMD_BUILD,LOCAL_CMAKE_CMD_BUILD)
$(call macro-copy,LOCAL_CMD_INSTALL,LOCAL_CMAKE_CMD_INSTALL)
$(call macro-copy,LOCAL_CMD_CLEAN,LOCAL_CMAKE_CMD_CLEAN)
$(call macro-copy,LOCAL_CMD_POST_CONFIGURE,LOCAL_CMAKE_CMD_POST_CONFIGURE)
$(call macro-copy,LOCAL_CMD_POST_BUILD,LOCAL_CMAKE_CMD_POST_BUILD)
$(call macro-copy,LOCAL_CMD_POST_INSTALL,LOCAL_CMAKE_CMD_POST_INSTALL)
$(call macro-copy,LOCAL_CMD_POST_CLEAN,LOCAL_CMAKE_CMD_POST_CLEAN)

# Register in the system
$(module-add)
