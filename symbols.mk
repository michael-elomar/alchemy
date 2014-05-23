###############################################################################
## @file symbols.mk
## @author Y.M. Morgan
## @date 2013/04/20
##
## Generate an archive with debugging symbols from staging directory.
###############################################################################

SYMBOLS_TAR := $(TARGET_OUT)/symbols-$(TARGET_PRODUCT_FULL_NAME).tar
SYMBOLS_TAR_GZ := $(TARGET_OUT)/symbols-$(TARGET_PRODUCT_FULL_NAME).tar.gz

# Determine chroot path of the target
SYMBOLS_ROOT :=
ifeq ("$(TARGET_CHROOT)","1")
  ifneq ("$(TARGET_IMAGE_PATH_MAP_FILE)","")
    SYMBOLS_ROOT := $(shell awk '{ if ($$1 ~ /^\/$$/ ){print $$3;}}' $(TARGET_IMAGE_PATH_MAP_FILE))
  endif
endif

# Tar archive, no compression
.PHONY: symbols-tar
symbols-tar:
	@echo "Symbols: start"
	@rm -f $(SYMBOLS_TAR)
	$(Q) cd $(TARGET_OUT_STAGING) && find | file -f- | \
		grep 'not stripped' | cut -d: -f1 | \
		tar -T- -cf $(SYMBOLS_TAR) --transform "s|^\./|symbols$(SYMBOLS_ROOT)/|"
	@echo "Symbols: done -> $(SYMBOLS_TAR)"

# Tar archive gzip compressed
.PHONY: symbols-tar-gz
symbols-tar-gz:
	@echo "Symbols: start"
	@rm -f $(SYMBOLS_TAR_GZ)
	$(Q) cd $(TARGET_OUT_STAGING) && find | file -f- | \
		grep 'not stripped' | cut -d: -f1 | \
		tar -T- -czf $(SYMBOLS_TAR_GZ) --transform "s|^\./|symbols$(SYMBOLS_ROOT)/|"
	@echo "Symbols: done -> $(SYMBOLS_TAR_GZ)"

.PHONY: symbols-clean
symbols-clean:
	$(Q) rm -rf $(SYMBOLS_TAR)
	$(Q) rm -rf $(SYMBOLS_TAR_GZ)

# Only add dependency if it is also given in goals to avoid unecessary checks
# symbols target never depends on final
ifneq ("$(call is-targets-in-make-goals,all)","")
symbols: all
endif

clean: symbols-clean
dirclean: symbols-clean
clobber: symbols-clean

# Compatiblility
.PHONY: symbols
symbols: symbols-tar-gz

