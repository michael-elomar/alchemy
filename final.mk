###############################################################################
## @file final.mk
## @author Y.M. Morgan
## @date 2012/11/05
##
## Final tree generation.
###############################################################################

###############################################################################
## Determine arguments to script.
###############################################################################

MAKEFINAL_SCRIPT := $(BUILD_SYSTEM)/scripts/makefinal.py
MAKEFINAL_ARGS := 

ifneq ("$(TARGET_STRIP)","")
  MAKEFINAL_ARGS += --strip="$(TARGET_STRIP)"
endif

ifneq ("$(TARGET_SKEL)","")
  MAKEFINAL_ARGS += --skel="$(TARGET_SKEL)"
endif

ifneq ("$(TOOLCHAIN_LIBC)","")
  MAKEFINAL_ARGS += --toolchain-libc="$(TOOLCHAIN_LIBC)"
endif

ifneq ("$(TOOLCHAIN_GDBSERVER)","")
  MAKEFINAL_ARGS += --toolchain-gdbserver="$(TOOLCHAIN_GDBSERVER)"
endif

###############################################################################
## Hooks.
###############################################################################

# Prepare final tree by deleting it in some configurations
ifeq ("$(TARGET_OS_FLAVOUR)","native-chroot")
__final-prepare =
else
__final-prepare = rm -rf $(TARGET_OUT_FINAL)
endif

# Finish final tree
ifeq ("$(TARGET_OS_FLAVOUR)","native-chroot")
__final-finish = \
	$(BUILD_SYSTEM)/scripts/native-chroot-copy-libs.sh \
		$(TARGET_OUT_FINAL) $(TARGET_ARCH)
else
__final-finish =
endif

###############################################################################
## Rules.
###############################################################################

# Generate final tree
.PHONY: final
final:
	@echo "Generating final tree..."
	$(Q)$(__final-prepare)
	$(Q)$(MAKEFINAL_SCRIPT) $(MAKEFINAL_ARGS) \
		$(TARGET_OUT_STAGING) $(TARGET_OUT_FINAL)
	$(Q)$(__final-finish)
	@echo "Done generating final tree"

