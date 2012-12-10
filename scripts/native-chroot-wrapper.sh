#!/bin/bash

# This script assumes it is copied in the staging or final dir
# Folders bin, usr/bin, lib, /usr/lib are subdirectories there

# Get full path to this script (either when executed or sourced)
SCRIPT_PATH=$(cd $(dirname ${BASH_SOURCE}) && pwd)
SYSROOT=${SCRIPT_PATH}

# Help ?
if [ "$1" = "--help" ]; then
	echo "usage: $0 [--help|--root] prog..."
	echo "  --help  : display this help message"
	echo "  --root  : switch to root user"
	echo "  prog... : program to execute (default: /bin/sh)"
	exit 0
fi

# Need to be root ?
OPT_ROOT=0
if [ "$1" = "--root" ]; then
	OPT_ROOT=1
	shift
fi

# Program to execute
OPT_PROG="/bin/sh -l"
if [ "$*" != "" ]; then
	OPT_PROG=$*
fi

# Need to be root to chroot, but then go back to initial user
if [ "${OPT_ROOT}" = "0" ]; then
	sudo chroot --userspec=${UID}:${UID} ${SYSROOT} ${OPT_PROG}
else
	sudo chroot ${SYSROOT} ${OPT_PROG}
fi

