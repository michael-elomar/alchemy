#!/usr/bin/env python

import sys, os, logging
import platform
import subprocess
import optparse
import tempfile
import re
import signal
import shutil

# Full path to this script
SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))

# 32-bit or 64-bit ?
ARCH = "x64" if (platform.architecture()[0] == "64bit") else "x86"

# Possible actions
ACTION_CHECK = "check"
ACTION_UPDATE = "update"
ACTION_CONFIG = "config"
ACTIONS = [ACTION_CHECK, ACTION_UPDATE, ACTION_CONFIG]

# Possible user interfaces
UIS = ["qconf", "mconf", "nconf"]

# Field separator in argument
ARG_FIELD_SEP = ":"

# Suffix for temp files
TEMP_SUFFIX = ".alchemy"

# Path to kconfig binaries
KCONFIG_BIN_DIR = os.path.join(SCRIPT_PATH, "kconfig/bin-linux-" + ARCH)

# Title we wand to display (also saved in config files)
KCONFIG_TITLE = "Alchemy Configuration"

#===============================================================================
# Encapsulate module information.
#===============================================================================
class Module:
	def __init__(self, arg):
		fields = arg.split(ARG_FIELD_SEP)
		self.name = ""
		self.configPath = ""
		self.configInPathList = []
		if len(fields) > 0:
			self.name = fields[0]
		if len(fields) > 1:
			self.configPath = fields[1]
		if len(fields) > 2:
			self.configInPathList = fields[2:]

#===============================================================================
# Expand a list of string as a string with items separated by comma.
#===============================================================================
def expandListStr(itemList):
	res = ""
	for item in itemList:
		res += item if (len(res) == 0) else (", " + item)
	return res

#===============================================================================
# Get the define value of a name. '-' are replaced by '_' then to upper case.
#===============================================================================
def getDefine(name):
	return name.replace("-", "_").upper()

#===============================================================================
# Print a message to stdout.
#===============================================================================
def message(msg, *args):
	sys.stdout.write(msg % args + "\n")

#===============================================================================
# Delete a file, silently ignoring error if it does not exists.
# path : file path to delete
#===============================================================================
def safeUnlink(path):
	try:
		os.unlink(path)
	except OSError:
		pass

#===============================================================================
# Rename a file, taking into account the fact that under Windows destination
# shall not exits to succeed.
# old : old path.
# new : new path.
#===============================================================================
def safeRename(old, new):
	if platform.system() == "Windows" and os.path.exists(new):
		safeUnlink(new)
	os.rename(old, new)

#===============================================================================
# Get the path to use for config edition.
# path : original config path.
#===============================================================================
def getEditConfigPath(origPath):
	return origPath + ".new"

#===============================================================================
# Get the path to use for config diff.
# path : original config path.
#===============================================================================
def getDiffConfigPath(origPath):
	return origPath + ".diff"

#===============================================================================
# Write a 'diff' file.
# path1 : first file to compare.
# path2 : second file to compare.
# diffPath : file path to resulting 'diff' file.
#===============================================================================
def writeDiff(path1, path2, diffPath):
	os.system("diff -u %s %s > %s" % (path1, path2, diffPath))

#===============================================================================
# Write a 'diff' file of a configuration afeter edition.
# configPath : original config path.
#===============================================================================
def writeDiffConfig(configPath):
	writeDiff(configPath, getEditConfigPath(configPath),
		getDiffConfigPath(configPath))

#===============================================================================
# Find a module by its define name.
# modules : list of modules to search.
# moduleDefine : name of module to find in its 'define' form.
#===============================================================================
def findModule(modules, moduleDefine):
	for module in modules:
		if getDefine(module.name) == moduleDefine:
			return module
	return None

#===============================================================================
# Write the config.in file for a module.
# outFile : output file object.
# module : module to generate.
#===============================================================================
def writeModuleConfigIn(outFile, module):
	outFile.write("menu '%s'\n" % module.name)
	if len(module.configInPathList) > 0:
		for configInPath in module.configInPathList:
			outFile.write("source %s\n" % configInPath)
	outFile.write("endmenu\n")

