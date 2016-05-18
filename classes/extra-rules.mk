###############################################################################
## @file classes/extra-rules.mk
## @author Y.M. Morgan
## @date 2016/05/1
##
## Extra rules for module classes not build related (doc, codecheck...).
###############################################################################

###############################################################################
## Documentation generation rules.
###############################################################################

$(LOCAL_MODULE)-doc: PRIVATE_DOC_DIR := $(TARGET_OUT_DOC)/$(LOCAL_MODULE)

ifneq ("$(LOCAL_DOXYFILE)","")

LOCAL_DOXYFILE := \
	$(if $(call is-path-absolute,$(LOCAL_DOXYFILE)), \
		$(LOCAL_DOXYFILE), \
		$(addprefix $(LOCAL_PATH)/,$(LOCAL_DOXYFILE)) \
	)

# If a doxyfile has been defined by the user, we use it
# Check if the input paths are absolute and if not, correct them
_module_doc_input := $(shell egrep '^INPUT *=' $(LOCAL_DOXYFILE) | sed 's/^INPUT *=//g')
_module_doc_input += $(LOCAL_DOXYGEN_INPUT)
_module_doc_input := $(foreach __path,$(_module_doc_input), \
	$(if $(call is-path-absolute,$(__path)), \
		$(__path),$(addprefix $(LOCAL_PATH)/,$(__path)) \
	))

$(LOCAL_MODULE)-doc: PRIVATE_INPUT := $(_module_doc_input)
$(LOCAL_MODULE)-doc: PRIVATE_DOXYFILE := $(LOCAL_DOXYFILE)

# Use the doxyfile, but override output to out/doc and input with absolute paths
.PHONY: $(LOCAL_MODULE)-doc
$(LOCAL_MODULE)-doc:
	@echo "$(PRIVATE_MODULE): Generating doxygen documentation from $(PRIVATE_DOXYFILE)"
	@rm -rf $(PRIVATE_DOC_DIR)
	@mkdir -p $(PRIVATE_DOC_DIR)
	@cd $(PRIVATE_PATH) && ( \
		cat $(PRIVATE_DOXYFILE); \
		echo "PROJECT_NAME=$(PRIVATE_MODULE)"; \
		echo "PROJECT_BRIEF=\"$(PRIVATE_DESCRIPTION)\""; \
		echo "INPUT=$(PRIVATE_INPUT)"; \
		echo "EXCLUDE_PATTERNS+=.git out sdk"; \
		echo "OUTPUT_DIRECTORY=$(PRIVATE_DOC_DIR)"; \
	) | doxygen - &> $(PRIVATE_DOC_DIR)/doxygen.log
else

# Use LOCAL_PATH and other input
_module_doc_input := $(LOCAL_PATH) $(LOCAL_DOXYGEN_INPUT)
_module_doc_input := $(foreach __path,$(_module_doc_input), \
	$(if $(call is-path-absolute,$(__path)), \
		$(__path),$(addprefix $(LOCAL_PATH)/,$(__path)) \
	))

$(LOCAL_MODULE)-doc: PRIVATE_INPUT := $(_module_doc_input)

# If no doxyfile has been defined by the user, we generate one on the fly from
# a template created by doxygen which tries to document all and for all
# languages
# We disable warnings because they are plenty in this case
.PHONY: $(LOCAL_MODULE)-doc
$(LOCAL_MODULE)-doc:
	@echo "$(PRIVATE_MODULE): Generating doxygen documentation from generated doxyfile"
	@rm -rf $(PRIVATE_DOC_DIR)
	@mkdir -p $(PRIVATE_DOC_DIR)
	@cd $(PRIVATE_PATH) && ( \
		doxygen -g -; \
		echo "PROJECT_NAME=$(PRIVATE_MODULE)"; \
		echo "PROJECT_BRIEF=\"$(PRIVATE_DESCRIPTION)\""; \
		echo "EXTRACT_ALL=YES"; \
		echo "GENERATE_LATEX=NO"; \
		echo "WARNINGS=NO"; \
		echo "WARN_IF_DOC_ERROR=NO"; \
		echo "RECURSIVE=YES"; \
		echo "INPUT=$(PRIVATE_INPUT)"; \
		echo "EXCLUDE_PATTERNS+=.git out sdk"; \
		echo "OUTPUT_DIRECTORY=$(PRIVATE_DOC_DIR)"; \
	) | doxygen - &> $(PRIVATE_DOC_DIR)/doxygen.log

endif

###############################################################################
## Code check / cloc (count line of code) rules.
###############################################################################

# Original data before import
_module_src_files := $(addprefix $(LOCAL_PATH)/,$(__modules.$(LOCAL_MODULE).SRC_FILES))
_module_c_includes := $(__modules.$(LOCAL_MODULE).C_INCLUDES)
_module_c_includes += $(__modules.$(LOCAL_MODULE).EXPORT_C_INCLUDES)
_module_c_includes += $(LOCAL_PATH)

# Search for include files in directories with source files
_module_c_includes += $(sort $(foreach __src,$(_module_src_files),$(dir $(__src))))
_module_c_includes := $(sort $(abspath $(_module_c_includes)))

