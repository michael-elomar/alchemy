#!/bin/sh

export KCONFIG_NOTIMESTAMP=1
readonly SCRIPT_PATH=$(cd $(dirname $0) && pwd)

# 32-bit or 64-bit ?
file ${SHELL} | grep '64-bit' 2> /dev/null 1>&2
if [ "$?" = "0" ]; then
	readonly ARCH=x64
else
	readonly ARCH=x86
fi

readonly CONF_BIN="${SCRIPT_PATH}/kconfig/bin-linux-${ARCH}/conf"
readonly QCONF_BIN="${SCRIPT_PATH}/kconfig/bin-linux-${ARCH}/qconf"

tmpConfigDir=""
tmpConfigFile=""

# Command line options
optArgCount=0
optQuiet=0
optVerbose=0
optHelp=0
optAction=""
optConfigInFile=""
optConfigFile=""
optDiffFile=""

#===============================================================================
# Logging functions.
#===============================================================================
LOGC() echo "[C]"$*
LOGE() if [ ${optQuiet} -ne 1 ]; then echo "[E]"$*; fi
LOGW() if [ ${optQuiet} -ne 1 ]; then echo "[W]"$*; fi
LOGI() if [ ${optQuiet} -ne 1 -a ${optVerbose} -ge 1 ]; then echo "[I]"$*; fi
LOGD() if [ ${optQuiet} -ne 1 -a ${optVerbose} -ge 2 ]; then echo "[D]"$*; fi

#===============================================================================
# Usage.
#===============================================================================
usage()
{
	echo "usage : $0 [options] <action> <configInFile> <configFile> [<diffFile>]"
	echo "  -q : be quiet"
	echo "  -v : be verbose (more verbose if specified twice)"
	echo "  -h : print this help message and exit"
	echo " <action>       : action to execute (check|update|config)"
	echo " <configInFile> : config.in input file"
	echo " <configFile>   : configuration file to use for given action"
	echo " <diffFile>     : file where to append diff during check"
}

#===============================================================================
# Begin conf/qconf by copying configuration file to a temp .config file.
# $1 : configuration file.
#===============================================================================
beginConf()
{
	local configFile="$1"

	# Create a temp directory
	tmpConfigDir=$(mktemp --directory)
	LOGD "Created temp directory : ${tmpConfigDir}"

	# Copy given config file and preserve date/time
	tmpConfigFile="${tmpConfigDir}/.config"
	if [ -f "${configFile}" ]; then
		cp -pf "${configFile}" "${tmpConfigFile}"
		LOGD "${configFile} copied to ${tmpConfigFile}"
	else
		LOGW "${configFile} is not a valid file"
	fi
}

#===============================================================================
# End conf/qconf by copying temp .config file to configuration file.
# $1 : configuration file.
#===============================================================================
endConf()
{
	local configFile="$1"

	# Copy and preserve date/time
	if [ -f "${tmpConfigFile}" ]; then
		cp -pf "${tmpConfigFile}" "${configFile}"
		LOGD "${tmpConfigFile} copied to ${configFile}"
	else
		LOGW "${tmpConfigFile} is not a valid file"
	fi

	# Cleanup temp directory
	rm -rf "${tmpConfigDir}"
	LOGD "Deleted temp directory : ${tmpConfigDir}"
}

#===============================================================================
# Execute qconf/conf.
# $1 : executable to launch
# $2 : Config.in file.
# $3 : options.
#===============================================================================
execConf()
{
	local exe="$1"
	local configInFile="$2"
	local options="$3"

	# Change directory before executing command but restore it afterward (subshell execution)
	(
		cd "${tmpConfigDir}"
		if [ -f "${configInFile}" ]; then
			LOGD "Execute ${exe} in directory ${tmpConfigDir}"
			if [ "${options}" != "" ]; then
				"${exe}" "${options}" "${configInFile}"
			else
				"${exe}" "${configInFile}"
			fi
		else
			LOGW "${configInFile} is not a valid file after cd in ${tmpConfigDir}"
		fi
	)
}

