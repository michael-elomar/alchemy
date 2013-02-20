#!/usr/bin/env python
#
# @file makefinal.py
# @author Y.M. Morgan
# @date 2012/07/09
#
# Generate the final directory by copying files from staging directory
#
# It also incorporate skeletons and toolchain libraries.
#
# It takes care of resolving links relative to final dir when copying files
# to avoid surprises...

import sys, os, logging
import subprocess
import optparse
import re

#===============================================================================
# Global variables.
#===============================================================================

# Directories to exclude
EXCLUDE_DIRS = [
	".git", ".repo",
	"linux-headers", "include",
	"man", "doc", "html", "info",
	"pkgconfig", "aclocal", "locale"]

# Extension to exclude
EXCLUDE_FILTERS = [".a", ".la", ".py", ".pyc", ".pyo"]

# Files to exclude
EXCLUDE_FILES = [
	".gitignore",
	"Image", "zImage", "bzImage", "uImage", "kernel.plf"]

# Linux folders/links
LINUX_BASIC_SKEL = [
	["debugfs", None],
	["dev", None],
	["home", None],
	["proc", None],
	["sys", None],
	["tmp", None],
]

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
# Resolve links using finalDir as root for absolute path.
#
# Taken from os.path._resolve_link
#===============================================================================
def resolveLink(finalDir, path):
	pathSeen = set()
	while os.path.islink(path):
		if path in pathSeen:
			# Already seen this path, so we must have a symlink loop
			return None
		pathSeen.add(path)
		# Resolve where the link points to
		resolved = os.readlink(path)
		if not os.path.isabs(resolved):
			dir = os.path.dirname(path)
			path = os.path.normpath(os.path.join(dir, resolved))
		elif resolved[0] == "/":
			# Remove leading '/' and join with final dir
			path = os.path.normpath(os.path.join(finalDir, resolved[1:]))
		else:
			# Absolute path not starting with '/' ???
			return None
	return path

#===============================================================================
# Get the realpath of a file by processing links relative to finalDir in case
# they points to absolute path
#
# Taken from os.path.realpath
#===============================================================================
def getRealPath(finalDir, path):
	# First, make it absolute
	if not os.path.isabs(path):
		path = os.path.join(finalDir, path)
	bits = ["/"] + path.split("/")[1:]

	for i in range(2, len(bits) + 1):
		component = os.path.join(*bits[0:i])
		# Resolve symbolic links.
		if os.path.islink(component):
			resolved = resolveLink(finalDir, component)
			if resolved is None:
				# Infinite loop -- return original component + rest of the path
				return os.path.abspath(os.path.join(*([component] + bits[i:])))
			else:
				return getRealPath(finalDir, os.path.join(*([resolved] + bits[i:])))

	return os.path.abspath(path)

#===============================================================================
# Copy a file using a makefile (to do strip in parallel).
#===============================================================================
def doCopyByMakefile(dstFileName, srcFileName, doStrip, options):
	srcFileNameEsc = srcFileName
	dstFileNameEsc = dstFileName
	# if source file contains ' ', ':' or '=' it doesn't work great
	# prerequisite shall be escaped
	# target can not contain at all any ' ', ':' or '=' so replace with '_'
	# in command do not use target name as it will be wrong
	# consequence is that target will never actually exists and commands
	# will always be executed
	if srcFileNameEsc.find(" ") >= 0:
		srcFileNameEsc = srcFileNameEsc.replace(" ", "\\ ")
		dstFileNameEsc = dstFileNameEsc.replace(" ", "_")
	if srcFileNameEsc.find(":") >= 0:
		srcFileNameEsc = srcFileNameEsc.replace(":", "\\:")
		dstFileNameEsc = dstFileNameEsc.replace(":", "_")
	if srcFileNameEsc.find("=") >= 0:
		srcFileNameEsc = srcFileNameEsc.replace("=", "\\=")
		dstFileNameEsc = dstFileNameEsc.replace("=", "_")

	# register destination in ALL variable
	options.makefile.write("ALL += %s\n" % dstFileNameEsc)

	# rule
	options.makefile.write("%s: %s\n" % (dstFileNameEsc, srcFileNameEsc))

	# commands, see doCopy for more info
	options.makefile.write("\t@mkdir -p \"%s\"\n" % os.path.dirname(dstFileName))
	options.makefile.write("\t@echo Alchemy install: %s\n" % os.path.relpath(dstFileName))
	if doStrip:
		options.makefile.write("\t$(Q)$(STRIP) -o \"%s\" \"%s\"\n" % \
			(dstFileName, srcFileName))
		options.makefile.write("\t$(Q)chmod $$(stat --printf '%%a' \"%s\") \"%s\"" % \
			(srcFileName, dstFileName))
	else:
		options.makefile.write("\t$(Q)cp -af \"%s\" \"%s\"\n" % \
			(srcFileName, dstFileName))
	options.makefile.write("\n")

