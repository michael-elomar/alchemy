###############################################################################
## @file config-rules.mk
## @author Y.M. Morgan
## @date 2012/08/31
##
## Configuration management, rules.
###############################################################################

###############################################################################
## General rules.
###############################################################################

# Check everything
.PHONY: config-check
config-check: config-check-global config-check-modules

# Update everything
.PHONY: config-update
config-update: config-update-global config-update-modules

# Avoid checking connfig if we want to configure something or if configuration
# directory does not exist at all
ifeq ("$(CONFIG_IN_MAKE_GOALS)","0")
ifeq ("$(CONFIG_DIR_AVAILABLE)","1")
$(CONFIG_GLOBAL_FILE): __config-check-global
endif
endif

###############################################################################
## Global configuration rules.
###############################################################################

# Check the global configuration
.PHONY: config-check-global
config-check-global: __config-check-global
	@echo "Global config is up to date";

# Internal version with no message
.PHONY: __config-check-global
__config-check-global:
	@( \
		$(call __begin-diff,$(TARGET_CONFIG_DIR)/.global.config.diff) \
		__tmpconfigin=$$(mktemp); \
		$(eval __config := $(CONFIG_GLOBAL_FILE)) \
		$(call __generate-config-in-global,$${__tmpconfigin}) \
		$(CONFWRAPPER) check $${__tmpconfigin} $(__config) $${__tmpdiff}; \
		rm -f $${__tmpconfigin}; \
		$(call __end-diff,1) \
	)

# Update the global configuration by selecting new option at their default value
.PHONY: config-update-global
config-update-global:
	@( \
		__tmpconfigin=$$(mktemp); \
		$(eval __config := $(CONFIG_GLOBAL_FILE)) \
		$(call __generate-config-in-global,$${__tmpconfigin}) \
		$(CONFWRAPPER) update $${__tmpconfigin} $(__config); \
		rm -f $${__tmpconfigin}; \
	)

# Display the global configuration
.PHONY: config-global
config-global:
	@( \
		__tmpconfigin=$$(mktemp); \
		$(eval __config := $(CONFIG_GLOBAL_FILE)) \
		$(call __generate-config-in-global,$${__tmpconfigin}) \
		$(CONFWRAPPER) config $${__tmpconfigin} $(__config); \
		rm -f $${__tmpconfigin}; \
	)

###############################################################################
## Modules configuration rules.
###############################################################################

# Check if module configurations are OK
.PHONY: config-check-modules
config-check-modules: __config-check-modules
	@echo "Module configs are up to date";

# Internal version with no message
.PHONY: __config-check-modules
__config-check-modules: $(foreach __mod,$(__modules),__config-check-modules-$(__mod))

# Update all module configurations by selecting new option at their default value
.PHONY: config-update-modules
config-update-modules: $(foreach __mod,$(__modules),config-update-modules-$(__mod))

# Display all module configurations
.PHONY: config-modules
config-modules: $(foreach __mod,$(__modules),config-modules-$(__mod))

# Check if a specific module configuration is OK
.PHONY: config-check-modules-%
config-check-modules-%: __config-check-modules-%
	$(eval __mod := $*)
	@echo "Config of $(__mod) is up to date";

# Internal version with no message
.PHONY: __config-check-modules-%
__config-check-modules-%:
	@( \
		$(call __begin-diff) \
		$(eval __mod := $*) \
		$(eval __config := $(call __get_module-config,$(__mod))) \
		$(eval __files := $(call __get_module-config-in-files,$(__mod))) \
		if [ "$(__files)" != "" ]; then \
			__tmpconfigin=$$(mktemp); \
			$(call __generate-config-in-module,$${__tmpconfigin},$(__mod),$(__files)) \
			$(CONFWRAPPER) check $${__tmpconfigin} $(__config) $${__tmpdiff}; \
			rm -f $${__tmpconfigin}; \
		fi; \
		$(call __end-diff,1) \
	)

# Update a specific module configuration by selecting new option at their default value
.PHONY: config-update-modules-%
config-update-modules-%:
	@( \
		$(eval __mod := $*) \
		$(eval __config := $(call __get_module-config,$(__mod))) \
		$(eval __files := $(call __get_module-config-in-files,$(__mod))) \
		if [ "$(__files)" != "" ]; then \
			__tmpconfigin=$$(mktemp); \
			$(call __generate-config-in-module,$${__tmpconfigin},$(__mod),$(__files)) \
			$(CONFWRAPPER) update $${__tmpconfigin} $(__config); \
			rm -f $${__tmpconfigin}; \
		fi; \
	)

# Configure a module specifically
.PHONY: config-modules-%
config-modules-%:
	@( \
		$(eval __mod := $*) \
		$(eval __config := $(call __get_module-config,$(__mod))) \
		$(eval __files := $(call __get_module-config-in-files,$(__mod))) \
		if [ "$(__files)" = "" ]; then \
			echo "Nothing to configure for $(__mod)"; \
		else \
			__tmpconfigin=$$(mktemp); \
			$(call __generate-config-in-module,$${__tmpconfigin},$(__mod),$(__files)) \
			$(CONFWRAPPER) config $${__tmpconfigin} $(__config); \
			rm -f $${__tmpconfigin}; \
			echo "Config of $(__mod) saved in $(__config)"; \
		fi; \
	)

