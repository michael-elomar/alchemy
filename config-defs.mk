###############################################################################
## @file config-defs.mk
## @author Y.M. Morgan
## @date 2012/07/09
##
## Configuration management, defines.
###############################################################################

# Tools
CONFWRAPPER := $(BUILD_SYSTEM)/confwrapper.py

# Directory where original configurations are stored
CONFIG_ORIG_DIR := $(TARGET_CONFIG_DIR)

# File where global configuration is stored
CONFIG_GLOBAL_FILE := $(CONFIG_ORIG_DIR)/global.config

# Remember if the config directory is present or not
ifeq ("$(wildcard $(TARGET_CONFIG_DIR))","")
  CONFIG_DIR_AVAILABLE := 0
else
  CONFIG_DIR_AVAILABLE := 1
endif

# Avoid checking global config if we are requested to skip it
# Skip also if configuration directory does not exist at all
# In other cases, try to include config but do not fail if not possible
ifeq ("$(CONFIG_DIR_AVAILABLE)","1")
  ifeq ("$(SKIP_DEPS_AND_CHECKS)","0")
    include $(CONFIG_GLOBAL_FILE)
    $(CONFIG_GLOBAL_FILE): __config-check
  else
    -include $(CONFIG_GLOBAL_FILE)
  endif
else
  -include $(CONFIG_GLOBAL_FILE)
endif

###############################################################################
## Check that a module is configurable.
## $1 : module name.
###############################################################################
__check-module-configurable = $(strip \
	$(if $(call is-module-registered,$1), \
		$(if $(call __get-module-config-in-files,$1), \
			$(true), \
			$(info Nothing configurable for $1) \
		), \
		$(error $1 is not a registered module) \
	))

###############################################################################
## Get the name of the configuration file of a module.
## $1 : module name.
###############################################################################
__get-module-config = $(CONFIG_ORIG_DIR)/$1.config

###############################################################################
## Get the list of path to Config.in files of a module.
## $1 : module name.
## Remark : should be called only after the module database have been built.
###############################################################################
__get-module-config-in-files = $(strip \
	$(eval __path := $(__modules.$1.PATH)) \
	$(eval __files := $(__modules.$1.CONFIG_FILES)) \
	$(addprefix $(__path)/,$(__files)))

###############################################################################
## Generate arguments suitable for an action on a module config.
## $1 : module name
###############################################################################
__generate-config-module-args = $(strip \
	$(eval __mod := $1) \
	$(eval __config := $(call __get-module-config,$(__mod))) \
	$(eval __configInFiles := $(call __get-module-config-in-files,$(__mod))) \
	$(eval __arg := $(__mod):$(__config)) \
	$(foreach __f,$(__configInFiles), \
		$(eval __arg := $(__arg):$(call fullpath,$(__f))) \
	) \
	$(__arg))

###############################################################################
## Generate arguments suitable for an action on a full config.
###############################################################################
__generate-config-args = $(strip \
	$(foreach __mod,$(sort $(__modules)), \
		$(call __generate-config-module-args,$(__mod)) \
	))

###############################################################################
## Load configuration of a module.
###############################################################################

# Avoid checking module config if we are requested to skip it
# In this case, do not fail if it can not be found
define __load-config-internal
  $(eval __config := $(call __get-module-config,$1))
  ifeq ("$(SKIP_DEPS_AND_CHECKS)","0")
    include $(__config)
    $(__config): __config-check-$1
  else
    -include $(__config)
  endif
endef

###############################################################################
## Load configuration of a module.
## Simply evaluate a call to simplify job of caller.
###############################################################################
load-config = $(eval $(call __load-config-internal,$(LOCAL_MODULE)))
