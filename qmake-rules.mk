###############################################################################
## @file qmake-rules.mk
## @author Y.M. Morgan
## @date 2014/01/08
##
## Build a module using qmake.
###############################################################################

ifdef QT5_QMAKE
  QMAKE := $(QT5_QMAKE)
  __qmake_has_qt_sysroot := $(true)
else ifdef QT4_QMAKE
  QMAKE := $(QT4_QMAKE)
  __qmake_has_qt_sysroot := $(false)
else ifdef QTSDK_QMAKE
  QMAKE := $(QTSDK_QMAKE)
  __qmake_has_qt_sysroot := $(false)
else
  QMAKE :=
endif

ifeq ("$(QMAKE)","")
  $(error $(LOCAL_MODULE): qmake not found, add Qt4/Qt5 alchemy package or specify Qt SDK path via TARGET_QT_SDKROOT or TARGET_QT_SDK.)
endif

built_file := $(build_dir)/$(LOCAL_MODULE).built
installed_file := $(build_dir)/$(LOCAL_MODULE).installed
alchemy_pri_file := $(build_dir)/alchemy.pri

# Delete some additionnal 'done' files if a skip of external checks is not done
ifeq ("$(skip_ext_checks)","0")
  $(call delete-one-done-file,$(built_file))
  $(call delete-one-done-file,$(installed_file))
endif

# Silence...
ifeq ("$(V)","0")
  qmake_make_arg := -s --no-print-directory
endif

# Generate a .pri file to be included by the .pro file with dependencies found
# by alchemy
ifeq ("$(TARGET_OS)","darwin")

define qmake_gen_deps
	@rm -f $(PRIVATE_ALCHEMY_PRI_FILE)
	@mkdir -p $(dir $(PRIVATE_ALCHEMY_PRI_FILE))
	@( \
		echo "target.path = $(if $(__qmake_has_qt_sysroot),$(TARGET_OUT_STAGING))/$(PRIVATE_DESTDIR)"; \
		echo "INSTALLS += target"; \
		echo "INCLUDEPATH += $(PRIVATE_C_INCLUDES) $(TARGET_GLOBAL_C_INCLUDES)"; \
		echo "DEPENDPATH += $(PRIVATE_C_INCLUDES) $(TARGET_GLOBAL_C_INCLUDES)"; \
		echo "QMAKE_CFLAGS += $(PRIVATE_CFLAGS $(TARGET_GLOBAL_CFLAGS))"; \
		echo "QMAKE_CXXFLAGS += $(PRIVATE_CFLAGS) $(TARGET_GLOBAL_CFLAGS) $(PRIVATE_CXXFLAGS) $(TARGET_GLOBAL_CXXFLAGS)"; \
		echo "LIBS += $(PRIVATE_LDFLAGS) $(TARGET_GLOBAL_LDFLAGS)"; \
		echo "LIBS += $(foreach __lib, $(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES), -force_load $(__lib))"; \
		echo "LIBS += $(PRIVATE_ALL_STATIC_LIBRARIES)"; \
		echo "LIBS += $(PRIVATE_ALL_SHARED_LIBRARIES)"; \
		echo "LIBS += $(PRIVATE_LDLIBS)"; \
		echo "LIBS += $(TARGET_GLOBAL_LDLIBS_SHARED)"; \
	) >> $(PRIVATE_ALCHEMY_PRI_FILE)
endef

else # !eq("$(TARGET_OS)","darwin")

define qmake_gen_deps
	@rm -f $(PRIVATE_ALCHEMY_PRI_FILE)
	@mkdir -p $(dir $(PRIVATE_ALCHEMY_PRI_FILE))
	@( \
		echo "target.path = $(if $(__qmake_has_qt_sysroot),$(TARGET_OUT_STAGING))/$(PRIVATE_DESTDIR)"; \
		echo "INSTALLS += target"; \
		echo "INCLUDEPATH += $(PRIVATE_C_INCLUDES) $(TARGET_GLOBAL_C_INCLUDES)"; \
		echo "DEPENDPATH += $(PRIVATE_C_INCLUDES) $(TARGET_GLOBAL_C_INCLUDES)"; \
		echo "QMAKE_CFLAGS += $(PRIVATE_CFLAGS $(TARGET_GLOBAL_CFLAGS))"; \
		echo "QMAKE_CXXFLAGS += $(PRIVATE_CFLAGS) $(TARGET_GLOBAL_CFLAGS) $(PRIVATE_CXXFLAGS) $(TARGET_GLOBAL_CXXFLAGS)"; \
		echo "LIBS += $(PRIVATE_LDFLAGS) $(TARGET_GLOBAL_LDFLAGS)"; \
		echo "LIBS += -Wl,--whole-archive $(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES) -Wl,--no-whole-archive"; \
		echo "LIBS += $(PRIVATE_ALL_STATIC_LIBRARIES)"; \
		echo "LIBS += $(PRIVATE_ALL_SHARED_LIBRARIES)"; \
		echo "LIBS += $(PRIVATE_LDLIBS)"; \
		echo "LIBS += $(TARGET_GLOBAL_LDLIBS_SHARED)"; \
	) >> $(PRIVATE_ALCHEMY_PRI_FILE)
