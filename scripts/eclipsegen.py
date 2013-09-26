#!/usr/bin/env python

import sys
import optparse
import xml.parsers

import moduledb

#===============================================================================
#===============================================================================
def genCdtProjectProperties(fd, modules, module):
	# Get dependencies of given module
	depends = [modules[dep] for dep in module.fields.get("depends.all", "").split()]

	# Langauges to generate
	languages = ["C++ Source File", "C Source File"]

	# Helper for includes
	def genIncludes(incPaths):
		for incPath in incPaths.split():
			fd.write("    <includepath>%s</includepath>\n" % incPath)

	# Helper for macros
	def genMacros(flags):
		for flag in flags.split():
			if not flag.startswith("-D"):
				continue
			if "=" in flag:
				(name, value) = flag[2:].split("=", 1)
			else:
				(name, value) = (flag[2:], "")
			fd.write("    <macro><name>%s</name><value>%s</value></macro>\n" %
					(name, value))

	# Header
	fd.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
	fd.write("<cdtprojectproperties>\n")

	# Includes
	fd.write("<section name=\"org.eclipse.cdt.internal.ui.wizards.settingswizards.IncludePaths\">\n")
	for language in languages:
		fd.write("  <language name=\"%s\">\n" % language)
		genIncludes(modules.targetVars.get("GLOBAL_C_INCLUDES", ""))
		for dep in depends:
			genIncludes(dep.fields.get("EXPORT_C_INCLUDES", ""))
		fd.write("  </language>\n")
	fd.write("</section>\n")

	# Macros
	fd.write("<section name=\"org.eclipse.cdt.internal.ui.wizards.settingswizards.Macros\">\n")
	for language in languages:
		fd.write("  <language name=\"%s\">\n" % language)
		genMacros(modules.targetVars.get("GLOBAL_CFLAGS", ""))
		if language == "C++ Source File":
			genMacros(modules.targetVars.get("GLOBAL_CXXFLAGS", ""))
		for dep in depends:
			genMacros(dep.fields.get("EXPORT_CFLAGS", ""))
			if language == "C++ Source File":
				genMacros(dep.fields.get("EXPORT_CXXFLAGS", ""))
		fd.write("  </language>\n")
	fd.write("</section>\n")

	# Footer
	fd.write("</cdtprojectproperties>\n")

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

	fd = open("%s-eclipse.xml" % args[1], "w")
	genCdtProjectProperties(fd, modules, modules[args[1]])
	fd.close()

#===============================================================================
# Setup option parser and parse command line.
#===============================================================================
def parseArgs():
	# Setup parser
	usage = "usage: %prog [options] <dump-xml> <module>"
	parser = optparse.OptionParser(usage=usage)

	# Main options
#	parser.add_option("--force",
#		dest="force",
#		action="store_true",
#		default=False,
#		help="Overwrite existing files.")

	# Parse arguments and check validity
	(options, args) = parser.parse_args()
	if len(args) != 2:
		parser.error("Bad number of arguments")
	return (options, args)

#===============================================================================
#===============================================================================
if __name__ == "__main__":
	main()

