#!/bin/bash

# This script assumes it is copied in the staging or final dir
# Folders bin, usr/bin, lib, /usr/lib are subdirectories there

# Get full path to this script (either when executed or sourced)
SCRIPT_PATH=$(cd $(dirname ${BASH_SOURCE}) && pwd)
SYSROOT=${SCRIPT_PATH}

# List of directory to mount as a binding with host
readonly MOUNT_POINTS="proc dev dev/pts"
readonly UMOUNT_POINTS="dev/pts dev proc"

# Help ?
if [ "$1" = "--help" ]; then
	echo "usage: $0 [--help|--root] prog..."
	echo "       $0 [--mount|--umount]"
	echo "  --help  : display this help message"
	echo "  --root  : switch to root user"
	echo "  --mount : mount proc, dev and dev/pts as a binding with host"
	echo "  --umount: un-mount proc, dev and dev/pts"
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

# Check if a directory is actually mounted as a binding with host
# $1: directory to check
function is_mounted()
{
	mount | grep "/$1 on ${SYSROOT}/$1" > /dev/null
	return $?
}

# Mount a directory as a binding with host
# $1: directory to mount
function do_mount()
{
	echo "Mounting /$d as ${SYSROOT}/$1"
	mkdir -p ${SYSROOT}/$1
	sudo mount --bind /$1 ${SYSROOT}/$1
	return $?
}

# Un-mount a directory that was a binding with host
# $1: directory to un-mount
function do_umount()
{
	sudo umount ${SYSROOT}/$1
	return $?
}

# Mount everything
if [ "$1" = "--mount" ]; then
	for d in ${MOUNT_POINTS}; do
		is_mounted $d
		if [ "$?" != "0" ]; then
			do_mount $d
		fi
	done
	exit
fi

# Un-mount everything
if [ "$1" = "--umount" ]; then
	for d in ${UMOUNT_POINTS}; do
		is_mounted $d
		if [ "$?" = "0" ]; then
			do_umount $d
		fi
	done
	exit
fi

# Check mount points
for d in ${MOUNT_POINTS}; do
	is_mounted $d
	if [ "$?" != "0" ]; then
		echo "$d is not mounted"
	fi
done

# Need to be root to chroot, but then go back to initial user
if [ "${OPT_ROOT}" = "0" ]; then
	sudo chroot --userspec=${UID}:${UID} ${SYSROOT} ${OPT_PROG}
else
	sudo chroot ${SYSROOT} ${OPT_PROG}
fi

