###############################################################################
## @file autotools-setup.mk
## @author Y.M. Morgan
## @date 2012/09/21
###############################################################################

###############################################################################
## Variable used for autotools.
###############################################################################

# Get path to 'install' binary so we can override it in configure environement
# (we add the -p option to preserve timestamp of installed files)
AUTOTOOLS_INSTALL_BIN := $(shell which install)

# This needs to be exported to be working properly (In case an already configured
# package tries to reconfigure itself, it will need this)
export PKG_CONFIG_PATH := $(TARGET_OUT_STAGING)/usr/lib/pkgconfig
export PKG_CONFIG_LIBDIR := $(TARGET_OUT_STAGING)/usr/lib/pkgconfig
ifeq ("$(TARGET_OS_FLAVOUR)","native")
  export PKG_CONFIG_SYSROOT_DIR :=
else
  export PKG_CONFIG_SYSROOT_DIR := $(TARGET_OUT_STAGING)
endif

# Environment to use when executing configure script
AUTOTOOLS_CONFIGURE_ENV := \
	AR="$(TARGET_CROSS)ar" \
	AS="$(TARGET_CROSS)as" \
	LD="$(TARGET_CROSS)ld" \
	NM="$(TARGET_CROSS)nm" \
	CC="$(CCACHE) $(TARGET_CROSS)gcc" \
	GCC="$(CCACHE) $(TARGET_CROSS)gcc" \
	CXX="$(CCACHE) $(TARGET_CROSS)g++" \
	CPP="$(TARGET_CROSS)cpp" \
	INSTALL="$(AUTOTOOLS_INSTALL_BIN) -p" \
	RANLIB="$(TARGET_CROSS)ranlib" \
	STRIP="$(TARGET_STRIP)" \
	OBJCOPY="$(TARGET_CROSS)objcopy" \
	OBJDUMP="$(TARGET_CROSS)objdump" \
	CC_FOR_BUILD="$(HOST_CC)" \
	CPPFLAGS="$(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES)) $(TARGET_GLOBAL_CFLAGS)" \
	CFLAGS="$(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES)) $(TARGET_GLOBAL_CFLAGS)" \
	CXXFLAGS="$(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES)) $(TARGET_GLOBAL_CFLAGS) $(TARGET_GLOBAL_CPPFLAGS)" \
	LDFLAGS="$(TARGET_GLOBAL_LDFLAGS) $(TARGET_GLOBAL_LDLIBS)" \
	DYN_LDFLAGS="$(TARGET_GLOBAL_LDFLAGS_SHARED) $(TARGET_GLOBAL_LDLIBS_SHARED)"

# Build triplet
GNU_BUILD_NAME := $(shell $(HOST_CC) -dumpmachine)

# Target triplet
GNU_TARGET_NAME := $(TOOLCHAIN_TARGET_NAME)

# Arguments to give to configure script. Autotools 'host' is the name of the machine
# on which the package will run and  we call it 'target'.
AUTOTOOLS_CONFIGURE_ARGS := \
	--build="$(GNU_BUILD_NAME)" \
	--host="$(GNU_TARGET_NAME)" \

# For cross-compilation, use /usr as prefix and install in our staging dir
# For native compilation, use staging as prefix and nothing for install dest dir
ifeq ("$(TARGET_OS_FLAVOUR)","native")
  AUTOTOOLS_CONFIGURE_PREFIX := $(TARGET_OUT_STAGING)/usr
  AUTOTOOLS_CONFIGURE_SYSCONFDIR := $(TARGET_OUT_STAGING)/etc
  AUTOTOOLS_INSTALL_DESTDIR :=
else
  AUTOTOOLS_CONFIGURE_PREFIX := /usr
  AUTOTOOLS_CONFIGURE_SYSCONFDIR := /etc
  AUTOTOOLS_INSTALL_DESTDIR := $(TARGET_OUT_STAGING)
endif

AUTOTOOLS_CONFIGURE_ARGS += \
	--prefix="$(AUTOTOOLS_CONFIGURE_PREFIX)" \
	--sysconfdir="$(AUTOTOOLS_CONFIGURE_SYSCONFDIR)"

# Avoid triggering regeneration of configure/Makefile.in. The regeneration
# could cause issues because it would remove the patches we made in libtool
AUTOTOOLS_CONFIGURE_ARGS += \
	--disable-maintainer-mode

# Environment to use when executing make
AUTOTOOLS_MAKE_ENV :=

# Arguments to give to make
AUTOTOOLS_MAKE_ARGS := DESTDIR="$(AUTOTOOLS_INSTALL_DESTDIR)"

# Quiet flags
ifeq ("$(V)","0")
  AUTOTOOLS_CONFIGURE_ARGS += --quiet --enable-silent-rules
  AUTOTOOLS_MAKE_ENV += LIBTOOLFLAGS="--quiet"
  AUTOTOOLS_MAKE_ARGS += -s --no-print-directory
endif

