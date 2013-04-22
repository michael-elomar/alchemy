###############################################################################
## @file dump-database.mk
## @author Y.M. Morgan
## @date 2012/11/28
##
## Dump of internal database for debugging purposes.
###############################################################################

###############################################################################
## Variables.
###############################################################################

# Where to store the xml
DUMP_DATABASE_XML_FILE := $(TARGET_OUT)/alchemy-database.xml

###############################################################################
## Macros.
###############################################################################

# This will dump everything
__dump-database = \
	$(info --------------------) \
	$(info Modules: $(__modules)) \
	$(foreach __mod,$(__modules), \
		$(info --------------------) \
		$(info $(__mod):) \
		$(info $(space4)BUILD:$(if $(call is-module-in-build-config,$(__mod)),yes,no)) \
		$(foreach __field,$(modules-fields-depends) $(vars-LOCAL), \
			$(call __dump-database-field,$(__field),$(strip $(__modules.$(__mod).$(__field)))) \
		) \
		$(foreach __field,$(macros-LOCAL), \
			$(call __dump-database-macro,$(__field),$(value __modules.$(__mod).$(__field))) \
		) \
	) \
	$(info --------------------)

# This will only dump dependencies
__dump-database-depends = \
	$(info --------------------) \
	$(info Modules: $(__modules)) \
	$(foreach __mod,$(__modules), \
		$(info --------------------) \
		$(info $(__mod):) \
		$(foreach __field,$(modules-fields-depends), \
			$(call __dump-database-field,$(__field),$(strip $(__modules.$(__mod).$(__field)))) \
		) \
	) \
	$(info --------------------)

# Dump a field if not empty
# $1 : field name
# $2 : field value
__dump-database-field = \
	$(if $2, \
		$(if $(call streq,$(words $2),1), \
			$(info $(space4)$1: $2), \
			$(info $(space4)$1: ) \
			$(foreach __fielditem,$2, \
				$(info $(space4)$(space4)$(__fielditem)) \
			) \
		) \
	)
# Dump a macro if not empty. Unlike __dump-database-field, it does not separate
# words on multiple lines.
# $1 : macro name
# $2 : macro value
__dump-database-macro = \
	$(if $2, \
		$(info $(space4)$1:) \
		$(info $2) \
	)

# Dump the full database in xml format
__dump-database-xml = \
	$(call __write-xml,<?xml version='1.0' encoding='UTF-8'?>) \
	$(call __write-xml,<modules>) \
	$(foreach __mod,$(__modules), \
		$(eval __build := $(if $(call is-module-in-build-config,$(__mod)),yes,no)) \
		$(call __write-xml,$(space4)<module name='$(__mod)' build='$(__build)'>) \
		$(foreach __field,$(modules-fields-depends) $(vars-LOCAL), \
			$(call __dump-database-field-xml,$(__field),$(strip $(__modules.$(__mod).$(__field)))) \
		) \
		$(foreach __field,$(macros-LOCAL), \
			$(call __dump-database-field-xml,$(__field),$(value __modules.$(__mod).$(__field))) \
		) \
		$(call __write-xml,$(space4)</module>) \
	) \
	$(call __write-xml,</modules>)

# Dump a field in xml format if not empty
# $1 : field name
# $2 : field value
__dump-database-field-xml = \
	$(if $2, \
		$(call __write-xml,$(space4)$(space4)<field name='$1'>) \
		$(call __write-xml,$(space4)$(space4)$(space4)<value>$(call __xml-escape,$2)</value>) \
		$(call __write-xml,$(space4)$(space4)</field>) \
	) \

# Escape characters for xml (escape '&' first, so in the innermost call at the end)
# $1 : string to escape
# Note: do NOT split the line to avoid inserting spaces in the resulting string
__xml-escape = $(subst ",&quot;,$(subst ',&apos;,$(subst >,&gt;,$(subst <,&lt;,$(subst &,&amp;,$1)))))

# Escape characters so it goes though the 'echo' correctly
# $1 : string to escape
# Note: do NOT split the line to avoid inserting spaces in the resulting string
# Note: for some strange reasons, a '\' shall be written as '\\\\' to be correctly
# interpreted. Mainly seen if a '\1' has to be written.
__echo-escape = $(subst ",\",$(subst $(dollar),\$(dollar),$(subst $(endl),\n,$(subst \,\\\\,$1))))

# We use the 'endl' to force a new line when macro is expanded. This avoids the
# need to put a ';' and a continuation line when the shell command is expanded.
# Otherwise the length of the single line of command generated will be to big
# to pass down the shell (several hundreds of KB)
__write-xml = \
	@echo "$(call __echo-escape,$1)" >> $(DUMP_DATABASE_XML_FILE) $(endl)

###############################################################################
## Rules.
###############################################################################

.PHONY: dump
dump:
	$(call __dump-database)

.PHONY: dump-depends
dump-depends:
	$(call __dump-database-depends)

.PHONY: dump-xml
dump-xml:
	@echo "Database dump: start"
	@mkdir -p $(dir $(DUMP_DATABASE_XML_FILE))
	@rm -f $(DUMP_DATABASE_XML_FILE)
	@touch $(DUMP_DATABASE_XML_FILE)
	$(call __dump-database-xml)
	@echo "Database dump: done -> $(DUMP_DATABASE_XML_FILE)"

.PHONY: dump-xml-clean
dump-xml-clean:
	$(Q)rm -f $(DUMP_DATABASE_XML_FILE)

clean: dump-xml-clean
dirclean: dump-xml-clean
clobber: dump-xml-clean

