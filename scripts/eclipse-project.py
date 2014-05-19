#!/usr/bin/env python

import sys
import os
import optparse
import xml.parsers

import moduledb

#===============================================================================
# generate .project file
#===============================================================================
def genProject(path, name, modules, options):
	filename = path + "/.project"
	sys.stderr.write("[%s]: generating '%s'\n" % (name, filename))
	fd = open(filename, "w")

	fd.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
	fd.write("<projectDescription>\n")
	fd.write("\t<name>%s</name>\n" % name)
	fd.write("\t<comment></comment>\n")
	fd.write("\t<projects>\n")
	fd.write("\t</projects>\n")
	fd.write("\t<buildSpec>\n")
	fd.write("\t\t<buildCommand>\n")
	fd.write("\t\t\t<name>org.eclipse.cdt.managedbuilder.core.genmakebuilder</name>\n")
	fd.write("\t\t\t<arguments>\n")
	fd.write("\t\t\t</arguments>\n")
	fd.write("\t\t</buildCommand>\n")
	fd.write("\t\t<buildCommand>\n")
	fd.write("\t\t\t<name>org.eclipse.cdt.managedbuilder.core.ScannerConfigBuilder</name>\n")
	fd.write("\t\t\t<triggers>auto,full,incremental,</triggers>\n")
	fd.write("\t\t\t<arguments>\n")
	fd.write("\t\t\t</arguments>\n")
	fd.write("\t\t</buildCommand>\n")
	fd.write("\t</buildSpec>\n")
	fd.write("\t<natures>\n")
	fd.write("\t\t<nature>org.eclipse.cdt.core.cnature</nature>\n")
	fd.write("\t\t<nature>org.eclipse.cdt.managedbuilder.core.managedBuildNature</nature>\n")
	fd.write("\t\t<nature>org.eclipse.cdt.managedbuilder.core.ScannerConfigNature</nature>\n")
	fd.write("\t\t<nature>org.eclipse.cdt.core.ccnature</nature>\n")
	fd.write("\t</natures>\n")
	fd.write("\t<linkedResources>\n")

	if options.linkdeps:
		module = modules[name]
		depends = [modules[dep] for dep in module.fields.get("depends", "").split()]
		for dep in depends:
			fd.write("\t\t<link>\n")
			fd.write("\t\t\t<name>%s</name>\n" % dep.name)
			fd.write("\t\t\t<type>2</type>\n")
			if "ARCHIVE" in dep.fields:
				location = modules.targetVars["OUT_BUILD"] + "/" + dep.name + "/" + dep.fields["ARCHIVE_SUBDIR"]
			else:
				location = dep.fields["PATH"]

			fd.write("\t\t\t<location>%s</location>\n" % location)
			fd.write("\t\t</link>\n")

	fd.write("\t</linkedResources>\n")
	fd.write("</projectDescription>\n")

	fd.close()

#===============================================================================
# generate include dirs
#===============================================================================
def genIncludes(fd, path, name, modules, product, variant, workspace):
	incDirs = []
	module = modules[name]
	depends = [modules[dep] for dep in module.fields.get("depends.all", "").split()]

	# add includes in incDirs
	def addIncludes(incPaths):
		for incPath in incPaths.split():
			if incPath not in incDirs:
				incDirs.append(incPath)

	# add global includes
	addIncludes(modules.targetVars.get("GLOBAL_C_INCLUDES", ""))

	# add module includes
	if "C_INCLUDES" in module.fields:
		addIncludes(module.fields["C_INCLUDES"])

	# add module dependency includes
	for dep in depends:
		addIncludes(dep.fields.get("EXPORT_C_INCLUDES", ""))

	# write includes
	for incDir in incDirs:
		fd.write("\t\t\t\t\t\t\t\t\t<listOptionValue builtIn=\"false\" value=\"%s\"/>\n" % (incDir))

#===============================================================================
# generate IncludeConfig File (autoconf)
#===============================================================================
def genIncludeConfigFiles(fd, path, name, modules, product, variant, workspace, language):
	incFiles = []
	module = modules[name]
	depends = [modules[dep] for dep in module.fields.get("depends.all", "").split()]

	# add includes in incDirs
	def addFile(f):
		if f not in incFiles:
			incFiles.append(f)

	# add module dependency includes
	for dep in depends + [module]:
		if "CONFIG_FILES" in dep.fields:
			f = modules.targetVars["OUT_BUILD"] + "/" + dep.name + "/autoconf-" + dep.name + ".h"
			addFile(f)

	# write includes files
	for f in incFiles:
		fd.write("\t\t\t\t\t\t\t\t\t<listOptionValue builtIn=\"false\" value=\"%s\"/>\n" % (f))