endef

endif

# Export android NDK path
ifeq ("$(TARGET_OS_FLAVOUR)","android")
QMAKE := ANDROID_NDK_ROOT=$(TARGET_ANDROID_NDK) $(QMAKE)
endif

###############################################################################
## Rules.
###############################################################################

# Make sure all prerequisites files are generated first
# But do NOT force recompilation (order only)
$(built_file): | $(all_prerequisites)

# Restart build if any of dependencies have changed
$(built_file): $(all_depends_build_filename) $(all_link_libs_filenames)

# If the user makefile is changed, restart the build
$(built_file): $(LOCAL_PATH)/$(USER_MAKEFILE_NAME)

# Build
# Generate files with dependencies then call qmake and make
$(built_file):
	$(qmake_gen_deps)
	$(call print-banner2,QMake,$(PRIVATE_MODULE),Building)
	@mkdir -p $(dir $@)
	$(Q) cd $(PRIVATE_BUILD_DIR) \
		&& $(QMAKE) $(PRIVATE_PATH)/$(PRIVATE_QMAKE_PRO_FILE) \
		&& $(MAKE) $(qmake_make_arg)
	@touch $@

# Install in staging directory by specifing INSTALL_ROOT (only for qt4, qt5 already
# knows QT_SYSROOT)
# Force STRIP at dummy to install unstripped binaries (alchemy will do it in
# final stage only)
# macro qt5_la_prl_files_fixup is actually defined in qt5/qtbase/atom.mk
$(installed_file): $(built_file)
	$(call print-banner2,QMake,$(PRIVATE_MODULE),Installing)
	@mkdir -p $(dir $@)
	$(Q) cd $(PRIVATE_BUILD_DIR) \
		&& $(MAKE) $(qmake_make_arg) \
			STRIP="true || ls" \
			$(if $(__qmake_has_qt_sysroot),$(empty),INSTALL_ROOT=$(TARGET_OUT_STAGING)) \
			install
	$(qt5_la_prl_files_fixup)
	@touch $@

# Done
$(build_dir)/$(LOCAL_MODULE_FILENAME): $(installed_file)
	@mkdir -p $(dir $@)
	@touch $@

# Clean targets additional commands
# If makefile is present, call uninstall and clean targets
$(LOCAL_MODULE)-clean:
	$(Q) if [ -f $(PRIVATE_BUILD_DIR)/Makefile ]; then \
		cd $(PRIVATE_BUILD_DIR); \
		$(MAKE) --keep-going --ignore-errors $(qmake_make_arg) \
			$(if $(__qmake_has_qt_sysroot),$(empty),INSTALL_ROOT=$(TARGET_OUT_STAGING)) \
			uninstall || echo "Ignoring uninstall errors"; \
		$(MAKE) --keep-going --ignore-errors $(qmake_make_arg) \
			clean || echo "Ignoring clean errors"; \
	fi

###############################################################################
## Rule-specific variable definitions.
###############################################################################

# clean targets additional variables
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(installed_file)
$(LOCAL_TARGETS): PRIVATE_CLEAN_FILES += $(built_file)

$(LOCAL_TARGETS): PRIVATE_QMAKE_PRO_FILE := $(LOCAL_QMAKE_PRO_FILE)
$(LOCAL_TARGETS): PRIVATE_DESTDIR := $(LOCAL_DESTDIR)
$(LOCAL_TARGETS): PRIVATE_CFLAGS := $(LOCAL_CFLAGS)
$(LOCAL_TARGETS): PRIVATE_C_INCLUDES := $(LOCAL_C_INCLUDES)
$(LOCAL_TARGETS): PRIVATE_CXXFLAGS := $(LOCAL_CXXFLAGS)
$(LOCAL_TARGETS): PRIVATE_LDFLAGS := $(LOCAL_LDFLAGS)
$(LOCAL_TARGETS): PRIVATE_LDLIBS := $(LOCAL_LDLIBS)
$(LOCAL_TARGETS): PRIVATE_ALL_SHARED_LIBRARIES := $(all_shared_libs_filename)
$(LOCAL_TARGETS): PRIVATE_ALL_STATIC_LIBRARIES := $(all_static_libs_filename)
$(LOCAL_TARGETS): PRIVATE_ALL_WHOLE_STATIC_LIBRARIES := $(all_whole_static_libs_filename)
$(LOCAL_TARGETS): PRIVATE_ALCHEMY_PRI_FILE := $(alchemy_pri_file)
