###############################################################################
## @file plf.mk
## @author Y.M. Morgan
## @date 2012/11/05
##
## Plf generation.
###############################################################################

###############################################################################
###############################################################################

PLFTOOL ?= plftool
MK_KERNEL_PLF ?= mk_kernel_plf
PRODUCT_PLF := $(TARGET_OUT)/$(TARGET_PRODUCT).plf

.PHONY: plf
plf:
	@echo "Plf image: start"
	$(Q) rm -f $(PRODUCT_PLF)
	$(Q) $(MK_KERNEL_PLF) \
		"ignore-boot.cfg" \
		$(TARGET_OUT_STAGING)/zImage \
		$(TARGET_OUT_BUILD)/linux/.config \
		$(TARGET_OUT)/kernel.plf
	$(Q) $(PLFTOOL) -a u_data=$(TARGET_OUT)/kernel.plf $(PRODUCT_PLF)
	$(Q) cd $(TARGET_OUT_FINAL); \
		find . ! -name '.' -printf '%P;uid=0;gid=0\n' | \
			plfbatch '-a u_unixfile="&"' $(PRODUCT_PLF)
	@echo "Plf image: done -> $(PRODUCT_PLF)"

.PHONY: plf-clean
plf-clean:
	$(Q)rm -f $(TARGET_OUT)/kernel.plf
	$(Q)rm -f $(PRODUCT_PLF)

clean: plf-clean
clobber: plf-clean

