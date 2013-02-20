###############################################################################
## @file image.mk
## @author Y.M. Morgan
## @date 2012/12/13
##
## Image generation.
###############################################################################

###############################################################################
## Image in plf format.
###############################################################################

PLFTOOL ?= plftool
MK_KERNEL_PLF ?= mk_kernel_plf
IMAGE_FILE_PLF := $(TARGET_OUT)/$(TARGET_PRODUCT_FULL_NAME).plf

# zImage can be found at 2 places
# TODO: migrate all atom.mk of kernel so that they use boot directory
ifneq ("$(wildcard $(TARGET_OUT_STAGING)/zImage)","")
  KERNEL_ZIMAGE := $(TARGET_OUT_STAGING)/zImage
else ifneq ("$(wildcard $(TARGET_OUT_STAGING)/boot/zImage)","")
  KERNEL_ZIMAGE := $(TARGET_OUT_STAGING)/boot/zImage
endif

.PHONY: image-plf
image-plf:
	@echo "Image plf: start"
	$(Q) rm -f $(IMAGE_FILE_PLF)
	$(Q) $(MK_KERNEL_PLF) \
		"ignore-boot.cfg" \
		$(KERNEL_ZIMAGE) \
		$(TARGET_OUT_BUILD)/linux/.config \
		$(TARGET_OUT)/kernel.plf
	$(Q) $(PLFTOOL) -a u_data=$(TARGET_OUT)/kernel.plf $(IMAGE_FILE_PLF)
	$(Q) cd $(TARGET_OUT_FINAL); \
		find . ! -name '.' -printf '%P;uid=0;gid=0\n' | \
			plfbatch '-a u_unixfile="&"' $(IMAGE_FILE_PLF)
	@echo "Image plf: done -> $(IMAGE_FILE_PLF)"

.PHONY: image-plf-clean
image-plf-clean:
	$(Q)rm -f $(TARGET_OUT)/kernel.plf
	$(Q)rm -f $(IMAGE_FILE_PLF)

clean: image-plf-clean
dirclean: image-plf-clean
clobber: image-plf-clean

# Compatibility shortcut
.PHONY: plf plf-clean
plf: image-plf
plf-clean: image-plf-clean

###############################################################################
## Image in cpio format.
###############################################################################

IMAGE_FILE_CPIO := $(TARGET_OUT)/$(TARGET_PRODUCT_FULL_NAME).cpio
IMAGE_FILE_CPIO_GZ := $(IMAGE_FILE_CPIO).gz

.PHONY: image-cpio
image-cpio:
	@echo "Image cpio: start"
	$(Q) rm -f $(IMAGE_FILE_CPIO)
	$(Q) rm -f $(IMAGE_FILE_CPIO_GZ)
	$(Q) cd $(TARGET_OUT_FINAL); \
		find . ! -name '.' | cpio --quiet -o -H newc > $(IMAGE_FILE_CPIO)
	$(Q) gzip -9 $(IMAGE_FILE_CPIO)
	@echo "Image cpio: done -> $(IMAGE_FILE_CPIO_GZ)"

.PHONY: image-cpio-clean
image-cpio-clean:
	$(Q) rm -f $(IMAGE_FILE_CPIO)
	$(Q) rm -f $(IMAGE_FILE_CPIO_GZ)

clean: image-cpio-clean
dirclean: image-cpio-clean
clobber: image-cpio-clean
