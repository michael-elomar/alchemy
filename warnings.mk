###############################################################################
## @file warnings.mk
## @author Y.M. Morgan
## @date 2012/06/09
##
## Setup warning flags.
###############################################################################

WARNINGS_COMMON_FLAGS :=
WARNINGS_CFLAGS :=
WARNINGS_CPPFLAGS :=

# show option associated with warning (clang or gcc >= 4.0.0)
ifeq ("$(USE_CLANG)","1")
  WARNINGS_COMMON_FLAGS += -fdiagnostics-show-option
else ifneq ("$(call check-version,$(TARGET_CC_VERSION),4.0.0)","")
  WARNINGS_COMMON_FLAGS += -fdiagnostics-show-option
endif

###############################################################################
## Common flags.
###############################################################################

WARNINGS_COMMON_FLAGS += -Wall
WARNINGS_COMMON_FLAGS += -Wextra
WARNINGS_COMMON_FLAGS += -Wno-unused -Wno-unused-parameter -Wunused-value -Wunused-variable -Wunused-label
#WARNINGS_COMMON_FLAGS += -Wshadow
#WARNINGS_COMMON_FLAGS += -Wswitch-default
#WARNINGS_COMMON_FLAGS += -Wwrite-strings
#WARNINGS_COMMON_FLAGS += -Wundef
#WARNINGS_COMMON_FLAGS += -Wpointer-arith
#WARNINGS_COMMON_FLAGS += -Wformat-nonliteral
#WARNINGS_COMMON_FLAGS += -Wformat-security
#WARNINGS_COMMON_FLAGS += -Winit-self

# Too many false positives with clang compiler
ifneq ("$(USE_CLANG)","1")
#  WARNINGS_COMMON_FLAGS += -Wcast-align
endif

# clang or gcc >= 4.5.0 (too many false positives with previous versions)
ifeq ("$(USE_CLANG)","1")
  WARNINGS_COMMON_FLAGS += -Wunreachable-code
else ifneq ("$(call check-version,$(TARGET_CC_VERSION),4.5.0)","")
  WARNINGS_COMMON_FLAGS += -Wunreachable-code
endif

# gcc >= 4.5.2
ifneq ("$(USE_CLANG)","1")
ifneq ("$(call check-version,$(TARGET_CC_VERSION),4.5.2)","")
  WARNINGS_COMMON_FLAGS += -Wlogical-op
endif
endif

###############################################################################
## Specific flags.
###############################################################################

# C specific
#WARNINGS_CFLAGS += -Wmissing-declarations
#WARNINGS_CFLAGS += -Wmissing-prototypes

# gcc >= 4.5.0
ifneq ("$(USE_CLANG)","1")
ifneq ("$(call check-version,$(TARGET_CC_VERSION),4.5.0)","")
  WARNINGS_CFLAGS += -Wjump-misses-init
endif
endif

# c++ specific
#WARNINGS_CPPFLAGS += -Wctor-dtor-privacy
#WARNINGS_CPPFLAGS += -Wnon-virtual-dtor
WARNINGS_CPPFLAGS += -Wreorder
WARNINGS_CPPFLAGS += -Woverloaded-virtual

###############################################################################
## Extra warnings.
###############################################################################

ifeq ("$(W)","1")

WARNINGS_COMMON_FLAGS += -Wconversion
WARNINGS_COMMON_FLAGS += -Wswitch-enum
WARNINGS_COMMON_FLAGS += -Wcast-qual

# gcc >= 4.4.0
ifneq ("$(USE_CLANG)","1")
ifneq ("$(call check-version,$(TARGET_CC_VERSION),4.4.0)","")
  WARNINGS_COMMON_FLAGS += -Wframe-larger-than=1024
endif
endif

endif

###############################################################################
## Add common flags to specific flags.
###############################################################################

WARNINGS_CFLAGS += $(WARNINGS_COMMON_FLAGS)
WARNINGS_CPPFLAGS += $(WARNINGS_COMMON_FLAGS)
