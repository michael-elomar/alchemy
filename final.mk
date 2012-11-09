###############################################################################
## @file final.mk
## @author Y.M. Morgan
## @date 2012/11/05
##
## Final tree generation.
###############################################################################

# Determine arguments
MAKEFINAL_SCRIPT := $(BUILD_SYSTEM)/scripts/makefinal.py -v
MAKEFINAL_ARGS := 

ifneq ("$(TARGET_SKEL)","")
  MAKEFINAL_ARGS += "--skel=$(TARGET_SKEL)"
endif

ifneq ("$(TOOLCHAIN_LIBC)","")
  MAKEFINAL_ARGS += "--toolchain-libc=$(TOOLCHAIN_LIBC)"
endif

ifneq ("$(TOOLCHAIN_GDBSERVER)","")
  MAKEFINAL_ARGS += "--toolchain-gdbserver=$(TOOLCHAIN_GDBSERVER)"
endif

# Generate final tree
.PHONY: final
final:
	@echo "Generating final tree..."
	$(Q)rm -rf $(TARGET_OUT_FINAL)
	$(Q)$(MAKEFINAL_SCRIPT) $(MAKEFINAL_ARGS) \
		--strip="$(TARGET_STRIP)" \
		$(TARGET_OUT_STAGING) $(TARGET_OUT_FINAL)
	@echo "Done generating final tree"

# Generate final tree without stripping executables
.PHONY: final-nostrip
final-nostrip:
	@echo "Generating final tree (no stripping)..."
	$(Q)rm -rf $(TARGET_OUT_FINAL)
	$(Q)$(MAKEFINAL_SCRIPT) $(MAKEFINAL_ARGS) \
		$(TARGET_OUT_STAGING) $(TARGET_OUT_FINAL)
	@echo "Done generating final tree (no stripping)"

