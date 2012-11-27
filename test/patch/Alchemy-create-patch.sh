#!/bin/bash

DRYRUN=0
if [ "$1" = "-n" ]; then
	DRYRUN=1
fi

# Get full path to this script (either when executed or sourced)
SCRIPT_PATH=$(cd $(dirname ${BASH_SOURCE}) && pwd)

ORIG=$(pwd)
PATCHDIR=${SCRIPT_PATH}
mkdir -p ${PATCHDIR}

if [ "${DRYRUN}" = "0" ]; then
	# Save some files
	if [ -f ${PATCHDIR}/Alchemy-create-patch.sh ]; then
		cp -af ${PATCHDIR}/Alchemy-create-patch.sh /tmp
	fi
	if [ -f ${PATCHDIR}/Alchemy-apply-patch.sh ]; then
		cp -af ${PATCHDIR}/Alchemy-apply-patch.sh /tmp
	fi

	# Delete all files
	rm -f ${PATCHDIR}/*

	# Restore saved files
	if [ -f /tmp/Alchemy-create-patch.sh ]; then
		cp -af /tmp/Alchemy-create-patch.sh ${PATCHDIR}
	fi
	if [ -f /tmp/Alchemy-apply-patch.sh ]; then
		cp -af /tmp/Alchemy-apply-patch.sh ${PATCHDIR}
	fi
fi

# get list of git repositories
echo "Searching git repositories"
readonly repolist=$(find -path ./Alchemy-out -prune -o -name ".git" -print)

filelist=Alchemy-build-*.sh

echo "Copying files"
for file in Alchemy-build-*.sh; do
	# remove leading './'
	file=${file#./}
	# replace '/' by '#' and .patch by .patch_
	name=$(echo ${file} | sed -e "s/\\//#/g" | sed -e "s/\\.patch/\\.patch_/g")
	echo "${file} -> ${name}"
	if [ "${DRYRUN}" = "0" ]; then
		cp -pf ${file} ${PATCHDIR}/${name}
	fi
done

function copy_new_files()
{
	# get new files
	NEW_FILES=$(git status -u --porcelain | grep \?\? | cut -b4-)
	for file in ${NEW_FILES}; do
		# replace '/' by '#' and .patch by .patch_
		name=$(echo $1/${file} | sed -e "s/\\//#/g" | sed -e "s/\\.patch/\\.patch_/g")
		echo "$1/${file} -> ${name}"
		if [ "${DRYRUN}" = "0" ]; then
			cp -af ${file} ${PATCHDIR}/${name}
		fi
	done
}

function save_patch()
{
	# get diff content
	DIFF=$(git --no-pager diff)
	if [ "${DIFF}" != "" ]; then
		# replace '/' by '#'
		if [ "$1" = "." ]; then
			name=#
		else
			name=$(echo $1 | sed -e "s/\\//#/g")
		fi
		echo "$1 -> ${name}.patch"
		if [ "${DRYRUN}" = "0" ]; then
			git --no-pager diff > ${PATCHDIR}/${name}.patch
		fi
	fi
}

for repo in ${repolist}; do
	# remove trailing '/.git' and leading './'
	repopath=${repo%/.git}
	repopath=${repopath#./}
	if [ "${repopath}" != "Alchemy" -a "${repopath}" != "Alchemy-patch" -a "${repopath}" != "Alchemy-config" ]; then
		(cd ${repopath} && copy_new_files ${repopath})
		(cd ${repopath} && save_patch ${repopath})
	fi
done