#===============================================================================
# generate Symbols
#===============================================================================
def genSymbols(fd, path, name, modules, product, variant, workspace, language):
	module = modules[name]
	depends = [modules[dep] for dep in module.fields.get("depends.all", "").split()]

	# add includes in incDirs
	def genMacros(flags):
		for flag in flags.split():
			if not flag.startswith("-D"):
				continue
			if "=" in flag:
				(name, value) = flag[2:].split("=", 1)
				fd.write("\t\t\t\t\t\t\t\t\t<listOptionValue builtIn=\"false\" value=\"%s=%s\"/>\n" % (name, value))
			else:
				(name, value) = (flag[2:], "")
				fd.write("\t\t\t\t\t\t\t\t\t<listOptionValue builtIn=\"false\" value=\"%s\"/>\n" % name)

	# always add cflags
	genMacros(modules.targetVars.get("GLOBAL_CFLAGS", ""))
	if "CFLAGS" in module.fields:
		genMacros(module.fields["CFLAGS"])
	for dep in depends:
			genMacros(dep.fields.get("EXPORT_CFLAGS", ""))

	# add cxx flags for C++
	if language == "C++":
		genMacros(modules.targetVars.get("GLOBAL_CXXFLAGS", ""))
		if "CXXFLAGS" in module.fields:
			genMacros(module.fields["CXXFLAGS"])
		for dep in depends:
			genMacros(dep.fields.get("EXPORT_CXXFLAGS", ""))

