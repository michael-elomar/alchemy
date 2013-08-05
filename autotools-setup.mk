###############################################################################
## @file autotools-setup.mk
## @author Y.M. Morgan
## @date 2012/09/21
###############################################################################

###############################################################################
## Setup some internal stuff.
###############################################################################

# Get path to 'install' binary so we can override it in configure environment
# (we add the -p option to preserve timestamp of installed files)
__autotools-install-bin := $(shell which install)

###############################################################################
## Variable used for autotools.
###############################################################################

# Setup compilations flags
TARGET_AUTOTOOLS_CPPFLAGS := $(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES))
TARGET_AUTOTOOLS_CFLAGS := $(TARGET_AUTOTOOLS_CPPFLAGS) $(TARGET_GLOBAL_CFLAGS)
TARGET_AUTOTOOLS_CXXFLAGS := $(TARGET_AUTOTOOLS_CFLAGS) $(TARGET_GLOBAL_CXXFLAGS)
TARGET_AUTOTOOLS_LDFLAGS := $(TARGET_GLOBAL_LDFLAGS) $(TARGET_GLOBAL_LDLIBS)
TARGET_AUTOTOOLS_DYN_LDFLAGS := $(TARGET_GLOBAL_LDFLAGS_SHARED) $(TARGET_GLOBAL_LDLIBS_SHARED)

# Setup pkg-config
TARGET_PKG_CONFIG_ENV := \
	PKG_CONFIG="$(shell which pkg-config)" \
	PKG_CONFIG_PATH="$(TARGET_OUT_STAGING)/usr/lib/pkgconfig:$(TARGET_OUT_STAGING)/lib/pkgconfig" \
	PKG_CONFIG_LIBDIR=""
ifeq ("$(TARGET_OS_FLAVOUR)","native")
  TARGET_PKG_CONFIG_ENV += PKG_CONFIG_SYSROOT_DIR=""
else
  TARGET_PKG_CONFIG_ENV += PKG_CONFIG_SYSROOT_DIR="$(TARGET_OUT_STAGING)"
endif

# Environment to use when executing configure script
TARGET_AUTOTOOLS_CONFIGURE_ENV := \
	AR="$(TARGET_AR)" \
	AS="$(TARGET_AS)" \
	LD="$(TARGET_LD)" \
	NM="$(TARGET_NM)" \
	CC="$(CCACHE) $(TARGET_CC)" \
	GCC="$(CCACHE) $(TARGET_CC)" \
	CXX="$(CCACHE) $(TARGET_CXX)" \
	CPP="$(TARGET_CPP)" \
	RANLIB="$(TARGET_RANLIB)" \
	STRIP="$(TARGET_STRIP)" \
	OBJCOPY="$(TARGET_OBJCOPY)" \
	OBJDUMP="$(TARGET_OBJDUMP)" \
	INSTALL="$(__autotools-install-bin) -p" \
	MANIFEST_TOOL=":" \
	CC_FOR_BUILD="$(HOST_CC)" \
	CPPFLAGS="$(TARGET_AUTOTOOLS_CPPFLAGS)" \
	CFLAGS="$(TARGET_AUTOTOOLS_CFLAGS)" \
	CXXFLAGS="$(TARGET_AUTOTOOLS_CXXFLAGS)" \
	LDFLAGS="$(TARGET_AUTOTOOLS_LDFLAGS)" \
	DYN_LDFLAGS="$(TARGET_AUTOTOOLS_DYN_LDFLAGS)" \
	$(TARGET_PKG_CONFIG_ENV)

# Build triplet
GNU_BUILD_NAME := $(shell $(HOST_CC) -dumpmachine)

# Target triplet
GNU_TARGET_NAME := $(TOOLCHAIN_TARGET_NAME)

# Arguments to give to configure script. Autotools 'host' is the name of the machine
# on which the package will run and  we call it 'target'.
TARGET_AUTOTOOLS_CONFIGURE_ARGS := \
	--build="$(GNU_BUILD_NAME)" \
	--host="$(GNU_TARGET_NAME)" \

