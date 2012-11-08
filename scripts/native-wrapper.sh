#!/bin/bash

# This script assumes it is copied in the staging or final dir
# Folders bin, usr/bin, lib, /usr/lib are subdirectories there

# Get full path to this script (either when executed or sourced)
SCRIPT_PATH=$(cd $(dirname ${BASH_SOURCE}) && pwd))

# Restore previous variables
if [ "${OLD_PATH}" != "" ]; then
	export PATH=${OLD_PATH}
fi
if [ "${OLD_LD_LIBRARY_PATH}" != "" ]; then
	export LD_LIBRARY_PATH=${OLD_LD_LIBRARY_PATH}
fi

# Save previous variables
OLD_PATH=${PATH}
OLD_LD_LIBRARY_PATH=${LD_LIBRARY_PATH}

# Update path
export PATH=${SCRIPT_PATH}/bin:${SCRIPT_PATH}/usr/bin:${PATH}

# Update library path
export LD_LIBRARY_PATH=${SCRIPT_PATH}/lib:${SCRIPT_PATH}/usr/lib:${LD_LIBRARY_PATH}

# execute given command line (only if not sourced)
if [ "${BASH_SOURCE}" = "$0" ]; then
	$@
fi

