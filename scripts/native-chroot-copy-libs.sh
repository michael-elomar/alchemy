#!/bin/bash

# Check arguments
if [ "$#" != "2" ]; then
	echo "Usage: $0 <final-dir> <arch>"
	exit 1
fi

# Get parameters
readonly SYSROOT=$1
readonly ARCH=$2

# Assume a multi-arch compatible system
if [ "${ARCH}" = "x64" ]; then
	readonly ARCHDIR=x86_64-linux-gnu
else
	readonly ARCHDIR=i386-linux-gnu
fi

mkdir -p ${SYSROOT}/lib
mkdir -p ${SYSROOT}/usr/lib

# /lib system libraries
lib_names=" \
  libc libpthread libm librt libdl libutil \
  libresolv libnss_files \
"

# copy them
for n in ${lib_names}; do
	cp -af /lib/${ARCHDIR}/${n}.so* ${SYSROOT}/lib
	cp -af /lib/${ARCHDIR}/${n}-*.so ${SYSROOT}/lib
done

# Linker and libgcc
cp -af /lib/${ARCHDIR}/ld-*.so ${SYSROOT}/lib
cp -af /lib/${ARCHDIR}/ld-linux.so* ${SYSROOT}/lib
cp -af /lib/${ARCHDIR}/libgcc_s.so* ${SYSROOT}/lib

# /usr/lib libraries
usr_lib_names="libstdc++ libICE libSM"

# copy them
for n in ${usr_lib_names}; do
	cp -af /usr/lib/${ARCHDIR}/${n}.so* ${SYSROOT}/usr/lib
done

# gdbserver
if [ -f /usr/bin/gdbserver ]; then
	cp -af /usr/bin/gdbserver ${SYSROOT}/usr/bin
fi

