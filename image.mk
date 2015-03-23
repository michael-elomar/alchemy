###############################################################################
## @file image.mk
## @author Y.M. Morgan
## @date 2012/12/13
##
## Image generation.
###############################################################################

# Script that will modify mode/uid/gid of files while generating the image
FIXSTAT := $(BUILD_SYSTEM)/scripts/fixstat.py \
	--user-file=$(TARGET_OUT_FINAL)/etc/passwd \
	--group-file=$(TARGET_OUT_FINAL)/etc/group \
	$(foreach __f,$(TARGET_PERMISSIONS_FILES), \
		--permissions-file=$(__f) \
	)

# Apply default permissions (quite restrictives) only if other rules are present
ifneq ("$(TARGET_PERMISSIONS_FILES)","")
  FIXSTAT += --use-default
endif

###############################################################################
## Image in plf format.
###############################################################################

PLFTOOL ?= plftool
MK_KERNEL_PLF ?= mk_kernel_plf
IMAGE_FILE_PLF := $(TARGET_OUT)/$(TARGET_PRODUCT_FULL_NAME).plf
KERNEL_ZIMAGE := $(TARGET_OUT_STAGING)/boot/zImage

.PHONY: image-plf
image-plf:
	@echo "Image plf: start"
	$(Q) rm -f $(IMAGE_FILE_PLF)
	$(Q) if [ -f "$(KERNEL_ZIMAGE)" ]; then \
		$(MK_KERNEL_PLF) \
			"ignore-boot.cfg" \
			$(KERNEL_ZIMAGE) \
			$(TARGET_OUT_BUILD)/linux/.config \
			$(TARGET_OUT)/kernel.plf; \
		$(PLFTOOL) -a u_data=$(TARGET_OUT)/kernel.plf $(IMAGE_FILE_PLF); \
	elif [ "$(TARGET_CHROOT)" = "0" ]; then \
		echo "Image plf: no kernel image found"; \
	fi
	$(Q) if [ ! -d $(TARGET_OUT_FINAL) ]; then \
		echo "Image plf: missing final directory"; exit 1; \
	else \
		cd $(TARGET_OUT_FINAL); \
		find . ! -name '.' -printf '%P\n' | $(FIXSTAT) | \
			plfbatch '-a u_unixfile="&"' $(IMAGE_FILE_PLF); \
	fi
ifneq ("$(TARGET_IMAGE_PATH_MAP_FILE)","")
	$(Q) PLFTOOL=$(PLFTOOL) $(BUILD_SYSTEM)/scripts/plfremap.py \
		$(TARGET_IMAGE_PATH_MAP_FILE) \
		$(IMAGE_FILE_PLF)
endif
	@echo "Image plf: done -> $(IMAGE_FILE_PLF)"

.PHONY: image-plf-clean
image-plf-clean:
	$(Q)rm -f $(TARGET_OUT)/kernel.plf
	$(Q)rm -f $(IMAGE_FILE_PLF)

# Only add dependency if it is also given in goals to avoid unecessary checks
ifneq ("$(call is-targets-in-make-goals,all)","")
image-plf: all
endif
ifneq ("$(call is-targets-in-make-goals,final)","")
image-plf: final
endif

clobber: image-plf-clean

# Compatibility shortcut
.PHONY: plf plf-clean
plf: image-plf
plf-clean: image-plf-clean

###############################################################################
## Generic image generation
###############################################################################
# $1 : file system type
# $2 : output filename
# $3 : extra arguments
define genimage
	$(Q) if [ ! -d $(TARGET_OUT_FINAL) ]; then \
		echo "Image $1: missing final directory"; exit 1; \
	else \
		cd $(TARGET_OUT_FINAL); \
		find . ! -name '.' -printf '%P\n' | $(FIXSTAT) | \
			$(BUILD_SYSTEM)/scripts/mkfs.py --fstype $1 $3 $2; \
	fi
endef

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
	$(call genimage,cpio,$(IMAGE_FILE_CPIO) --devnode "dev/console:622:0:0:c:5:1")
	$(Q) gzip -9 $(IMAGE_FILE_CPIO)
	@echo "Image cpio: done -> $(IMAGE_FILE_CPIO_GZ)"
ifneq ("$(TARGET_LINUX_LINK_CPIO_IMAGE)","0")
	@echo "Rebuilding linux kernel with initramfs"
	$(Q) cp -af $(IMAGE_FILE_CPIO_GZ) $(LINUX_BUILD_DIR)/rootfs.cpio.gz
	$(Q) $(MAKE) $(LINUX_MAKE_ARGS)
	$(call linux-copy-images)
endif

.PHONY: image-cpio-clean
image-cpio-clean:
	$(Q) rm -f $(IMAGE_FILE_CPIO)
	$(Q) rm -f $(IMAGE_FILE_CPIO_GZ)

# Only add dependency if it is also given in goals to avoid unecessary checks
ifneq ("$(call is-targets-in-make-goals,all)","")
image-cpio: all
endif
ifneq ("$(call is-targets-in-make-goals,final)","")
image-cpio: final
endif

clobber: image-cpio-clean

###############################################################################
## Image in ext2 format.
###############################################################################

IMAGE_FILE_EXT2 := $(TARGET_OUT)/$(TARGET_PRODUCT_FULL_NAME).ext2

.PHONY: image-ext2
image-ext2:
	@echo "Image ext2: start"
	$(Q) rm -f $(IMAGE_FILE_EXT2)
	$(Q) rm -f $(IMAGE_FILE_EXT2_GZ)
	$(call genimage,ext2,$(IMAGE_FILE_EXT2),$(empty))
	@echo "Image ext2: done -> $(IMAGE_FILE_EXT2)"

.PHONY: image-ext2-clean
image-ext2-clean:
	$(Q) rm -f $(IMAGE_FILE_EXT2)
	$(Q) rm -f $(IMAGE_FILE_EXT2_GZ)

# Only add dependency if it is also given in goals to avoid unecessary checks
ifneq ("$(call is-targets-in-make-goals,all)","")
image-ext2: all
endif
ifneq ("$(call is-targets-in-make-goals,final)","")
image-ext2: final
endif

clobber: image-ext2-clean

###############################################################################
## Script for fixing permissions on-the-fly in native final tree.
###############################################################################
.PHONY: native-fix-script
native-fix-script:
	$(Q) if [ -f $(TARGET_OUT)/filelist.txt ]; then \
		cd $(TARGET_OUT_FINAL); \
			cat $(TARGET_OUT)/filelist.txt | \
			$(FIXSTAT) --generate-fix-script > \
			$(TARGET_OUT_FINAL)/native-fixperms.sh; \
	fi
	@chmod +x $(TARGET_OUT_FINAL)/native-fixperms.sh

.PHONY: native-fix-script-clean
native-fix-script-clean:
	$(Q) rm -f $(TARGET_OUT_FINAL)/native-fixperms.sh

# Only add dependency if it is also given in goals to avoid unecessary checks
ifneq ("$(call is-targets-in-make-goals,all)","")
native-fix-script: all
endif
ifneq ("$(call is-targets-in-make-goals,final)","")
native-fix-script: final
endif

clobber: native-fix-script-clean
