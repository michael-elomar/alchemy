###############################################################################
###############################################################################

# Turns off suffix rules built into make
.SUFFIXES:

# This is the default target.  It must be the first declared target.
all:

###############################################################################
###############################################################################

# Tools
TARGET_CC ?= gcc
TARGET_CXX ?= g++
TARGET_AR ?= ar

TARGET_OS ?= linux

# Determine default target architecture
ifndef TARGET_ARCH
  ifneq ("$(shell $(TARGET_CC) -dumpmachine | grep 64)","")
    TARGET_ARCH := x64
  else
    TARGET_ARCH := x86
  endif
endif

# Setup flags
CFLAGS := -O2 -g0
LDFLAGS := -s
ifeq ("$(TARGET_ARCH)","x86")
  CFLAGS += -m32
  LDFLAGS += -m32
else ifeq ("$(TARGET_ARCH)","x64")
  CFLAGS += -m64 -fPIC
  LDFLAGS += -m64
endif

BUILD_DIR := build-$(TARGET_OS)-$(TARGET_ARCH)
BIN_DIR := bin-$(TARGET_OS)-$(TARGET_ARCH)

###############################################################################
# Libs/Progs to build
###############################################################################

LIBS := parser lxdialog
PROGS := conf qconf mconf nconf

parser_SRC := parser/zconf.c
parser_CFLAGS := -Iparser

conf_SRC := conf.c
conf_LIB := parser

lxdialog_SRC := $(addprefix lxdialog/,checklist.c inputbox.c menubox.c textbox.c util.c yesno.c)
lxdialog_CFLAGS := -DCURSES_LOC="<ncurses.h>"

mconf_SRC := mconf.c
mconf_LIB := parser lxdialog
mconf_LDFLAGS := -lncurses

nconf_SRC := nconf.c nconf.gui.c
nconf_LIB := parser
nconf_LDFLAGS := -lmenu -lpanel -lncurses

qconf_SRC := qconf.cc
qconf_LIB := parser
qconf_CFLAGS := $(shell pkg-config QtCore QtGui Qt3Support --cflags)
qconf_LDFLAGS := $(shell pkg-config QtCore QtGui Qt3Support --libs)
qconf_MOC := $(shell pkg-config QtCore --variable=moc_location)

###############################################################################
## Rules.
###############################################################################

.PHONY: all
all: $(LIBS) $(PROGS)

.PHONY: clean
clean: $(foreach lib,$(LIBS),$(lib)-clean)
clean: $(foreach prog,$(PROGS),$(prog)-clean)

# $1 : prog/lib to compile
define do-compile
$(eval $(1)_src_c := $(filter %.c,$($(1)_SRC)))
$(eval $(1)_src_cc := $(filter %.cc,$($(1)_SRC)))
$(eval $(1)_obj_c := $(addprefix $(BUILD_DIR)/,$($(1)_src_c:%.c=%.o)))
$(eval $(1)_obj_cc := $(addprefix $(BUILD_DIR)/,$($(1)_src_cc:%.cc=%.o)))
$(eval $(1)_obj := $($(1)_obj_c) $($(1)_obj_cc))
$(eval $(1)_cflags := $(foreach lib,$($(1)_LIB),$($(lib)_CFLAGS)))
$($(1)_obj_c): $(BUILD_DIR)/%.o: %.c
	@mkdir -p $$(dir $$@)
	$(TARGET_CC) -MMD -o $$@ -c $$< $(CFLAGS) $($(1)_cflags) $($(1)_CFLAGS)
$($(1)_obj_cc): $(BUILD_DIR)/%.o: %.cc
	@mkdir -p $$(dir $$@)
	$(TARGET_CXX) -MMD -o $$@ -c $$< $(CFLAGS) $($(1)_cflags) $($(1)_CFLAGS)
-include $($(1)_obj:%.o=%.d)
endef

# $1 : prog/lib to clean
# $2 : prog/lib extension
define do-clean
.PHONY: $(1)-clean
$(1)-clean:
	rm -f $(BUILD_DIR)/$(1)$(2)
	rm -f $(BIN_DIR)/$(1)$(2)
	rm -f $($(1)_obj)
endef

# $1 : lib
define do-lib
$(eval $(call do-compile,$(1)))
$(eval $(call do-clean,$(1),.a))
.PHONY: $(1)
$(1): $(BUILD_DIR)/$(1).a
$(BUILD_DIR)/$(1).a: $($(1)_obj)
	@mkdir -p $$(dir $$@)
	@rm -f $$@
	$(TARGET_AR) rcs $$@ $($(1)_obj)
endef

# $1 : prog
define do-prog
$(eval $(call do-compile,$(1)))
$(eval $(call do-clean,$(1),))
$(eval $(1)_lib_a := $(addprefix $(BUILD_DIR)/,$(addsuffix .a,$($(1)_LIB))))
.PHONY: $(1)
$(1): $(BUILD_DIR)/$(1)
$(BUILD_DIR)/$(1): $($(1)_obj) $($(1)_lib_a)
	@mkdir -p $$(dir $$@)
	@mkdir -p $(BIN_DIR)
	$(TARGET_CC) -o $$@ $($(1)_obj) $($(1)_lib_a) $(LDFLAGS) $($(1)_LDFLAGS)
	cp -f $$@ $(BIN_DIR)/$(1)
endef

# Generate rules for libs
$(foreach lib,$(LIBS), \
	$(eval $(call do-lib,$(lib))) \
)

# Generate rules for progs
$(foreach prog,$(PROGS), \
	$(eval $(call do-prog,$(prog))) \
)

###############################################################################
## Additionnal dependencies and rules.
###############################################################################

parser/zconf.c: parser/zconf.tab.c parser/zconf.lex.c
parser/zconf.tab.c: parser/zconf.hash.c

parser/zconf.lex.c: parser/zconf.l
	flex --noline --prefix=zconf --outfile=$@ $<

parser/zconf.hash.c: parser/zconf.gperf
	gperf --readonly-tables --output-file=$@ $<

parser/zconf.tab.c: parser/zconf.y
	bison --debug --no-lines --name-prefix=zconf --output=$@ $<

qconf.cc: qconf.moc

qconf.moc: qconf.h
	$(qconf_MOC) -i $< -o $@

