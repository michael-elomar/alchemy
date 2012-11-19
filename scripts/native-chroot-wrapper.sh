#!/bin/bash

# This script assumes it is copied in the staging or final dir
# Folders bin, usr/bin, lib, /usr/lib are subdirectories there

# Get full path to this script (either when executed or sourced)
SCRIPT_PATH=$(cd $(dirname ${BASH_SOURCE}) && pwd)
SYSROOT=${SCRIPT_PATH}

# Need to be root to chroot, but then go back to initial user
sudo chroot --userspec=${UID}:${UID} ${SYSROOT} /bin/sh -l