#===============================================================================
# Write the config.in file for the full configuration.
# outFile : output file object.
# module : list of modules.
#===============================================================================
def writeFullConfigIn(outFile, modules):
	for module in modules:
		buildDefine = "ALCHEMY_BUILD_" + getDefine(module.name)
		if len(module.configInPathList) > 0:
			outFile.write("menuconfig %s\n" % buildDefine)
		else:
			outFile.write("config %s\n" % buildDefine)

		outFile.write("  bool '%s'\n" % module.name)
		outFile.write("  default y\n")
		outFile.write("  help\n")
		outFile.write("    Build %s\n" % module.name)
		outFile.write("\n")

		if len(module.configInPathList) > 0:
			outFile.write("if %s\n" % buildDefine)
			outFile.write("\n")
			outFile.write("config ALCHEMY_FILE_%s\n" % getDefine(module.name))
			outFile.write("  string\n")
			outFile.write("  default '%s'\n" % module.configPath)
			outFile.write("\n")
			for configInPath in module.configInPathList:
				outFile.write("source %s\n" % configInPath)
			outFile.write("\n")
			outFile.write("endif\n")
			outFile.write("\n")

#===============================================================================
# Write the header of the config file.
# outFile : output file object.
# module : optional module this config belongs.
#===============================================================================
def writeConfigHeader(outFile, module=None):
	outFile.write("#\n")
	outFile.write("# Automatically generated file; DO NOT EDIT.\n")
	outFile.write("# %s\n" % KCONFIG_TITLE)
	outFile.write("#\n")

	# Add module name if given. Required because we add an extra menu entry
	# when editing a single module (see writeModuleConfigIn)
	if module != None:
		outFile.write("\n")
		outFile.write("#\n")
		outFile.write("# %s\n" % module.name)
		outFile.write("#\n")

#===============================================================================
# Copy configuration file to '.new' file for edition.
# configName : configuration file name to copy.
#===============================================================================
def prepareConfig(configPath):
	if os.path.exists(configPath):
		shutil.copy(configPath, getEditConfigPath(configPath))

#===============================================================================
# Prepare a module config file for edition.
# module : module to prepare.
#===============================================================================
def prepareModuleConfig(module):
	prepareConfig(module.configPath)

#===============================================================================
# Prepare the full configuration for edition.
# outFile : output file object.
# modules : list of modules to edit.
# mainConfigPath : main config path.
#===============================================================================
def prepareFullConfig(outFile, modules, mainConfigPath):
	# Read main configuration file
	mainConfig = []
	try:
		mainConfigFile = open(mainConfigPath, "r")
		mainConfig = mainConfigFile.read().split("\n")
		mainConfigFile.close()
	except IOError as ex:
		logging.error("Unable to open file: %s [err=%d %s]",
			mainConfigPath, ex.errno, ex.strerror)

	# Write header followed by modules
	writeConfigHeader(outFile)
	for module in modules:
		moduleBuildDefine = "CONFIG_ALCHEMY_BUILD_" + getDefine(module.name)
		moduleBuildDefineSet = moduleBuildDefine + "=y"
		moduleBuildDefineNotSet = "# " + moduleBuildDefine + " is not set"
		# Determine if module is set or not
		if moduleBuildDefineNotSet in mainConfig >= 0:
			outFile.write(moduleBuildDefineNotSet + "\n")
		else:
			# Only write the module as set it it was before
			if moduleBuildDefineSet in mainConfig >= 0:
				outFile.write(moduleBuildDefineSet + "\n")
			# However, always write module configuration
			# (if some can be configured though)
			if len(module.configInPathList) > 0:
				moduleFileDefine = "CONFIG_ALCHEMY_FILE_" + getDefine(module.name)
				outFile.write("%s=\"%s\"\n" % (moduleFileDefine, module.configPath))
				# Read module configuration file
				moduleConfig = []
				try:
					moduleConfigFile = open(module.configPath, "r")
					moduleConfig = moduleConfigFile.read().split("\n")
					moduleConfigFile.close()
				except IOError as ex:
					logging.error("Unable to open file: %s [err=%d %s]",
						module.configPath, ex.errno, ex.strerror)
				# Skip the 8 first lines, as well as empty last line
				# (header + extra menu added by generateModuleConfigIn)
				lastEmpty = (len(moduleConfig) > 0 and len(moduleConfig[-1]) == 0)
				for line in (moduleConfig[8:-1] if lastEmpty else moduleConfig[8:]):
					outFile.write(line + "\n")

