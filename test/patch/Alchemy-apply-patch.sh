#!/bin/bash

DRYRUN=0
if [ "$1" = "-n" ]; then
	DRYRUN=1
fi

ORIG=$(pwd)
PATCHDIR=${ORIG}/Alchemy/test/patch

copyfiles=$(cd ${PATCHDIR} && find -maxdepth 1 -type f -not -name '*.patch')
patchfiles=$(cd ${PATCHDIR} && find -maxdepth 1 -type f -name '*.patch')

echo "Copying files"
for file in ${copyfiles}; do
	# remove leading './'
	file=${file#./}
	# replace '#' by '/' and and .patch_ by .patch
	name=$(echo ${file} | sed -e "s/#/\\//g" | sed -e "s/\\.patch_/\\.patch/g")
	if [ "${name}" != "Alchemy-create-patch.sh" -a "${name}" != "Alchemy-apply-patch.sh" ]; then
		if [ "${DRYRUN}" = "0" ]; then
			cp -pf ${PATCHDIR}/${file} ${name}
		else
			echo "${PATCHDIR}/${file} -> ${name}"
		fi
	fi
done

echo "Applying patches"
for file in ${patchfiles}; do
	# remove leading './'
	file=${file#./}
	# Remove .patch extension and replace '#' by '/'
	name=$(echo ${file} | sed -e "s/#/\\//g" | sed -e "s/\.patch//g")
	if [ "${name}" = "/" ]; then
		name="."
	fi
	echo "Apply patch in ${name}"
	if [ "${DRYRUN}" = "0" ]; then
		(cd ${name} && git apply --check ${PATCHDIR}/${file} &>/dev/null)
		if [ "$?" != "0" ]; then
			echo "Impossible to apply patch, maybe already applied ?"
		else
			(cd ${name} && git apply -v ${PATCHDIR}/${file})
		fi
	else
		echo "${PATCHDIR}/${file} -> ${name}"
	fi
done

