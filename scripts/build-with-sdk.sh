#!/bin/sh

set -e

SCRIPT_PATH=$(cd $(dirname $0) && pwd -P)

# Determine ALCHEMY_HOME
if [ "${ALCHEMY_HOME}" = "" ]; then
    export ALCHEMY_HOME=${SCRIPT_PATH}/..
fi
readonly ALCHEMAKE=${ALCHEMY_HOME}/scripts/alchemake

# Setup minimal variables
export ALCHEMY_WORKSPACE_DIR=$(pwd)
export ALCHEMY_TARGET_CONFIG_DIR=$(pwd)/config
export ALCHEMY_TARGET_OUT=$(pwd)/out
export ALCHEMY_TARGET_SDK_DIRS=$(cd $(pwd)/sdk && pwd -P)

# Generate a full config
rm -f ${ALCHEMY_TARGET_CONFIG_DIR}/*.config
${ALCHEMAKE} config-force-all config-update
cp -r ${ALCHEMY_TARGET_SDK_DIRS}/config/*.config ${ALCHEMY_TARGET_CONFIG_DIR}

# Go !
if [ "${JKS_DO_SAST}" = "true" ]; then

    if [ "${CODECHECKER_HOME}" = "" ]; then
        export CODECHECKER_HOME=/opt/codechecker
    fi
    if [ ! -d "${CODECHECKER_HOME}" ]; then
        echo "\e[1;31mPlease set the CODECHECKER_HOME environment variable to a valid location... Aborting.\e[0m"
        exit 1
    fi

    . ${CODECHECKER_HOME}/venv/bin/activate

    BUILD_COMMAND="${ALCHEMAKE} $@"

    CodeChecker log -b "${BUILD_COMMAND}" \
        --keep-link \
        --output "${ALCHEMY_TARGET_OUT}"/compilation_commands.json

    deactivate
else
    ${ALCHEMAKE} "$@"
fi