#===============================================================================
# generate .cproject configuration
#===============================================================================
def genConfig(fd, path, name, modules, product, variant, workspace, options):

	# Get dependencies of given module
	module = modules[name]
	depends = [modules[dep] for dep in module.fields.get("depends.all", "").split()]

	fd.write("\t\t<cconfiguration id=\"cdt.managedbuild.toolchain.gnu.cross.base.235287930\">\n")
	fd.write("\t\t\t<storageModule buildSystemId=\"org.eclipse.cdt.managedbuilder.core.configurationDataProvider\" id=\"cdt.managedbuild.toolchain.gnu.cross.base.235287930\" moduleId=\"org.eclipse.cdt.core.settings\" name=\"%s %s\">\n" % (product, variant))
	fd.write("\t\t\t\t<macros>\n")
	fd.write("\t\t\t\t\t<stringMacro name=\"TARGET_PRODUCT_VARIANT\" type=\"VALUE_TEXT\" value=\"%s\"/>\n" % variant)
	fd.write("\t\t\t\t\t<stringMacro name=\"TARGET_PRODUCT\" type=\"VALUE_TEXT\" value=\"%s\"/>\n" % product)
	fd.write("\t\t\t\t</macros>\n")
	fd.write("\t\t\t\t<externalSettings/>\n")
	fd.write("\t\t\t\t<extensions>\n")
	fd.write("\t\t\t\t\t<extension id=\"org.eclipse.cdt.core.GmakeErrorParser\" point=\"org.eclipse.cdt.core.ErrorParser\"/>\n")
	fd.write("\t\t\t\t\t<extension id=\"org.eclipse.cdt.core.CWDLocator\" point=\"org.eclipse.cdt.core.ErrorParser\"/>\n")
	fd.write("\t\t\t\t\t<extension id=\"org.eclipse.cdt.core.GCCErrorParser\" point=\"org.eclipse.cdt.core.ErrorParser\"/>\n")
	fd.write("\t\t\t\t\t<extension id=\"org.eclipse.cdt.core.GASErrorParser\" point=\"org.eclipse.cdt.core.ErrorParser\"/>\n")
	fd.write("\t\t\t\t\t<extension id=\"org.eclipse.cdt.core.GLDErrorParser\" point=\"org.eclipse.cdt.core.ErrorParser\"/>\n")
	fd.write("\t\t\t\t\t<extension id=\"org.eclipse.cdt.core.ELF\" point=\"org.eclipse.cdt.core.BinaryParser\"/>\n")
	fd.write("\t\t\t\t</extensions>\n")
	fd.write("\t\t\t</storageModule>\n")
	fd.write("\t\t\t<storageModule moduleId=\"cdtBuildSystem\" version=\"4.0.0\">\n")
	fd.write("\t\t\t\t<configuration artifactName=\"${ProjName}\" buildProperties=\"\" description=\"\" id=\"cdt.managedbuild.toolchain.gnu.cross.base.235287930\" name=\"%s %s\" parent=\"org.eclipse.cdt.build.core.emptycfg\">\n" % (product, variant))
	fd.write("\t\t\t\t\t<folderInfo id=\"cdt.managedbuild.toolchain.gnu.cross.base.235287930.445303279\" name=\"/\" resourcePath=\"\">\n")
	fd.write("\t\t\t\t\t\t<toolChain id=\"cdt.managedbuild.toolchain.gnu.cross.base.1202958509\" name=\"cdt.managedbuild.toolchain.gnu.cross.base\" superClass=\"cdt.managedbuild.toolchain.gnu.cross.base\">\n")

	#crossPath ='/opt/arm-2012.03/bin'
	#crossPrefix = 'arm-none-linux-gnueabi-'
	crossPath = os.path.dirname(modules.targetVars["CC"])
	crossPrefix = ''
	if "CROSS" in modules.targetVars:
		crossPrefix = os.path.basename(modules.targetVars["CROSS"])

	fd.write("\t\t\t\t\t\t\t<option id=\"cdt.managedbuild.option.gnu.cross.prefix.1532971020\" name=\"Prefix\" superClass=\"cdt.managedbuild.option.gnu.cross.prefix\" value=\"%s\" valueType=\"string\"/>\n" % crossPrefix)
	fd.write("\t\t\t\t\t\t\t<option id=\"cdt.managedbuild.option.gnu.cross.path.1371778372\" name=\"Path\" superClass=\"cdt.managedbuild.option.gnu.cross.path\" value=\"%s\" valueType=\"string\"/>\n" % crossPath)
	fd.write("\t\t\t\t\t\t\t<targetPlatform archList=\"all\" binaryParser=\"org.eclipse.cdt.core.ELF\" id=\"cdt.managedbuild.targetPlatform.gnu.cross.1850660649\" isAbstract=\"false\" osList=\"all\" superClass=\"cdt.managedbuild.targetPlatform.gnu.cross\"/>\n")
	fd.write("\t\t\t\t\t\t\t<builder arguments=\"${TARGET_PRODUCT} ${TARGET_PRODUCT_VARIANT}\" autoBuildTarget=\"${ProjName}\" buildPath=\"%s\" cleanBuildTarget=\"${ProjName}-clean\" command=\"${CWD}/build.sh\" enableAutoBuild=\"false\" id=\"cdt.managedbuild.builder.gnu.cross.60154042\" incrementalBuildTarget=\"${ProjName}\" keepEnvironmentInBuildfile=\"false\" managedBuildOn=\"false\" name=\"Gnu Make Builder\" superClass=\"cdt.managedbuild.builder.gnu.cross\"/>\n" % (workspace))
	# Generate C compiler
	fd.write("\t\t\t\t\t\t\t<tool id=\"cdt.managedbuild.tool.gnu.cross.c.compiler.1213173184\" name=\"Cross GCC Compiler\" superClass=\"cdt.managedbuild.tool.gnu.cross.c.compiler\">\n")
	fd.write("\t\t\t\t\t\t\t\t<option id=\"gnu.c.compiler.option.include.paths.1976964143\" name=\"Include paths (-I)\" superClass=\"gnu.c.compiler.option.include.paths\" useByScannerDiscovery=\"false\" valueType=\"includePath\">\n")
	# generate C includes dirs
	genIncludes(fd, path, name, modules, product, variant, workspace)
	fd.write("\t\t\t\t\t\t\t\t</option>\n")
	# generate C symbols
	fd.write("\t\t\t\t\t\t\t\t<option id=\"gnu.c.compiler.option.preprocessor.def.symbols.924731729\" name=\"Defined symbols (-D)\" superClass=\"gnu.c.compiler.option.preprocessor.def.symbols\" useByScannerDiscovery=\"false\" valueType=\"definedSymbols\">\n")
	genSymbols(fd, path, name, modules, product, variant, workspace, "C")
	fd.write("\t\t\t\t\t\t\t\t</option>\n")
	# generate C config includes files
	fd.write("\t\t\t\t\t\t\t\t<option id=\"gnu.c.compiler.option.include.files.2029277116\" name=\"Include files (-include)\" superClass=\"gnu.c.compiler.option.include.files\" useByScannerDiscovery=\"false\" valueType=\"includeFiles\">\n")
	genIncludeConfigFiles(fd, path, name, modules, product, variant, workspace, "C")
	fd.write("\t\t\t\t\t\t\t\t</option>\n")
	fd.write("\t\t\t\t\t\t\t\t<inputType id=\"cdt.managedbuild.tool.gnu.c.compiler.input.1142186925\" superClass=\"cdt.managedbuild.tool.gnu.c.compiler.input\"/>\n")
	fd.write("\t\t\t\t\t\t\t</tool>\n")
	# Generate CPP compiler
	fd.write("\t\t\t\t\t\t\t<tool id=\"cdt.managedbuild.tool.gnu.cross.cpp.compiler.1287506518\" name=\"Cross G++ Compiler\" superClass=\"cdt.managedbuild.tool.gnu.cross.cpp.compiler\">\n")
	fd.write("\t\t\t\t\t\t\t\t<option id=\"gnu.cpp.compiler.option.include.paths.603669782\" name=\"Include paths (-I)\" superClass=\"gnu.cpp.compiler.option.include.paths\" useByScannerDiscovery=\"false\" valueType=\"includePath\">\n")
	# generate CPP includes dirs
	genIncludes(fd, path, name, modules, product, variant, workspace)
	fd.write("\t\t\t\t\t\t\t\t</option>\n")
	fd.write("\t\t\t\t\t\t\t\t<option id=\"gnu.cpp.compiler.option.preprocessor.def.1041455944\" name=\"Defined symbols (-D)\" superClass=\"gnu.cpp.compiler.option.preprocessor.def\" useByScannerDiscovery=\"false\" valueType=\"definedSymbols\">\n")
	# generate CPP symbols
	genSymbols(fd, path, name, modules, product, variant, workspace, "C++")
	fd.write("\t\t\t\t\t\t\t\t</option>\n")
	# generate CPP config includes files
	fd.write("\t\t\t\t\t\t\t\t<option id=\"gnu.cpp.compiler.option.include.files.661612011\" name=\"Include files (-include)\" superClass=\"gnu.cpp.compiler.option.include.files\" useByScannerDiscovery=\"false\" valueType=\"includeFiles\">\n")
	genIncludeConfigFiles(fd, path, name, modules, product, variant, workspace, "C++")
	fd.write("\t\t\t\t\t\t\t\t</option>\n")
	fd.write("\t\t\t\t\t\t\t\t<inputType id=\"cdt.managedbuild.tool.gnu.cpp.compiler.input.1158160426\" superClass=\"cdt.managedbuild.tool.gnu.cpp.compiler.input\"/>\n")
	fd.write("\t\t\t\t\t\t\t</tool>\n")
	fd.write("\t\t\t\t\t\t\t<tool id=\"cdt.managedbuild.tool.gnu.cross.c.linker.1965638524\" name=\"Cross GCC Linker\" superClass=\"cdt.managedbuild.tool.gnu.cross.c.linker\"/>\n")
	fd.write("\t\t\t\t\t\t\t<tool id=\"cdt.managedbuild.tool.gnu.cross.cpp.linker.924514558\" name=\"Cross G++ Linker\" superClass=\"cdt.managedbuild.tool.gnu.cross.cpp.linker\">\n")
	fd.write("\t\t\t\t\t\t\t\t<inputType id=\"cdt.managedbuild.tool.gnu.cpp.linker.input.1315528557\" superClass=\"cdt.managedbuild.tool.gnu.cpp.linker.input\">\n")
	fd.write("\t\t\t\t\t\t\t\t\t<additionalInput kind=\"additionalinputdependency\" paths=\"$(USER_OBJS)\"/>\n")
	fd.write("\t\t\t\t\t\t\t\t\t<additionalInput kind=\"additionalinput\" paths=\"$(LIBS)\"/>\n")
	fd.write("\t\t\t\t\t\t\t\t</inputType>\n")
	fd.write("\t\t\t\t\t\t\t</tool>\n")
	fd.write("\t\t\t\t\t\t\t<tool id=\"cdt.managedbuild.tool.gnu.cross.archiver.2086349530\" name=\"Cross GCC Archiver\" superClass=\"cdt.managedbuild.tool.gnu.cross.archiver\"/>\n")
	fd.write("\t\t\t\t\t\t\t<tool id=\"cdt.managedbuild.tool.gnu.cross.assembler.665047314\" name=\"Cross GCC Assembler\" superClass=\"cdt.managedbuild.tool.gnu.cross.assembler\">\n")
	fd.write("\t\t\t\t\t\t\t\t<inputType id=\"cdt.managedbuild.tool.gnu.assembler.input.1023730334\" superClass=\"cdt.managedbuild.tool.gnu.assembler.input\"/>\n")
	fd.write("\t\t\t\t\t\t\t</tool>\n")
	fd.write("\t\t\t\t\t\t</toolChain>\n")
	fd.write("\t\t\t\t\t</folderInfo>\n")
	
	if options.linkdeps:
		fd.write("\t\t\t\t\t<sourceEntries>\n")
		module = modules[name]
		depends = [modules[dep] for dep in module.fields.get("depends", "").split()]
		excluding = "|".join([dep.name for dep in depends])
		fd.write("\t\t\t\t\t\t<entry excluding=\"%s\" flags=\"VALUE_WORKSPACE_PATH|RESOLVED\" kind=\"sourcePath\" name=\"\"/>\n" % excluding)
		for dep in depends:
			fd.write("\t\t\t\t\t\t<entry flags=\"VALUE_WORKSPACE_PATH|RESOLVED\" kind=\"sourcePath\" name=\"%s\"/>\n" % dep.name)
		fd.write("\t\t\t\t\t</sourceEntries>\n")

	fd.write("\t\t\t\t</configuration>\n")
	fd.write("\t\t\t</storageModule>\n")
	fd.write("\t\t\t<storageModule moduleId=\"org.eclipse.cdt.core.externalSettings\"/>\n")
	fd.write("\t\t</cconfiguration>\n")



					
