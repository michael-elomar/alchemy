###############################################################################
## @file build-graph.mk
## @author Y.M. Morgan
## @date 2012/10/19
##
## Rules to generate a graph of build dependencies.
###############################################################################

BUILD_GRAPH_DOT := $(TARGET_OUT)/build-graph.dot
BUILD_GRAPH_SVG := $(TARGET_OUT)/build-graph.svg
BUILD_GRAPH_PDF := $(TARGET_OUT)/build-graph.pdf

# Force regeneration of this file everytime
$(BUILD_GRAPH_DOT): .FORCE
	@echo "Generating $(call path-from-top,$@)"
	@mkdir -p $(dir $@)
	$(Q)( \
		echo 'digraph {'; \
		echo 'graph [ ratio=.5 ];'; \
		$(foreach __mod1,$(__modules), \
			$(if $(call is-module-in-build-config,$(__mod1)), \
				$(foreach __mod2,$(__modules.$(__mod1).depends), \
					echo \"$(__mod1)\" -\> \"$(__mod2)\"; \
				) \
			) \
		) \
		echo '}'; \
	) > $@
	
$(BUILD_GRAPH_SVG): $(BUILD_GRAPH_DOT)
	@echo "Generating $(call path-from-top,$@)"
	$(Q)dot -Tsvg -Nshape=box -o $@ $<

$(BUILD_GRAPH_PDF): $(BUILD_GRAPH_DOT)
	@echo "Generating $(call path-from-top,$@)"
	$(Q)dot -Tpdf -Nshape=box -o $@ $<


.PHONY: build-graph
build-graph: $(BUILD_GRAPH_SVG) $(BUILD_GRAPH_PDF)

