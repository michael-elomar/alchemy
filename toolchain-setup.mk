###############################################################################
## @file toolchain-setup.mk
## @author Y.M. Morgan
## @date 2016/03/08
###############################################################################

# If product has a toolchain-setup.mk file, include it
ifdef TARGET_CONFIG_DIR
  -include $(TARGET_CONFIG_DIR)/toolchain-setup.mk
endif

# If a sdk has a toolchain-setup.mk file, include it
TARGET_SDK_DIRS ?=
$(foreach __dir,$(TARGET_SDK_DIRS), \
	$(eval -include $(__dir)/toolchain-setup.mk) \
)

# Remember all TARGET_XXX variables from external setup
# FIXME: using := causes trouble if one of the sdk setup file has done a +=
# on a TARGET variable and used a not yet defined variable
#
# For example:
# TARGET_GLOBAL_LDFLAGS += \
#     -L$(TARGET_OUT_STAGING)/usr/lib/arm-linux-gnueabihf/tegra
# TARGET_OUT_STAGING is NOT yet defined, it will be after
#
# It works because the var will be recursive and not immediate
# So we use macro-copy and after full setup value will be correct.
$(foreach __var,$(vars-TARGET_SETUP), \
	$(if $(call is-var-defined,TARGET_$(__var)), \
		$(call macro-copy,TARGET_SETUP_$(__var),TARGET_$(__var)) \
	) \
)

# User specific debug setup makefile
debug-setup-makefile := Alchemy-debug-setup.mk
ifneq ("$(wildcard $(TOP_DIR)/$(debug-setup-makefile))","")
  ifneq ("$(V)","0")
    $(info Including $(TOP_DIR)/$(debug-setup-makefile))
  endif
  include $(TOP_DIR)/$(debug-setup-makefile)
endif

# Setup toolchain specific variables
include $(BUILD_SYSTEM)/toolchains/setup.mk

###############################################################################
## Copy content of host staging from sdks.
## Required because some modules expect to find tools in $(HOST_OUT_STAGING)
## even if it came from a sdk.
###############################################################################

# Generate rules to copy content of host staging from a sdk
# $1 : sdk dir
# The copy will be done only when the atom.mk of the sdk is changed (which is
# normally the case when the sdk is regenerated)
# The copy will be triggered before the build (TARGET_GLOBAL_PREREQUISITES)
# If several sdk are used, copy them sequentially (__sdk-copy-host-list will
# contains previously copied sdk).
__sdk-copy-host-list :=
define __sdk-copy-host
$(TARGET_OUT_BUILD)/sdk_$(subst /,_,$1).done: $1/$(USER_MAKEFILE_NAME) $(__sdk-copy-host-list)
	@echo "Copying $1/host/ to $(HOST_OUT_STAGING)"
	@mkdir -p $$(dir $$@)
	@mkdir -p $(HOST_OUT_STAGING)
	@cp -Raf $1/host/* $(HOST_OUT_STAGING)
	@touch $$@
TARGET_GLOBAL_PREREQUISITES += $(TARGET_OUT_BUILD)/sdk_$(subst /,_,$1).done
__sdk-copy-host-list += $(TARGET_OUT_BUILD)/sdk_$(subst /,_,$1).done
endef

$(foreach __dir,$(TARGET_SDK_DIRS), \
	$(if $(wildcard $(__dir)/host), \
		$(eval $(call __sdk-copy-host,$(__dir))) \
	) \
)

###############################################################################
## Find some tools.
###############################################################################

ifeq ("$(HOST_OS)","darwin")
  # Use bison from Homebrew by default on MacOS, as Xcode version is too old
  BISON_HOMEBREW_PATH := /usr/local/opt/bison/bin/bison
  BISON_PATH := $(shell if [ -e $(BISON_HOMEBREW_PATH) ]; then echo $(BISON_HOMEBREW_PATH); else which bison 2>/dev/null; fi)
else
  BISON_PATH := $(shell which bison 2>/dev/null)
endif
# We need bison 2.5 but android force version 2.3 in the path that causes troubles
ifneq ("$(BISON_PATH)","")
  BISON_VERSION := $(shell $(BISON_PATH) --version | head -1 | perl -pe "s/.*?([0-9]+\.[0-9]+(\.[0-9]+)?(-[0-9]+)?)$$/\1/")
  ifeq ("$(call check-version,$(BISON_VERSION),2.5)","")
    BISON_PATH := /usr/bin/bison
  endif
endif
