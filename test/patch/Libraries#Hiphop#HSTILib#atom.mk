
LOCAL_PATH := $(call my-dir)

###############################################################################
# Settings
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := hstilib
LOCAL_PBUILD_HOOK := 1

LOCAL_CONFIG_FILES := Build/ConfigHstiSet.in
$(call load-config)

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/inc \
	$(LOCAL_PATH)/src

LOCAL_EXPORT_CFLAGS := \
	-DHSTI_OSAL_PAL \
	-DHSTI_CHAR_UNSAFE

ifeq ("$(TARGET_OS)","linux")
  LOCAL_EXPORT_CFLAGS += -DHSTI_USE_UART_POSIX
  ifeq ("$(TARGET_LIBC)","bionic")
    LOCAL_EXPORT_CFLAGS += -DHSTI_NO_POSIX_OPENPT
  endif
endif

LOCAL_C_INCLUDES :=

LOCAL_CFLAGS :=

LOCAL_SRC_FILES := \
	src/Common/Data/HSTI_ATData.c \
	src/Common/Data/HSTI_Format.c \
	src/Common/Data/HSTI_Parse.c  \
	src/Common/Data/HSTI_Generated.c \
	src/Common/OSAL/OSAL_Sync.c \
	src/Common/OSAL/OSAL_Time.c \
	src/Common/OSAL/OSAL_Thread.c \
	src/Common/HSTI_Transport.c \
	src/Common/HSTI_Log.c \
	src/Common/HSTI_Str.c \
	src/Common/HSTI_ExchBuffer.c \
	src/Common/HSTI_Mux.c \
	src/Common/HSTI_PosixCrc.c \
	src/Target/HSTI_API_Target.c \
	src/Target/HSTI_TargetDriver.c \
	src/Target/HSTI_TargetDriver_v2.c \
	src/Host/HSTI_API.c \
	src/Host/HSTI_HostDriver.c \
	src/Cpp/ConnectInterface.cpp \
	src/Cpp/HostInterface.cpp \
	src/Cpp/TargetInterface.cpp \
	src/Cpp/TransportInterface.cpp \
	src/Cpp/TransportServer.cpp \
	src/Cpp/DataHandler.cpp \
	src/Cpp/MuxSlave.cpp \
	src/Cpp/MuxMaster.cpp \
	src/Cpp/ExchBuffer.cpp \
	src/Cpp/Port/PipeInterface.cpp \
	src/Cpp/Port/PortInterface.cpp \
	src/Cpp/Port/SocketInterface.cpp \
    src/Cpp/Port/UnixSocketInterface.cpp \
	src/Cpp/Port/UARTInterface.cpp \
	src/Cpp/Port/PtyInterface.cpp \
	src/Cpp/Port/QnxPtyInterface.cpp \
	src/Cpp/Port/ResourceManagerInterface.cpp \
	src/aio/aio_core.cpp \
	src/aio/aio_monitor.cpp \
	src/aio/aio_alarm.cpp \
	src/aio/aio_notifier.cpp \
	src/aio/aio_portfactory.cpp \
	src/aio/aio_packet.cpp \
	src/aio/aio_port.cpp \
	src/aio/aio_portio.cpp \
	src/aio/aio_socket.cpp \
	src/aio/aio_pipe.cpp \
	src/aio/aio_serial.cpp \
	src/aio/aio_pty.cpp

LOCAL_LIBRARIES := hsti-generator pal-utils pal-core

include $(BUILD_STATIC_LIBRARY)

