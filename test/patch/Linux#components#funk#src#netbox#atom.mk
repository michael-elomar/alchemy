
LOCAL_PATH := $(call my-dir)

###############################################################################
# Variables used for netboxd and test code.
###############################################################################

NETBOX_BB_SRC_FILES := \
	busybox/stubs.c	\
	busybox/libbb/bb_bswap_64.c \
	busybox/libbb/bb_strtonum.c \
	busybox/libbb/compare_string_array.c \
	busybox/libbb/copyfd.c \
	busybox/libbb/default_error_retval.c \
	busybox/libbb/full_write.c \
	busybox/libbb/get_line_from_file.c \
	busybox/libbb/getopt32.c \
	busybox/libbb/info_msg.c \
	busybox/libbb/llist.c \
	busybox/libbb/messages.c \
	busybox/libbb/parse_config.c \
	busybox/libbb/perror_msg.c \
	busybox/libbb/pidfile.c \
	busybox/libbb/read.c \
	busybox/libbb/safe_poll.c \
	busybox/libbb/safe_strncpy.c \
	busybox/libbb/safe_write.c \
	busybox/libbb/signals.c \
	busybox/libbb/time.c \
	busybox/libbb/verror_msg.c \
	busybox/libbb/wfopen.c \
	busybox/libbb/wfopen_input.c \
	busybox/libbb/xatonum.c \
	busybox/libbb/xconnect.c \
	busybox/libbb/xfunc_die.c \
	busybox/libbb/xfuncs.c \
	busybox/libbb/xfuncs_printf.c \
	busybox/networking/udhcp/arpping.c \
	busybox/networking/udhcp/common.c \
	busybox/networking/udhcp/dhcpc.c \
	busybox/networking/udhcp/dhcpd.c \
	busybox/networking/udhcp/files.c \
	busybox/networking/udhcp/leases.c \
	busybox/networking/udhcp/packet.c \
	busybox/networking/udhcp/signalpipe.c \
	busybox/networking/udhcp/socket.c \
	busybox/networking/udhcp/static_leases.c

NETBOX_IPTABLES_SRC_FILES := \
	iptables/iptables/iptables-restore.c \
	iptables/iptables/iptables-standalone.c \
	iptables/iptables/iptables.c \
	iptables/iptables/xshared.c

###############################################################################
# netboxd.
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := netboxd

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/busybox/include \
	$(LOCAL_PATH)/iptables/include

# "-std=gnu99 needed for [U]LLONG_MAX on some systems"
LOCAL_CFLAGS := \
	-std=gnu99 \
	-D_GNU_SOURCE

LOCAL_LDLIBS := \
	-lxtables -liptc -lip4tc -lip6tc

LOCAL_SRC_FILES := \
	$(NETBOX_BB_SRC_FILES) \
	$(NETBOX_IPTABLES_SRC_FILES) \
	netbox_answers.c \
	netbox_applet.c \
	netbox_fast_command.c \
	netbox_log.c \
	netbox_platform.c \
	netbox_strings.c \
	netbox_utils.c \
	netbox_worker.c \
	netbox_workers.c \
	netboxd.c

LOCAL_LIBRARIES := iptables

include $(BUILD_EXECUTABLE)

###############################################################################
# netbox-test.
###############################################################################

ifdef CONFIG_NETBOX_TEST

include $(CLEAR_VARS)

LOCAL_MODULE := netbox-test

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/busybox/include \
	$(LOCAL_PATH)/iptables/include

# "-std=gnu99 needed for [U]LLONG_MAX on some systems"
LOCAL_CFLAGS := \
	-std=gnu99 \
	-D_GNU_SOURCE \
	-DCUNIT_TESTS

LOCAL_LDLIBS := \
	-lxtables -liptc -lip4tc -lip6tc

LOCAL_SRC_FILES := \
	$(NETBOX_BB_SRC_FILES) \
	$(NETBOX_IPTABLES_SRC_FILES) \
	netbox_answers.c \
	netbox_applet.c \
	netbox_fast_command.c \
	netbox_log.c \
	netbox_platform.c \
	netbox_strings.c \
	netbox_utils.c \
	netbox_worker.c \
	netbox_workers.c \
	netboxd.c \
	tests/answers_test.c \
	tests/applet_test.c \
	tests/fast_command_test.c \
	tests/strings_test.c \
	tests/tests.c \
	tests/tests_common.c \
	tests/utils_test.c \
	tests/workers_test.c \
	tests/worker_test.c

LOCAL_LIBRARIES := iptables libcunit

include $(BUILD_EXECUTABLE)

endif

###############################################################################
# netbox-client.
###############################################################################

ifdef CONFIG_NETBOX_TEST

include $(CLEAR_VARS)

LOCAL_MODULE := netbox-client

LOCAL_SRC_FILES := \
	netbox.c \
	netbox_platform.c

include $(BUILD_EXECUTABLE)

endif
