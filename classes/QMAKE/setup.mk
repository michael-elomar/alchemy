###############################################################################
## @file classes/QMAKE/setup.mk
## @author F.F. Ferrand
## @date 2015/05/07
###############################################################################

###############################################################################
## Variables used for qmake.
###############################################################################

# Default Qt version
TARGET_QT_VERSION ?= 5.4

# Map TARGET_OS/FLAVOUR to Qt platforms
ifeq ("$(TARGET_OS)-$(TARGET_OS_FLAVOUR)","$(HOST_OS)-native")
  ifeq ("$(TARGET_OS)","darwin")
    TARGET_QT_PLATFORM ?= clang_64
  else ifeq ("$(TARGET_OS)-$(TARGET_ARCH)","linux-x64")
    TARGET_QT_PLATFORM ?= gcc_64
  else ifeq ("$(TARGET_OS)-$(TARGET_ARCH)-$(HOST_ARCH)","linux-x86-x64")
    TARGET_QT_PLATFORM ?= gcc_32
  else ifeq ("$(TARGET_OS)-$(TARGET_ARCH)-$(HOST_ARCH)","linux-x86-x86")
    TARGET_QT_PLATFORM ?= gcc
  else
    TARGET_QT_PLATFORM ?= unknown
  endif
else ifeq ("$(TARGET_OS)","linux")
  ifeq ("$(TARGET_OS_FLAVOUR)","android")
    TARGET_QT_PLATFORM ?= android_armv7
  else ifeq ("$(TARGET_OS_FLAVOUR)-$(TARGET_ARCH)","native-x64")
    TARGET_QT_PLATFORM ?= linux_64
  else ifeq ("$(TARGET_OS_FLAVOUR)-$(TARGET_ARCH)","native-x86")
    TARGET_QT_PLATFORM ?= linux_32
  else
    TARGET_QT_PLATFORM ?= unknown
  endif
else ifeq ("$(TARGET_OS)","darwin")
  ifeq ("$(TARGET_OS_FLAVOUR)","native")
    TARGET_QT_PLATFORM ?= macos
  else
    TARGET_QT_PLATFORM ?= ios
  endif
else
  TARGET_QT_PLATFORM ?= unknown
endif

# Try to auto-detect Qt SDK path
QT_SDK_DEFAULT_PATHS := \
	/opt/Qt* \
	/opt/QT* \
	/Applications/Qt* \
	~/Qt*

ifndef TARGET_QT_SDKROOT
TARGET_QT_SDKROOT := $(shell shopt -s nullglob ; \
	for path in $(QT_SDK_DEFAULT_PATHS) ; do \
		if [ -e $$path/$(TARGET_QT_VERSION)/$(TARGET_QT_PLATFORM)/bin/qmake ]; then \
			cd $$path && pwd && break; \
		fi; \
	done)
endif

# Define QMake path accordingly
ifndef TARGET_QT_SDK
  ifneq ("$(TARGET_QT_SDKROOT)","")
    TARGET_QT_SDK := $(TARGET_QT_SDKROOT)/$(TARGET_QT_VERSION)/$(TARGET_QT_PLATFORM)
  else
    TARGET_QT_SDK :=
  endif
endif

# Use qmake from PATH in last resort, on host build
ifndef QTSDK_QMAKE
  ifneq ("$(TARGET_QT_SDK)","")
    QTSDK_QMAKE := $(TARGET_QT_SDK)/bin/qmake
  else ifeq ("$(TARGET_OS)-$(TARGET_OS_FLAVOUR)","$(HOST_OS)-native")
    QTSDK_QMAKE := $(shell which qmake 2>/dev/null)
  else
    QTSDK_QMAKE :=
  endif
endif
