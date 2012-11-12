#!/bin/bash

ORIG=$(pwd)
PATCHDIR=${ORIG}/Alchemy/test/patch
mkdir -p ${PATCHDIR}

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

# Search new files
echo "Searching new files"
filelist=" $(find -path ./Alchemy -prune \
  -o -name atom.mk -print \
  -o -name blues-config.h -print \
  -o -name blues-stub.c -print \
  -o -name ConfigHSTIGenerator.in -print \
  -o -name svox-stub.c -print \
  -o -name pal_main.c -print \
  -o -name tcpdump-4.1.1-configure.patch -print \
  -o -name valgrind-3.6.1-extern.patch -print ) \
  Alchemy-build-*.sh \
"

echo "Copying files"
for file in ${filelist}; do
	# remove leading './'
	file=${file#./}
	# replace '/' by '#'
	name=$(echo ${file} | sed -e "s/\\//#/g")
	echo "${file} -> ${name}"
	cp -pf ${file} ${PATCHDIR}/${name}
done

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
		git --no-pager diff > ${PATCHDIR}/${name}.patch
	fi
}

# get list of git repositories
echo "Searching git repositories"
readonly repolist=$(find -name ".git")

echo "Generating git patches"
for repo in ${repolist}; do
	# remove trailing '/.git' and leading './'
	repopath=${repo%/.git}
	repopath=${repopath#./}
	if [ "${repopath}" != "Alchemy" -a "${repopath}" != "Alchemy-patch" -a "${repopath}" != "Alchemy-config" ]; then
		(cd ${repopath} && save_patch ${repopath})
	fi
done

