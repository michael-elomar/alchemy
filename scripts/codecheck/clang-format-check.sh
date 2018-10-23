#!/bin/bash

SCRIPT_PATH=$(cd $(dirname $0) && pwd -P)

FILES=$1
MODULE_DIR=$2

# Exec everything from MODULE_DIR
cd ${MODULE_DIR}

# Search .clang-format file in MODULE_DIR or its parents, up to the
# git repository root
GITROOT=$(git rev-parse --show-toplevel)
if [ "${GITROOT}" ]; then
	TESTDIR=${MODULE_DIR}
	while true; do
		CLANG_FORMAT_CFG=${TESTDIR}/.clang-format
		if [ -f "${CLANG_FORMAT_CFG}" ]; then
			break
		fi
		if [ "${TESTDIR}" = "${GITROOT}" ]; then
			break
		fi
		TESTDIR=$(dirname ${TESTDIR})
	done
else
	CLANG_FORMAT_CFG=${MODULE_DIR}/.clang-format
fi

# If no .clang-format file, skip the tests
if [ ! -f "${CLANG_FORMAT_CFG}" ]; then
	exit 0
fi

# From now, exec everything from the directory where CLANG_FORMAT_CFG is located
echo "found .clang-format file: ${CLANG_FORMAT_CFG}"
cd $(dirname ${CLANG_FORMAT_CFG})

# Find newest clang-format available
OLD_IFS=$IFS
IFS=":"
CLANG_FORMAT=$(ls ${PATH} 2>/dev/null | grep -E '^clang-format(-[0-9]\.[0-9])?$' | sort -r | head -n1)
IFS=$OLD_IFS

# If not clang-format, skip the tests, but print a message
if [ -z "${CLANG_FORMAT}" ]; then
	echo "clang-format not available, skipping clang-format checks"
	exit 0
fi

# If the clang-format file is not valid, skip the tests, but print a message
CLANG_ERROR=$(${CLANG_FORMAT} -style=file -dump-config </dev/null 2>&1 >/dev/null)
if [ "${CLANG_ERROR}" ]; then
	echo ".clang-format file not valid with current clang-format binary, skipping clang-format checks"
	exit 0
fi

for FILE in ${FILES}; do
	NAME=$(basename ${FILE})
	diff -y --suppress-common-lines ${FILE} <(${CLANG_FORMAT} -style=file --assume-filename=${NAME} <${FILE})
	if [ $? -ne 0 ]; then
		echo "${FILE}:1: WARNING:CLANG-FORMAT: wrong format"
	fi
done
