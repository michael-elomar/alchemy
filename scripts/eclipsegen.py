#!/usr/bin/env python

import sys
import optparse
import xml.parsers

import moduledb

#===============================================================================
#===============================================================================
def genCdtProjectProperties(fd, modules, module):
	# Get dependencies of given module
	depends = [modules[dep] for dep in module.fields.get("depends", "").split()]

	languages = ["C++ Source File", "C Source File"]
	fd.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
	fd.write("<cdtprojectproperties>\n")

	fd.write("<section name=\"org.eclipse.cdt.internal.ui.wizards.settingswizards.IncludePaths\">\n")
	for language in languages:
		fd.write("<language name=\"%s\">\n" % language)
		for dep in depends:
			for incPath in dep.fields.get("EXPORT_C_INCLUDES", "").split():
				fd.write("<includepath>%s</includepath>\n" % incPath)
		fd.write("</language>\n")
	fd.write("</section>\n")

	fd.write("<section name=\"org.eclipse.cdt.internal.ui.wizards.settingswizards.Macros\">\n")
	for language in languages:
		fd.write("<language name=\"%s\">\n" % language)
		for dep in depends:
			cflags = dep.fields.get("EXPORT_CFLAGS", "").split()
			cxxflags = dep.fields.get("EXPORT_CXXFLAGS", "").split()
			flags = cflags + cxxflags if language == "C++ Source File" else cflags
			for flag in flags:
				if not flag.startswith("-D"):
					continue
				if "=" in flag:
					(name, value) = flag[2:].split("=", 1)
				else:
					(name, value) = (flag[2:], "")
				fd.write("<macro><name>%s</name><value>%s</value></macro>\n" %
						(name, value))
		fd.write("</language>\n")
	fd.write("</section>\n")

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
	parser.add_option("--force",
		dest="force",
		action="store_true",
		default=False,
		help="Overwrite existing files.")

	# Parse arguments and check validity
	(options, args) = parser.parse_args()
	if len(args) != 2:
		parser.error("Bad number of arguments")
	return (options, args)

#===============================================================================
#===============================================================================
if __name__ == "__main__":
	main()

