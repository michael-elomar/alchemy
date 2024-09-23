###############################################################################
## @file toolchains/linux/flags.mk
## @author Y.M. Morgan
## @date 2016/03/05
##
## Additional flags for linux toolchain.
###############################################################################

ifneq ("$(TARGET_LIBC)","")
  -include $(BUILD_SYSTEM)/toolchains/$(TARGET_OS)/$(TARGET_LIBC)/flags.mk
endif

ifeq ("$(TARGET_OS_FLAVOUR)-$(TARGET_CC_FLAVOUR)","yocto-gcc")
  # This is not part of regular GCC, but Yocto builds of GCC support this to
  # prevent broken projects from adding things like -I/usr/include, which doesn't
  # make sense in our case.
  # Qualcomm's Clang toolchain seems to ignore this warning. but regular Clang
  # toolchains throw an error because this option is not recognized.
  TARGET_GLOBAL_CFLAGS += -Werror=poison-system-directories
endif
