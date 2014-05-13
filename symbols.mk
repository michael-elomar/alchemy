###############################################################################
## @file symbols.mk
## @author Y.M. Morgan
## @date 2013/04/20
##
## Generate an archive with debugging symbols from staging directory.
###############################################################################

SYMBOLS_TGZ := $(TARGET_OUT)/symbols-$(TARGET_PRODUCT_FULL_NAME).tar.gz

# Determine chroot path of the target
SYMBOLS_ROOT :=
ifeq ("$(TARGET_CHROOT)","1")
  ifneq ("$(TARGET_IMAGE_PATH_MAP_FILE)","")
    SYMBOLS_ROOT := $(shell grep '^/ ' $(TARGET_IMAGE_PATH_MAP_FILE) | awk '{ printf $$3 }')
  endif
endif

.PHONY: symbols
symbols:
	@echo "Symbols: start"
	@rm -f $(SYMBOLS_TGZ)
	$(Q) cd $(TARGET_OUT_STAGING) && find | file -f- | \
		grep 'not stripped' | cut -d: -f1 | \
		tar -T- -czf $(SYMBOLS_TGZ) --transform "s|^\./|symbols$(SYMBOLS_ROOT)/|"
	@echo "Symbols: done -> $(SYMBOLS_TGZ)"

.PHONY: symbols-clean
symbols-clean:
	$(Q) rm -rf $(SYMBOLS_TGZ)

# Only add dependency if it is also given in goals to avoid unecessary checks
# symbols target never depends on final
ifneq ("$(call is-targets-in-make-goals,all)","")
symbols: all
endif

clean: symbols-clean
dirclean: symbols-clean
clobber: symbols-clean

