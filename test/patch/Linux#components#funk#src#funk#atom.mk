
LOCAL_PATH := $(call my-dir)

###############################################################################
# funk library.
###############################################################################

include $(CLEAR_VARS)

FUNK_LIB_VERSION :=1
FUNK_LIB_MINOR   :=2
FUNK_LIB_RELEASE :=0

LOCAL_MODULE := funk

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/../../include

LOCAL_C_INCLUDES :=

LOCAL_EXPORT_CFLAGS := \
	-DFUNK_MAJOR=$(FUNK_LIB_VERSION) \
	-DFUNK_MINOR=$(FUNK_LIB_MINOR) \
	-DFUNK_REV=$(FUNK_LIB_RELEASE)

LOCAL_SRC_FILES := \
	funk.c \
	funk_dhcp.c \
	funk_dhcpc.c \
	funk_dhcps.c \
	funk_ifconfig.c \
	funk_ifevent.c \
	funk_log.c \
	funk_monitor.c \
	funk_nat.c \
	funk_netbox.c \
	funk_netbox_requests.c \
	funk_platform.c \
	funk_resolver.c \
	funk_route.c \
	funk_sysctl.c

LOCAL_LIBRARIES := udev

include $(BUILD_SHARED_LIBRARY)

###############################################################################
# funk-test.
###############################################################################

ifdef CONFIG_FUNK_TEST

include $(CLEAR_VARS)

LOCAL_MODULE := funk-test

LOCAL_CFLAGS := \
	-DCUNIT_TESTS

LOCAL_SRC_FILES := \
	tests/dhcpc_test.c \
	tests/dhcps_test.c \
	tests/ifconfig_test.c \
	tests/ifevent_test.c \
	tests/nat_test.c \
	tests/resolver_test.c \
	tests/route_test.c \
	tests/sysctl_test.c \
	tests/tests.c \
	tests/tests_common.c

LOCAL_LIBRARIES := libcunit funk

include $(BUILD_EXECUTABLE)

endif

###############################################################################
# funk-examples.
###############################################################################

ifdef CONFIG_FUNK_TEST

FUNK_EXAMPLES := \
	fdhcpc \
	fdhcps \
	fdhcps_config \
	fifconfig \
	fifevent \
	fminimal_client \
	fnat \
	fnetbox \
	fresolver \
	froute \
	funky \

# Register
$(foreach __bin,$(FUNK_EXAMPLES), \
	$(eval include $(CLEAR_VARS)) \
	$(eval LOCAL_MODULE := funk-example-$(__bin)) \
	$(eval LOCAL_MODULE_FILENAME := $(__bin)) \
	$(eval LOCAL_SRC_FILES := examples/$(__bin).c) \
	$(eval LOCAL_LIBRARIES := funk) \
	$(eval include $(BUILD_EXECUTABLE)) \
)

# Shortcuts
.PHONY: funk-examples
funk-examples: $(foreach __bin,$(FUNK_EXAMPLES),funk-example-$(__bin))
.PHONY: funk-examples-clean
funk-examples-clean: $(foreach __bin,$(FUNK_EXAMPLES),funk-example-$(__bin)-clean)
.PHONY: funk-examples-dirclean
funk-examples-dirclean: $(foreach __bin,$(FUNK_EXAMPLES),funk-example-$(__bin)-dirclean)

endif
