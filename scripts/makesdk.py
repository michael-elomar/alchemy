#!/usr/bin/env python

import sys, os, logging
import optparse
import shutil
import xml.parsers

from cStringIO import StringIO

import moduledb

#===============================================================================
#===============================================================================
class Context(object):
	def __init__(self, args):
		self.dumpXmlPath = os.path.abspath(args[0])
		self.hostBuildDir = os.path.abspath(args[1])
		self.hostStagingDir = os.path.abspath(args[2])
		self.buildDir = os.path.abspath(args[3])
		self.stagingDir = os.path.abspath(args[4])
		self.outDir = os.path.abspath(args[5])
		self.atom = StringIO()
		self.sdkDirs = []
		self.modules = None

#===============================================================================
#===============================================================================
def copyHostStaging(srcDir, dstDir):
	for (dirPath, dirNames, fileNames) in os.walk(srcDir):
		for fileName in fileNames:
			srcFilePath = os.path.join(dirPath, fileName)
			relPath = os.path.relpath(srcFilePath, srcDir)
			dstFilePath = os.path.join(dstDir, relPath)
			# When combining several sdk the same file could be found several times
			if not os.path.lexists(dstFilePath):
				if not os.path.exists(os.path.split(dstFilePath)[0]):
					os.makedirs(os.path.split(dstFilePath)[0], mode=0755)
				if os.path.islink(srcFilePath):
					logging.debug("Link: %s -> %s", srcFilePath, dstFilePath)
					linkTarget = os.readlink(srcFilePath)
					os.symlink(linkTarget, dstFilePath)
				else:
					logging.debug("Copy: %s -> %s", srcFilePath, dstFilePath)
					shutil.copy2(srcFilePath, dstFilePath)

#===============================================================================
#===============================================================================
def copyStaging(srcDir, dstDir):
	extensions = [".h", ".hpp", ".hxx", ".so", ".a", ".pc", ".tcc", ".doxygen", ".inl"]
	for (dirPath, dirNames, fileNames) in os.walk(srcDir):
		for fileName in fileNames:
			srcFilePath = os.path.join(dirPath, fileName)
			relPath = os.path.relpath(srcFilePath, srcDir)
			dstFilePath = os.path.join(dstDir, relPath)
			# When combining several sdk the same file could be found several times
			if not os.path.lexists(dstFilePath) \
					and (os.path.splitext(fileName)[1] in extensions \
							or ".so." in fileName \
							or "include" in dirPath):
				if not os.path.exists(os.path.split(dstFilePath)[0]):
					os.makedirs(os.path.split(dstFilePath)[0], mode=0755)
				if os.path.islink(srcFilePath):
					logging.debug("Link: %s -> %s", srcFilePath, dstFilePath)
					linkTarget = os.readlink(srcFilePath)
					os.symlink(linkTarget, dstFilePath)
				else:
					logging.debug("Copy: %s -> %s", srcFilePath, dstFilePath)
					shutil.copy2(srcFilePath, dstFilePath)

#===============================================================================
#===============================================================================
def copySdk(srcDir, dstDir):
	for (dirPath, dirNames, fileNames) in os.walk(srcDir):
		for fileName in fileNames:
			srcFilePath = os.path.join(dirPath, fileName)
			relPath = os.path.relpath(srcFilePath, srcDir)
			dstFilePath = os.path.join(dstDir, relPath)
			# When combining several sdk the same file could be found several times
			if not os.path.lexists(dstFilePath):
				if not os.path.exists(os.path.split(dstFilePath)[0]):
					os.makedirs(os.path.split(dstFilePath)[0], mode=0755)
				if os.path.islink(srcFilePath):
					logging.debug("Link: %s -> %s", srcFilePath, dstFilePath)
					linkTarget = os.readlink(srcFilePath)
					os.symlink(linkTarget, dstFilePath)
				else:
					logging.debug("Copy: %s -> %s", srcFilePath, dstFilePath)
					shutil.copy2(srcFilePath, dstFilePath)
		# Link to directories are in dirNames...
		for dirName in dirNames:
			srcDirPath = os.path.join(dirPath, dirName)
			relPath = os.path.relpath(srcDirPath, srcDir)
			dstDirPath = os.path.join(dstDir, relPath)
			# When combining several sdk the same file could be found several times
			if not os.path.lexists(dstDirPath):
				if not os.path.exists(os.path.split(dstDirPath)[0]):
					os.makedirs(os.path.split(dstDirPath)[0], mode=0755)
				if os.path.islink(srcDirPath):
					logging.debug("Link: %s -> %s", srcDirPath, dstDirPath)
					linkTarget = os.readlink(srcDirPath)
					os.symlink(linkTarget, dstDirPath)