#===============================================================================
# Process ful configuration after its edition.
# inFile : input file object.
# modules : list of modules.
# mainConfigPath : main config path.
#===============================================================================
def processFullConfig(inFile, modules, mainConfigPath):
	logging.debug("Processing full config")

	reConfigBuild = re.compile(r"(# )?CONFIG_ALCHEMY_BUILD_([^= ]*)[= ].*")

	# Create main configuration file
	try:
		mainConfigFile = open(getEditConfigPath(mainConfigPath), "w")
	except IOError as ex:
		logging.error("Unable to create file: %s [err=%d %s]",
			getEditConfigPath(mainConfigPath), ex.errno, ex.strerror)
		return
	writeConfigHeader(mainConfigFile)

	module = None
	moduleConfigFile = None

	lineIdx = 0
	for line in inFile:
		line = line.rstrip("\n")
		# Determine if we are starting a new module
		if line.startswith("# CONFIG_ALCHEMY_BUILD_") \
				or line.startswith("CONFIG_ALCHEMY_BUILD_"):
			mainConfigFile.write(line + "\n")
			match = reConfigBuild.match(line)
			if match == None:
				logging.warning("Unable to extract module name from: %s", line)
			else:
				module = findModule(modules, match.group(2))
				if module == None:
					logging.warning("Unknown module: %s", match.group(2))
				else:
					logging.debug("New module: %s", module.name)
			if moduleConfigFile != None:
				moduleConfigFile.close()
			moduleConfigFile = None
		# Get the name of the configuration file for the module
		elif line.startswith("CONFIG_ALCHEMY_FILE_"):
			if moduleConfigFile != None:
				moduleConfigFile.close()
			moduleConfigFile = None
			idx = line.find("=")
			if idx >= 0:
				moduleConfigPath = line[idx+1:].strip("\"\'")
				logging.debug("New module config: %s", moduleConfigPath)
				try:
					moduleConfigFile = open(getEditConfigPath(moduleConfigPath), "w")
					writeConfigHeader(moduleConfigFile, module)
				except IOError as ex:
					logging.error("Unable to create file: %s [err=%d %s]",
						getEditConfigPath(moduleConfigPath), ex.errno, ex.strerror)
		elif moduleConfigFile != None:
			moduleConfigFile.write(line + "\n")
		# The 4 first lines are the header, and are silently skipped
		elif lineIdx >= 4:
			logging.warning("Skipping line: %s", line)
		lineIdx += 1

	mainConfigFile.close()
	if moduleConfigFile != None:
		moduleConfigFile.close()

#===============================================================================
# Check if a configuration is up to date.
# name : name to display in log messages.
# configPath : current configuration name.
# return True if config is up to date, False otherwise.
#===============================================================================
def checkConfig(name, configPath):
	logging.debug("Checking %s config: %s", name, configPath)

	# Try to open new configuration file
	# If no new file, assume configuration is up to date
	try:
		newFile = open(getEditConfigPath(configPath), "r")
	except IOError:
		logging.debug("New %s config does not exist", name)
		return True

	# Try to open current configuration file
	# If no current file, assume configuration is not up to date
	try:
		currentFile = open(configPath, "r")
	except IOError:
		logging.debug("Current %s config does not exist", name)
		newFile.close()
		return False

	# Read content, close files and Compare content
	newContent = newFile.read()
	currentContent = currentFile.read()
	newFile.close()
	currentFile.close()
	result = (newContent == currentContent)
	logging.debug("%s config is %s", name, "up to date" if result else "old")
	return result

#===============================================================================
# Update a configuration.
# name : name to display in log messages.
# configPath : current configuration name.
#===============================================================================
def updateConfig(name, configPath):
	logging.debug("Updating %s config: %s", name, configPath)

	# Check configuration
	if checkConfig(name, configPath):
		# Delete new configuration
		logging.debug("Delete new %s config", name)
		safeUnlink(getEditConfigPath(configPath))
	else:
		# Move new configuration
		logging.debug("Move new %s config", name)
		safeRename(getEditConfigPath(configPath), configPath)
		message("%s config updated: %s", name, configPath)

#===============================================================================
# Check a module config.
# module : module to check.
# doWriteDiff : True to write a diff file in case of config mismatch.
# return True if config is up to date, False otherwise.
#===============================================================================
def checkModuleConfig(module, doWriteDiff):
	# Skip modules with nothing configurable
	if len(module.configInPathList) == 0:
		return True
	result = checkConfig(module.name, module.configPath)
	if not result and doWriteDiff:
		message("%s config is old, see diff in: %s",
			module.name, getDiffConfigPath(module.configPath))
		writeDiffConfig(module.configPath)
	elif not result:
		message("%s config is old", module.name)
	logging.debug("Delete %s", getEditConfigPath(module.configPath))
	safeUnlink(getEditConfigPath(module.configPath))
	return result

#===============================================================================
# Update a module config.
# module : module to update.
#===============================================================================
def updateModuleConfig(module):
	# Skip modules with nothing configurable
	if len(module.configInPathList) == 0:
		return
	updateConfig(module.name, module.configPath)

