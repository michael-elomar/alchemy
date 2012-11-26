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
	$(info Modules: $(sort $(__modules))) \
	$(foreach __mod,$(sort $(__modules)), \
		$(info --------------------) \
		$(info $(__mod):) \
		$(info $(space4)BUILD:$(if $(call is-module-in-build-config,$(__mod)),yes,no)) \
		$(foreach __field,$(modules-fields), \
			$(eval __fieldval := $(strip $(__modules.$(__mod).$(__field)))) \
			$(call __dump-database-field,$(__field),$(__fieldval)) \
		) \
	) \
	$(info --------------------)

# This will only dump dependencies
__dump-database-depends = \
	$(info --------------------) \
	$(info Modules: $(sort $(__modules))) \
	$(foreach __mod,$(sort $(__modules)), \
		$(info --------------------) \
		$(info $(__mod):) \
		$(foreach __field,$(modules-fields-depends), \
			$(eval __fieldval := $(strip $(__modules.$(__mod).$(__field)))) \
			$(call __dump-field,$(__field),$(__fieldval)) \
		) \
	) \
	$(info --------------------)

# Dump a field if not empty
# $1 : field name
# $2 : field value
__dump-database-field = \
	$(if $2, \
		$(if $(filter 1,$(words $2)), \
			$(info $(space4)$1: $2), \
			$(info $(space4)$1: ) \
			$(foreach __fielditem,$2, \
				$(info $(space4)$(space4)$(__fielditem)) \
			) \
		) \
	)

# Dump the full database in xml format
__dump-database-xml = \
	$(call __write-xml,<?xml version='1.0' encoding='UTF-8'?>) \
	$(call __write-xml,<modules>) \
	$(foreach __mod,$(sort $(__modules)), \
		$(eval __build := $(if $(call is-module-in-build-config,$(__mod)),yes,no)) \
		$(call __write-xml,$(space4)<module name='$(__mod)' build='$(__build)'>) \
		$(foreach __field,$(modules-fields), \
			$(eval __fieldval := $(strip $(__modules.$(__mod).$(__field)))) \
			$(if $(__fieldval), \
				$(call __write-xml,$(space4)$(space4)<field name='$(__field)'>) \
				$(call __write-xml,$(space4)$(space4)$(space4)<value>$(__fieldval)</value>) \
				$(call __write-xml,$(space4)$(space4)</field>) \
			) \
		) \
		$(call __write-xml,$(space4)</module>) \
	) \
	$(call __write-xml,</modules>)

# We use the 'endl' to force a new line when macro is expanded. This avoid the
# need to put a ';' and a continuation line when the shell command is expanded.
# Otherwise the line of the single line of command generated will be to big
# to pass down the shell (several hundreds of KB)
__write-xml = \
	@echo "$1" >> $(DUMP_DATABASE_XML_FILE) $(endl)

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
	@mkdir -p $(dir $(DUMP_DATABASE_XML_FILE))
	@rm -f $(DUMP_DATABASE_XML_FILE)
	@touch $(DUMP_DATABASE_XML_FILE)
	$(call __dump-database-xml)
	@echo "Database dump done: $(DUMP_DATABASE_XML_FILE)"

.PHONY: dump-xml-clean
dump-xml-clean:
	@rm -f $(DUMP_DATABASE_XML_FILE)

clean: dump-xml-clean
dirclean: dump-xml-clean
clobber: dump-xml-clean

