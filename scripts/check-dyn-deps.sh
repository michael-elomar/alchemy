#!/bin/sh

# Exclude some directories during search
readonly FIND_PATTERN='-path */proc -prune -o -path */dev -prune -o -print'

# List of binaries
binaries=$(file $(find ${FIND_PATTERN} -type f) | /bin/grep 'ELF' | cut -d: -f1)

# Get libs needed by binaries
libs=""
rpath=""
for bin in ${binaries}; do
	libs="${libs} $(objdump -p ${bin} | /bin/grep NEEDED | cut -b24-)"
	bin_rpath="$(objdump -p ${bin} | /bin/grep RPATH | cut -b24-)"
	if test -n "${bin_rpath}"; then
		rpath="${rpath} ${bin}:${bin_rpath}"
	fi
done

# Use tr to split libs on several lines, then sort and remove duplicates
libs="$(echo "${libs}" | tr [:space:] '\n' | sort | uniq)"

# Check that all libraries exist
missing="no"
for lib in ${libs}; do
	res="$(find ${FIND_PATTERN} -name ${lib})"
	if test -z "${res}"; then
		echo "Missing ${lib}"
		missing="yes"
	fi
done

if [ "${missing}" = "no" ]; then
	echo "No libraries missing"
fi

if [ "${rpath}" != "" ]; then
	echo "Some binaries uses DT_RPATH"
	echo ${rpath}
fi