#===============================================================================
# Update a configuration automatically.
# $1 : Config.in input file.
# $2 : current config file.
# $3 : update config file (can be the same as configFileOld).
#===============================================================================
updateConfigInternal()
{
	local configInFile="$1"
	local configFileCurrent="$2"
	local configFileUpdate="$3"

	# Update config in silence
	beginConf "${configFileCurrent}"
	(yes "" | execConf "${CONF_BIN}" "${configInFile}" "-o") > /dev/null
	endConf "${configFileUpdate}"
}

#===============================================================================
# Check a configuration.
# $1 : Config.in input file.
# $2 : current config file.
#===============================================================================
checkConfig()
{
	local configInFile="$1"
	local configFile="$2"

	if [ ! -f "${configFile}" ]; then
		echo "Configuration file ${configFile} does not exist" | tee -a "${optDiffFile}"
	else
		# Update config in a temp file
		local tmpCheckFile=$(mktemp)
		LOGD "Created temp file : ${tmpCheckFile}"
		updateConfigInternal "${configInFile}" "${configFile}" "${tmpCheckFile}"

		# If modification detected, append in global diff file
		if ! cmp -s "${configFile}" "${tmpCheckFile}"; then
			echo "Configuration file ${configFile} is not up to date"
			diff -u "${configFile}" "${tmpCheckFile}" >> "${optDiffFile}"
		fi

		# Cleanup temp file
		rm -f "${tmpCheckFile}"
		LOGD "Deleted temp file : ${tmpCheckFile}"
	fi
}

#===============================================================================
# Update a configuration automatically.
# configInFile : Config.in input file.
# configFile : current config file.
#===============================================================================
updateConfig()
{
	local configInFile="$1"
	local configFile="$2"

	# Update given file in temp file
	local tmpCheckFile=$(mktemp)
	LOGD "Created temp file : ${tmpCheckFile}"
	updateConfigInternal "${configInFile}" "${configFile}" "${tmpCheckFile}"

	# Compare old and update file, replace and print message if update done
	if ! cmp -s "${configFile}" "${tmpCheckFile}"; then
		cp -pf "${tmpCheckFile}" "${configFile}";
		echo "Configuration file ${configFile} has been updated";
	fi

	# Cleanup temp file
	rm -f "${tmpCheckFile}"
	LOGD "Deleted temp file : ${tmpCheckFile}"
}

#===============================================================================
#===============================================================================
doCheck()
{
	checkConfig "${optConfigInFile}" "${optConfigFile}"
}

#===============================================================================
#===============================================================================
doUpdate()
{
	updateConfig "${optConfigInFile}" "${optConfigFile}"
}

#===============================================================================
#===============================================================================
doConfig()
{
	beginConf "${optConfigFile}"
	execConf "${QCONF_BIN}" "${optConfigInFile}"
	endConf "${optConfigFile}"
}

#===============================================================================
#===============================================================================
parseOptions()
{
	# Parse given options
	while getopts qvh opt; do
		case ${opt} in
			q) optQuiet=1;;
			v) optVerbose=$((${optVerbose} + 1));;
			h) optHelp=1;;
			\?) usage; exit 1;;
		esac
	done

	# Get remaining positional arguments
	shift $((${OPTIND} - 1))

	# 3 or 4 arguments required
	optArgCount=$#
	if [ ${optArgCount} -ne 3 -a ${optArgCount} -ne 4 ]; then
		echo "Bad number of arguments : ${optArgCount}" 
		usage; exit 1;
	fi

	# Get arguments
	optAction="$1"
	optConfigInFile="$2"
	optConfigFile="$3"
	optDiffFile="$4"
}

# Parse command line
parseOptions $*

# Execute given action
if [ "${optAction}" = "check" ]; then
	if [ ${optArgCount} -eq 4 ]; then
		doCheck
	else
		echo "Missing diff file argument"
		usage; exit 1;
	fi
elif [ "${optAction}" = "update" ]; then
	doUpdate
elif [ "${optAction}" = "config" ]; then
	doConfig
else
	echo "Unknown action : ${optAction}"
	usage; exit 1;
fi

