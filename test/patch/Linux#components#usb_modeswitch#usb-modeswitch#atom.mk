
LOCAL_PATH := $(call my-dir)

###############################################################################
# usb_modeswitch
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := usb-modeswitch
LOCAL_MODULE_FILENAME := usb_modeswitch

LOCAL_SRC_FILES := \
	usb_modeswitch.c

LOCAL_COPY_FILES := \
	usb_modeswitch.sh:lib/udev/usb_modeswitch \
	usb_modeswitch.conf:usr/share/usb_modeswitch.conf

LOCAL_LIBRARIES := libusb

include $(BUILD_EXECUTABLE)

###############################################################################
# usb-modeswitch-dispatcher bionic/android, use an eglibc prebuilt executable
###############################################################################

ifeq ("$(TARGET_LIBC)","bionic")

include $(CLEAR_VARS)

LOCAL_MODULE := usb-modeswitch-dispatcher

LOCAL_COPY_FILES := \
	lucie/usb_modeswitch_dispatcher:sbin/usb_modeswitch_dispatcher

$(call local-add-module)

endif

###############################################################################
# usb-modeswitch-dispatcher not bionic/android
###############################################################################

ifneq ("$(TARGET_LIBC)","bionic")

include $(CLEAR_VARS)

LOCAL_MODULE := usb-modeswitch-dispatcher
LOCAL_MODULE_FILENAME := usb_modeswitch_dispatcher

USMD_BUILD_DIR := $(call local-get-build-dir)
USMD_MAKE_STRING := $(LOCAL_PATH)/make_string.tcl
USMD_TCL := $(LOCAL_PATH)/usb_modeswitch.tcl
USMD_STRING := $(USMD_BUILD_DIR)/usb_modeswitch.string

# Jim variable
JIM_DIR := $(LOCAL_PATH)/jim
JIM_LIB := $(USMD_BUILD_DIR)/libjim.a
JIM_SETUP_MAKE := $(JIM_DIR)/make-bootstrap-jim
JIM_SETUP_C := $(USMD_BUILD_DIR)/autosetup/jimsh0.c
JIM_SETUP_EXE := $(USMD_BUILD_DIR)/autosetup/jimsh

# Build system variables. Build dir is internally added in include path
# To NOT put it (to find usb_modeswitch.string) to avoid a warning saying that
# the build dir does not exist yet...
LOCAL_SRC_FILES := dispatcher.c
LOCAL_C_INCLUDES := $(JIM_DIR)
LOCAL_LDLIBS := $(JIM_LIB)
LOCAL_PREREQUISITES := $(JIM_LIB) $(USMD_STRING)

# Generate jimsh0 bootstrap
$(JIM_SETUP_C): $(JIM_SETUP_MAKE)
	@echo "Creating the Jim bootstrap source ..."
	@mkdir -p $(dir $@)
	$(Q)cd $(JIM_DIR); $(JIM_SETUP_MAKE) > $@

# Compile jimsh0 bootstrap
$(JIM_SETUP_EXE): $(JIM_SETUP_C)
	@echo "Compiling Jim bootstrap for pc ..."
	@mkdir -p $(dir $@)
	$(Q)$(HOST_CC) -o $@ $<

# Build the libjim.a library
$(JIM_LIB): $(JIM_SETUP_EXE)
	@echo "Configuring the Jim library ..."
	@mkdir -p $(dir $@)
	$(Q)cd $(dir $@); \
		PATH=$(dir $(JIM_SETUP_EXE)):$(PATH) $(AUTOTOOLS_CONFIGURE_ENV) \
			$(JIM_DIR)/configure \
			--host="$(GNU_TARGET_NAME)" \
			--prefix="$(AUTOTOOLS_CONFIGURE_PREFIX)" \
			--disable-lineedit \
			--with-out-jim-ext="stdlib posix load signal syslog"
	@echo "Compiling the Jim library ..."
	$(Q)$(AUTOTOOLS_CONFIGURE_ENV) $(MAKE) -C $(dir $@) lib

# Convert tcl script to c string, using a tcl script executed by jimsh0 bootstrap...
$(USMD_STRING): $(JIM_SETUP_EXE) $(USMD_MAKE_STRING) $(USMD_TCL)
	@echo "Convert usbmodeswitch.tcl in c string format ..."
	$(Q)$(JIM_SETUP_EXE) $(USMD_MAKE_STRING) $(USMD_TCL) > $@

include $(BUILD_EXECUTABLE)

endif

