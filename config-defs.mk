###############################################################################
## @file config-defs.mk
## @author Y.M. Morgan
## @date 2012/07/09
##
## Configuration management, defines.
###############################################################################

# Tools (absolute path)
CONFWRAPPER := $(call fullpath,$(BUILD_SYSTEM)/confwrapper.sh)

# Directory where original configurations are stored
CONFIG_ORIG_DIR := $(TARGET_CONFIG_DIR)

# File where global configuration is stored
CONFIG_GLOBAL_FILE := $(CONFIG_ORIG_DIR)/global.config
-include $(CONFIG_GLOBAL_FILE)

# Determine if a config something is requested
CONFIG_IN_MAKE_GOALS := 0
ifneq ("$(findstring config-,$(MAKECMDGOALS))","")
  CONFIG_IN_MAKE_GOALS := 1
endif

# Remember if the config directory is present or not
ifeq ("$(wildcard $(TARGET_CONFIG_DIR))","")
  CONFIG_DIR_AVAILABLE := 0
else
  CONFIG_DIR_AVAILABLE := 1
endif

###############################################################################
## Get the name of the configuration file of a module.
## $1 : module name.
###############################################################################
__get_module-config = $(CONFIG_ORIG_DIR)/$1.config

###############################################################################
## Get the list of path to Config.in files of a module.
## $1 : module name.
## Remark : should be called only after the module database have been built.
###############################################################################
__get_module-config-in-files = \
	$(eval __path := $(__modules.$1.PATH)) \
	$(eval __files := $(__modules.$1.CONFIG_FILES)) \
	$(addprefix $(__path)/,$(__files))

###############################################################################
## Begin the update/check operation by creating a temp diff file.
## $1 : file to use as a diff file, or empty to generate one
###############################################################################
define __begin-diff
	if [ "$1" = "" ]; then __tmpdiff=$$(mktemp); else __tmpdiff=$1; fi; \
	truncate -s 0 $${__tmpdiff};
endef

###############################################################################
## End the update/check operation.
## $1 : 1 to exit, 0 or empty to continue.
###############################################################################
define __end-diff
	if [ "$$(stat -c %s $${__tmpdiff})" != "0" ]; then \
		echo "Configuration diff can be found in $${__tmpdiff}"; \
		if [ "$1" = "1" ]; then exit 1; fi; \
	else \
		rm -f $${__tmpdiff}; \
	fi;
endef

###############################################################################
## Generate Config.in for global configuration.
## $1 : destination file.
###############################################################################
define __generate-config-in-global
	rm -f $1; \
	mkdir -p $(dir $1); \
	touch $1; \
	echo "menu Modules" >> $1; \
	$(foreach __mod,$(__modules), \
		$(eval __build := BUILD_$(call get-define,$(__mod))) \
		echo "config $(__build)" >> $1; \
		echo "  bool 'Build $(__mod)'" >> $1; \
		echo "  default y" >> $1; \
		echo "  help" >> $1; \
		echo "    Build $(__mod)" >> $1; \
	) \
	echo "endmenu" >> $1;
endef

###############################################################################
## Generate Config.in for one module.
## $1 : destination file.
## $2 : module name.
## $3 : list of path to Config.in files.
###############################################################################
define __generate-config-in-module
	rm -f $1; \
	mkdir -p $(dir $1); \
	touch $1; \
	echo "menu $2" >> $1; \
	$(if $(strip $3), \
		$(foreach __f,$3, \
			echo "source $(call fullpath,$(__f))" >> $1; \
		) \
	) \
	echo "endmenu" >> $1;
endef

###############################################################################
## Load configuration of a module.
###############################################################################

# Do NOT check the config if a config is explicitely requested
define __load-config-internal
  $(eval __config := $(call __get_module-config,$1))
  -include $(__config)
  ifeq ("$(CONFIG_IN_MAKE_GOALS)","0")
    $(__config): __config-check-modules-$1
  endif
endef

###############################################################################
## Load configuration of a module.
## Simply evaluate a call to simplify job of caller.
###############################################################################
load-config = $(eval $(call __load-config-internal,$(LOCAL_MODULE)))