#===============================================================================
#===============================================================================
def copyHeaders(srcDir, dstDir):
	extensions = [".h", ".hpp", ".hxx", ".doxygen", ".inl"]
	if not os.path.exists(srcDir):
		logging.warning("Missing include directory: %s", srcDir)
	for (dirPath, dirNames, fileNames) in os.walk(srcDir):
		for fileName in fileNames:
			srcFilePath = os.path.join(dirPath, fileName)
			relPath = os.path.relpath(srcFilePath, srcDir)
			dstFilePath = os.path.join(dstDir, relPath)
			if os.path.splitext(fileName)[1] in extensions:
				logging.debug("Copy: %s -> %s", srcFilePath, dstFilePath)
				if not os.path.exists(os.path.split(dstFilePath)[0]):
					os.makedirs(os.path.split(dstFilePath)[0], mode=0755)
				shutil.copy2(srcFilePath, dstFilePath)

#===============================================================================
#===============================================================================
def copyLibs(srcDir, dstDir):
	extensions = [".a"]
	if not os.path.exists(srcDir):
		logging.warning("Missing lib directory: %s", srcDir)
	for (dirPath, dirNames, fileNames) in os.walk(srcDir):
		for fileName in fileNames:
			srcFilePath = os.path.join(dirPath, fileName)
			relPath = os.path.relpath(srcFilePath, srcDir)
			dstFilePath = os.path.join(dstDir, relPath)
			if os.path.splitext(fileName)[1] in extensions:
				logging.debug("Copy: %s -> %s", srcFilePath, dstFilePath)
				if not os.path.exists(os.path.split(dstFilePath)[0]):
					os.makedirs(os.path.split(dstFilePath)[0], mode=0755)
				shutil.copy2(srcFilePath, dstFilePath)
		# Only first level
		break

#===============================================================================
#===============================================================================
def processModuleSdk(ctx, module):
	# Only once per sdk
	sdkDir = module.fields["SDK"]
	if sdkDir in ctx.sdkDirs:
		return
	ctx.sdkDirs.append(sdkDir)

	# Copy content of atom.mk of sdk in current context
	sdkAtomFile = open(os.path.join(sdkDir, "atom.mk"))
	for line in sdkAtomFile:
		# Skip header
		if line.startswith("# GENERATED FILE, DO NOT EDIT"):
			continue
		if line.startswith("LOCAL_PATH :="):
			continue
		ctx.atom.write(line)
	sdkAtomFile.close()

	# Copy content of sdk
	copySdk(sdkDir, ctx.outDir)

