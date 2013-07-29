###############################################################################
## @file defs.mk
## @author Y.M. Morgan
## @date 2011/05/14
##
## This file contains macros used by other makefiles.
###############################################################################

###############################################################################
## Some useful macros.
###############################################################################

# Empty variable and space (useful for pretty prinf of messages)
empty :=
space := $(empty) $(empty)
space4 := $(space)$(space)$(space)$(space)

# Other special characters definition (useful to avoid parsing error in functions)
dollar := $$
comma := ,
colon := :
left-paren := (
right-paren := )

# True/False values. Any non-empty test is considered as True
true := T
false :=

# New line definition, please keep the two and only two empty lines in the macro
define endl


endef

# Return negation of argument.
# $1 : input boolean argument.
not = $(if $1,$(false),$(true))

# Return the first element of a list.
# $1 : input list.
first = $(firstword $1)

# Return the list with the first element removed.
# $1 : input list.
rest = $(wordlist 2,$(words $1),$1)

# Get a path relative to top directory.
# $1 : full path to convert.
path-from-top = $(patsubst $(TOP_DIR)/%,%,$1)

# Replace '-' by '_' and convert to upper case.
# $1 : text to convert.
_from := a b c d e f g h i j k l m n o p q r s t u v w x y z . -
_to   := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z _ _
_conv := $(join $(addsuffix :,$(_from)),$(_to))
get-define = $(strip \
	$(eval __tmp := $1) \
	$(foreach __pair, $(_conv), \
		$(eval __pair2 := $(subst :,$(space),$(__pair))) \
		$(eval __w1 := $(word 1,$(__pair2))) \
		$(eval __w2 := $(word 2,$(__pair2))) \
		$(eval __tmp := $(subst $(__w1),$(__w2),$(__tmp))) \
	) \
	$(__tmp))

