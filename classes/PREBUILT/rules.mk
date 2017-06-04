###############################################################################
## @file classes/PREBUILT/rules.mk
## @author Y.M. Morgan
## @date 2016/03/20
##
## Rules for PREBUILT modules.
###############################################################################

_module_msg := $(if $(_mode_host),Host )Prebuilt

include $(BUILD_SYSTEM)/classes/GENERIC/rules.mk

# Nothing more to do
