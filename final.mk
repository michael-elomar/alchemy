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
ifeq ("$(TARGET_NOSTRIP_FINAL)","0")
  MAKEFINAL_ARGS += --strip="$(TARGET_STRIP)"
endif
endif

ifneq ("$(TARGET_SKEL_DIRS)","")
  $(foreach d,$(TARGET_SKEL_DIRS),$(eval MAKEFINAL_ARGS += --skel="$(d)"))
endif

# If a sdk is used, we assume that basic components shall not be put in final dir
ifeq ("$(TARGET_SDK_DIRS)","")

# Create very minimal skeleton for linux (some absolute required directories)
ifeq ("$(TARGET_OS)","linux")
ifneq ("$(TARGET_OS_FLAVOUR)","native")
  MAKEFINAL_ARGS += --linux-basic-skel
endif
endif

endif

# When valgrind is used, some libs shall not be stripped
ifneq ("$(call is-module-in-build-config,valgrind)","")
MAKEFINAL_ARGS += \
	--strip-filter="ld-*.so" \
	--strip-filter="libc-*.so" \
	--strip-filter="vgpreload*.so"
endif

# When python is used, keep its files, otherwise filter them (default)
ifneq ("$(call is-module-in-build-config,python)","")
  MAKEFINAL_ARGS += --keep-python-files
endif
ifneq ("$(call is-module-in-build-config,python3)","")
  MAKEFINAL_ARGS += --keep-python-files
endif

# Remove write access to 'group' and 'other'. For native only, a fixstat tools
# is used on other variant when generating the image
ifeq ("$(TARGET_OS)","linux")
ifeq ("$(TARGET_OS_FLAVOUR)","native-chroot")
  MAKEFINAL_ARGS += --remove-wgo
endif
endif

# Additional files to filter
MAKEFINAL_ARGS += \
	$(foreach __lib,$(TARGET_STRIP_FILTER),--strip-filter="$(__lib)")

MAKEFINAL_ARGS += \
	--filelist=$(TARGET_OUT)/filelist.txt

###############################################################################
## Add a build-id section to all binaries in staging dir before copying them
## in final tree. This section is similar to what ld -Wl,--build-id would do
## but fixes a bug present on some version of toolchain we use (arm-20009q1 for
## example).
###############################################################################

ifneq ("$(TARGET_ADD_BUILDID_SECTION)","0")
MAKEFINAL_ARGS += \
	--build-id \
	--build-id-objcopy="$(TARGET_CROSS)objcopy" \
	--build-id-section-name="$(TARGET_BUILDID_SECTION_NAME)"
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

# Create /etc/ld.so.conf and create cache with ldconfig
# We use the ldconfig from the host to generate. Hopefully it will be compatible
# with the target. This is what buildroot do if there is no ldconfig in the
# cross toolchain.
ifeq ("$(TARGET_LIBC)","eglibc")
__final-ldconfig = \
	mkdir -p $(TARGET_OUT_FINAL)/etc; \
	touch $(TARGET_OUT_FINAL)/etc/ld.so.conf; \
	/sbin/ldconfig -r $(TARGET_OUT_FINAL);
else
__final-ldconfig =
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
		$(TARGET_OUT_STAGING) $(TARGET_OUT_FINAL) $(TARGET_OUT)/final.mk
	$(Q) $(MAKE) -f $(TARGET_OUT)/final.mk -j1
	$(Q)$(__final-finish)
	$(Q)$(__final-ldconfig)
	@echo "Done generating final tree"

# Only add dependency if it is also given in goals to avoid unecessary checks
ifneq ("$(call is-targets-in-make-goals,all)","")
final: all
endif

