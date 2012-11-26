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

# Translate characters.
# $1 : text to convert.
# $2 : characters to convert from.
# $3 : characters to convert to.
tr = $(shell echo $1 | tr $2 $3)

# Convert to upper case.
# $1 : text to convert.
upcase = $(shell echo $1 | tr [:lower:] [:upper:])

# Convert to lower case.
# $1 : text to convert.
locase = $(shell echo $1 | tr [:upper:] [:lower:])

# Replace '-' by '_' and convert to upper case.
# $1 : text to convert.
get-define = $(strip $(call upcase,$(call tr,$1,-,_)))

# Remove quotes from string
remove-quotes = $(strip $(subst ",,$1))

# Check that the current directory is the top directory
check-pwd-is-top-dir = \
	$(if $(patsubst $(TOP_DIR)%,%,$(shell pwd)), \
		$(error Not at the top directory))

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
## List of LOCAL_XXX variables that can be set by makefiles.
###############################################################################
modules-LOCALS :=

# Path of the root of module
modules-LOCALS += PATH

# Name of what's supposed to be generated
modules-LOCALS += MODULE

# Override the name of what will be generated
modules-LOCALS += MODULE_FILENAME

# List of 'done' files indicating internal steps already done and that does not need
# to be executed next time unless a force is requested
# Name is relative to build directory
modules-LOCALS += DONE_FILES

# Source files to compile
# All files are relative to LOCAL_PATH
modules-LOCALS += SRC_FILES

# Static libraries that you want to include in your module
# Names of modules in the build system, without path/prefix/suffix
modules-LOCALS += STATIC_LIBRARIES

# Static libraries that you want to include as a whole in your module
# To generate a '.so' from a '.a' for ex
# Names of modules in the build system, without path/prefix/suffix
modules-LOCALS += WHOLE_STATIC_LIBRARIES

# Libraries you directly link against
# Names of modules in the build system, without path/prefix/suffix
modules-LOCALS += SHARED_LIBRARIES

# External libraries (not built directly by the build system rules)
# Used as dependencies to trigger indirect build.
modules-LOCALS += EXTERNAL_LIBRARIES

# General libraries to add in dependency based on their actual class (STATIC/SHARED/EXTERNAL).
modules-LOCALS += LIBRARIES

# Additional include directories to pass into the C/C++ compilers
# Format : <fullpath> (-I will be prepended automatically)
modules-LOCALS += C_INCLUDES

# Additional flags to pass into the C or C++ compiler
modules-LOCALS += CFLAGS

# Additional flags to pass into only the C++ compiler
modules-LOCALS += CPPFLAGS

# Additional flags to pass into the static library generator
modules-LOCALS += ARFLAGS

# Additional flags to pass into the linker
modules-LOCALS += LDFLAGS

# Additional libraries to pass into the linker
# Format : -l<name>
modules-LOCALS += LDLIBS

# Precompiled file
# Relative to LOCAL_PATH
modules-LOCALS += PRECOMPILED_FILE

# Arm compilation mode (arm or thumb)
modules-LOCALS += ARM_MODE

# Paths to config.in files to configure the module
# Relative to LOCAL_PATH
modules-LOCALS += CONFIG_FILES

# List of prerequisites for all objects
modules-LOCALS += PREREQUISITES

# ParrotBuild compatibility hook required
modules-LOCALS += PBUILD_HOOK

# Force modules that depends on this one to use whole-statid library
modules-LOCALS += FORCE_WHOLE_STATIC_LIBRARY

# Files and directories to delete during a clean
modules-LOCALS += CLEAN_FILES
modules-LOCALS += CLEAN_DIRS

# Macro to be executed before installing binary in staging dir
# It MUST be a macro that will execute commands, not directly commands
modules-LOCALS += CMD_PRE_INSTALL

# Autotools customization
modules-LOCALS += AUTOTOOLS_VERSION
modules-LOCALS += AUTOTOOLS_ARCHIVE
modules-LOCALS += AUTOTOOLS_DIR
modules-LOCALS += AUTOTOOLS_PATCHES
modules-LOCALS += AUTOTOOLS_CONFIGURE_ENV
modules-LOCALS += AUTOTOOLS_CONFIGURE_ARGS
modules-LOCALS += AUTOTOOLS_MAKE_BUILD_ENV
modules-LOCALS += AUTOTOOLS_MAKE_BUILD_ARGS
modules-LOCALS += AUTOTOOLS_MAKE_INSTALL_ENV
modules-LOCALS += AUTOTOOLS_MAKE_INSTALL_ARGS
modules-LOCALS += AUTOTOOLS_CMD_UNPACK
modules-LOCALS += AUTOTOOLS_CMD_CONFIGURE
modules-LOCALS += AUTOTOOLS_CMD_BUILD
modules-LOCALS += AUTOTOOLS_CMD_INSTALL
modules-LOCALS += AUTOTOOLS_CMD_CLEAN
modules-LOCALS += AUTOTOOLS_CMD_POST_UNPACK
modules-LOCALS += AUTOTOOLS_CMD_POST_CONFIGURE
modules-LOCALS += AUTOTOOLS_CMD_POST_BUILD
modules-LOCALS += AUTOTOOLS_CMD_POST_INSTALL
modules-LOCALS += AUTOTOOLS_CMD_POST_CLEAN

# Exported stuff (will be added in modules depending on this one)
modules-LOCALS += EXPORT_C_INCLUDES
modules-LOCALS += EXPORT_CFLAGS
modules-LOCALS += EXPORT_CPPFLAGS
modules-LOCALS += EXPORT_LDLIBS
modules-LOCALS += EXPORT_PREREQUISITES

# Module class : STATIC_LIBRARY SHARED_LIBRARY EXECUTABLE PREBUILT
modules-LOCALS += MODULE_CLASS

# List of files to copy
# Format <src>:<dst>
# src : source (relative to module path)
# dst : destination (relative to staging dir)
modules-LOCALS += COPY_FILES

# Other variables used internally
modules-LOCALS += BUILD_MODULE
modules-LOCALS += STAGING_MODULE
modules-LOCALS += DESTDIR
modules-LOCALS += TARGETS

# The list of fields related to dependency
modules-fields-depends := \
	depends \
	depends.EXTERNAL_LIBRARIES \
	depends.STATIC_LIBRARIES \
	depends.WHOLE_STATIC_LIBRARIES \
	depends.SHARED_LIBRARIES \
	depends.all

# the list of managed fields per module
modules-fields := \
	$(modules-fields-depends) \
	$(modules-LOCALS)

###############################################################################
## Add a module in the build system and save its LOCAL_xxx variables.
## All LOCAL_xxx variables will be saved in module database.
###############################################################################
module-add = \
	$(eval LOCAL_MODULE := $(strip $(LOCAL_MODULE))) \
	$(if $(LOCAL_MODULE),$(empty), \
		$(error $(LOCAL_PATH): LOCAL_MODULE is not defined)) \
	$(eval __mod := $(LOCAL_MODULE)) \
	$(eval __add := 1) \
	$(if $(call is-module-registered,$(__mod)), \
		$(eval __add := 0) \
		$(eval __path := $(__modules.$(__mod).PATH)) \
		$(eval __class := $(__modules.$(__mod).MODULE_CLASS)) \
		$(if $(call streq,$(__class),PREBUILT), \
			$(warning $(LOCAL_PATH): module '$(__mod)' is already prebuilt), \
			$(error $(LOCAL_PATH): module '$(__mod)' already registered at $(__path)) \
		) \
	) \
	$(if $(call streq,$(__add),1), \
		$(eval __modules += $(__mod)) \
		$(foreach __local,$(modules-LOCALS), \
			$(eval __modules.$(__mod).$(__local) := $(LOCAL_$(__local))) \
		) \
	)

###############################################################################
## Check if a list of targets is given in make goals.
## $1 : list of targets to check
###############################################################################
is-targets-in-make-goals = $(strip \
	$(foreach __t,$1, \
		$(foreach __g,$(MAKECMDGOALS), \
			$(if $(call streq,$(__g),$(__t)),$(true)) \
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
## Check if a module is registered.
## $1 : module to check.
###############################################################################
is-module-registered = $(strip \
	$(foreach __mod,$(__modules), \
		$(if $(call streq,$(__mod),$1),$(true)) \
	))

###############################################################################
## Check if a module is built externally (by autotools or custom rules).
## $1 : module to check.
###############################################################################
is-module-external = $(strip \
	$(eval __class := $(__modules.$1.MODULE_CLASS)) \
	$(if $(call streq,$(__class),AUTOTOOLS),$(true), \
		$(if $(__class),$(false),$(false)) \
	))

###############################################################################
## Check if a module will be built.
## $1 : module to check.
## Prebuild modules are considered as in the config (even if they are not
## actually in it).
## If no configuration directory present, always return true.
###############################################################################
is-module-in-build-config = $(strip \
	$(if $(call streq,$(__modules.$1.MODULE_CLASS),PREBUILT),$(true), \
		$(eval __var := CONFIG_ALCHEMY_BUILD_$(call get-define,$1)) \
		$(if $(call streq,$(CONFIG_DIR_AVAILABLE),0),$(true), \
			$(if $(call streq,$(origin $(__var)),undefined), \
				$(false), \
				$(if $($(__var)),$(true)) \
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
	$(foreach __local,$(modules-LOCALS), \
		$(eval LOCAL_$(__local) := $(__modules.$1.$(__local))) \
	)

###############################################################################
## Used to check all dependencies once all module information has been
## recorded.
###############################################################################

# Check dependencies of all modules
modules-check-depends = \
	$(foreach __mod,$(__modules), \
		$(call __module-check-depends,$(__mod)) \
	)

# Check dependencies of a module
# $1 : module name.
__module-check-depends = \
	$(foreach __lib,$(__modules.$1.depends), \
		$(if $(call is-module-registered,$(__lib)),$(empty), \
			$(eval __path := $(__modules.$1.PATH)) \
			$(if $(call is-module-in-build-config,$1), \
				$(error $(__path): module '$1' depends on unknown module '$(__lib)'), \
				$(warning $(__path): module '$1' depends on unknown module '$(__lib)') \
			) \
		) \
	) \
	$(call __module-check-libs-class,$1,WHOLE_STATIC_LIBRARIES,STATIC_LIBRARY) \
	$(call __module-check-libs-class,$1,STATIC_LIBRARIES,STATIC_LIBRARY) \
	$(call __module-check-libs-class,$1,SHARED_LIBRARIES,SHARED_LIBRARY) \

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
		$(if $(call is-module-in-build-config,$1), \
			$(error $(__path): module '$1' depends on module '$2' which is not of class '$3'), \
			$(warning $(__path): module '$1' depends on module '$2' which is not of class '$3') \
		) \
	)

###############################################################################
## Used to make some internal checks.
###############################################################################

# Check variables of all modules
modules-check-variables = \
	$(foreach __mod,$(__modules), \
		$(call __module-check-variables,$(__mod)) \
	)

# Check variables of a module
# $1 : module name.
__module-check-variables = \
	$(call __module-check-src-files,$1) \
	$(call __module-check-c-includes,$1)

# Check that all files listed in LOCAL_SRC_FILES exist
# $1 : module name.
__module-check-src-files = \
	$(eval __path := $(__modules.$1.PATH)) \
	$(foreach __file,$(__modules.$1.SRC_FILES), \
		$(if $(wildcard $(__path)/$(__file)),$(empty), \
			$(warning $(__path): module '$1' uses missing source file '$(__file)') \
		) \
	)

# Check that all directory listed in LOCAL_C_INCLUDES exist
__module-check-c-includes = \
	$(eval __path := $(__modules.$1.PATH)) \
	$(foreach __inc,$(__modules.$1.C_INCLUDES), \
		$(eval __inc2 := $(patsubst -I%,%,$(__inc))) \
		$(if $(wildcard $(__inc2)),$(empty), \
			$(warning $(__path): module '$1' uses missing include '$(__inc2)') \
		) \
	)

###############################################################################
## Used to compute all dependencies once all module information has been
## recorded.
###############################################################################

# Compute dependencies of all modules
# Do direct dependencies first, then full
# The dummy assignment is to discard output generated internally
modules-compute-depends = \
	$(foreach __mod,$(__modules), \
		$(eval __modules.$(__mod).depends := $(empty)) \
		$(eval __modules.$(__mod).depends.EXTERNAL_LIBRARIES := $(empty)) \
		$(eval __modules.$(__mod).depends.STATIC_LIBRARIES := $(empty)) \
		$(eval __modules.$(__mod).depends.WHOLE_STATIC_LIBRARIES := $(empty)) \
		$(eval __modules.$(__mod).depends.SHARED_LIBRARIES := $(empty)) \
		$(eval __modules.$(__mod).depends.all := $(empty)) \
		$(call __module-update-depends-direct,$(__mod)) \
		$(call __module-compute-depends-direct,$(__mod)) \
	) \
	$(foreach __mod,$(__modules), \
		$(eval __dummy := $(call __module-compute-depends-static,$(__mod),EXTERNAL_LIBRARIES)) \
		$(eval __dummy := $(call __module-compute-depends-static,$(__mod),STATIC_LIBRARIES)) \
		$(eval __dummy := $(call __module-compute-depends-static,$(__mod),WHOLE_STATIC_LIBRARIES)) \
		$(eval __dummy := $(call __module-compute-depends-static,$(__mod),SHARED_LIBRARIES)) \
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
	$(call __module-add-depends-direct,$1,$(__modules.$1.EXTERNAL_LIBRARIES))

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
# TODO: detect cycles, for now it will loop indefinitely.
__module-compute-depends-static = \
	$(eval $1.__var := __modules.$1.depends.$2) \
	$(if $($($1.__var)),$($($1.__var)), \
		$(eval $($1.__var) := $(strip \
			$(call uniq2,$(call __module-compute-depends-static-internal,$1,$2))) \
		) \
		$($($1.__var)) \
	)

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

# Compute all dependencies of a module.
# $1 : module name.
# Note : it recursively descends into libraries to get their dependencies.
# See above the way we use 'local' variable.
__module-compute-depends-all = \
	$(eval $1.__var := __modules.$1.depends.all) \
	$(if $($($1.__var)),$($($1.__var)), \
		$(eval $($1.__var) := $(strip \
			$(call uniq2,$(call __module-compute-depends-all-internal,$1))) \
		) \
		$($($1.__var)) \
	)

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
###############################################################################

module-get-static-depends = \
	$(__modules.$1.depends.$2)

module-get-all-depends = \
	$(__modules.$1.depends.all)

###############################################################################
## Get path of module main target file (in build or staging directory).
## $1 : module name.
###############################################################################
module-get-build-dir = \
	$(TARGET_OUT_BUILD)/$1

module-get-build-filename = \
	$(TARGET_OUT_BUILD)/$1/$(__modules.$1.MODULE_FILENAME)

module-get-staging-filename = \
	$(TARGET_OUT_STAGING)/$(__modules.$1.DESTDIR)/$(__modules.$1.MODULE_FILENAME)

###############################################################################
## Debug cutomization access.
## $1 : module name.
## $2 : field name (CFLAGS, CPPFLAGS, LDFLAGS).
###############################################################################
module-get-debug-flags = $(strip \
	$(if $(call strneq,$(origin debug.$1.$2),undefined), \
		$(debug.$1.$2) \
	))

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
		$(foreach __lib,$(__modules.$1.depends.all), \
			$(eval __deps_data += $(__lib):$(__modules.$(__lib).PATH)) \
		)\
		$(shell $(BUILD_SYSTEM)/pbuild-hook/pbuild-link-hook.sh \
			"$(TARGET_NM)" "$(TARGET_CC) $(TARGET_GLOBAL_CFLAGS)" \
			$1 $2 "$(__deps_data)" $3 \
		) \
	))

###############################################################################
## Commands to generate a precompiled file.
###############################################################################

define transform-h-to-gch
@mkdir -p $(dir $@)
$(call print-banner1,"Precompile",$(PRIVATE_MODULE),$(call path-from-top,$<))
$(call check-pwd-is-top-dir)
$(Q)$(CCACHE) $(TARGET_CXX) \
	$(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES)) \
	$(call normalize-c-includes,$(PRIVATE_C_INCLUDES)) \
	$(TARGET_GLOBAL_CFLAGS) $(TARGET_GLOBAL_CPPFLAGS) $(WARNINGS_CPPFLAGS) \
	$(PRIVATE_CFLAGS) $(PRIVATE_CPPFLAGS) \
	$(TARGET_PCH_FLAGS) -MMD -MP -o $@ \
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
	$(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES)) \
	$(call normalize-c-includes,$(PRIVATE_C_INCLUDES)) \
	$(TARGET_GLOBAL_CFLAGS_$(PRIVATE_MODE)) \
	$(TARGET_GLOBAL_CFLAGS) $(TARGET_GLOBAL_CPPFLAGS) $(WARNINGS_CPPFLAGS) \
	$(PRIVATE_CFLAGS) $(PRIVATE_CPPFLAGS) \
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
	$(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES)) \
	$(call normalize-c-includes,$(PRIVATE_C_INCLUDES)) \
	$(TARGET_GLOBAL_CFLAGS_$(PRIVATE_MODE)) \
	$(TARGET_GLOBAL_CFLAGS) $(WARNINGS_CFLAGS) \
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
	$(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES)) \
	$(call normalize-c-includes,$(PRIVATE_C_INCLUDES)) \
	$(TARGET_GLOBAL_CFLAGS_$(PRIVATE_MODE)) \
	$(TARGET_GLOBAL_CFLAGS) $(WARNINGS_CFLAGS) \
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

# Copy a single file from one place to another, preserving permissions/links and
# overwriting any existing file.
define do-copy-file
@mkdir -p $(dir $@)
$(Q)cp -af $< $@
endef

# Define a rule to copy a file. For use via $(eval).
# $(1) : source file
# $(2) : destination file
define copy-one-file
$(2): $(1)
	@echo "Copy: $$(call path-from-top,$$<) => $$(call path-from-top,$$@)"
	$$(do-copy-file)
endef

###############################################################################
## Commands callable from user makefiles.
###############################################################################

# Get local path
local-get-path = $(call my-dir)

# Get build directory
local-get-build-dir = $(call module-get-build-dir,$(LOCAL_MODULE))

# Register module
local-add-module = $(module-add)
