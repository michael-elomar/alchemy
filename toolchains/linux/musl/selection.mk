###############################################################################
## @file toolchains/linux/musl/selection.mk
## @author Y.M. Morgan
## @author J. Perchet
## @date 2016/08/01
##
## Setup toolchain variables.
###############################################################################

ifndef TARGET_CROSS
  ifeq ("$(TARGET_CPU)","o3")
    TARGET_CROSS := /opt/arm-2015.10-musl-ct-ng/bin/arm-none-linux-musleabi-
  endif
endif

# TODO: move this in autotools setup
# Machine targetted by toolchain to be used by autotools
# Use a name that will force autotools to believe we are cross-compiling
# Do nothing for non chroot native build with TARGET_ARCH = HOST_ARCH
ifeq ("$(TARGET_OS_FLAVOUR)-$(TARGET_ARCH)","native-$(HOST_ARCH)")
  # Leave GNU_TARGET_NAME undefined
else ifeq ("$(subst -chroot,,$(TARGET_OS_FLAVOUR))","native")
  # Native with foreign architecture or native chroot
  ifeq ("$(TARGET_ARCH)","x64")
    GNU_TARGET_NAME := x86_64-pc-linux-gnu
  else ifeq ("$(TARGET_ARCH)","x86")
    GNU_TARGET_NAME := i686-pc-linux-gnu
  endif
else
  # Not a native flavour
  ifeq ("$(TARGET_ARCH)","x64")
    GNU_TARGET_NAME := x86_64-none-linux-gnu
  else ifeq ("$(TARGET_ARCH)","x86")
    GNU_TARGET_NAME := i686-none-linux-gnu
  else
    ifeq ("$(TARGET_ARCH)","arm")
        # A lot of autotools are not musl ready. Lying allows to reach a much
        # better interoperability.
      GNU_TARGET_NAME := arm-none-linux-gnueabi
    endif
  endif
endif

