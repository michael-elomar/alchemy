#!/bin/bash

readonly binaries=$(file $(find -type f) | grep 'ELF' | cut -d: -f1)

libs=""
rpath=""
for bin in ${binaries}; do
	libs="${libs} $(objdump -p ${bin} | grep NEEDED | cut -b24-)"
	bin_rpath="$(objdump -p ${bin} | grep RPATH | cut -b24-)"
	if test -n "${bin_rpath}"; then
		rpath="${rpath} ${bin}:${bin_rpath}"
	fi
done

libs="$(echo "${libs}" | sort | uniq)"
echo ${libs}

for lib in ${libs}; do
	res="$(find -name ${lib})"
	if test -z "${res}"; then
		echo "Missing ${lib}"
	fi
done

echo ${rpath}