#===============================================================================
# Check the main config.
# mainConfigPath : main config path.
# doWriteDiff : True to write a diff file in case of config mismatch.
# return True if config is up to date, False otherwise.
#===============================================================================
def checkMainConfig(mainConfigPath, doWriteDiff):
	result = checkConfig("main", mainConfigPath)
	if not result and doWriteDiff:
		message("%s config is old, see diff in: %s",
			"main", getDiffConfigPath(mainConfigPath))
		writeDiffConfig(mainConfigPath)
	elif not result:
		message("%s config is old", "main")
	logging.debug("Delete %s", getEditConfigPath(mainConfigPath))
	safeUnlink(getEditConfigPath(mainConfigPath))
	return result

#===============================================================================
# Update the main config.
# mainConfigPath : main config path.
#===============================================================================
def updateMainConfig(mainConfigPath):
	updateConfig("main", mainConfigPath)

#===============================================================================
# Check the full config.
# modules : list of modules to check.
# mainConfigPath : main config path.
# doWriteDiff : True to write a diff file in case of config mismatch.
# return True if config is up to date, False otherwise.
#===============================================================================
def checkFullConfig(modules, mainConfigPath, doWriteDiff):
	logging.debug("Checking full config")
	result = True

	# Check everything
	result = checkMainConfig(mainConfigPath, doWriteDiff) and result
	for module in modules:
		result = checkModuleConfig(module, doWriteDiff) and result
	return result

#===============================================================================
# Update the full config.
# modules : list of modules to update.
# mainConfigPath : main config path.
#===============================================================================
def updateFullConfig(modules, mainConfigPath):
	logging.debug("Updating full config")

	# Update everything
	updateMainConfig(mainConfigPath)
	for module in modules:
		updateModuleConfig(module)

#===============================================================================
# Execute 'conf' to silently update a configuration.
# configInPath : path to 'config.in' file.
# configPath : path to '.config' file.
#===============================================================================
def execConf(configInPath, configPath):
	logging.info("Executing conf %s %s", configInPath, configPath)

	# Construct command line, simulate accepting all new options to their
	# default values by piping 'yes' as input
	cmdline = "yes \"\" | %s --oldconfig %s" % \
		(os.path.join(KCONFIG_BIN_DIR, "conf"), configInPath)

	# Setup environment
	# KCONFIG_CONFIG : name of .config file to use as input/ouput
	# KCONFIG_OVERWRITECONFIG : do not create .old file
	# KCONFIG_TITLE : set title (also saved in config file)
	env = os.environ
	env["KCONFIG_CONFIG"] = configPath
	env["KCONFIG_OVERWRITECONFIG"] = "1"
	env["KCONFIG_TITLE"] = KCONFIG_TITLE

	# Execute command in silence (stdout/stderr redirected and not used)
	try:
		process = subprocess.Popen(cmdline,
			stdout=subprocess.PIPE,
			stderr=subprocess.PIPE,
			shell=True, env=env)
		process.communicate()
		if process.returncode != 0:
			logging.error("%s failed with status %d", cmdline, process.returncode)
	except OSError as ex:
		logging.error("Unable to execute command: %s [err=%d %s]",
			cmdline, ex.errno, ex.strerror)

#===============================================================================
# Execute 'xconf' to edit a configuration in a user interface.
# confUi : user interface program to use.
# configInPath : path to 'config.in' file.
# configPath : path to '.config' file.
#===============================================================================
def execConfUi(confUi, configInPath, configPath):
	logging.info("Executing %s %s %s", confUi, configInPath, configPath)

	# Construct command line
	cmdline = "%s %s" % \
		(os.path.join(KCONFIG_BIN_DIR, confUi), configInPath)

	# Setup environment
	# KCONFIG_CONFIG : name of .config file to use as input/ouput
	# KCONFIG_OVERWRITECONFIG : do not create .old file
	# KCONFIG_TITLE : set title (also saved in config file)
	env = os.environ
	env["KCONFIG_CONFIG"] = configPath
	env["KCONFIG_OVERWRITECONFIG"] = "1"
	env["KCONFIG_TITLE"] = KCONFIG_TITLE

	# Execute command (we can not redirect input/output in case UI
	# is mconf or nconf)
	try:
		process = subprocess.Popen(cmdline,
			shell=True, env=env)
		process.communicate()
		if process.returncode != 0:
			logging.error("%s failed with status %d", cmdline, process.returncode)
	except OSError as ex:
		logging.error("Unable to execute command: %s [err=%d %s]",
			cmdline, ex.errno, ex.strerror)

