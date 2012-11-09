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
	# replace '#' by '/'
	name=$(echo ${file} | sed -e "s/#/\\//g")
	if [ "${DRYRUN}" = "0" ]; then
		cp -pf ${PATCHDIR}/${file} ${name}
	else
		echo "${PATCHDIR}/${file} -> ${name}"
	fi
done

if false; then
echo "Applying patches"
for file in ${patchfiles}; do
	# remove leading './'
	file=${file#./}
	# Remove .patch extension and replace '#' by '/'
	name=$(echo ${file} | sed -e "s/#/\\//g" | sed -e "s/\.patch//g")
	echo "Apply patch in ${name}"
	if [ "${DRYRUN}" = "0" ]; then
		(cd ${name} && git apply -v ${PATCHDIR}/${file})
	else
		echo "${PATCHDIR}/${file} -> ${name}"
	fi
done
fi

