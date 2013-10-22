###############################################################################
## @file config-defs.mk
## @author Y.M. Morgan
## @date 2012/07/09
##
## Configuration management, defines.
###############################################################################

# TARGET_xxx variables to pass as environment for confwrapper
CONFWRAPPER_ENV := \
	TARGET_PRODUCT="$(TARGET_PRODUCT)" \
	TARGET_PRODUCT_VARIANT="$(TARGET_PRODUCT_VARIANT)" \
	TARGET_OS="$(TARGET_OS)" \
	TARGET_OS_FLAVOUR="$(TARGET_OS_FLAVOUR)" \
	TARGET_LIBC="$(TARGET_LIBC)" \
	TARGET_ARCH="$(TARGET_ARCH)" \
	TARGET_CPU="$(TARGET_CPU)"

# Tools
CONFWRAPPER := $(CONFWRAPPER_ENV) $(BUILD_SYSTEM)/scripts/confwrapper.py

# File where global configuration is stored
ifndef CONFIG_GLOBAL_FILE
  CONFIG_GLOBAL_FILE := $(TARGET_CONFIG_DIR)/global.config
endif

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
## Get the name of the configuration file of a module.
## If a variable named custom.<module>.config exists, it is used, otherwise
## it gets the file from the original config directory.
## $1 : module name.
###############################################################################

# Path to original file given as input
__get-orig-module-config = $(strip \
	$(if $(call is-var-defined,custom.$1.config), \
		$(custom.$1.config),$(TARGET_CONFIG_DIR)/$1.config \
	))

# Path to final file after optional patching with sed files
__get-final-module-config = $(strip \
	$(if $(call is-var-defined,custom.$1.config.sedfiles), \
		$(call module-get-build-dir,$1)/$1.config \
		, \
		$(call __get-orig-module-config,$1) \
	))

# Public version
module-get-config = $(call __get-final-module-config,$1)

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
# It removes completely '|' and escape quotes.
# $1 : description
__config-desc-escape = $(subst ",\",$(subst |,$(empty),$1))

# Generate arguments suitable for an action on a module config.
# $1 : module name
__generate-config-module-args = $(strip \
	$(eval __mod := $1) \
	$(eval __desc := $(call __config-desc-escape,$(__modules.$(__mod).DESCRIPTION))) \
	$(eval __depends := $(call module-get-config-depends,$(__mod))) \
	$(eval __dependsCond := $(__modules.$(__mod).CONDITIONAL_LIBRARIES)) \
	$(eval __modPath := $(call path-from-top,$(__modules.$(__mod).PATH))) \
	$(eval __categoryPath := $(__modules.$(__mod).CATEGORY_PATH)) \
	$(eval __sdk := $(__modules.$(__mod).SDK)) \
	$(eval __configInFiles := $(call __get-module-config-in-files,$(__mod))) \
	$(if $(__configInFiles), \
		$(eval __configPath := $(call __get-orig-module-config,$(__mod))), \
		$(eval __configPath := $(empty)) \
	) \
	$(eval __arg := $(__mod)|$(__desc)|$(__depends)|$(__dependsCond)|$(__modPath)) \
	$(eval __arg := $(__arg)|$(__categoryPath)|$(__sdk)|$(__configPath)) \
	$(foreach __f,$(__configInFiles), \
		$(eval __arg := $(__arg)|$(abspath $(__f))) \
	) \
	"$(__arg)")

###############################################################################
## Generate arguments suitable for an action on a full config.
## Do not include prebuilt modules, it has no real sense.
## Autotools modules won't compile under ecos, so don't bother display them or
## any module that has a dependency on it.
## Host module will be activated internally when necessary so don't display them.
###############################################################################

# Check if a module has a dependency on an autotools module
# $1 : module name
__has-autotools-deps = $(strip \
	$(foreach __mod,$(call module-get-all-depends,$1), \
		$(call streq,$(__modules.$(__mod).MODULE_CLASS),AUTOTOOLS) \
	))

# Check if a single module shall be displayed in the config
# $1 : module name
__show-in-config = $(strip \
	$(if $(or $(call is-module-prebuilt,$1),$(call is-module-host,$1)), \
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
	$(foreach __mod,$(__modules), \
		$(if $(or $(call __show-in-config,$(__mod)),$(__modules.$(__mod).SDK)), \
			$(call __generate-config-module-args,$(__mod)) \
		) \
	))

###############################################################################
## Load configuration of a module. If sed files are specified, a copy is made
## in build directory and sed files applied there.
## $1: module name.
###############################################################################

# Path to script used to aply sed files on config file
__apply-sed-script := $(BUILD_SYSTEM)/scripts/config-apply-sedfiles.sh

define __load-config-internal
$(if $(call is-var-defined,custom.$1.config.sedfiles), \
	$(if $(wildcard $(call __get-orig-module-config,$1)), \
		$(foreach __f,$(custom.$1.config.sedfiles), \
			$(info Apply $(__f) on '$1' config) \
		) \
		$(eval __out := $(shell $(__apply-sed-script) \
			$(call __get-orig-module-config,$1) \
			$(call __get-final-module-config,$1) \
			$(custom.$1.config.sedfiles) \
		)) \
	) \
)
-include $(call module-get-config,$1)
endef

###############################################################################
## Load configuration of a module.
## Simply evaluate a call to simplify job of caller.
###############################################################################
load-config = $(eval $(call __load-config-internal,$(LOCAL_MODULE)))