#===============================================================================
# Main function.
#===============================================================================
def main():
	result = True
	(options, args) = parseArgs()
	setupLog(options)

	# Extract arguments
	action = args[0]
	modules = []
	for arg in args[1:]:
		modules.append(Module(arg))

	# If only one module, check it has some configuration data
	if options.main == None:
		if len(modules[0].configInPathList) == 0:
			message("Nothing to do for %s" % modules[0].name)
			sys.exit(0)

	# Create 'config.in' file
	(configInFd, configInPath) = tempfile.mkstemp(suffix=TEMP_SUFFIX)
	configInFile = os.fdopen(configInFd, "w")
	if options.main == None:
		logging.info("Generating %s 'config.in' file as %s",
			 modules[0].name, configInPath)
		writeModuleConfigIn(configInFile, modules[0])
	else:
		logging.info("Generating full 'config.in' file as %s", configInPath)
		writeFullConfigIn(configInFile, modules)
	configInFile.close()

	# prepare input config file
	if options.main == None:
		moduleEditConfigPath = getEditConfigPath(modules[0].configPath)
		prepareModuleConfig(modules[0])
	else:
		# Create full '.config' file
		(fullConfigFd, fullConfigPath) = tempfile.mkstemp(suffix=TEMP_SUFFIX)
		fullConfigFile = os.fdopen(fullConfigFd, "w")
		logging.info("Generating full '.config' file as %s", fullConfigPath)
		prepareFullConfig(fullConfigFile, modules, options.main)
		fullConfigFile.close()

	# Cleanup function (in main context)
	def cleanup():
		logging.info("Cleanup before exit")
		# Delete temp files
		safeUnlink(configInPath)
		if options.main != None:
			safeUnlink(fullConfigPath)
		# Delete all module edition files
		for module in modules:
			if len(module.configInPathList) > 0:
				safeUnlink(getEditConfigPath(module.configPath))

	# signal handler (in main context)
	def signalHandler(sig, frame):
		logging.info("Signal %d caught", sig)
		cleanup()
		sys.exit(1)

	# Register signals to cleanup in case we are interrupted below
	signal.signal(signal.SIGINT, signalHandler)
	signal.signal(signal.SIGTERM, signalHandler)

	# Configure only one module config
	if options.main == None:
		# Display UI or execute action in silence
		if action == ACTION_CONFIG:
			execConfUi(options.ui, configInPath, moduleEditConfigPath)
		else:
			execConf(configInPath, moduleEditConfigPath)
		# Check/Update result
		if action == ACTION_CHECK:
			result = checkModuleConfig(modules[0], options.diff)
		else:
			updateModuleConfig(modules[0])
	# Configure the full config
	else:
		# Display UI or execute action in silence
		if action == ACTION_CONFIG:
			execConfUi(options.ui, configInPath, fullConfigPath)
		else:
			execConf(configInPath, fullConfigPath)
		# Process resulting full config
		configFullFile = open(fullConfigPath, "r")
		processFullConfig(configFullFile, modules, options.main)
		configFullFile.close()
		# Check/Update result
		if action == ACTION_CHECK:
			result = checkFullConfig(modules, options.main, options.diff)
		else:
			updateFullConfig(modules, options.main)

	# Do some cleanup and then exit with status=1 in case checking failed 
	cleanup()
	sys.exit(0 if result else 1)

#===============================================================================
# Setup option parser and parse command line.
#===============================================================================
def parseArgs():
	# Setup parser
	usage = "usage: %prog [options] <action> <modules>..."
	parser = optparse.OptionParser(usage=usage)

	# Main options
	parser.add_option("--main",
		dest="main",
		action="store",
		default=None,
		metavar="FILE",
		help="Name of main configuration file")
	parser.add_option("--diff",
		dest="diff",
		action="store_true",
		default=False,
		help="Write diff file if configuration is not up to date after check")
	parser.add_option("--ui",
		dest="ui",
		default="qconf",
		help="User interface to use: %s [default: %%default]" % expandListStr(UIS))

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
	if len(args) < 1:
		parser.error("Missing action")
	elif len(args) < 2:
		parser.error("At least one module required")
	elif args[0] not in ACTIONS:
		parser.error("Bad action: %s (%s)" %(args[0], expandListStr(ACTIONS)))
	elif len(args) > 2 and options.main == None:
		parser.error("Main configuration file required if more than one module")
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
