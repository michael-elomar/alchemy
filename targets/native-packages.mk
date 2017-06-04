###############################################################################
## @file targets/native-packages.mk
## @author Y.M. Morgan
## @date 2016/03/05
##
## Additional generic packages for native target.
###############################################################################

LOCAL_PATH := $(call my-dir)

ifeq ("$(TARGET_ARCH)","$(HOST_ARCH)")

$(call register-prebuilt-pkg-config-module,json,json-c)
$(call register-prebuilt-pkg-config-module,libusb,libusb)
$(call register-prebuilt-pkg-config-module,libusb_1_0,libusb-1.0)
$(call register-prebuilt-pkg-config-module,ncurses,ncurses)
$(call register-prebuilt-pkg-config-module,zlib,zlib)

$(call register-prebuilt-pkg-config-module,glib-2.0,glib-2.0)
$(call register-prebuilt-pkg-config-module,gobject-2.0,gobject-2.0)
$(call register-prebuilt-pkg-config-module,gio-2.0,gio-2.0)

include $(CLEAR_VARS)
LOCAL_MODULE := glib
LOCAL_LIBRARIES := glib-2.0 gobject-2.0 gio-2.0
$(call local-register-prebuilt-overridable)

$(call register-prebuilt-pkg-config-module,gstreamer-1.0,gstreamer-1.0)
$(call register-prebuilt-pkg-config-module,gstreamer-app-1.0,gstreamer-app-1.0)
$(call register-prebuilt-pkg-config-module,gstreamer-audio-1.0,gstreamer-audio-1.0)
$(call register-prebuilt-pkg-config-module,gstreamer-base-1.0,gstreamer-base-1.0)
$(call register-prebuilt-pkg-config-module,gstreamer-video-1.0,gstreamer-video-1.0)

include $(CLEAR_VARS)
LOCAL_MODULE := gstreamer
LOCAL_LIBRARIES := gstreamer-1.0 gstreamer-base-1.0
$(call local-register-prebuilt-overridable)

include $(CLEAR_VARS)
LOCAL_MODULE := gst-plugins-base
LOCAL_LIBRARIES := gstreamer-app-1.0 gstreamer-audio-1.0 gstreamer-video-1.0
$(call local-register-prebuilt-overridable)

endif

# If ncurses not available via pkg-config, try harder...
ifeq ("$(call is-module-registered,ncurses)","")
  ifneq ("$(wildcard /usr/include/ncurses.h)","")
    include $(CLEAR_VARS)
    LOCAL_MODULE := ncurses
    LOCAL_EXPORT_LDLIBS := -lncurses
    $(call local-register-prebuilt-overridable)
  endif
endif
