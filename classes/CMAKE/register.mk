###############################################################################
## @file classes/CMAKE/register.mk
## @author Y.M. Morgan
## @date 2013/07/24
##
## Register CMAKE modules.
###############################################################################

ifneq ("$(LOCAL_HOST_MODULE)","")
  $(error $(LOCAL_PATH): CMAKE not supported for host modules)
endif

LOCAL_MODULE_CLASS := CMAKE

LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done
LOCAL_DONE_FILES += $(LOCAL_MODULE).done

# If host.cmake is enabled, we're going to use it, hence
# LOCAL_DEPENDS_HOST_MODULES for proper ordering
$(if $(call is-module-in-build-config,host.cmake), \
  $(eval LOCAL_DEPENDS_HOST_MODULES += host.cmake),)

# Register in the system
$(module-add)