#===============================================================================
# generate .cproject file
#===============================================================================
def genCProject(path, name, modules, product, variant, workspace, options):

	filename = path + "/.cproject"

	sys.stderr.write("[%s]: generating '%s'\n" % (name, filename))
	
	fd = open(filename, "w")

	fd.write("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n")
	fd.write("<?fileVersion 4.0.0?><cproject storage_type_id=\"org.eclipse.cdt.core.XmlProjectDescriptionStorage\">\n")
	fd.write("\t<storageModule moduleId=\"org.eclipse.cdt.core.settings\">\n")

	# TODO: generate for each config
	genConfig(fd, path, name, modules, product, variant, workspace, options)

	fd.write("\t</storageModule>\n")
	fd.write("\t<storageModule moduleId=\"cdtBuildSystem\" version=\"4.0.0\">\n")
	fd.write("\t\t<project id=\"%s.null.1434616597\" name=\"%s\"/>\n" % (name, name))
	fd.write("\t</storageModule>\n")

	fd.write("\t<storageModule moduleId=\"org.eclipse.cdt.core.LanguageSettingsProviders\"/>\n")
	fd.write("\t<storageModule moduleId=\"refreshScope\" versionNumber=\"2\">\n")
	fd.write("\t\t<configuration configurationName=\"Default\">\n")
	fd.write("\t\t\t<resource resourceType=\"PROJECT\" workspacePath=\"/%s\"/>\n" % name)
	fd.write("\t\t</configuration>\n")

	# TODO: add for each config
	fd.write("\t\t<configuration configurationName=\"%s %s\">\n" % (product, variant))
	fd.write("\t\t\t<resource resourceType=\"PROJECT\" workspacePath=\"/%s\"/>\n" % name)
	fd.write("\t\t</configuration>\n")
	fd.write("\t</storageModule>\n")

	fd.write("</cproject>\n")
	fd.close()

