###############################################################################
## @file classes/codeformat-rules.mk
## @author N. Brulez
## @date 2018/11/16
##
## Rules for code formatting.
###############################################################################

# Original data before import
_module_src_files := $(addprefix $(LOCAL_PATH)/,$(__modules.$(LOCAL_MODULE).SRC_FILES))
_module_c_includes := $(__modules.$(LOCAL_MODULE).C_INCLUDES)
_module_c_includes += $(__modules.$(LOCAL_MODULE).EXPORT_C_INCLUDES)
_module_c_includes += $(LOCAL_PATH)

# Search for include files in directories with source files
_module_c_includes += $(sort $(foreach __src,$(_module_src_files),$(dir $(__src))))
_module_c_includes := $(sort $(abspath $(_module_c_includes)))

# Codeformat for c files
_codeformat_c_files := $(filter %.c,$(_module_src_files))
_codeformat_c_files += $(foreach __inc,$(_module_c_includes),$(wildcard $(__inc)/*.h))

# Codeformat for c++ files
_codeformat_cxx_files := $(filter %.cpp,$(_module_src_files))
_codeformat_cxx_files += $(filter %.cc,$(_module_src_files))
_codeformat_cxx_files += $(filter %.cxx,$(_module_src_files))
_codeformat_cxx_files += $(foreach __inc,$(_module_c_includes),$(wildcard $(__inc)/*.hpp))
_codeformat_cxx_files += $(foreach __inc,$(_module_c_includes),$(wildcard $(__inc)/*.hh))
_codeformat_cxx_files += $(foreach __inc,$(_module_c_includes),$(wildcard $(__inc)/*.hxx))

# Codeformat for objc files
_codeformat_objc_files := $(filter %.m,$(_module_src_files))

# Sort to have unique names
_codeformat_c_files := $(sort $(_codeformat_c_files))
_codeformat_cxx_files := $(sort $(_codeformat_cxx_files))
_codeformat_objc_files := $(sort $(_codeformat_objc_files))

# Generate rules
.PHONY: $(LOCAL_MODULE)-codeformat
$(eval $(call _codeformat-gen-rules,c,C))
$(eval $(call _codeformat-gen-rules,cxx,CXX))
$(eval $(call _codeformat-gen-rules,objc,OBJC))
