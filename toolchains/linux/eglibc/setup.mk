###############################################################################
## @file linux/eglibc/setup.mk
## @author Y.M. Morgan
## @date 2012/11/05
##
## This file contains additional setup for eglibc.
###############################################################################

# Select a default toolchain
ifndef TARGET_CROSS
  ifeq ("$(TARGET_ARCH)","arm")
    __target_triplet := arm-none-linux-gnueabi
    ifeq ("$(TARGET_CPU)","p6")
      __toolchain_root := /opt/arm-2009q1
    else ifeq ("$(TARGET_CPU)","p6i")
      __toolchain_root := /opt/arm-2009q1
    else
      __toolchain_root := /opt/arm-2012.03
    endif
    TARGET_CROSS := $(__toolchain_root)/bin/$(__target_triplet)-
  endif
else
  # Try to extract info from TARGET_CROSS
  __target_triplet :=$(notdir $(TARGET_CROSS:-=))
  __toolchain_root := $(shell PARAM=$(TARGET_CROSS);echo $${PARAM%/bin*})
endif

# Assume everybody will wants this
TARGET_GLOBAL_LDLIBS += -pthread -lrt
TARGET_GLOBAL_LDLIBS_SHARED += -pthread -lrt
TARGET_GLOBAL_CFLAGS += -funwind-tables

# Gcc sysroot
# We use cflags as well as arm/thumb mode to select correct variant
gcc-sysroot-flags := $(TARGET_GLOBAL_CFLAGS)
ifeq ("$(TARGET_ARCH)","arm")
  gcc-sysroot-flags += $(TARGET_GLOBAL_CFLAGS_$(TARGET_DEFAULT_ARM_MODE))
endif
gcc-sysroot := $(shell $(TARGET_CROSS)gcc $(gcc-sysroot-flags) -print-sysroot)

# Get libc/gdbserver to copy
ifneq ("$(gcc-sysroot)","")
  ifneq ("$(wildcard $(gcc-sysroot))","")
    TOOLCHAIN_LIBC := $(gcc-sysroot)
    ifneq ("$(wildcard $(gcc-sysroot)/usr/bin/gdbserver)","")
      TOOLCHAIN_GDBSERVER := $(gcc-sysroot)/usr/bin/gdbserver
    else ifneq ("$(wildcard $(gcc-sysroot)/../debug-root/usr/bin/gdbserver)","")
      TOOLCHAIN_GDBSERVER := $(gcc-sysroot)/../debug-root/usr/bin/gdbserver
    endif
  endif
endif

# Clang uses eglibc toochain(libc&binutils) to cross-compile
ifeq ("$(TARGET_ARCH)","arm")
# Clang needs the raw sysroot, so remove the binary specific version.
TARGET_GLOBAL_CFLAGS_clang += --sysroot=$(subst thumb2,,$(gcc-sysroot)) \
	-target $(__target_triplet) -B $(__toolchain_root)
TARGET_GLOBAL_LDFLAGS_clang += --sysroot=$(subst thumb2,,$(gcc-sysroot)) \
	-target $(__target_triplet) -B $(__toolchain_root)
TARGET_GLOBAL_LDFLAGS_SHARED_clang += --sysroot=$(subst thumb2,,$(gcc-sysroot)) \
	-target $(__target_triplet) -B $(__toolchain_root)
endif
