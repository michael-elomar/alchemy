###############################################################################
## @file variables.mk
## @author Y.M. Morgan
## @date 2013/04/02
##
## List LOCAL_XXX and TARGET_XXX variables .
###############################################################################

###############################################################################
## List of LOCAL_XXX variables that can be set by makefiles.
###############################################################################
vars-LOCAL :=
macros-LOCAL :=

# Path of the root of module
vars-LOCAL += PATH

# Name of what's supposed to be generated
vars-LOCAL += MODULE

# Override the name of what will be generated
vars-LOCAL += MODULE_FILENAME

# Description of the module
vars-LOCAL += DESCRIPTION

# Category path of the module
vars-LOCAL += CATEGORY_PATH

# List of 'done' files indicating internal steps already done and that does not need
# to be executed next time unless a force is requested
# Name is relative to build directory
vars-LOCAL += DONE_FILES

# Source files to compile
# All files are relative to LOCAL_PATH
vars-LOCAL += SRC_FILES

# Generated source files to compile
# All files are relative to build directory
vars-LOCAL += GENERATED_SRC_FILES

# Static libraries that you want to include in your module
# Names of modules in the build system, without path/prefix/suffix
vars-LOCAL += STATIC_LIBRARIES

# Static libraries that you want to include as a whole in your module
# To generate a '.so' from a '.a' for ex
# Names of modules in the build system, without path/prefix/suffix
vars-LOCAL += WHOLE_STATIC_LIBRARIES

# Libraries you directly link against
# Names of modules in the build system, without path/prefix/suffix
vars-LOCAL += SHARED_LIBRARIES

# External libraries (not built directly by the build system rules)
# Used as dependencies to trigger indirect build.
vars-LOCAL += EXTERNAL_LIBRARIES

# General libraries to add in dependency based on their actual class (STATIC/SHARED/EXTERNAL).
vars-LOCAL += LIBRARIES

# Modules whose headers are required to build
vars-LOCAL += DEPENDS_HEADERS

# Other modules required (at runtime for example). But not required for build
vars-LOCAL += DEPENDS_MODULES
vars-LOCAL += REQUIRED_MODULES

# Additional include directories to pass into the C/C++ compilers
# Format : <fullpath> (-I will be prepended automatically)
vars-LOCAL += C_INCLUDES

# Additional flags to pass into the C or C++ compiler
vars-LOCAL += CFLAGS

# Additional flags to pass into only the C++ compiler
vars-LOCAL += CXXFLAGS

# Additional flags to pass into the static library generator
vars-LOCAL += ARFLAGS

# Additional flags to pass into the linker
vars-LOCAL += LDFLAGS

# Additional libraries to pass into the linker
# Format : -l<name>
vars-LOCAL += LDLIBS

# Precompiled file
# Relative to LOCAL_PATH
vars-LOCAL += PRECOMPILED_FILE

# Arm compilation mode (arm or thumb)
vars-LOCAL += ARM_MODE

# Paths to config.in files to configure the module
# Relative to LOCAL_PATH
vars-LOCAL += CONFIG_FILES

# List of prerequisites for all objects
vars-LOCAL += PREREQUISITES

# ParrotBuild compatibility hook required
vars-LOCAL += PBUILD_HOOK
vars-LOCAL += PBUILD_ALLOW_FORCE_STATIC

# Force modules that depends on this one to use whole-static library
vars-LOCAL += FORCE_WHOLE_STATIC_LIBRARY

# Files and directories to delete during a clean
vars-LOCAL += CLEAN_FILES
vars-LOCAL += CLEAN_DIRS

# Macro to be executed before installing binary in staging dir
macros-LOCAL += CMD_PRE_INSTALL

# Macro to be executed after dirclean is done
macros-LOCAL += CMD_POST_DIRCLEAN

# Archive extraction + patch support
vars-LOCAL += ARCHIVE
vars-LOCAL += ARCHIVE_VERSION
vars-LOCAL += ARCHIVE_SUBDIR
vars-LOCAL += ARCHIVE_PATCHES
macros-LOCAL += ARCHIVE_CMD_UNPACK
macros-LOCAL += ARCHIVE_CMD_POST_UNPACK

# Autotools customization
vars-LOCAL += AUTOTOOLS_VERSION
vars-LOCAL += AUTOTOOLS_ARCHIVE
vars-LOCAL += AUTOTOOLS_SUBDIR
vars-LOCAL += AUTOTOOLS_PATCHES
vars-LOCAL += AUTOTOOLS_CONFIGURE_ENV
vars-LOCAL += AUTOTOOLS_CONFIGURE_ARGS
vars-LOCAL += AUTOTOOLS_MAKE_BUILD_ENV
vars-LOCAL += AUTOTOOLS_MAKE_BUILD_ARGS
vars-LOCAL += AUTOTOOLS_MAKE_INSTALL_ENV
vars-LOCAL += AUTOTOOLS_MAKE_INSTALL_ARGS
macros-LOCAL += AUTOTOOLS_CMD_UNPACK
macros-LOCAL += AUTOTOOLS_CMD_CONFIGURE
macros-LOCAL += AUTOTOOLS_CMD_BUILD
macros-LOCAL += AUTOTOOLS_CMD_INSTALL
macros-LOCAL += AUTOTOOLS_CMD_CLEAN
macros-LOCAL += AUTOTOOLS_CMD_POST_UNPACK
macros-LOCAL += AUTOTOOLS_CMD_POST_CONFIGURE
macros-LOCAL += AUTOTOOLS_CMD_POST_BUILD
macros-LOCAL += AUTOTOOLS_CMD_POST_INSTALL
macros-LOCAL += AUTOTOOLS_CMD_POST_CLEAN

# Exported stuff (will be added in modules depending on this one)
vars-LOCAL += EXPORT_C_INCLUDES
vars-LOCAL += EXPORT_CFLAGS
vars-LOCAL += EXPORT_CXXFLAGS
vars-LOCAL += EXPORT_LDLIBS
vars-LOCAL += EXPORT_PREREQUISITES

# Module class : STATIC_LIBRARY SHARED_LIBRARY EXECUTABLE PREBUILT AUTOTOOLS
vars-LOCAL += MODULE_CLASS

# List of files to copy
# Format <src>:<dst>
# src : source, relative to module path or abosulte path
# dst : destination, relative to staging dir or abosulte path, ends with '/'
#       to use same basename as <src>
vars-LOCAL += COPY_FILES

# List of links to create
# Format <name>:<target>
# name : name of the link (relative to staging dir)
# target : target of the link
vars-LOCAL += CREATE_LINKS

# List of headers to install
# Format <src>[:<dst]>
# src : source, relative to module path or abosulte path
# dst : destination, relative to staging dir or abosulte path, ends with '/'
#       to use same basename as <src>. If not specified, will be put in
#       usr/include directory of staging directory
vars-LOCAL += INSTALL_HEADERS

# Other variables used internally
vars-LOCAL += BUILD_MODULE
vars-LOCAL += STAGING_MODULE
vars-LOCAL += DESTDIR
vars-LOCAL += TARGETS
