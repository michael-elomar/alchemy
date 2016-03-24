###############################################################################
## @file classes/BINARY/setup.mk
## @author F. Ferrand
## @date 2015/05/11
##
## Setup BINARY modules.
###############################################################################

###############################################################################
## Commands to generate a precompiled file.
###############################################################################

# $1 : mode (HOST / TARGET)
# $2 : destination
# $3 : source
define _internal-transform-h-to-gch
@mkdir -p $(dir $2)
$(call print-banner1,"$(PRIVATE_MODE_MSG)$(PRIVATE_ARCH) Precompile",$(PRIVATE_MODULE),$(call path-from-top,$3))
$(call check-pwd-is-top-dir)
$(Q) $(CCACHE) $(PRIVATE_CXX) \
	$(call normalize-c-includes-rel,$(PRIVATE_C_INCLUDES)) \
	$(call normalize-system-c-includes-rel,$($1_GLOBAL_C_INCLUDES)) \
	$($1_GLOBAL_CFLAGS) $($1_GLOBAL_CXXFLAGS) $(WARNINGS_CXXFLAGS) \
	$($1_GLOBAL_CXXFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$($1_GLOBAL_CFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$(WARNINGS_CXXFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$($1_GLOBAL_CFLAGS_$(PRIVATE_ARCH)) \
	$($1_GLOBAL_CFLAGS_$(PRIVATE_ARCH)_$(PRIVATE_CC_FLAVOUR)) \
	$(PRIVATE_CFLAGS) $(PRIVATE_CXXFLAGS) \
	-MMD -MP -MF $(call path-from-top,$(2:.gch=.d)) -MT $(call path-from-top,$2) \
	-o $(call path-from-top,$2) \
	$($1_GLOBAL_PCH_FLAGS) $(call path-from-top,$3)
$(call fix-deps-file,$(2:.gch=.d))
endef

transform-h-to-gch = $(call _internal-transform-h-to-gch,$(PRIVATE_MODE),$@,$<)

###############################################################################
## Commands to compile a C++ file.
###############################################################################

define _internal-transform-cpp-to-o
@mkdir -p $(dir $2)
$(call print-banner1,"$(PRIVATE_MODE_MSG)$(PRIVATE_ARCH) C++",$(PRIVATE_MODULE),$(call path-from-top,$3))
$(call check-pwd-is-top-dir)
$(Q) $(CCACHE) $(PRIVATE_CXX) \
	$(call normalize-c-includes-rel,$(PRIVATE_C_INCLUDES)) \
	$(call normalize-system-c-includes-rel,$($1_GLOBAL_C_INCLUDES)) \
	$(filter-out -std=%,$($1_GLOBAL_CFLAGS)) $($1_GLOBAL_CXXFLAGS) $(WARNINGS_CXXFLAGS) \
	$($1_GLOBAL_CXXFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$(filter-out -std=%,$($1_GLOBAL_CFLAGS_$(PRIVATE_CC_FLAVOUR))) \
	$(WARNINGS_CXXFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$(filter-out -std=%,$($1_GLOBAL_CFLAGS_$(PRIVATE_ARCH))) \
	$(filter-out -std=%,$($1_GLOBAL_CFLAGS_$(PRIVATE_ARCH)_$(PRIVATE_CC_FLAVOUR))) \
	$(PRIVATE_PCH_INCLUDE) \
	$(filter-out -std=%,$(PRIVATE_CFLAGS)) $(PRIVATE_CXXFLAGS) \
	-MMD -MP -MF $(call path-from-top,$(2:.o=.d)) -MT $(call path-from-top,$2) \
	-o $(call path-from-top,$2) \
	-c $(call path-from-top,$3)
$(call fix-deps-file,$(2:.o=.d))
endef

transform-cpp-to-o = $(call _internal-transform-cpp-to-o,$(PRIVATE_MODE),$@,$<)
transform-cxx-to-o = $(call _internal-transform-cpp-to-o,$(PRIVATE_MODE),$@,$<)
transform-cc-to-o = $(call _internal-transform-cpp-to-o,$(PRIVATE_MODE),$@,$<)

###############################################################################
## Commands to compile a C file.
###############################################################################

define _internal-transform-c-to-o
$(call print-banner1,"$(PRIVATE_MODE_MSG)$(PRIVATE_ARCH) C",$(PRIVATE_MODULE),$(call path-from-top,$3))
$(call check-pwd-is-top-dir)
@mkdir -p $(dir $2)
$(Q) $(CCACHE) $(PRIVATE_CC) \
	$(call normalize-c-includes-rel,$(PRIVATE_C_INCLUDES)) \
	$(call normalize-system-c-includes-rel,$($1_GLOBAL_C_INCLUDES)) \
	$($1_GLOBAL_CFLAGS) $(WARNINGS_CFLAGS) \
	$($1_GLOBAL_CFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$(WARNINGS_CFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$($1_GLOBAL_CFLAGS_$(PRIVATE_ARCH)) \
	$($1_GLOBAL_CFLAGS_$(PRIVATE_ARCH)_$(PRIVATE_CC_FLAVOUR)) \
	$(PRIVATE_CFLAGS) \
	-MMD -MP -MF $(call path-from-top,$(2:.o=.d)) -MT $(call path-from-top,$2) \
	-o $(call path-from-top,$2) \
	-c $(call path-from-top,$3)
$(call fix-deps-file,$(2:.o=.d))
endef

transform-c-to-o = $(call _internal-transform-c-to-o,$(PRIVATE_MODE),$@,$<)

###############################################################################
## Commands to compile a Objective-C file.
###############################################################################

define _internal-transform-m-to-o
$(call print-banner1,"$(PRIVATE_MODE_MSG)$(PRIVATE_ARCH) ObjC",$(PRIVATE_MODULE),$(call path-from-top,$3))
$(call check-pwd-is-top-dir)
@mkdir -p $(dir $2)
$(Q) $(CCACHE) $(PRIVATE_CC) \
	$(call normalize-c-includes-rel,$(PRIVATE_C_INCLUDES)) \
	$(call normalize-system-c-includes-rel,$($1_GLOBAL_C_INCLUDES)) \
	$($1_GLOBAL_CFLAGS) $(WARNINGS_CFLAGS) \
	$($1_GLOBAL_CFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$(WARNINGS_CFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$($1_GLOBAL_CFLAGS_$(PRIVATE_ARCH)) \
	$($1_GLOBAL_CFLAGS_$(PRIVATE_ARCH)_$(PRIVATE_CC_FLAVOUR)) \
	$($1_GLOBAL_OBJCFLAGS) \
	$(PRIVATE_CFLAGS) $(PRIVATE_OBJCFLAGS) \
	-MMD -MP -MF $(call path-from-top,$(2:.o=.d)) -MT $(call path-from-top,$2) \
	-o $(call path-from-top,$2) \
	-c $(call path-from-top,$3)
$(call fix-deps-file,$(2:.o=.d))
endef

transform-m-to-o = $(call _internal-transform-m-to-o,$(PRIVATE_MODE),$@,$<)

###############################################################################
## Commands to compile a s/S file.
###############################################################################

define _internal-transform-s-to-o
$(call print-banner1,"$(PRIVATE_MODE_MSG)Asm",$(PRIVATE_MODULE),$(call path-from-top,$3))
$(call check-pwd-is-top-dir)
@mkdir -p $(dir $@)
$(Q) $(CCACHE) $(PRIVATE_CC) \
	$(call normalize-c-includes-rel,$(PRIVATE_C_INCLUDES)) \
	$(call normalize-system-c-includes-rel,$($1_GLOBAL_C_INCLUDES)) \
	$($1_GLOBAL_ASFLAGS) \
	-D __ASSEMBLY__ \
	$($1_GLOBAL_CFLAGS) $(WARNINGS_CFLAGS) \
	$($1_GLOBAL_CFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$(WARNINGS_CFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$($1_GLOBAL_CFLAGS_$(PRIVATE_ARCH)) \
	$($1_GLOBAL_CFLAGS_$(PRIVATE_ARCH)_$(PRIVATE_CC_FLAVOUR)) \
	$(PRIVATE_ASFLAGS) \
	$(PRIVATE_CFLAGS) \
	-MMD -MP -MF $(call path-from-top,$(2:.o=.d)) -MT $(call path-from-top,$2) \
	-o $(call path-from-top,$2) \
	-c $(call path-from-top,$3)
$(call fix-deps-file,$(2:.o=.d))
endef

transform-s-to-o = $(call _internal-transform-s-to-o,$(PRIVATE_MODE),$@,$<)
transform-S-to-o = $(call _internal-transform-s-to-o,$(PRIVATE_MODE),$@,$<)

###############################################################################
## Commands to compile vala files.
###############################################################################

define _internal-transform-vala-to-c
$(call print-banner1,"$(PRIVATE_MODE_MSG)Valac",$(PRIVATE_MODULE),$(call path-from-top,$(PRIVATE_VALA_SOURCES)))
$(call check-pwd-is-top-dir)
$(Q) $(HOST_OUT_STAGING)/usr/bin/valac \
	$($1_GLOBAL_VALAFLAGS) \
	$(PRIVATE_VALAFLAGS) \
	-C -d $(PRIVATE_VALA_OUT_DIR) \
	-b $(PRIVATE_PATH) \
	--deps $(PRIVATE_VALA_DEPS_FILE) \
	$(PRIVATE_VALA_SOURCES)
endef

transform-vala-to-c = $(call _internal-transform-vala-to-c,$(PRIVATE_MODE))

###############################################################################
## Commands to compile a cu file (cuda).
## Note: Only available for target
###############################################################################

define _internal-transform-cu-to-o
$(call print-banner1,"$(PRIVATE_MODE_MSG)Cuda",$(PRIVATE_MODULE),$(call path-from-top,$3))
$(call check-pwd-is-top-dir)
@mkdir -p $(dir $2)
$(if $(TARGET_NVCC),$(empty),@echo "TARGET_NVCC is not defined"; exit 1)
$(Q) $(TARGET_NVCC) \
	$(call normalize-c-includes-rel,$(PRIVATE_C_INCLUDES)) \
	$(call normalize-system-c-includes-rel,$(TARGET_GLOBAL_C_INCLUDES)) \
	$(TARGET_GLOBAL_NVCFLAGS) \
	$(PRIVATE_NVCFLAGS) \
	-ccbin $(TARGET_CC) \
	-o $(call path-from-top,$2) \
	-c $(call path-from-top,$3)
$(call fix-deps-file,$(2:.o=.d))
endef

transform-cu-to-o = $(call _internal-transform-cu-to-o,$(PRIVATE_MODE),$@,$<)

###############################################################################
## Commands for running ar.
###############################################################################

# Explicitly delete the archive first so that ar doesn't
# try to add to an existing archive.
define _internal-transform-o-to-static-lib
@mkdir -p $(dir $2)
$(call print-banner2,"$(PRIVATE_MODE_MSG)StaticLib",$(PRIVATE_MODULE),$(call path-from-top,$2))
$(call check-pwd-is-top-dir)
@rm -f $2
$(Q) $(PRIVATE_AR) $($1_GLOBAL_ARFLAGS) $(PRIVATE_ARFLAGS) $2 $(PRIVATE_ALL_OBJECTS)
endef

transform-o-to-static-lib = $(call _internal-transform-o-to-static-lib,$(PRIVATE_MODE),$@)

###############################################################################
## Commands to link a shared library.
###############################################################################

define _internal-transform-o-to-shared-lib-darwin
@mkdir -p $(dir $2)
$(call print-banner2,"$(PRIVATE_MODE_MSG)SharedLib",$(PRIVATE_MODULE),$(call path-from-top,$2))
$(call check-pwd-is-top-dir)
$(Q) $(PRIVATE_CXX) \
	$($1_GLOBAL_LDFLAGS_SHARED) \
	$($1_GLOBAL_LDFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$(if $(call streq,$(USE_LINK_MAP_FILE),1), \
		-Wl$(comma)-map$(comma)$(basename $(call path-from-top,$2)).map \
	) \
	-shared \
	-Wl,-dead_strip \
	-Wl,-install_name,$($1_OUT_STAGING)/$($1_DEFAULT_LIB_DESTDIR)/$(notdir $2) \
	$(PRIVATE_LDFLAGS) \
	$(PRIVATE_ALL_OBJECTS) \
	$(call link-hook,$(PRIVATE_MODULE),$2, \
		$(PRIVATE_ALL_OBJECTS) \
		$(PRIVATE_ALL_STATIC_LIBRARIES) \
		$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
	$(foreach __lib, $(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES), -force_load $(__lib)) \
	$(PRIVATE_ALL_STATIC_LIBRARIES) \
	$(PRIVATE_ALL_SHARED_LIBRARIES) \
	-o $(call path-from-top,$2) \
	$(PRIVATE_LDLIBS) \
	$($1_GLOBAL_LDLIBS_SHARED)
endef

define _internal-transform-o-to-shared-lib
@mkdir -p $(dir $2)
$(call print-banner2,"$(PRIVATE_MODE_MSG)SharedLib",$(PRIVATE_MODULE),$(call path-from-top,$2))
$(call check-pwd-is-top-dir)
$(Q) $(PRIVATE_CXX) \
	$($1_GLOBAL_LDFLAGS_SHARED) \
	$($1_GLOBAL_LDFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$(if $(call streq,$(USE_LINK_MAP_FILE),1), \
		-Wl$(comma)-Map$(comma)$(basename $(call path-from-top,$2)).map \
	) \
	-shared \
	-Wl,-soname -Wl,$(notdir $2) \
	-Wl,--no-undefined \
	-Wl,--gc-sections \
	-Wl,--as-needed \
	$(PRIVATE_LDFLAGS) \
	$(PRIVATE_ALL_OBJECTS) \
	$(call link-hook,$(PRIVATE_MODULE),$2, \
		$(PRIVATE_ALL_OBJECTS) \
		$(PRIVATE_ALL_STATIC_LIBRARIES) \
		$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
	-Wl,--whole-archive \
	$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES) \
	-Wl,--no-whole-archive \
	$(PRIVATE_ALL_STATIC_LIBRARIES) \
	$(PRIVATE_ALL_SHARED_LIBRARIES) \
	-o $(call path-from-top,$2) \
	$(PRIVATE_LDLIBS) \
	$($1_GLOBAL_LDLIBS_SHARED)
endef

transform-o-to-shared-lib = $(if $(call streq,$($(PRIVATE_MODE)_OS),darwin), \
	$(call _internal-transform-o-to-shared-lib-darwin,$(PRIVATE_MODE),$@) \
	, \
	$(call _internal-transform-o-to-shared-lib,$(PRIVATE_MODE),$@) \
)

###############################################################################
## Commands to link an executable.
###############################################################################

define _internal-transform-o-to-executable-darwin
@mkdir -p $(dir $2)
$(call print-banner2,"$(PRIVATE_MODE_MSG)Executable",$(PRIVATE_MODULE),$(call path-from-top,$2))
$(call check-pwd-is-top-dir)
$(Q) $(PRIVATE_CXX) \
	$($1_GLOBAL_LDFLAGS) \
	$($1_GLOBAL_LDFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$(if $(call streq,$(USE_LINK_MAP_FILE),1), \
		-Wl$(comma)-map$(comma)$(basename $(call path-from-top,$2)).map \
	) \
	-Wl,-dead_strip \
	$(PRIVATE_LDFLAGS) \
	$(PRIVATE_ALL_OBJECTS) \
	$(call link-hook,$(PRIVATE_MODULE),$2, \
		$(PRIVATE_ALL_OBJECTS) \
		$(PRIVATE_ALL_STATIC_LIBRARIES) \
		$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
	$(foreach __lib, $(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES), -force_load $(__lib)) \
	$(PRIVATE_ALL_STATIC_LIBRARIES) \
	$(PRIVATE_ALL_SHARED_LIBRARIES) \
	-o $(call path-from-top,$2) \
	$(PRIVATE_LDLIBS) \
	$($1_GLOBAL_LDLIBS)
endef

define _internal-transform-o-to-executable
@mkdir -p $(dir $2)
$(call print-banner2,"$(PRIVATE_MODE_MSG)Executable",$(PRIVATE_MODULE),$(call path-from-top,$2))
$(call check-pwd-is-top-dir)
$(Q) $(PRIVATE_CXX) \
	$($1_GLOBAL_LDFLAGS) \
	$($1_GLOBAL_LDFLAGS_$(PRIVATE_CC_FLAVOUR)) \
	$(if $(call streq,$(USE_LINK_MAP_FILE),1), \
		-Wl$(comma)-Map$(comma)$(basename $(call path-from-top,$2)).map \
	) \
	-Wl,--gc-sections \
	-Wl,--as-needed \
	$(PRIVATE_LDFLAGS) \
	$(PRIVATE_ALL_OBJECTS) \
	$(call link-hook,$(PRIVATE_MODULE),$2, \
		$(PRIVATE_ALL_OBJECTS) \
		$(PRIVATE_ALL_STATIC_LIBRARIES) \
		$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
	-Wl,--whole-archive \
	$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES) \
	-Wl,--no-whole-archive \
	$(PRIVATE_ALL_STATIC_LIBRARIES) \
	$(PRIVATE_ALL_SHARED_LIBRARIES) \
	-o $(call path-from-top,$2) \
	$(PRIVATE_LDLIBS) \
	$($1_GLOBAL_LDLIBS)
endef

transform-o-to-executable = $(if $(call streq,$($(PRIVATE_MODE)_OS),darwin), \
	$(call _internal-transform-o-to-executable-darwin,$(PRIVATE_MODE),$@) \
	, \
	$(call _internal-transform-o-to-executable,$(PRIVATE_MODE),$@) \
)

###############################################################################
## Copy to staging/final directory if needed, with strip in final dir
## $1 : HOST/TARGET mode
## $2 : source file
## $3 : destination file
###############################################################################

define _binary-copy-to-final-strip
$3: $2
	@echo "Strip: $(call path-from-top,$2) => $(call path-from-top,$3)"
	@mkdir -p $(dir $3)
	$(Q) $($1_STRIP) -o $3 $2
endef

_binary-copy-to-staging = \
	$(eval $(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $3) \
	$(eval $(_module_installed_stamp_file): $3) \
	$(eval $(call copy-one-file,$2,$3))

_binary-copy-to-final = \
	$(if $(and $(call streq,$1,TARGET),$(wildcard $(TARGET_OUT_FINAL))), \
		$(eval $(LOCAL_MODULE): $3) \
		$(if $(or $(call streq,$(TARGET_NOSTRIP_FINAL),1),$(filter $(TARGET_STRIP_FILTER),$(notdir $2))), \
			$(eval $(call copy-one-file,$2,$3)) \
			, \
			$(eval $(call _binary-copy-to-final-strip,$1,$2,$3)) \
		) \
	)