#===============================================================================
#===============================================================================
def processModule(ctx, module):
	# Skip module not built
	if not module.build:
		return
	logging.info("Processing module %s", module.name)

	# Handle module from a previous sdk separately
	if "SDK" in module.fields:
		processModuleSdk(ctx, module)
		return

	# Start a new module
	ctx.atom.write("include $(CLEAR_VARS)\n")
	modulePath = module.fields["PATH"]
	moduleClass = module.fields["MODULE_CLASS"]

	# Write verbatim some fields
	fields = ["DESCRIPTION", "CATEGORY_PATH",
			"REVISION", "FORCE_WHOLE_STATIC_LIBRARY",
			"EXPORT_CFLAGS", "EXPORT_CXXFLAGS"]
	for field in fields:
		if field in module.fields and module.fields[field] :
			ctx.atom.write("LOCAL_%s := %s\n" % (field, module.fields[field]))

	if module.name.startswith("host."):
		ctx.atom.write("LOCAL_HOST_MODULE := %s\n" % module.name[5:])
	else:
		ctx.atom.write("LOCAL_MODULE := %s\n" % module.name)

	# Libraries
	# If a module contains prelinked '.a' mentionned in its EXPORT_LDLIBS, copy
	# them and uptade the variable
	if "EXPORT_LDLIBS" in module.fields:
		libs = module.fields["EXPORT_LDLIBS"].split()
		newLibs = []
		for lib in libs:
			if lib.startswith("-L" + modulePath):
				libDir = lib[2:]
				# TODO: simplify destination by remove extra 'lib' and 'module name'
				relPath = os.path.relpath(libDir, modulePath)
				if relPath != ".":
					dstDir = "usr/lib/" + module.name + "/" + relPath
				else:
					dstDir = "usr/lib/" + module.name
				# Copy libs and add new directory only if files have actually
				# been copied (ie directory was created)
				copyLibs(libDir, os.path.join(ctx.outDir, dstDir))
				if os.path.exists(os.path.join(ctx.outDir, dstDir)):
					newLibs.append("-L$(LOCAL_PATH)/" + dstDir)
			elif lib.startswith(ctx.stagingDir):
				# Some module directly reference a path in staging, simply update
				# path, normally the file is already copied
				relPath = os.path.relpath(lib, ctx.stagingDir)
				newLibs.append("$(LOCAL_PATH)/" + relPath)
			else:
				newLibs.append(lib)
		# Write libs in a readable way
		ctx.atom.write("LOCAL_EXPORT_LDLIBS :=")
		for lib in newLibs:
			ctx.atom.write(" \\\n\t%s" % lib)
		ctx.atom.write("\n")

	# Include directories
	if "EXPORT_C_INCLUDES" in module.fields:
		includeDirs = module.fields["EXPORT_C_INCLUDES"].split()
		# First, convert path
		newIncludeDirs = []
		for includeDir in includeDirs:
			if includeDir.startswith(modulePath):
				# TODO: simplify destination by remove extra 'include' and 'module name'
				relPath = os.path.relpath(includeDir, modulePath)
				if relPath != ".":
					dstDir = "usr/include/" + module.name + "/" + relPath
				else:
					dstDir = "usr/include/" + module.name
				# Copy headers and add new directory only if files have actually
				# been copied (ie directory was created)
				copyHeaders(includeDir, os.path.join(ctx.outDir, dstDir))
				if os.path.exists(os.path.join(ctx.outDir, dstDir)):
					newIncludeDirs.append("$(LOCAL_PATH)/" + dstDir)
			elif includeDir.startswith(os.path.join(ctx.buildDir, module.name)):
				# TODO: simplify destination by remove extra 'include' and 'module name'
				relPath = os.path.relpath(includeDir, os.path.join(ctx.buildDir, module.name))
				if relPath != ".":
					dstDir = "usr/include/" + module.name + "/" + relPath
				else:
					dstDir = "usr/include/" + module.name
				# Copy headers and add new directory only if files have actually
				# been copied (ie directory was created)
				copyHeaders(includeDir, os.path.join(ctx.outDir, dstDir))
				if os.path.exists(os.path.join(ctx.outDir, dstDir)):
					newIncludeDirs.append("$(LOCAL_PATH)/" + dstDir)

			elif includeDir.startswith(ctx.stagingDir):
				relPath = os.path.relpath(includeDir, ctx.stagingDir)
				# Only add existing directory that is not in a standard place
				if relPath != "usr/include" and os.path.exists(includeDir):
					newIncludeDirs.append("$(LOCAL_PATH)/" + relPath)
			else:
				logging.warning("Ignoring include dir: %s", includeDir)
		# Write path in a readable way
		ctx.atom.write("LOCAL_EXPORT_C_INCLUDES :=")
		for includeDir in newIncludeDirs:
			ctx.atom.write(" \\\n\t%s" % includeDir)
		ctx.atom.write("\n")

	# Autoconf file
	# Note: for sdk modules, LOCAL_CONFIG_FILES will simply indicate that a
	# autoconf file is present, reconfiguration will not be possible.
	if "CONFIG_FILES" in module.fields:
		autoconfFileName = "autoconf-%s.h" % module.name
		ctx.atom.write("LOCAL_CONFIG_FILES := 1\n")
		if not os.path.exists(os.path.join(ctx.outDir, "usr/include", module.name)):
			os.makedirs(os.path.join(ctx.outDir, "usr/include", module.name), mode=0755)
		if os.path.exists(os.path.join(ctx.buildDir, module.name, autoconfFileName)):
			shutil.copy2(
					os.path.join(ctx.buildDir, module.name, autoconfFileName),
					os.path.join(ctx.outDir, "usr/include", module.name, autoconfFileName))

	# Set LOCAL_LIBRARIES with the content of 'depends'
	if "depends" in module.fields:
		ctx.atom.write("LOCAL_LIBRARIES := %s\n" % module.fields["depends"])

	# Register shared/static libraries as normal so we can manage dependencies
	# Other are simply put as prebuilt
	ctx.atom.write("LOCAL_SDK := $(LOCAL_PATH)\n")
	if moduleClass == "SHARED_LIBRARY" or moduleClass == "STATIC_LIBRARY" or moduleClass == "LIBRARY":
		ctx.atom.write("LOCAL_DESTDIR := %s\n" % module.fields["DESTDIR"])
		ctx.atom.write("LOCAL_MODULE_FILENAME := %s\n" % module.fields["MODULE_FILENAME"])
		ctx.atom.write("include $(BUILD_%s)\n" % moduleClass)
	else:
		ctx.atom.write("include $(BUILD_PREBUILT)\n")

	# End of module
	ctx.atom.write("\n")

