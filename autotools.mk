###############################################################################
## @file autotools.mk
## @author Y.M. Morgan
## @date 2012/07/13
##
## Handle modules using autotools.
###############################################################################

LOCAL_MODULE_CLASS := AUTOTOOLS

LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done
LOCAL_DONE_FILES := $(LOCAL_MODULE).done

# Check if a module is using old LOCAL_AUTOTOOLS_DIR variable
ifdef LOCAL_AUTOTOOLS_DIR
ifneq ("$(LOCAL_AUTOTOOLS_DIR)","")
  $(info $(LOCAL_PATH): module '$(LOCAL_MODULE)' is using deprecated variable 'LOCAL_AUTOTOOLS_DIR')
  LOCAL_AUTOTOOLS_SUBDIR := $(LOCAL_AUTOTOOLS_DIR)
  LOCAL_AUTOTOOLS_DIR := $(empty)
endif
endif

# Check if a module is using old way of creating hooks.
# Note : we check if variable contains only one word (previously used a the
#        name of the actual macro with commands to execute), but accept if
#        the content is a verbatim '$(empty)'.
__autotools-cmd-vars := \
	UNPACK CONFIGURE BUILD INSTALL CLEAN \
	POST_UNPACK POST_CONFIGURE POST_BUILD POST_INSTALL POST_CLEAN
$(foreach __var,$(__autotools-cmd-vars), \
	$(eval __var2 := LOCAL_AUTOTOOLS_CMD_$(__var)) \
	$(if $(call streq,$(words $(value $(__var2))),1), \
		$(if $(call strneq,$(strip $(value $(__var2))),$$(empty)), \
			$(info $(LOCAL_PATH): module '$(LOCAL_MODULE)' uses variable '$(__var2)' in a deprecated way) \
		) \
	) \
)

$(module-add)
