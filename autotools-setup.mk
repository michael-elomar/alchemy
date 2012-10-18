###############################################################################
## @file autotools-setup.mk
## @author Y.M. Morgan
## @date 2012/09/21
###############################################################################

###############################################################################
## Variable used for autotools.
###############################################################################

# Environment to use when executing configure script
AUTOTOOLS_CONFIGURE_ENV := \
	AR="$(TARGET_CROSS)ar" \
	AS="$(TARGET_CROSS)as" \
	LD="$(TARGET_CROSS)ld" \
	NM="$(TARGET_CROSS)nm" \
	CC="$(TARGET_CROSS)gcc" \
	GCC="$(TARGET_CROSS)gcc" \
	CXX="$(TARGET_CROSS)g++" \
	CPP="$(TARGET_CROSS)cpp" \
	RANLIB="$(TARGET_CROSS)ranlib" \
	STRIP="$(TARGET_STRIP)" \
	OBJCOPY="$(TARGET_CROSS)objcopy" \
	CC_FOR_BUILD="$(HOST_CC)" \
	CPPFLAGS="$(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES)) $(TARGET_GLOBAL_CFLAGS)" \
	CFLAGS="$(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES)) $(TARGET_GLOBAL_CFLAGS)" \
	CXXFLAGS="$(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES)) $(TARGET_GLOBAL_CFLAGS) $(TARGET_GLOBAL_CPPFLAGS)" \
	LDFLAGS="$(TARGET_GLOBAL_LDFLAGS) $(TARGET_GLOBAL_LDLIBS)" \
	DYN_LDFLAGS="$(TARGET_GLOBAL_LDFLAGS_SHARED) $(TARGET_GLOBAL_LDLIBS_SHARED)"

#	PKG_CONFIG_SYSROOT="$(TARGET_OUT_STAGING)" \
#	PKG_CONFIG="$(TARGET_OUT_STAGING)/usr/bin/pkg-config"

# FIXME : put this somewehere else...
ifeq ("$(TARGET_ARCH)","ARM")
  ifeq ("$(TARGET_OS_FLAVOUR)","ANDROID")
    GNU_TARGET_NAME := arm-eabi
  else
    GNU_TARGET_NAME := arm-none-linux-gnueabi
  endif
else ifeq ("$(TARGET_ARCH)","X86")
  GNU_TARGET_NAME := i386-linux-gnu
else ifeq ("$(TARGET_ARCH)","X64")
  GNU_TARGET_NAME := x86_64-linux-gnu
endif

# Arguments to give to configure script
AUTOTOOLS_CONFIGURE_ARGS := \
	--host="${GNU_TARGET_NAME}" \
	--prefix="$(TARGET_OUT_STAGING)/usr"

# Environment to use when executing make
AUTOTOOLS_MAKE_ENV :=

# Arguments to give to make
AUTOTOOLS_MAKE_ARGS :=

# Quiet flags
ifeq ("$(V)","0")
  AUTOTOOLS_CONFIGURE_ARGS += --quiet
  AUTOTOOLS_MAKE_ENV += LIBTOOLFLAGS="--quiet"
  AUTOTOOLS_MAKE_ARGS += -s --no-print-directory
endif

