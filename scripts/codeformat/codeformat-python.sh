#!/bin/bash

SCRIPT_PATH=$(cd $(dirname $0) && pwd -P)

FORMATTERS=$1
ARGS=$2
FILES=$3
MODULE_DIR=$4

for FORMATTER in ${FORMATTERS}; do
	if [ "${FORMATTER}" = "pep8" ]; then
		 python3 -m autopep8 -i ${FILES}
	elif [ "${FORMATTER}" = "autoflake8" ]; then
                autoflake8 -i ${ARGS} ${FILES}
	else
		echo "Unknown 'python' formatter '${FORMATTER}'"
	fi
done
