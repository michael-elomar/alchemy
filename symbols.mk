###############################################################################
## @file symbols.mk
## @author Y.M. Morgan
## @date 2013/04/20
##
## Generate an archive with debugging symbols from staging directory.
###############################################################################

SYMBOLS_TGZ := $(TARGET_OUT)/symbols-$(TARGET_PRODUCT_FULL_NAME).tar.gz

.PHONY: symbols
symbols:
	@echo "Symbols: start"
	@rm -f $(SYMBOLS_TGZ)
	$(Q) cd $(TARGET_OUT_STAGING) && find | file -f- | \
		grep 'not stripped' | cut -d: -f1 | \
		tar -T- -czf $(SYMBOLS_TGZ) --transform "s|^\./|symbols/|"
	@echo "Symbols: done -> $(SYMBOLS_TGZ)"

.PHONY: symbols-clean
symbols-clean:
	$(Q) rm -rf $(SYMBOLS_TGZ)

clean: symbols-clean
dirclean: symbols-clean
clobber: symbols-clean