# For cross-compilation, use /usr as prefix and install in our staging dir
# For native compilation, use staging as prefix and nothing for install dest dir
ifeq ("$(TARGET_OS_FLAVOUR)","native")
  TARGET_AUTOTOOLS_CONFIGURE_PREFIX := $(TARGET_OUT_STAGING)/usr
  TARGET_AUTOTOOLS_CONFIGURE_SYSCONFDIR := $(TARGET_OUT_STAGING)/etc
  TARGET_AUTOTOOLS_INSTALL_DESTDIR :=
else
  TARGET_AUTOTOOLS_CONFIGURE_PREFIX := /usr
  TARGET_AUTOTOOLS_CONFIGURE_SYSCONFDIR := /etc
  TARGET_AUTOTOOLS_INSTALL_DESTDIR := $(TARGET_OUT_STAGING)
endif

TARGET_AUTOTOOLS_CONFIGURE_ARGS += \
	--prefix="$(TARGET_AUTOTOOLS_CONFIGURE_PREFIX)" \
	--sysconfdir="$(TARGET_AUTOTOOLS_CONFIGURE_SYSCONFDIR)"

# Avoid triggering regeneration of configure/Makefile.in. The regeneration
# could cause issues because it would remove the patches we made in libtool
TARGET_AUTOTOOLS_CONFIGURE_ARGS += \
	--disable-maintainer-mode

# Disable locale support
TARGET_AUTOTOOLS_CONFIGURE_ARGS += \
	--disable-nls

# Disable documentation
TARGET_AUTOTOOLS_CONFIGURE_ARGS += \
	--disable-gtk-doc \
	--disable-gtk-doc-html \
	--disable-doxygen-docs \
	--disable-doc \
	--disable-docs \
	--disable-documentation

# Do'nt display warning for unrecognized options (abvove disabled options may
# not be ctually supported)
TARGET_AUTOTOOLS_CONFIGURE_ARGS += \
	--disable-option-checking

# Environment to use when executing make
# Use PKG_CONFIG_ENV in case a package needs automatic reconfiguration
TARGET_AUTOTOOLS_MAKE_ENV := $(TARGET_PKG_CONFIG_ENV)

# Arguments to give to make
TARGET_AUTOTOOLS_MAKE_ARGS := DESTDIR="$(TARGET_AUTOTOOLS_INSTALL_DESTDIR)"

# Quiet flags
ifeq ("$(V)","0")
  TARGET_AUTOTOOLS_CONFIGURE_ARGS += --quiet --enable-silent-rules
  TARGET_AUTOTOOLS_MAKE_ENV += LIBTOOLFLAGS="--quiet"
  TARGET_AUTOTOOLS_MAKE_ARGS += -s --no-print-directory
endif

###############################################################################
## For compatibility.
###############################################################################

PKG_CONFIG_ENV := $(TARGET_PKG_CONFIG_ENV)
AUTOTOOLS_CONFIGURE_ENV := $(TARGET_AUTOTOOLS_CONFIGURE_ENV)
AUTOTOOLS_CONFIGURE_ARGS := $(TARGET_AUTOTOOLS_CONFIGURE_ARGS)
AUTOTOOLS_CONFIGURE_PREFIX := $(TARGET_AUTOTOOLS_CONFIGURE_PREFIX)
AUTOTOOLS_CONFIGURE_SYSCONFDIR := $(TARGET_AUTOTOOLS_CONFIGURE_SYSCONFDIR)
AUTOTOOLS_INSTALL_DESTDIR := $(TARGET_AUTOTOOLS_INSTALL_DESTDIR)
AUTOTOOLS_MAKE_ENV := $(TARGET_AUTOTOOLS_MAKE_ENV)
AUTOTOOLS_MAKE_ARGS := $(TARGET_AUTOTOOLS_MAKE_ARGS)
