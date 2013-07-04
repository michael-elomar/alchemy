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
BASE_LIB_PATH="/lib/${ARCHDIR}"
BASE_LIB_PATH_DBG="/usr/lib/debug/lib/${ARCHDIR}"
BASE_USRLIB_PATH="/usr/lib/${ARCHDIR}"

# Fallback in legacy hierarchy
if [ ! -d "${BASE_LIB_PATH}" ] ; then
	BASE_LIB_PATH="/lib"
fi
if [ ! -d "${BASE_LIB_PATH_DBG}" ] ; then
	BASE_LIB_PATH_DBG="/usr/lib/debug/lib"
fi
if [ ! -d "${BASE_USRLIB_PATH}" ] ; then
	BASE_USRLIB_PATH="/usr/lib"
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
		# In case no matches, the pattern is returned varbatim...
		if [ -f $f ]; then
			copy_file $f $2
		fi
	done
}

mkdir -p ${SYSROOT}/lib
mkdir -p ${SYSROOT}/usr/lib
mkdir -p ${SYSROOT}/usr/lib/debug/lib

# /lib system libraries
lib_names=" \
  libc libpthread libm librt libdl libutil \
  libresolv libnss_files libthread_db \
"
for n in ${lib_names}; do
	# Normal files
	copy_file_pattern "${BASE_LIB_PATH}/${n}.so*" "${SYSROOT}/lib"
	copy_file_pattern "${BASE_LIB_PATH}/${n}-*.so" "${SYSROOT}/lib"
	# With debug symbols
	copy_file_pattern "${BASE_LIB_PATH_DBG}/${n}-*.so" "${SYSROOT}/usr/lib/debug/lib"
done

# Linker and libgcc
copy_file_pattern "${BASE_LIB_PATH}/ld-*.so" "${SYSROOT}/lib"
copy_file_pattern "${BASE_LIB_PATH}/ld-linux*.so*" "${SYSROOT}/lib"
copy_file_pattern "${BASE_LIB_PATH}/libgcc_s.so*" "${SYSROOT}/lib"
# With debug symbols
copy_file_pattern "${BASE_LIB_PATH_DBG}/ld-*.so" "${SYSROOT}/usr/lib/debug/lib"

# Link /lib64 -> /lib
if [ "${ARCH}" = "x64" ]; then
	ln -sf lib ${SYSROOT}/lib64
fi

# /usr/lib libraries
usr_lib_names="libstdc++ libICE libSM"
for n in ${usr_lib_names}; do
	# Normal files
	copy_file_pattern "${BASE_USRLIB_PATH}/${n}.so*" "${SYSROOT}/usr/lib"
done

# gdbserver
if [ -f /usr/bin/gdbserver ]; then
	copy_file "/usr/bin/gdbserver" "${SYSROOT}/usr/bin"
fi
