###############################################################################
## @file config-defs.mk
## @author Y.M. Morgan
## @date 2012/07/09
##
## Configuration management, defines.
###############################################################################

# Tools
CONFWRAPPER := $(BUILD_SYSTEM)/scripts/confwrapper.py

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

# Include global config file, do not fail if directory does not exists or we
# are requested to skip checks.
ifeq ("$(CONFIG_DIR_AVAILABLE)","1")
  ifeq ("$(SKIP_DEPS_AND_CHECKS)","0")
    include $(CONFIG_GLOBAL_FILE)
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
## If a variable named custom.<module>.config exists, it is used, otherwise
## it gets the file from the original config directory.
## $1 : module name.
###############################################################################
__get-module-config = $(strip \
	$(if $(call strneq,$(origin custom.$1.config),undefined), \
		$(custom.$1.config),$(CONFIG_ORIG_DIR)/$1.config \
	))

module-get-config = $(call __get-module-config,$1)

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
###############################################################################

# Escape description so it can be inserted as a parameter in the command line
# It removes completely ':' and escape quotes.
# $1 : description
__config-desc-escape = $(subst ",\",$(subst $(colon),$(empty),$1))

# Generate arguments suitable for an action on a module config.
# $1 : module name
__generate-config-module-args = $(strip \
	$(eval __mod := $1) \
	$(eval __desc := $(call __config-desc-escape,$(__modules.$(__mod).DESCRIPTION))) \
	$(eval __depends := $(call module-get-config-depends,$(__mod))) \
	$(eval __grouppath := $(call path-from-top,$(__modules.$(__mod).PATH))) \
	$(eval __config := $(call __get-module-config,$(__mod))) \
	$(eval __configInFiles := $(call __get-module-config-in-files,$(__mod))) \
	$(eval __arg := $(__mod):$(__desc):$(__depends):$(__grouppath):$(__config)) \
	$(foreach __f,$(__configInFiles), \
		$(eval __arg := $(__arg):$(call fullpath,$(__f))) \
	) \
	"$(__arg)")

###############################################################################
## Generate arguments suitable for an action on a full config.
## Do not include prebuilt modules, it has no real sense.
## Autotools modules won't compile under ecos, so don't bother display them or
## any module that has a dependency on it.
###############################################################################

# Check if a module has a dependency on an autotools module
# $1 : module name
__has-autotools-deps = $(strip \
	$(foreach __mod,$(call module-get-all-depends,$1)), \
		$(call streq,$(__modules.$(__mod).MODULE_CLASS),AUTOTOOLS) \
	))

# Check if a single module shall be displayed in the config
# $1 : module name
__show-in-config = $(strip \
	$(if $(call streq,$(__modules.$1.MODULE_CLASS),PREBUILT), \
		$(false), \
		$(if $(call strneq,$(TARGET_OS),ecos), \
			$(true), \
			$(if $(call streq,$(__modules.$1.MODULE_CLASS),AUTOTOOLS), \
				$(false), \
				$(if $(call __has-autotools-deps,$1),$(false),$(true)) \
			) \
		) \
	))

# No arguments
__generate-config-args = $(strip \
	$(foreach __mod,$(sort $(__modules)), \
		$(if $(call __show-in-config,$(__mod)), \
			$(call __generate-config-module-args,$(__mod)) \
		) \
	))

###############################################################################
## Load configuration of a module.
## $1: module name.
###############################################################################
define __load-config-internal
  $(eval __config := $(call __get-module-config,$1))
  -include $(__config)
endef

###############################################################################
## Load configuration of a module.
## Simply evaluate a call to simplify job of caller.
###############################################################################
load-config = $(eval $(call __load-config-internal,$(LOCAL_MODULE)))
