#!/bin/sh

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
	readonly ARCHDIR="x86_64-linux-gnu"
else
	readonly ARCHDIR="i386-linux-gnu"
fi

# Copy a file if needed
# $1: source file
# $2: destination path
copy_file()
{
	local readonly src=$1
	local readonly dst=$2/$(basename ${src})
	if [ ! -e ${dst} -o ${src} -nt ${dst} ]; then
		cp -af ${src} ${dst}
	fi
}

# Copy files matching a pattern
# $1: source file pattern
# $2: destination path
copy_file_pattern()
{
	for f in $1; do
		copy_file $f $2
	done
}

mkdir -p ${SYSROOT}/lib
mkdir -p ${SYSROOT}/usr/lib

# /lib system libraries
lib_names=" \
  libc libpthread libm librt libdl libutil \
  libresolv libnss_files \
"
for n in ${lib_names}; do
	copy_file_pattern "/lib/${ARCHDIR}/${n}.so*" "${SYSROOT}/lib"
	copy_file_pattern "/lib/${ARCHDIR}/${n}-*.so" "${SYSROOT}/lib"
done

# Linker and libgcc
copy_file_pattern "/lib/${ARCHDIR}/ld-*.so" "${SYSROOT}/lib"
copy_file_pattern "/lib/${ARCHDIR}/ld-linux*.so*" "${SYSROOT}/lib"
copy_file_pattern "/lib/${ARCHDIR}/libgcc_s.so*" "${SYSROOT}/lib"

# Link /lib64 -> /lib
if [ "${ARCH}" = "x64" ]; then
	ln -sf lib ${SYSROOT}/lib64
fi

# /usr/lib libraries
usr_lib_names="libstdc++ libICE libSM"
for n in ${usr_lib_names}; do
	copy_file_pattern "/usr/lib/${ARCHDIR}/${n}.so*" "${SYSROOT}/usr/lib"
done

# gdbserver
if [ -f /usr/bin/gdbserver ]; then
	copy_file "/usr/bin/gdbserver" "${SYSROOT}/usr/bin"
fi