#===============================================================================
# Copy a file by directly making a copy.
#===============================================================================
def doCopyDirect(dstFileName, srcFileName, doStrip, options):
	# copy and strip executables
	# make sure we restore permission bits after strip operation
	if doStrip:
		os.system("%s -o \"%s\" \"%s\"" % (options.strip, dstFileName, srcFileName))
		os.system("chmod $(stat --printf '%%a' \"%s\") \"%s\"" % (srcFileName, dstFileName))
	else:
		os.system("cp -af \"%s\" \"%s\"" % (srcFileName, dstFileName))

#===============================================================================
# Copy a file/link.
#===============================================================================
def doCopy(dstFileName, srcFileName, options):
	relPath = os.path.relpath(dstFileName, options.finalDir)

	# do we need to strip ?
	# FIXME: stripping kernel modules under android causes issues
	doStrip = False
	if options.strip != None \
		and not os.path.islink(srcFileName) \
		and not srcFileName.endswith(".ko") \
		and isExec(srcFileName) \
		and canStrip(srcFileName):
		doStrip = True

	# check if we need to do something, do not follow symlinks
	doAction = False
	if not os.path.lexists(dstFileName):
		doAction = True
	elif not os.path.islink(srcFileName):
		srcStat = os.stat(srcFileName)
		dstStat = os.stat(dstFileName)
		if srcStat.st_mtime > dstStat.st_mtime:
			doAction = True

	# nothing to do if destination is already OK
	if doAction == False:
		return
	if os.path.islink(srcFileName):
		logging.info("Link : %s", relPath)
	else:
		logging.info("File : %s", relPath)

	# make sure destination directory exists
	dstDirName = os.path.split(dstFileName)[0]
	if not os.path.exists(dstDirName):
		os.makedirs(dstDirName, 0755)

	# do the copy by wanted method
	if options.makefile != None and not os.path.islink(srcFileName):
		doCopyByMakefile(dstFileName, srcFileName, doStrip, options)
	else:
		doCopyDirect(dstFileName, srcFileName, doStrip, options)

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
	options.makefile.write("V ?= 0\n")
	options.makefile.write("ifeq (\"$(V)\",\"0\")\n")
	options.makefile.write("  Q := @\n")
	options.makefile.write("endif\n")
	options.makefile.write(".PHONY: all\n")
	options.makefile.write("all: do-all\n\n")

#===============================================================================
# Makefile footer.
#===============================================================================
def writeMakefileFooter(options):
	options.makefile.write(".PHONY: do-all\n")
	options.makefile.write("do-all: $(ALL)\n\n")

