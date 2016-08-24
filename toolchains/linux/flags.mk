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

# Enable link optimization for binutils's ld.
TARGET_GLOBAL_LDFLAGS += -Wl,-O1,--hash-style=both