#===============================================================================
#===============================================================================
def main():
	(options, args) = parseArgs()

	# Load modules from xml
	try:
		modules = moduledb.loadXml(args[0])
	except xml.parsers.expat.ExpatError as ex:
		sys.stderr.write("Error while loading '%s':\n" % args[0])
		sys.stderr.write("  %s\n" % ex)
		sys.exit(1)

	for name in args[1:]:
		if name not in modules:
			sys.stderr.write("Error module '%s' not found:\n" % name)
			continue;

		module = modules[name]
		genProject(module.fields["PATH"], module.name, modules, options)
		genCProject(module.fields["PATH"], module.name, modules,
				modules.targetVars["PRODUCT"],
				modules.targetVars["PRODUCT_VARIANT"],
				modules.targetVars["ALCHEMY_WORKSPACE_DIR"],
				options)

#===============================================================================
# Setup option parser and parse command line.
#===============================================================================
def parseArgs():
	# Setup parser
	usage = "usage: %prog [options] <dump-xml> <module1> <module2> ..."
	parser = optparse.OptionParser(usage=usage)

	# Main options
	parser.add_option("--force",
		dest="force",
		action="store_true",
		default=False,
		help="Overwrite existing files.")
	parser.add_option("--link-dependencies",
		dest="linkdeps",
		action="store_true",
		default=False,
		help="Link direct dependencies sources in project.")

	# Parse arguments and check validity
	(options, args) = parser.parse_args()
	if len(args) < 2:
		parser.error("Bad number of arguments")
	return (options, args)

#===============================================================================
#===============================================================================
if __name__ == "__main__":
	main()