#===============================================================================
#===============================================================================
def checkTargetVar(ctx, name):
	val = ctx.modules.targetVars.get(name, "")
	if val:
		ctx.atom.write("ifneq (\"$(TARGET_%s)\",\"%s\")\n" % (name, val))
		ctx.atom.write("  $(error This sdk is for TARGET_%s=%s)\n" % (name, val))
		ctx.atom.write("endif\n\n")

#===============================================================================
# Main function.
#===============================================================================
def main():
	(options, args) = parseArgs()
	setupLog(options)

	# Extract arguments
	ctx = Context(args)

	# Load modules from xml
	logging.info("Loading xml '%s'", ctx.dumpXmlPath)
	try:
		ctx.modules = moduledb.loadXml(ctx.dumpXmlPath)
	except xml.parsers.expat.ExpatError as ex:
		sys.stderr.write("Error while loading '%s':\n" % ctx.dumpXmlPath)
		sys.stderr.write("  %s\n" % ex)
		sys.exit(1)

	# Setup output directory
	logging.info("Initializing output directory '%s'", ctx.outDir)
	if os.path.exists(ctx.outDir):
		shutil.rmtree(ctx.outDir)
	os.makedirs(ctx.outDir, mode=0755)

	# Copy content of host staging directory
	if os.path.exists(ctx.hostStagingDir):
		logging.info("Copying host staging directory")
		copyHostStaging(ctx.hostStagingDir, os.path.join(ctx.outDir, "host"))

	# Copy content of staging directory
	logging.info("Copying staging directory")
	copyStaging(ctx.stagingDir, ctx.outDir)

	# Make sure that when the sdk is used it will be on the same target
	checkTargetVar(ctx, "OS")
	checkTargetVar(ctx, "OS_FLAVOUR")
	checkTargetVar(ctx, "ARCH")
	checkTargetVar(ctx, "CPU")
	checkTargetVar(ctx, "LIBC")
	checkTargetVar(ctx, "DEFAULT_ARM_MODE")

	# Process modules
	for module in ctx.modules:
		processModule(ctx, module)

	# Process custom macros
	for macro in ctx.modules.customMacros.values():
		ctx.atom.write("define %s\n" % macro.name)
		ctx.atom.write(macro.value)
		ctx.atom.write("\nendef\n")

	# Write the atom.mk
	atomFile = open(os.path.join(ctx.outDir, "atom.mk"), "w")
	atomFile.write("# GENERATED FILE, DO NOT EDIT\n\n")
	atomFile.write("LOCAL_PATH := $(call my-dir)\n\n")
	atomFile.write(ctx.atom.getvalue())
	atomFile.close()

#===============================================================================
# Setup option parser and parse command line.
#===============================================================================
def parseArgs():
	# Setup parser
	usage = "usage: %prog [options] <dump-xml> <host-build-dir>" \
			" <host-staging-dir> <build-dir> <staging-dir> <out-dir>"
	parser = optparse.OptionParser(usage=usage)

	# Main options

	# Other options
	parser.add_option("-q",
		dest="quiet",
		action="store_true",
		default=False,
		help="be quiet")
	parser.add_option("-v",
		dest="verbose",
		action="count",
		default=0,
		help="verbose output (more verbose if specified twice)")

	# Parse arguments and check validity
	(options, args) = parser.parse_args()
	if len(args) != 6:
		parser.error("Bad number of arguments")
	return (options, args)

#===============================================================================
# Setup logging system.
#===============================================================================
def setupLog(options):
	logging.basicConfig(
		level=logging.WARNING,
		format="[%(levelname)s] %(message)s",
		stream=sys.stderr)
	logging.addLevelName(logging.CRITICAL, "C")
	logging.addLevelName(logging.ERROR, "E")
	logging.addLevelName(logging.WARNING, "W")
	logging.addLevelName(logging.INFO, "I")
	logging.addLevelName(logging.DEBUG, "D")

	# Setup log level
	if options.quiet == True:
		logging.getLogger().setLevel(logging.CRITICAL)
	elif options.verbose >= 2:
		logging.getLogger().setLevel(logging.DEBUG)
	elif options.verbose >= 1:
		logging.getLogger().setLevel(logging.INFO)

#===============================================================================
# Entry point.
#===============================================================================
if __name__ == "__main__":
	main()
