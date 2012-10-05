#!/usr/bin/env python
#
# @file make-final.py
# @author Y.M. Morgan
# @date 2012/07/09
#
# Generate the final directory by copying files from staging directories
# 

import sys, os, logging
import subprocess
import optparse
import shutil

#===============================================================================
# Global variables.
#===============================================================================

# Directories to exclude
EXCLUDE_DIRS = ["include", "man"]

# Extension to exclude
EXCLUDE_FILTERS = [".a", ".la"]

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
# Main function.
#===============================================================================
def main():
	(options, args) = parseArgs()
	setupLog(options)

	# get parameters
	stagingDir = args[0]
	finalDir = args[1]
	logging.info("staging-dir : %s", stagingDir)
	logging.info("final-dir : %s", finalDir)

	# do we need to output a makefile ?
	makefile = None
	if len(args) >= 3:
		logging.info("makefile : %s", args[2])
		makefile = open(args[2], "w")

	# check that staging directory exists
	if not os.path.isdir(stagingDir):
		logging.error("%s is not a directory", stagingDir)

	# Makefile banner
	# The .SUFFIXES is important to remove all impicit rules.
	# There is one which is really, really nasty :
	#   a file x is updated from a file x.sh automatically
	# Guess what happen when you have both in a folder :
	#  the executable is replace by the script if older...
	if makefile != None:
		makefile.write("# GENERATED FILE, DO NOT MODIFY\n\n")
		makefile.write(".SUFFIXES:\n\n")
		if options.strip != None:
			makefile.write("STRIP := %s\n" % options.strip)
		makefile.write("PWD := $(shell pwd)\n")
		makefile.write("ALL :=\n")
		makefile.write("ifneq (\"$(V)\",\"1\")\n")
		makefile.write("  Q := @\n")
		makefile.write("endif\n")
		makefile.write(".PHONY: all\n")
		makefile.write("all: do-all\n\n")

	# browse staging directory
	for (dirPath, dirNames, fileNames) in os.walk(stagingDir):
		# exclude some directories
		for dirName in EXCLUDE_DIRS:
			if dirName in dirNames:
				logging.debug("Exclude directory : %s",
					os.path.relpath(os.path.join(dirPath, dirName), stagingDir))
				dirNames.remove(dirName)
		for fileName in fileNames:
			# skip dome extensions
			srcFileName = os.path.join(dirPath, fileName)
			relPath = os.path.relpath(srcFileName, stagingDir)
			if os.path.splitext(srcFileName)[1] in EXCLUDE_FILTERS:
				logging.debug("Exclude file : %s", relPath) 
				continue
			logging.info("File : %s", relPath)
			# destination
			dstFileName = os.path.join(finalDir, relPath)
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
			if makefile != None:
				# if source file contains ':' or '=' it doesn't work great
				# prerequisite shall be escaped
				# target can not contain at all  any ':' or '=' so replace with '_'
				# in command do not use target name as it will be wrong
				# consequence is that target will never actually exists and commands
				# will always be executed
				patched = True
				if srcFileName.find(":") >= 0:
					srcFileName = srcFileName.replace(":", "\\:")
					srcFileName = srcFileName.replace("=", "\\=")
					dstFileName = dstFileName.replace(":", "_")
					dstFileName = dstFileName.replace("=", "_")

				# register destination in ALL variable
				makefile.write("ALL += %s\n" % dstFileName)

				# rule
				makefile.write("%s: %s\n" % (dstFileName, srcFileName))

				# define variables with real src and dst (in case it was patched above)
				makefile.write("\t$(eval __src := $<)\n")
				makefile.write("\t$(eval __dst := $(patsubst %s/%%,%s/%%,$<))\n" % \
					(stagingDir, finalDir))

				# commands
				makefile.write("\t@mkdir -p $(dir $(__dst))\n")
				makefile.write("\t@echo Alchemy install: $(patsubst $(PWD)/%,%,$(__dst))\n")
				if doStrip:
					makefile.write("\t$(Q)$(STRIP) -o $(__dst) $(__src)\n")
				else:
					makefile.write("\t$(Q)cp -af $(__src) $(__dst)\n")
				makefile.write("\n")
			else:
				# copy and strip executables
				if doAction:
					if doStrip:
						os.system("%s -o %s %s" % (options.strip, dstFileName, srcFileName))
					else:
						shutil.copy2(srcFileName, dstFileName)

	if makefile != None:
		makefile.write(".PHONY: do-all\n")
		makefile.write("do-all: $(ALL)\n\n")

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