# Checkpatch is only for c files
_codecheck_files := $(filter %.c,$(_module_src_files))
_codecheck_files += $(foreach __inc,$(_module_c_includes),$(wildcard $(__inc)/*.h))

# Cpplint is only for cpp files
_cppcheck_files := $(filter %.cpp,$(_module_src_files))
_cppcheck_files += $(filter %.cc,$(_module_src_files))
_cppcheck_files += $(filter %.cxx,$(_module_src_files))
_cppcheck_files += $(foreach __inc,$(_module_c_includes),$(wildcard $(__inc)/*.hpp))
_cppcheck_files += $(foreach __inc,$(_module_c_includes),$(wildcard $(__inc)/*.hh))
_cppcheck_files += $(foreach __inc,$(_module_c_includes),$(wildcard $(__inc)/*.hxx))

# Checkvalastyle is only for vala files
_valacheck_files := $(filter %.vala,$(_module_src_files))

# Cloc
_cloc_files := $(_module_src_files)
_cloc_files += $(foreach __inc,$(_module_c_includes),$(wildcard $(__inc)/*.h))
_cloc_files += $(foreach __inc,$(_module_c_includes),$(wildcard $(__inc)/*.hpp))
_cloc_files += $(foreach __inc,$(_module_c_includes),$(wildcard $(__inc)/*.hh))
_cloc_files += $(foreach __inc,$(_module_c_includes),$(wildcard $(__inc)/*.hxx))

# Sort to have unique names
_codecheck_files := $(sort $(_codecheck_files))
_cppcheck_files := $(sort $(_cppcheck_files))
_valacheck_files := $(sort $(_valacheck_files))
_cloc_files := $(sort $(_cloc_files))

# Define target variables because we don't inherit from 'standard' targets
$(LOCAL_MODULE)-codecheck: PRIVATE_CODECHECK_FILES := $(_codecheck_files)
$(LOCAL_MODULE)-codecheck: PRIVATE_CODECHECK_ARGS := $(LOCAL_CODECHECK_ARGS)
ifneq ("$(LOCAL_MODULE_CLASS)","LINUX")
ifneq ("$(LOCAL_MODULE_CLASS)","LINUX_MODULE")
$(LOCAL_MODULE)-codecheck: PRIVATE_CODECHECK_ARGS += --ignore SPLIT_STRING,PREFER_ALIGNED,PREFER_PACKED
endif
endif

$(LOCAL_MODULE)-cppcheck: PRIVATE_CPPCHECK_FILES := $(_cppcheck_files)
$(LOCAL_MODULE)-cppcheck: PRIVATE_CPPCHECK_ARGS := $(LOCAL_CPPCHECK_ARGS)

$(LOCAL_MODULE)-valacheck: PRIVATE_VALACHECK_FILES := $(_valacheck_files)
$(LOCAL_MODULE)-valacheck: PRIVATE_VALACHECK_ARGS := $(LOCAL_VALACHECK_ARGS)

$(LOCAL_MODULE)-cloc: PRIVATE_CLOC_FILES := $(_cloc_files)

.PHONY: $(LOCAL_MODULE)-codecheck
$(LOCAL_MODULE)-codecheck:
	@echo "$(PRIVATE_MODULE): Checking files...";
	@$(BUILD_SYSTEM)/scripts/checkpatch.pl \
		--no-tree --no-summary --terse --show-types -f \
		$(PRIVATE_CODECHECK_ARGS) $(PRIVATE_CODECHECK_FILES) \
	|| true;

.PHONY: $(LOCAL_MODULE)-cppcheck
$(LOCAL_MODULE)-cppcheck:
	@echo "$(PRIVATE_MODULE): Checking files...";
	@for f in $(PRIVATE_CPPCHECK_FILES); do \
		echo "$(PRIVATE_MODULE): Checking file $${f#$(TOP_DIR)/}"; \
		$(BUILD_SYSTEM)/scripts/cpplint.py \
			--extension hpp,cpp,cxx,hxx,cc,hh \
			--counting detailed --verbose 0 \
			$(PRIVATE_CPPCHECK_ARGS) $$f \
		|| true; \
	done

.PHONY: $(LOCAL_MODULE)-valacheck
$(LOCAL_MODULE)-valacheck:
	@echo "$(PRIVATE_MODULE): Checking files ...";
	@$(BUILD_SYSTEM)/scripts/checkvalastyle.pl \
		$(PRIVATE_VALACHECK_ARGS) $(PRIVATE_VALACHECK_FILES) \
	|| true;

.PHONY: $(LOCAL_MODULE)-cloc
$(LOCAL_MODULE)-cloc:
	@mkdir -p $(PRIVATE_BUILD_DIR)
	@:> $(PRIVATE_BUILD_DIR)/cloc-list.txt
	@for f in $(PRIVATE_CLOC_FILES); do \
		echo $${f} >> $(PRIVATE_BUILD_DIR)/cloc-list.txt; \
	done
	$(Q) cloc --list-file=$(PRIVATE_BUILD_DIR)/cloc-list.txt \
		--by-file --xml \
		--out $(PRIVATE_BUILD_DIR)/cloc.xml
