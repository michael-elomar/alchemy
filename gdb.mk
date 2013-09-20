###############################################################################
## @file gdb.mk
## @author Y.M. Morgan
## @date 2013/02/18
##
## Gdb helper file generation.
###############################################################################

GDB_WRAPPER_SCRIPT := $(TARGET_OUT)/alchemy.gdb

GDB_ABSOLUTE_PREFIX := $(TARGET_OUT_STAGING)

GDB_SEARCH_PATH :=

ifeq ("$(TARGET_OS)","linux")
ifeq ("$(TARGET_OS_FLAVOUR)","native-chroot")
  GDB_SEARCH_PATH := $(GDB_SEARCH_PATH):$(TARGET_OUT_FINAL)/usr/lib/debug/lib
endif
endif

ifneq ("$(TOOLCHAIN_LIBC)","")
  GDB_SEARCH_PATH := $(GDB_SEARCH_PATH):$(TOOLCHAIN_LIBC)/lib
  GDB_SEARCH_PATH := $(GDB_SEARCH_PATH):$(TOOLCHAIN_LIBC)/usr/lib
else
  GDB_SEARCH_PATH := $(GDB_SEARCH_PATH):$(TARGET_OUT_FINAL)/lib
  GDB_SEARCH_PATH := $(GDB_SEARCH_PATH):$(TARGET_OUT_FINAL)/usr/lib
endif

# Create a wrapper to be used in gdb with internal macro 'set-lib-path'
$(GDB_WRAPPER_SCRIPT):
	@mkdir -p $(dir $@)
	@rm -f $@
	@echo "Gdb wrapper: $@"
	@echo "define set-lib-path" >> $@
	@echo "  set solib-absolute-prefix $(GDB_ABSOLUTE_PREFIX)" >> $@
	@echo "  set solib-search-path $(GDB_SEARCH_PATH)" >> $@
	@echo "end" >> $@

.PHONY: gdb-wrapper
gdb-wrapper: $(GDB_WRAPPER_SCRIPT)

.PHONY: gdb-wrapper-clean
gdb-wrapper-clean:
	$(Q) rm -f $(GDB_WRAPPER_SCRIPT)

$(ALL_BUILD_MODULES): gdb-wrapper
clean: gdb-wrapper-clean
dirclean: gdb-wrapper-clean
clobber: gdb-wrapper-clean