# Remove quotes from string
remove-quotes = $(strip $(subst ",,$1))

# Check that the current directory is the top directory
check-pwd-is-top-dir = \
	$(if $(patsubst $(TOP_DIR)%,%,$(shell pwd)), \
		$(error Not at the top directory))

# Determine if a path is absolute.
# It simply checks if the path starts with a '/'
# $1 : path to check.
is-path-absolute = $(strip $(call not,$(patsubst /%,,$1)))

# Determine if a path is a directory. This check does not look in the
# filesystem, it just checks if the path ends with a '/'.
# $1 : path to check.
is-path-dir = $(strip $(call not,$(patsubst %/,,$1)))

# Compare 2 strings for equality.
# $1 : first string.
# $2 : second string.
streq = $(if $(filter-out xx,x$(subst $1,,$2)$(subst $2,,$1)x),$(false),$(true))

# Compare 2 strings for inequality.
# $1 : first string.
# $2 : second string.
strneq = $(call not,$(call streq,$1,$2))

# Check that a version is at least the one given.
# $1 : version.
# $2 : minimum version.
check-version = $(call strneq,0,$(shell expr $1 \>= $2))

# Make sure an item appears only once in a list, keeping only the last reference.
# $1 : input list.
uniq2 = \
	$(eval __r := $1) \
	$(foreach __f,$1, \
		$(eval __r := $(call rest,$(__r))) \
		$(if $(filter $(__f),$(__r)),,$(__f)) \
	)

# Determine if a variable has been defined
# $1 : name of the variable (not its content)
is-var-defined = $(call strneq,$(origin $1),undefined)

# Determine if a variable is not defined
# $1 : name of the variable (not its content)
is-var-undefined = $(call streq,$(origin $1),undefined)

###############################################################################
## Use some colors if requested.
###############################################################################

# Forcing using /bin/echo ensures -e option exists and do what is expected
ifeq ("$(USE_COLORS)","1")
  CLR_DEFAULT := $(shell /bin/echo -e "\033[00m")
  CLR_RED     := $(shell /bin/echo -e "\033[31m")
  CLR_GREEN   := $(shell /bin/echo -e "\033[32m")
  CLR_YELLOW  := $(shell /bin/echo -e "\033[33m")
  CLR_BLUE    := $(shell /bin/echo -e "\033[34m")
  CLR_PURPLE  := $(shell /bin/echo -e "\033[35m")
  CLR_CYAN    := $(shell /bin/echo -e "\033[36m")
else
  CLR_DEFAULT :=
  CLR_RED     :=
  CLR_GREEN   :=
  CLR_YELLOW  :=
  CLR_BLUE    :=
  CLR_PURPLE  :=
  CLR_CYAN    :=
endif

###############################################################################
## Modules database.
## For each module 'mod', __modules.mod.<field> is used to store
## module-specific information.
###############################################################################
__modules := $(empty)

###############################################################################
## Clear a list of variables.
###############################################################################
clear-vars = $(foreach __varname,$1,$(eval $(__varname) := $(empty)))

###############################################################################
## The list of fields related to dependency
###############################################################################
modules-fields-depends := \
	depends \
	depends.EXTERNAL_LIBRARIES \
	depends.STATIC_LIBRARIES \
	depends.WHOLE_STATIC_LIBRARIES \
	depends.SHARED_LIBRARIES \
	depends.link \
	depends.other \
	depends.headers \
	depends.all

###############################################################################
## Check for usage of CPPFLAGS instead of CXXFLAGS.
## Correctly save same in CXXFLAGS but warn user.
###############################################################################
check-cppflags-compat = \
	$(if $(LOCAL_CPPFLAGS), \
		$(eval LOCAL_CXXFLAGS += $(LOCAL_CPPFLAGS)) \
		$(eval __msg := Please use LOCAL_CXXFLAGS instead of LOCAL_CPPFLAGS) \
		$(warning $(LOCAL_PATH): module '$(__mod)': $(__msg)) \
	) \
	$(if $(LOCAL_EXPORT_CPPFLAGS), \
		$(eval LOCAL_EXPORT_CXXFLAGS += $(LOCAL_EXPORT_CPPFLAGS)) \
		$(eval __msg := Please use LOCAL_EXPORT_CXXFLAGS instead of LOCAL_EXPORT_CPPFLAGS) \
		$(warning $(LOCAL_PATH): module '$(__mod)': $(__msg)) \
	)

###############################################################################
## Add a module in the build system and save its LOCAL_xxx variables.
## All LOCAL_xxx variables will be saved in module database.
## An internal prebuilt module (for example a bionic one) will take precedence
## over another module with the same name.
## A module comming from a sdk will be overidden by a standard module.
###############################################################################
module-add = \
	$(eval LOCAL_MODULE := $(strip $(LOCAL_MODULE))) \
	$(if $(LOCAL_MODULE),$(empty), \
		$(error $(LOCAL_PATH): LOCAL_MODULE is not defined)) \
	$(eval __mod := $(LOCAL_MODULE)) \
	$(eval __add := 1) \
	$(if $(call is-module-registered,$(__mod)), \
		$(if $(__modules.$(__mod).SDK), \
			$(info $(LOCAL_PATH): module '$(__mod)' overwrites sdk at $(__modules.$(__mod).SDK)) \
			$(foreach __local,$(vars-LOCAL), \
				$(eval __modules.$(__mod).$(__local) := $(empty))) \
			$(foreach __local,$(macros-LOCAL), \
				$(eval __modules.$(__mod).$(__local) := $(empty))) \
			, \
			$(eval __add := 0) \
			$(eval __path := $(__modules.$(__mod).PATH)) \
			$(eval __class := $(__modules.$(__mod).MODULE_CLASS)) \
			$(if $(call streq,$(__class),PREBUILT), \
				$(warning $(LOCAL_PATH): module '$(__mod)' is already prebuilt), \
				$(error $(LOCAL_PATH): module '$(__mod)' already registered at $(__path)) \
			) \
		) \
	) \
	$(if $(call streq,$(__add),1), \
		$(eval __modules += $(__mod)) \
		$(foreach __local,$(vars-LOCAL), \
			$(eval __modules.$(__mod).$(__local) := $(LOCAL_$(__local))) \
		) \
		$(foreach __local,$(macros-LOCAL), \
			$(call macro-copy,__modules.$(__mod).$(__local),LOCAL_$(__local)) \
		) \
		$(check-cppflags-compat) \
		$(call install-headers-setup,$(LOCAL_MODULE)) \
	)

###############################################################################
## Get the module name as a 'define' value to be used in kconfig and CFLAGS.
## $1 : module name.
###############################################################################
module-get-define = $(strip \
	$(if $(call is-var-undefined,__modules.$1.define), \
		$(eval __modules.$1.define := $(call get-define,$1)) \
	) \
	$(__modules.$1.define))

###############################################################################
## Check if a list of targets is given in make goals.
## $1 : list of targets to check
###############################################################################
is-targets-in-make-goals = $(strip \
	$(foreach __t,$1, \
		$(foreach __g,$(MAKECMDGOALS), \
			$(call streq,$(__g),$(__t)) \
		) \
	))

###############################################################################
## Check if a module is given in make goals
## It consider its clean/dirclean as well.
## $1 : module to check.
###############################################################################
is-module-in-make-goals = $(strip \
	$(call is-targets-in-make-goals,$1 $1-clean $1-dirclean))

###############################################################################
## Check if a module is registered. It simply verifies that the variable
## __modules.$1.PATH has been set.
## $1 : module to check.
###############################################################################
is-module-registered = $(call is-var-defined,__modules.$1.PATH)

###############################################################################
## Check if a module is built externally (by autotools or custom rules).
## $1 : module to check.
## AUTOTOOLS/CMAKE/GENERIC/CUSTOM class or empty class means external.
###############################################################################
is-module-external = $(strip \
	$(eval __class := $(__modules.$1.MODULE_CLASS)) \
	$(or $(call streq,$(__class),AUTOTOOLS), \
		$(call streq,$(__class),CMAKE), \
		$(call streq,$(__class),GENERIC), \
		$(call streq,$(__class),CUSTOM) \
	))

###############################################################################
## Check if a module is prebuilt.
## $1 : module to check.
## Note : a module is prebuilt if its class is PREBUILT or is part of a sdk
## in which case LOCAL_SDK is not empty
###############################################################################
is-module-prebuilt = $(strip \
	$(or \
		$(call streq,$(__modules.$1.MODULE_CLASS),PREBUILT), \
		$(__modules.$1.SDK) \
	))

###############################################################################
## Check if a module will be built.
## $1 : module to check.
## Prebuild modules are considered as in the config (even if they are not
## actually in it).
## If no configuration directory present, always return true.
###############################################################################
is-module-in-build-config = $(strip \
	$(if $(call is-module-prebuilt,$1),$(true), \
		$(eval __var := CONFIG_ALCHEMY_BUILD_$(call module-get-define,$1)) \
		$(if $(call streq,$(CONFIG_DIR_AVAILABLE),0),$(true), \
			$(if $(call is-var-defined,$(__var)), \
				$(if $($(__var)),$(true),$(false)), \
				$(false) \
			) \
		) \
	))

###############################################################################
## Restore the recorded LOCAL_XXX definitions for a given module. Called
## for each module once they have all been registered and their dependencies
## have been computed to actually define rules.
## $1 : name of module to restore.
###############################################################################
module-restore-locals = \
	$(foreach __local,$(vars-LOCAL), \
		$(eval LOCAL_$(__local) := $(__modules.$1.$(__local))) \
	) \
	$(foreach __local,$(macros-LOCAL), \
		$(call macro-copy,LOCAL_$(__local),__modules.$1.$(__local)) \
	)

###############################################################################
## Used to check all dependencies once all module information has been
## recorded.
###############################################################################

# Check dependencies of all modules. Only if module will be built and not from
# a sdk.
modules-check-depends = \
	$(foreach __mod,$(__modules), \
		$(if $(call is-module-in-build-config,$(__mod)), \
			$(if $(__modules.$(__mod).SDK),$(empty), \
				$(call __module-check-depends,$(__mod)) \
			) \
		) \
	)

# Check dependencies of a module.
# $1 : module name.
__module-check-depends = \
	$(eval __path := $(__modules.$1.PATH)) \
	$(call __module-check-depends-direct,$1) \
	$(call __module-check-depends-other,$1) \
	$(call __module-check-depends-headers,$1) \
	$(call __module-check-libs-class,$1,WHOLE_STATIC_LIBRARIES,STATIC_LIBRARY) \
	$(call __module-check-libs-class,$1,STATIC_LIBRARIES,STATIC_LIBRARY) \
	$(call __module-check-libs-class,$1,SHARED_LIBRARIES,SHARED_LIBRARY)

# Check direct dependencies
# $1 : module name.
__module-check-depends-direct = \
	$(foreach __lib,$(__modules.$1.depends), \
		$(if $(call is-module-registered,$(__lib)), \
			$(if $(call is-module-in-build-config,$(__lib)),$(empty), \
				$(error $(__path): module '$1' depends on disabled module '$(__lib)') \
			), \
			$(error $(__path): module '$1' depends on unknown module '$(__lib)') \
		) \
	)

# Make sure runtime dependencies (other) are OK. Print warning only
# $1 : module name.
__module-check-depends-other = \
	$(foreach __lib,$(__modules.$1.depends.other), \
		$(if $(call is-module-registered,$(__lib)), \
			$(if $(call is-module-in-build-config,$(__lib)),$(empty), \
				$(warning $(__path): module '$1' requires disabled module '$(__lib)') \
			), \
			$(warning $(__path): module '$1' requires unknown module '$(__lib)') \
		) \
	)

# Make sure headers dependencies are OK.
# $1 : module name.
__module-check-depends-headers = \
	$(foreach __lib,$(__modules.$1.depends.headers), \
		$(if $(call is-module-registered,$(__lib)),$(empty), \
			$(error $(__path): module '$1' depends on headers of unknown module '$(__lib)') \
		) \
	)

# $1 : module name of owner.
# $2 : dependency to check (WHOLE_STATIC_LIBRARIES,STATIC_LIBRARIES,SHARED_LIBRARIES).
# $3 : class to check (STATIC_LIBRARY,SHARED_LIBRARY)
__module-check-libs-class = \
	$(foreach __lib,$(__modules.$1.$2), \
		$(call __module-check-lib-class,$1,$(__lib),$3) \
	)

# Check that a dependency is of the correct class
# $1 : module name of owner.
# $2 : library to check.
# $3 : class to check (STATIC_LIBRARY,SHARED_LIBRARY)
__module-check-lib-class = \
	$(if $(call strneq,$(__modules.$2.MODULE_CLASS),$3), \
		$(eval __path := $(__modules.$1.PATH)) \
		$(error $(__path): module '$1' depends on module '$2' which is not of class '$3') \
	)

###############################################################################
## Used to make some internal checks.
###############################################################################

# Check variables of all modules. Only if module will be built
modules-check-variables = \
	$(foreach __mod,$(__modules), \
		$(if $(call is-module-in-build-config,$(__mod)), \
			$(call __module-check-variables,$(__mod)) \
		) \
	)

# Check variables of a module
# $1 : module name.
__module-check-variables = \
	$(call __module-check-src-files,$1) \
	$(call __module-check-c-includes,$1,$(__modules.$1.C_INCLUDES),uses) \
	$(call __module-check-c-includes,$1,$(__modules.$1.EXPORT_C_INCLUDES),exports) \

# Check that all files listed in LOCAL_SRC_FILES exist
# $1 : module name.
__module-check-src-files = \
	$(eval __path := $(__modules.$1.PATH)) \
	$(foreach __file,$(__modules.$1.SRC_FILES), \
		$(if $(wildcard $(__path)/$(__file)),$(empty), \
			$(warning $(__path): module '$1' uses missing source file '$(__file)') \
		) \
	)

# Check that all directory listed in LOCAL_C_INCLUDES exist. Only check the
# ones relative to LOCAL_PATH (others may not exist yet if in build/staging)
# $1 : module name.
# $2 : list of include directory to check.
# $3 : message : 'uses' or 'exports'
__module-check-c-includes = \
	$(eval __path := $(__modules.$1.PATH)) \
	$(foreach __inc,$(patsubst -I%,%,$2), \
		$(if $(call not,$(patsubst $(__path)%,,$(__inc))), \
			$(if $(wildcard $(__inc)),$(empty), \
				$(warning $(__path): module '$1' $3 missing include '$(__inc)') \
			) \
		) \
	)

###############################################################################
## Used to compute all dependencies once all module information has been
## recorded.
###############################################################################

# Variable used to detect cycles in recursion. It will hold all modules
# processed so far. If a module is already in the list, a loop is detected
__depends-loop :=

# Determine if a module is already in the recursion
# $1 : module to check
__is-in-depends-loop = $(strip \
	$(foreach __i,$(__depends-loop), \
		$(call streq,$1,$(__i)) \
	))

# Compute dependencies of all modules
# Do direct dependencies first, then full
# The dummy assignment is to discard output generated internally
modules-compute-depends = \
	$(foreach __mod,$(__modules), \
		$(call conditional-libraries-setup,$(__mod)) \
		$(foreach __field,$(modules-fields-depends), \
			$(eval __modules.$(__mod).$(__field) := $(empty)) \
		) \
		$(call __module-update-depends-direct,$(__mod)) \
		$(call __module-compute-depends-direct,$(__mod)) \
	) \
	$(foreach __mod,$(__modules), \
		$(eval __depends-loop := $(empty)) \
		$(eval __dummy := $(call __module-compute-depends-static,$(__mod),EXTERNAL_LIBRARIES)) \
		$(eval __depends-loop := $(empty)) \
		$(eval __dummy := $(call __module-compute-depends-static,$(__mod),STATIC_LIBRARIES)) \
		$(eval __depends-loop := $(empty)) \
		$(eval __dummy := $(call __module-compute-depends-static,$(__mod),WHOLE_STATIC_LIBRARIES)) \
		$(eval __depends-loop := $(empty)) \
		$(eval __dummy := $(call __module-compute-depends-static,$(__mod),SHARED_LIBRARIES)) \
		$(eval __depends-loop := $(empty)) \
		$(eval __dummy := $(call __module-compute-depends-link,$(__mod))) \
		$(eval __depends-loop := $(empty)) \
		$(eval __dummy := $(call __module-compute-depends-all,$(__mod))) \
	)

# Update direct dependencies of a single module.
# It updates XXX_LIBRARIES based on LIBRARIES and actual dependency class.
# $1 : module name.
__module-update-depends-direct = \
	$(foreach __lib,$(__modules.$1.LIBRARIES), \
		$(eval __class := $(__modules.$(__lib).MODULE_CLASS)) \
		$(if $(call streq,$(__class),STATIC_LIBRARY), \
			$(if $(call streq,$(__modules.$(__lib).FORCE_WHOLE_STATIC_LIBRARY),1), \
				$(eval __modules.$1.WHOLE_STATIC_LIBRARIES += $(__lib)), \
				$(eval __modules.$1.STATIC_LIBRARIES += $(__lib)) \
			), \
			$(if $(call streq,$(__class),SHARED_LIBRARY), \
				$(eval __modules.$1.SHARED_LIBRARIES += $(__lib)), \
				$(eval __modules.$1.EXTERNAL_LIBRARIES += $(__lib)) \
			) \
		) \
	)

# Compute direct dependencies of a single module
# $1 : module name.
__module-compute-depends-direct = \
	$(call __module-add-depends-direct,$1,$(__modules.$1.STATIC_LIBRARIES)) \
	$(call __module-add-depends-direct,$1,$(__modules.$1.WHOLE_STATIC_LIBRARIES)) \
	$(call __module-add-depends-direct,$1,$(__modules.$1.SHARED_LIBRARIES)) \
	$(call __module-add-depends-direct,$1,$(__modules.$1.EXTERNAL_LIBRARIES)) \
	$(eval __modules.$1.depends.headers := $(__modules.$1.DEPENDS_HEADERS)) \
	$(eval __modules.$1.depends.other := $(__modules.$1.DEPENDS_MODULES)) \
	$(eval __modules.$1.depends.other += $(__modules.$1.REQUIRED_MODULES))

# Add direct dependencies to a module
# $1 : module name.
# $2 : list of modules to add in dependency list.
__module-add-depends-direct = \
	$(eval __modules.$1.depends += $(filter-out $(__modules.$1.depends),$2))

# Compute dependencies due to static libraries.
# $1 : module name.
# $2 : class of library to compute dependencies.
# Note : it recursively descends into static libraries to get their dependencies.
# Internally we use a 'local' variable that will hold the name of the variable
# in which we will store the result (a kind of pointer)
# It is prefixed by the name of the module because there is no 'stack' but a
# single namespace.
# Note : the result is ordered in way compatible to link. It means that if
# a library A depends on library B, B will be after A. This order is guaranteed
# even if the recursion and dependency is tricky as long as there is no cycle.
__module-compute-depends-static = \
	$(if $(call __is-in-depends-loop,$1), \
		$(error cyclic dependency detected: $(__depends-loop) $1) \
	) \
	$(eval $1.__var := __modules.$1.depends.$2) \
	$(if $($($1.__var)),$($($1.__var)), \
		$(eval $($1.__var) := $(strip \
			$(call uniq2,$(call __module-compute-depends-static-internal,$1,$2))) \
		) \
		$($($1.__var)) \
	) \
	$(eval __depends-loop := $(filter-out $1,$(__depends-loop)))

# Internal macro called by __module-compute-depends-static to do the recursion
# by calling again __module-compute-depends-static.
# $1 : module name.
# $2 : class of library to compute dependencies.
__module-compute-depends-static-internal = \
	$(__modules.$1.$2) \
	$(foreach __mod,$(__modules.$1.STATIC_LIBRARIES), \
		$(call __module-compute-depends-static,$(__mod),$2) \
	) \
	$(foreach __mod,$(__modules.$1.WHOLE_STATIC_LIBRARIES), \
		$(call __module-compute-depends-static,$(__mod),$2) \
	)

# Compute dependencies for link. It simply aggregate (and sort) static
# dependencies
# $1 : module name.
__module-compute-depends-link = \
	$(eval __modules.$1.depends.link := $(strip $(sort \
		$(__modules.$1.depends.EXTERNAL_LIBRARIES) \
		$(__modules.$1.depends.STATIC_LIBRARIES) \
		$(__modules.$1.depends.WHOLE_STATIC_LIBRARIES) \
		$(__modules.$1.depends.SHARED_LIBRARIES) \
	)))

# Compute all dependencies of a module.
# $1 : module name.
# Note : it recursively descends into libraries to get their dependencies.
# See above the way we use 'local' variable.
__module-compute-depends-all = \
	$(if $(call __is-in-depends-loop,$1), \
		$(error cyclic dependency detected: $(__depends-loop) $1) \
	) \
	$(eval __depends-loop += $1) \
	$(eval $1.__var := __modules.$1.depends.all) \
	$(if $($($1.__var)),$($($1.__var)), \
		$(eval $($1.__var) := $(strip \
			$(call uniq2,$(call __module-compute-depends-all-internal,$1))) \
		) \
		$($($1.__var)) \
	) \
	$(eval __depends-loop := $(filter-out $1,$(__depends-loop)))

# Internal macro called by __module-compute-depends-all to do the recursion
# by calling again __module-compute-depends-all.
# $1 : module name.
# $2 : class of library to compute dependencies.
__module-compute-depends-all-internal = \
	$(__modules.$1.depends) \
	$(foreach __mod,$(__modules.$1.depends), \
		$(call __module-compute-depends-all,$(__mod)) \
	)

###############################################################################
## Automatic extraction from dependencies of a module.
###############################################################################

# Return the recorded value of LOCAL_EXPORT_$2, if any, for module $1.
# $1 : module name.
# $2 : export variable name without LOCAL_EXPORT_ prefix (e.g. 'CFLAGS').
module-get-export = $(__modules.$1.EXPORT_$2)

# Return the recorded value of LOCAL_EXPORT_$2, if any, for modules listed in $1.
# $1 : list of module names.
# $2 : export variable name without LOCAL_EXPORT_ prefix (e.g. 'CFLAGS').
module-get-listed-export = $(strip \
	$(foreach __mod,$1, \
		$(call module-get-export,$(__mod),$2) \
	))

# Return the autoconf.h file, if any, for module $1.
# $1 : module name.
module-get-autoconf = \
	$(if $(__modules.$1.CONFIG_FILES),$(TARGET_OUT_BUILD)/$1/autoconf-$1.h)

# Return the autoconf.h files, if any, for modules listed in $1.
# $1 : list of module names.
module-get-listed-autoconf = $(strip \
	$(foreach __mod,$1, \
		$(call module-get-autoconf,$(__mod)) \
	))

###############################################################################
## Dependency helpers.
## $1: module name.
###############################################################################

# Get dependencies due to static libraries
module-get-static-depends = \
	$(__modules.$1.depends.$2)

# Get link dependencies for the build (aggregation of all static depends)
# list is sorted and is mainly used for generation of elf section with dependencies.
module-get-link-depends = \
	$(__modules.$1.depends.link)

# Get all dependencies for the build
module-get-all-depends = \
	$(__modules.$1.depends.all)

# Get direct dependencies
module-get-depends = \
	$(__modules.$1.depends)

# Get dependencies for configuration
# Put build dependencies only if requested
# FIXME: configurable until all modules remove conditional deps in atom.mk
ifeq ("$(USE_BUILD_DEPS_CHECK_IN_CONFIG)","0")
module-get-config-depends = \
	$(__modules.$1.depends.other)
else
module-get-config-depends = \
	$(__modules.$1.depends) \
	$(__modules.$1.depends.other)
endif

###############################################################################
## Get path of module main target file (in build or staging directory).
## $1 : module name.
###############################################################################
module-get-build-dir = \
	$(TARGET_OUT_BUILD)/$1

module-get-build-filename = \
	$(TARGET_OUT_BUILD)/$1/$(__modules.$1.MODULE_FILENAME)

# Check if module is part of a sdk
module-get-staging-filename = $(strip \
	$(if $(__modules.$1.SDK), \
		$(__modules.$1.SDK)/$(__modules.$1.DESTDIR)/$(__modules.$1.MODULE_FILENAME), \
		$(TARGET_OUT_STAGING)/$(__modules.$1.DESTDIR)/$(__modules.$1.MODULE_FILENAME) \
	))

###############################################################################
## Debug cutomization access.
## $1 : module name.
## $2 : field name (CFLAGS, CXXFLAGS, LDFLAGS).
###############################################################################
module-get-debug-flags = $(strip \
	$(if $(call is-var-defined,debug.$1.$2), \
		$(debug.$1.$2) \
	))

###############################################################################
## Module revision management. Assume git is used and return SHA1 of HEAD.
###############################################################################

ifneq ("$(USE_GIT_REV)","0")

# Get revision of one module
# $1 : module name.
module-get-revision = $(__modules.$1.REVISION)

# Get last revision of one module. It is found in a generated file that may
# not exist so the result can be empty.
# $1 : module name.
module-get-last-revision = $(strip \
	$(if $(call is-var-defined,build.$1.revision.last), \
		$(build.$1.revision.last) \
	))

# Compute revision of all modules
module-compute-revisions = \
	$(foreach __mod,$(__modules), \
		$(if $(__modules.$(__mod).REVISION),$(empty), \
			$(eval __path := $(__modules.$(__mod).PATH)) \
			$(eval __rev := $(shell cd $(__path) && git rev-parse HEAD 2>/dev/null)) \
			$(eval __modules.$(__mod).REVISION := $(__rev)) \
		) \
	)

# Check if revision of module has changed since last build.
# If either current/last revision is unknown, it will return false.
# $1 : module name.
module-check-revision-changed = $(strip \
	$(eval __current := $(call module-get-revision,$1)) \
	$(eval __last := $(call module-get-last-revision,$1)) \
	$(and $(__current),$(__last),$(call strneq,$(__current),$(__last))))

# Generate the file with last revision. Some duplication with
# 'module-check-revision-changed' to update the file only when needed.
# $1 : module name.
# $2 : output file.
# Note: shall be call as a command in side a rule.
generate-last-revision-file = \
	$(eval __current := $(call module-get-revision,$1)) \
	$(eval __last := $(call module-get-last-revision,$1)) \
	$(if $(and $(__current),$(call strneq,$(__current),$(__last))), \
		mkdir -p $(dir $2); \
		echo "build.$1.revision.last=$(__current)" > $2; \
	) \

endif

###############################################################################
## Generate autoconf.h file from config file.
## $1 : input config file.
## $2 : output autoconf.h file.
##
## Remove CONFIG_ prefix.
## Remove CONFIG_ in commented lines.
## Put lines begining with '#' between '/*' '*/'.
## Replace 'key=value' by '#define key value'.
## Replace trailing ' y' by ' 1'.
## Remove leading and trailing quotes from string.
## Replace '\"' by '"'.
###############################################################################
define generate-autoconf-file
	echo "Generating $(call path-from-top,$2) from $(call path-from-top,$1)"; \
	mkdir -p $(dir $2); \
	sed \
		-e 's/^CONFIG_//' \
		-e 's/^\# CONFIG_/\# /' \
		-e 's/^\#\(.*\)/\/*\1 *\//' \
		-e 's/\(.*\)=\(.*\)/\#define \1 \2/' \
		-e 's/ y$$/ 1/' \
		-e 's/\"\(.*\)\"/\1/' \
		-e 's/\\\"/\"/g' \
		$1 > $2;
endef

###############################################################################
## Search files matching an extension under LOCAL_PATH.
###############################################################################

# $1 : directory relative to LOCAL_PATH to search
# $2 : extension to search (.c, .cpp ...)
all-files-under = $(strip \
	$(patsubst ./%,%, \
		$(shell cd $(LOCAL_PATH); \
			find $1 -name "*$2" -and -not -name ".*") \
	))

# $1 : directory relative to LOCAL_PATH to search
all-c-files-under = $(call all-files-under,$1,.c)
all-cpp-files-under = $(call all-files-under,$1,.cpp)
all-cxx-files-under = $(call all-files-under,$1,.cxx)
all-cc-files-under = $(call all-files-under,$1,.cc)

###############################################################################
## Check compilation flags for some forbidden stuff.
## $1 : variable to check (its name, not its value).
## $2 : list of flags to check for their presence in $1.
## $3 : message to display in case of error.
###############################################################################
check-flags = \
	$(foreach __flag,$2, \
		$(if $(findstring $(__flag),$($1)), \
			$(error $(LOCAL_PATH): $1 contains $(__flag) : $3) \
		) \
	)

###############################################################################
## Normalize a list of includes. It adds -I if needed.
## $1 : list of includes
###############################################################################
normalize-c-includes = $(strip \
	$(foreach __inc,$1, \
		$(addprefix -I,$(patsubst -I%,%,$(__inc))) \
	))

# Same but convert path relative to top
normalize-c-includes-rel = $(strip \
	$(foreach __inc,$1, \
		$(addprefix -I,$(call path-from-top,$(patsubst -I%,%,$(__inc)))) \
	))

###############################################################################
## Copy files helpers.
###############################################################################

# Get full source path for the copy.
# $1 : path relative to LOCAL_PATH, or directly the full path.
copy-get-src-path = $(strip \
	$(if $(call is-path-absolute,$1), \
		$1,$(addprefix $(LOCAL_PATH)/,$1) \
	))

# Get full destination path for the copy.
# $1 : path relative to TARGET_OUT_STAGING, or directly the full path.
copy-get-dst-path = $(strip \
	$(if $(call is-path-absolute,$1), \
		$1,$(addprefix $(TARGET_OUT_STAGING)/,$1) \
	))

###############################################################################
## Setup installed headers in LOCAL_COPY_FILES and LOCAL_EXPORT_PREREQUISITES.
## $1 : module name.
###############################################################################
install-headers-setup = \
	$(foreach __pair,$(__modules.$1.INSTALL_HEADERS), \
		$(eval __pair2 := $(subst :,$(space),$(__pair))) \
		$(eval __w1 := $(word 1,$(__pair2))) \
		$(eval __w2 := $(word 2,$(__pair2))) \
		$(if $(__w2),$(empty),$(eval __w2 := usr/include/)) \
		$(eval __src := $(call copy-get-src-path,$(__w1))) \
		$(eval __dst := $(call copy-get-dst-path,$(__w2))) \
		$(if $(call is-path-dir,$(__dst)), \
			$(eval __dst := $(__dst)$(notdir $(__src))) \
		) \
		$(eval __modules.$1.COPY_FILES += $(__w1):$(__w2)) \
		$(eval __modules.$1.EXPORT_PREREQUISITES += $(__dst)) \
	)

###############################################################################
## Setup conditional libraries. It looks for pairs <var>:<lib> in
## LOCAL_CONDITIONAL_LIBRARIES and add <lib> in LOCAL_LIBRARIES if <var> is
## defined.
## If <var> equals 'OPTIONAL', <lib> is added if it is in the build config.
## $1 : module name.
###############################################################################
conditional-libraries-setup = \
	$(foreach __pair,$(__modules.$1.CONDITIONAL_LIBRARIES), \
		$(eval __pair2 := $(subst :,$(space),$(__pair))) \
		$(eval __w1 := $(word 1,$(__pair2))) \
		$(eval __w2 := $(word 2,$(__pair2))) \
		$(if $(call streq,$(__w1),OPTIONAL), \
			$(if $(call is-module-in-build-config,$(__w2)), \
				$(eval __modules.$1.LIBRARIES += $(__w2)) \
			) \
			, \
			$(if $(call is-var-defined,$(__w1)), \
				$(eval __modules.$1.LIBRARIES += $(__w2)) \
			) \
		) \
	)

###############################################################################
## Copy a macro.
## $1 : destination variable.
## $1 : source variable.
## This works by reevaluating the content of the macro in a new variable.
###############################################################################
macro-copy = $(eval define $1$(endl)$(value $2)$(endl)endef)

###############################################################################
## Compare 2 macros.
## $1 : first variable.
## $2 : second variable.
###############################################################################
macro-compare = $(call streq,$(value $1),$(value $2))

###############################################################################
## Determine if a macro is empty.
## $1 : name of macro.
###############################################################################
macro-is-empty = $(call not,$(value $1))

###############################################################################
## Execute commands of a macro.
## $1 : Type of commands to execute. Ex : AUTOTOOLS_CMD_CONFIGURE...
## $2 : default macro if $1 is empty.
##
## Note : if the content of the variable is empty, the default one will be used.
##        If the content is only one word, it is assumed to be the actual macro
##        to be called (one more level of macro call). Otherwise, macro is
##        called directly.
## Note : we access macros from the module database because we can't create
##        PRIVATE_XXX target-specific variables for them.
## Note : the part where we check for single word can be removed when all user
##        makefiles have been converted to use new way of defining commands.
###############################################################################
macro-exec-cmd = \
	$(eval __var := __modules.$(PRIVATE_MODULE).$1) \
	$(if $(value $(__var)), \
		$(if $(call streq,$(words $(value $(__var))),1), \
			$($($(__var))),$($(__var)) \
		), \
		$(if $2,$($2)) \
	)

###############################################################################
## Macros to be called before and after inclusion of user makefiles.
## It checks that user makefile does not overwrite internal variables.
##
## Use macro-copy/macro-compare in case some variables contains stuff that
## should not be done while being evaluated.
## For example the variable TARGET_GLOBAL_CFLAGS_thumb may contains an error
## message displayed when used while TARGET_DEFAULT_ARM_MODE is 'arm'.
###############################################################################

# Save TARGET_XXX variables
user-makefile-before-include = \
	$(foreach __var,$(vars-TARGET), \
		$(if $(call is-var-defined,TARGET_$(__var)), \
			$(call macro-copy,saved-TARGET_$(__var),TARGET_$(__var)) \
		) \
	)

# Make sure that TARGET_XXX have not been modified
user-makefile-after-include = \
	$(foreach __var,$(vars-TARGET), \
		$(if $(call is-var-defined,TARGET_$(__var)), \
			$(if $(call macro-compare,TARGET_$(__var),saved-TARGET_$(__var)),$(empty), \
				$(warning $1: attempt to modify TARGET_$(__var)) \
				$(call macro-copy,TARGET_$(__var),saved-TARGET_$(__var)) \
			) \
		) \
	)

###############################################################################
## Print some banners.
## $1 : operation.
## $2 : module.
## $3 : file.
###############################################################################

CLR_TOOL   := $(CLR_PURPLE)
CLR_MODULE := $(CLR_CYAN)
CLR_FILE   := $(CLR_YELLOW)

print-banner1 = \
	@echo "$(CLR_TOOL)$1:$(CLR_DEFAULT) $(CLR_MODULE)$2$(CLR_DEFAULT) <= $(CLR_FILE)$3$(CLR_DEFAULT)"

print-banner2 = \
	@echo "$(CLR_TOOL)$1:$(CLR_DEFAULT) $(CLR_MODULE)$2$(CLR_DEFAULT) => $(CLR_FILE)$3$(CLR_DEFAULT)"

###############################################################################
## Macro called during link.
## $1 : module name.
## $2 : name of the binary being linked.
## $3 : list of object files as well as static libraries used during link.
## It returns additional object files to add in link.
##
## The pbuild hook will be given the list of all dependencies of the module.
###############################################################################
link-hook = $(strip \
	$(if $(PRIVATE_PBUILD_HOOK), \
		$(eval __depsdata := $(empty)) \
		$(foreach __lib,$(sort $1 $(__modules.$1.depends.all)), \
			$(eval __depsdata += $(__lib):$(__modules.$(__lib).PATH)) \
		)\
		$(shell $(BUILD_SYSTEM)/pbuild-hook/pbuild-link-hook.sh \
			"$(TARGET_NM)" "$(TARGET_CC) $(TARGET_GLOBAL_CFLAGS)" \
			$1 $2 "$(__depsdata)" $3 \
		) \
	))

###############################################################################
## Add a section in a binary with list of dependencies and their revision.
## The revision of this module is also added a the start of the list.
## The section will simply be a list of lines in the form lib:revision.
###############################################################################

define add-depends-section
$(eval __depsdata := $(empty))
$(foreach __lib,$(PRIVATE_MODULE) $(__modules.$(PRIVATE_MODULE).depends.link), \
	$(eval __depsdata += $(__lib):$(__modules.$(__lib).REVISION)) \
)
$(eval __depsdata := $(subst $(space),\n,$(strip $(__depsdata))))
@( \
	__tmpfile=$$(mktemp); \
	/bin/echo -e "$(__depsdata)" > $${__tmpfile}; \
	$(TARGET_CROSS)objcopy --add-section \
		$(TARGET_DEPENDS_SECTION_NAME)=$${__tmpfile} $@; \
	rm -f $${__tmpfile}; \
)
endef

###############################################################################
## Commands to generate a precompiled file.
###############################################################################

define transform-h-to-gch
@mkdir -p $(dir $@)
$(call print-banner1,"Precompile",$(PRIVATE_MODULE),$(call path-from-top,$<))
$(call check-pwd-is-top-dir)
$(Q)$(CCACHE) $(TARGET_CXX) \
	$(call normalize-c-includes-rel,$(PRIVATE_C_INCLUDES)) \
	$(call normalize-c-includes-rel,$(TARGET_GLOBAL_C_INCLUDES)) \
	$(TARGET_GLOBAL_CFLAGS) $(TARGET_GLOBAL_CXXFLAGS) $(WARNINGS_CXXFLAGS) \
	$(PRIVATE_CFLAGS) $(PRIVATE_CXXFLAGS) \
	$(TARGET_GLOBAL_PCH_FLAGS) -MMD -MP -o $@ \
	$(call path-from-top,$<)
endef

###############################################################################
## Commands to compile a C++ file.
###############################################################################

define transform-cpp-to-o
@mkdir -p $(dir $@)
$(call print-banner1,"$(PRIVATE_MODE) C++",$(PRIVATE_MODULE),$(call path-from-top,$<))
$(call check-pwd-is-top-dir)
$(Q)$(CCACHE) $(TARGET_CXX) \
	$(call normalize-c-includes-rel,$(PRIVATE_C_INCLUDES)) \
	$(call normalize-c-includes-rel,$(TARGET_GLOBAL_C_INCLUDES)) \
	$(TARGET_GLOBAL_CFLAGS) $(TARGET_GLOBAL_CXXFLAGS) $(WARNINGS_CXXFLAGS) \
	$(TARGET_GLOBAL_CFLAGS_$(PRIVATE_MODE)) \
	$(PRIVATE_CFLAGS) $(PRIVATE_CXXFLAGS) \
	-c -MMD -MP -o $@ \
	$(call path-from-top,$<)
endef

###############################################################################
## Commands to compile a C file.
###############################################################################

define transform-c-to-o
$(call print-banner1,"$(PRIVATE_MODE) C",$(PRIVATE_MODULE),$(call path-from-top,$<))
$(call check-pwd-is-top-dir)
@mkdir -p $(dir $@)
$(Q)$(CCACHE) $(TARGET_CC) \
	$(call normalize-c-includes-rel,$(PRIVATE_C_INCLUDES)) \
	$(call normalize-c-includes-rel,$(TARGET_GLOBAL_C_INCLUDES)) \
	$(TARGET_GLOBAL_CFLAGS) $(WARNINGS_CFLAGS) \
	$(TARGET_GLOBAL_CFLAGS_$(PRIVATE_MODE)) \
	$(PRIVATE_CFLAGS) \
	-c -MMD -MP -o $@ \
	$(call path-from-top,$<)
endef

###############################################################################
## Commands to compile a S file.
###############################################################################

define transform-s-to-o
$(call print-banner1,"Asm",$(PRIVATE_MODULE),$(call path-from-top,$<))
$(call check-pwd-is-top-dir)
@mkdir -p $(dir $@)
$(Q)$(CCACHE) $(TARGET_CC) \
	$(call normalize-c-includes-rel,$(PRIVATE_C_INCLUDES)) \
	$(call normalize-c-includes-rel,$(TARGET_GLOBAL_C_INCLUDES)) \
	$(TARGET_GLOBAL_CFLAGS) $(WARNINGS_CFLAGS) \
	$(TARGET_GLOBAL_CFLAGS_$(PRIVATE_MODE)) \
	$(PRIVATE_CFLAGS) \
	-c -MMD -MP -o $@ \
	$(call path-from-top,$<)
endef

###############################################################################
## Commands for running ar.
###############################################################################

# Explicitly delete the archive first so that ar doesn't
# try to add to an existing archive.
define transform-o-to-static-lib
@mkdir -p $(dir $@)
$(call print-banner2,"StaticLib",$(PRIVATE_MODULE),$(call path-from-top,$@))
$(call check-pwd-is-top-dir)
@rm -f $@
$(Q)$(TARGET_AR) $(TARGET_GLOBAL_ARFLAGS) $(PRIVATE_ARFLAGS) $@ $(PRIVATE_ALL_OBJECTS)
endef

###############################################################################
## Commands to link a shared library.
###############################################################################

define transform-o-to-shared-lib
@mkdir -p $(dir $@)
$(call print-banner2,"SharedLib",$(PRIVATE_MODULE),$(call path-from-top,$@))
$(call check-pwd-is-top-dir)
$(Q)$(TARGET_CXX) \
	$(TARGET_GLOBAL_LDFLAGS_SHARED) \
	-Wl,-Map -Wl,$(basename $@).map \
	-shared \
	-Wl,-soname -Wl,$(notdir $@) \
	-Wl,--no-undefined \
	-Wl,--gc-sections \
	-Wl,--as-needed \
	$(PRIVATE_LDFLAGS) \
	$(PRIVATE_ALL_OBJECTS) \
	$(call link-hook,$(PRIVATE_MODULE),$@, \
		$(PRIVATE_ALL_OBJECTS) \
		$(PRIVATE_ALL_STATIC_LIBRARIES) \
		$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
	-Wl,--whole-archive \
	$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES) \
	-Wl,--no-whole-archive \
	$(PRIVATE_ALL_STATIC_LIBRARIES) \
	$(PRIVATE_ALL_SHARED_LIBRARIES) \
	-o $@ \
	$(PRIVATE_LDLIBS) \
	$(TARGET_GLOBAL_LDLIBS_SHARED)
endef

###############################################################################
## Commands to link an executable.
###############################################################################

define transform-o-to-executable
@mkdir -p $(dir $@)
$(call print-banner2,"Executable",$(PRIVATE_MODULE),$(call path-from-top,$@))
$(call check-pwd-is-top-dir)
$(Q)$(TARGET_CXX) \
	$(TARGET_GLOBAL_LDFLAGS) \
	-Wl,-Map -Wl,$(basename $@).map \
	-Wl,--gc-sections \
	-Wl,--as-needed \
	$(PRIVATE_LDFLAGS) \
	$(PRIVATE_ALL_OBJECTS) \
	$(call link-hook,$(PRIVATE_MODULE),$@, \
		$(PRIVATE_ALL_OBJECTS) \
		$(PRIVATE_ALL_STATIC_LIBRARIES) \
		$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
	-Wl,--whole-archive \
	$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES) \
	-Wl,--no-whole-archive \
	$(PRIVATE_ALL_STATIC_LIBRARIES) \
	$(PRIVATE_ALL_SHARED_LIBRARIES) \
	-o $@ \
	$(PRIVATE_LDLIBS) \
	$(TARGET_GLOBAL_LDLIBS)
endef

###############################################################################
## Commands for copying files.
###############################################################################

# Define a rule to copy a file. For use via $(eval) so use $$@ and $$<.
# use '-a' to preserve permissions/links and
# use '--remove-destination' to overwrite any existing file to make sure
# existing symlinks are correctly overwritten.
# $(1) : source file
# $(2) : destination file
define copy-one-file
$(2): $(1)
	@echo "Copy: $$(call path-from-top,$$<) => $$(call path-from-top,$$@)"
	@mkdir -p $$(dir $$@)
	$(Q)cp -a --remove-destination $$< $$@
endef

###############################################################################
## Commands for creating links.
###############################################################################

# Define a rule to create a link. For use via $(eval) so use $$@ and $$<.
# $(1) : name of link
# $(2) : target of link
define create-one-link
$(1):
	@echo "Link: $$(call path-from-top,$$@) => $(2)"
	@mkdir -p $$(dir $$@)
	$(Q)ln -s -f $(2) $$@
endef

###############################################################################
## Commands callable from user makefiles.
###############################################################################

# Get local path
local-get-path = $(call my-dir)

# Get build directory
local-get-build-dir = $(call module-get-build-dir,$(LOCAL_MODULE))

# Register module (deprecated)
local-add-module = \
	$(warning Please use include $$(BUILD_CUSTOM) instead of local-add-module) \
	$(module-add)
