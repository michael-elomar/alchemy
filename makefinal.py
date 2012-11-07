#!/usr/bin/env python
#
# @file makefinal.py
# @author Y.M. Morgan
# @date 2012/07/09
#
# Generate the final directory by copying files from staging directory
#

import sys, os, logging
import subprocess
import optparse

#===============================================================================
# Global variables.
#===============================================================================

# Directories to exclude
EXCLUDE_DIRS = ["linux-headers", "include", "man", "pkgconfig", "doc", "aclocal", "info", "locale"]

# Extension to exclude
EXCLUDE_FILTERS = [".a", ".la", ".py", ".pyc", ".pyo"]

# Files to exclude
EXCLUDE_FILES = ["Image", "zImage", "bzImage", "uImage", "kernel.plf"]

#==============================================================================
# Execute a command and get its output
#==============================================================================
def executeCmd(cmd):
	p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell = True)
	return p.communicate()[0].rstrip("\n").split("\n")

#===============================================================================
# Determine if a file is an executable.
#===============================================================================
def isExec(filePath):
	result = False
	try:
		file = open(filePath, "r")
		header = str(file.read(4))
		if header.find("ELF") >= 0:
			result = True
		file.close()
	except IOError as ex:
		logging.error("Unable to open %s ([err=%d] %s)",
			filePath, ex.errno, ex.strerror)
	return result

#===============================================================================
# Determine if a file can be stripped.
# Required under android because soslim crashes when trying to strip
# static executables compiled with eglibc.
#===============================================================================
def canStrip(filePath):
	result = False
	try:
		# get error output from nm command to check for 'no symbols'
		p = subprocess.Popen("nm %s" % filePath,
			stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell = True)
		res = p.communicate()[1].rstrip("\n").split("\n")
		result = (len(res) == 0 or res[0].find("no symbols") < 0)
	except IOError as ex:
		# assume not strippable if nm failed
		result = False
	return result

#===============================================================================
#===============================================================================
def doCopyByMakefile(dstFileName, srcFileName, doStrip, options):
	# if source file contains ':' or '=' it doesn't work great
	# prerequisite shall be escaped
	# target can not contain at all any ':' or '=' so replace with '_'
	# in command do not use target name as it will be wrong
	# consequence is that target will never actually exists and commands
	# will always be executed
	if srcFileName.find(":") >= 0:
		srcFileName = srcFileName.replace(":", "\\:")
		srcFileName = srcFileName.replace("=", "\\=")
		dstFileName = dstFileName.replace(":", "_")
		dstFileName = dstFileName.replace("=", "_")

	# register destination in ALL variable
	options.makefile.write("ALL += %s\n" % dstFileName)

	# rule
	options.makefile.write("%s: %s\n" % (dstFileName, srcFileName))

	# define variables with real src and dst (in case it was patched above)
	options.makefile.write("\t$(eval __src := $<)\n")
	options.makefile.write("\t$(eval __dst := $(patsubst %s/%%,%s/%%,$<))\n" % \
		(options.stagingDir, options.finalDir))

	# commands, see doCopy for more info
	options.makefile.write("\t@mkdir -p $(dir $(__dst))\n")
	options.makefile.write("\t@echo Alchemy install: $(patsubst $(PWD)/%,%,$(__dst))\n")
	if doStrip:
		options.makefile.write("\t$(Q)$(STRIP) -o $(__dst) $(__src)\n")
		options.makefile.write("\t$(Q)chmod $$(stat --printf '%a' $(__src)) $(__dst)")
	else:
		options.makefile.write("\t$(Q)cp -af $(__src) $(__dst)\n")
	options.makefile.write("\n")

#===============================================================================
#===============================================================================
def doCopy(dstFileName, srcFileName, doStrip, options):
	# copy and strip executables
	# make sure we restore permission bits after strip operation
	if doStrip:
		os.system("%s -o %s %s" % (options.strip, dstFileName, srcFileName))
		os.system("chmod $(stat --printf '%%a' %s) %s" % (srcFileName, dstFileName))
	else:
		os.system("cp -af %s %s" % (srcFileName, dstFileName))