#===============================================================================
# Process a directory and copy dirs/files to final directory.
#===============================================================================
def processDir(rootDir, options, withEmptyDir):
	for (dirPath, dirNames, fileNames) in os.walk(rootDir):
		# exclude some directories
		for dirName in EXCLUDE_DIRS:
			if dirName in dirNames:
				logging.debug("Exclude directory : %s",
					os.path.relpath(os.path.join(dirPath, dirName), rootDir))
				dirNames.remove(dirName)

		# create directories (usefull for empty directories)
		if withEmptyDir:
			for dirName in dirNames:
				srcDirName = os.path.join(dirPath, dirName)
				relPath = os.path.relpath(srcDirName, rootDir)
				dstDirName = getRealPath(options.finalDir, relPath)
				if not os.path.exists(dstDirName):
					logging.info("Directory : %s", relPath)
					os.makedirs(dstDirName, 0755)

		# copy files
		for fileName in fileNames:
			if fileName in EXCLUDE_FILES:
				logging.debug("Exclude file : %s",
					os.path.relpath(os.path.join(dirPath, fileName), rootDir))
				continue
			# skip some extensions
			srcFileName = os.path.join(dirPath, fileName)
			relPath = os.path.relpath(srcFileName, rootDir)
			if os.path.splitext(srcFileName)[1] in EXCLUDE_FILTERS:
				logging.debug("Exclude file : %s", relPath) 
				continue
			# go
			dstFileName = getRealPath(options.finalDir, relPath)
			doCopy(dstFileName, srcFileName, options)

#===============================================================================
# Process toolchain libc directory.
#===============================================================================
def processToolchainLibc(libcDir, options):

	# copy name with .so from 'lib' directory
	libDir = os.path.join(libcDir, "lib")
	for fileName in os.listdir(libDir):
		if re.match(r".*\.so.*", fileName):
			srcFileName = os.path.join(libDir, fileName)
			relPath = os.path.relpath(srcFileName, libcDir)
			dstFileName = getRealPath(options.finalDir, relPath)
			doCopy(dstFileName, srcFileName, options)

	# copy 'libstdc++' from 'usr/lib' directory
	usrLibDir = os.path.join(libcDir, "usr/lib")
	for fileName in os.listdir(usrLibDir):
		if re.match(r"libstdc\+\+.*\.so.*", fileName):
			srcFileName = os.path.join(usrLibDir, fileName)
			relPath = os.path.relpath(srcFileName, libcDir)
			dstFileName = getRealPath(options.finalDir, relPath)
			doCopy(dstFileName, srcFileName, options)

#===============================================================================
# Process linux basic skel.
#===============================================================================
def processLinuxBasicSkel(options):
	for entry in LINUX_BASIC_SKEL:
		if entry[1] == None:
			dstDirName = getRealPath(options.finalDir, entry[0])
			if not os.path.exists(dstDirName):
				logging.info("Directory : %s", entry[0])
				os.makedirs(dstDirName, 0755)
		else:
			dstLnkName = getRealPath(options.finalDir, entry[0])
			logging.info("Link : %s", entry[0])
			os.system("ln -sf \"%s\" \"%s\"" % (entry[1], dstLnkName))

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

	# process staging directory (without empty dirs)
	processDir(options.stagingDir, options, False)

	# process skeleton directory (with empty dirs)
	for skelDir in options.skelDirs:
		processDir(skelDir, options, True)

	# process libc  directory
	if options.toolchainLibcDir != None:
		processToolchainLibc(options.toolchainLibcDir, options)

	# process gdbserver binary
	if options.toolchainGdbserverName:
		doCopy(getRealPath(options.finalDir, "usr/bin/gdbserver"),
			options.toolchainGdbserverName, options)

	# process linux basic skel
	if options.linuxBasicSkel:
		processLinuxBasicSkel(options)

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
	parser.add_option("--skel",
		dest="skelDirs",
		default=[],
		action="append",
		help="path to skeleton tree to merge in final tree")
	parser.add_option("--toolchain-libc",
		dest="toolchainLibcDir",
		default=None,
		help="path to toolchain libc directory to merge in final tree")
	parser.add_option("--toolchain-gdbserver",
		dest="toolchainGdbserverName",
		default=None,
		help="path to toolchain gdbserver binary to merge in final tree")
	parser.add_option("--linux-basic-skel",
		dest="linuxBasicSkel",
		action="store_true",
		default=False,
		help="Create a basic linux skel (proc, dev, tmp...)")
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
