###############################################################################
## @file config-rules.mk
## @author Y.M. Morgan
## @date 2012/08/31
##
## Configuration management, rules.
###############################################################################

# Avoid checking global config if directory does not exists or we
# are requested to skip checks.
ifeq ("$(CONFIG_DIR_AVAILABLE)","1")
ifeq ("$(SKIP_DEPS_AND_CHECKS)","0")
$(CONFIG_GLOBAL_FILE): __config-check
endif
endif

###############################################################################
## Full configuration rules.
###############################################################################

# Check everything at once
.PHONY: config-check
config-check:
	$(eval __args := $(call __generate-config-args))
	@( \
		if $(CONFWRAPPER) --main=$(CONFIG_GLOBAL_FILE) --diff check $(__args); then \
			echo "All configs are up to date"; \
		fi; \
	)

# Check everything at once, in silence, stopping in case not up to date
.PHONY: __config-check
__config-check:
	$(eval __args := $(call __generate-config-args))
	@$(CONFWRAPPER) --main=$(CONFIG_GLOBAL_FILE) check $(__args)

# Update everything at once
.PHONY: config-update
config-update:
	$(eval __args := $(call __generate-config-args))
	@$(CONFWRAPPER) --main=$(CONFIG_GLOBAL_FILE) update $(__args)

# Configure everything at once using default user interface (qconf)
.PHONY: config
config:
	$(eval __args := $(call __generate-config-args))
	@$(CONFWRAPPER) --main=$(CONFIG_GLOBAL_FILE) config $(__args)

# Configure everything at once using qconf
.PHONY: xconfig
xconfig:
	$(eval __args := $(call __generate-config-args))
	@$(CONFWRAPPER) --main=$(CONFIG_GLOBAL_FILE) --ui=qconf config $(__args)

# Configure everything at once using mconf
.PHONY: menuconfig
menuconfig:
	$(eval __args := $(call __generate-config-args))
	@$(CONFWRAPPER) --main=$(CONFIG_GLOBAL_FILE) --ui=mconf config $(__args)

# Configure everything at once using nconf
.PHONY: nconfig
nconfig:
	$(eval __args := $(call __generate-config-args))
	@$(CONFWRAPPER) --main=$(CONFIG_GLOBAL_FILE) --ui=nconf config $(__args)

###############################################################################
## Module configuration rules.
###############################################################################

# Check a module
.PHONY: %-config-check
%-config-check:
	$(eval __mod := $*)
	$(eval __args := $(call __generate-config-module-args,$(__mod)))
	$(if $(call __check-module-configurable,$(__mod)), \
		@( \
			if $(CONFWRAPPER) --diff check $(__args); then \
				echo "$(__mod) config is up to date"; \
			fi; \
		) \
	)

# Check a module, in silence, stopping in case not up to date
.PHONY: __config-check-%
__config-check-%:
	$(eval __mod := $*)
	$(eval __args := $(call __generate-config-module-args,$(__mod)))
	$(if $(call __check-module-configurable,$(__mod)), \
		@$(CONFWRAPPER) check $(__args) \
	)

# Update a module
.PHONY: %-config-update
%-config-update:
	$(eval __mod := $*)
	$(eval __args := $(call __generate-config-module-args,$(__mod)))
	$(if $(call __check-module-configurable,$(__mod)), \
		@$(CONFWRAPPER) update $(__args) \
	)

# Configure a module using default user interface (qconf)
.PHONY: %-config
%-config:
	$(eval __mod := $*)
	$(eval __args := $(call __generate-config-module-args,$(__mod)))
	$(if $(call __check-module-configurable,$(__mod)), \
		@$(CONFWRAPPER) config $(__args) \
	)

# Configure a module using qconf
.PHONY: %-xconfig
%-xconfig:
	$(eval __mod := $*)
	$(eval __args := $(call __generate-config-module-args,$(__mod)))
	$(if $(call __check-module-configurable,$(__mod)), \
		@$(CONFWRAPPER) --ui=qconf config $(__args) \
	)

# Configure a module using mconf
.PHONY: %-menuconfig
%-menuconfig:
	$(eval __mod := $*)
	$(eval __args := $(call __generate-config-module-args,$(__mod)))
	$(if $(call __check-module-configurable,$(__mod)), \
		@$(CONFWRAPPER) --ui=mconf config $(__args) \
	)

# Configure a module using nconf
.PHONY: %-nconfig
%-nconfig:
	$(eval __mod := $*)
	$(eval __args := $(call __generate-config-module-args,$(__mod)))
	$(if $(call __check-module-configurable,$(__mod)), \
		@$(CONFWRAPPER) --ui=nconf config $(__args) \
	)