#===============================================================================
# Makefile banner
# The .SUFFIXES is important to remove all implicit rules.
# There is one which is really, really nasty :
#   a file x is updated from a file x.sh automatically
# Guess what happen when you have both in a folder :
#  the executable is replaced by the script if older...
#===============================================================================
def writeMakefileHeader(options):
	options.makefile.write("# GENERATED FILE, DO NOT MODIFY\n\n")
	options.makefile.write(".SUFFIXES:\n\n")
	if options.strip != None:
		options.makefile.write("STRIP := %s\n" % options.strip)
	options.makefile.write("PWD := $(shell pwd)\n")
	options.makefile.write("ALL :=\n")
	options.makefile.write("ifeq (\"$(V)\",\"0\")\n")
	options.makefile.write("  Q := @\n")
	options.makefile.write("endif\n")
	options.makefile.write(".PHONY: all\n")
	options.makefile.write("all: do-all\n\n")

#===============================================================================
#===============================================================================
def writeMakefileFooter(options):
	options.makefile.write(".PHONY: do-all\n")
	options.makefile.write("do-all: $(ALL)\n\n")

#===============================================================================
# Main function.
#===============================================================================
def main():
	(options, args) = parseArgs()
	setupLog(options)

	# get parameters
	options.stagingDir = args[0]
	options.finalDir = args[1]
	logging.info("staging-dir : %s", options.stagingDir)
	logging.info("final-dir : %s", options.finalDir)

	# do we need to output a makefile ?
	options.makefile = None
	if len(args) >= 3:
		logging.info("makefile : %s", args[2])
		options.makefile = open(args[2], "w")

	# check that staging directory exists
	if not os.path.isdir(options.stagingDir):
		logging.error("%s is not a directory", options.stagingDir)

	if options.makefile != None:
		writeMakefileHeader(options)

	# browse staging directory
	for (dirPath, dirNames, fileNames) in os.walk(options.stagingDir):
		# exclude some directories
		for dirName in EXCLUDE_DIRS:
			if dirName in dirNames:
				logging.debug("Exclude directory : %s",
					os.path.relpath(os.path.join(dirPath, dirName), options.stagingDir))
				dirNames.remove(dirName)

		# create directories (usefull for empty directories)
		for dirName in dirNames:
			srcDirName = os.path.join(dirPath, dirName)
			relPath = os.path.relpath(srcDirName, options.stagingDir)
			dstDirName = os.path.join(options.finalDir, relPath)
			logging.info("Directory : %s", relPath)
			if not os.path.exists(dstDirName):
				os.makedirs(dstDirName, 0755)

		# copy files
		for fileName in fileNames:
			if fileName in EXCLUDE_FILES:
				logging.debug("Exclude file : %s",
					os.path.relpath(os.path.join(dirPath, fileName), options.stagingDir))
				continue
			# skip some extensions
			srcFileName = os.path.join(dirPath, fileName)
			relPath = os.path.relpath(srcFileName, options.stagingDir)
			if os.path.splitext(srcFileName)[1] in EXCLUDE_FILTERS:
				logging.debug("Exclude file : %s", relPath) 
				continue
			logging.info("File : %s", relPath)
			# destination
			dstFileName = os.path.join(options.finalDir, relPath)
			dstDirName = os.path.split(dstFileName)[0]
			if not os.path.exists(dstDirName):
				os.makedirs(dstDirName, 0755)

			# do we need to strip ?
			# FIXME: stripping kernel modules under android causes issues
			doStrip = False
			if options.strip != None \
				and not srcFileName.endswith(".ko") \
				and isExec(srcFileName) \
				and canStrip(srcFileName) \
				and not os.path.islink(srcFileName):
				doStrip = True

			# check if we need to do something
			doAction = False
			if not os.path.exists(dstFileName):
				doAction = True
			elif os.path.islink(srcFileName):
				doAction = True
			else:
				srcStat = os.stat(srcFileName)
				dstStat = os.stat(dstFileName)
				if srcStat.st_mtime > dstStat.st_mtime:
					doAction = True

			# nothing to do if destination is already OK
			if doAction == False:
				continue

			# go
			if options.makefile != None:
				doCopyByMakefile(dstFileName, srcFileName, doStrip, options)
			else:
				doCopy(dstFileName, srcFileName, doStrip, options)

	if options.makefile != None:
		writeMakefileFooter(options)

#===============================================================================
# Setup option parser and parse command line.
#===============================================================================
def parseArgs():
	usage = "usage: %prog [options] <staging-dir> <final-dir> [<makefile>]"
	parser = optparse.OptionParser(usage = usage)
	parser.add_option("--strip",
		dest="strip",
		default=None,
		help="strip program to use to remove symbols")
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

	(options, args) = parser.parse_args()
	if len(args) > 3:
		parser.error("Too many parameters")
	elif len(args) < 2:
		parser.error("Not enough parameters")
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

	# setup log level
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

