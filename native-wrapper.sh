#!/bin/sh

# This script assume it is copied in the staging or final dir
# folders bin, usr/bin, lib, /usr/lib are subdirectories there

# Full path to this script
readonly SCRIPT_PATH=`(cd $(dirname $0) && pwd)`

# Update path
export PATH=${SCRIPT_PATH}/bin:${SCRIPT_PATH}/usr/bin:${PATH}

# Update library path
export LD_LIBRARY_PATH=${SCRIPT_PATH}/lib:${SCRIPT_PATH}/usr/lib:${LD_LIBRARY_PATH}

# execute given command line
if [ "$#" != "0" ]; then
	$*
fi

