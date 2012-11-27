#!/bin/bash

readonly TOP_DIR=`pwd`
readonly ALCHEMY_DIR=${TOP_DIR}/Alchemy

export RAPTOR_DIR="${TOP_DIR}/raptor"
export RAPTOR_OUT="${RAPTOR_DIR}/out/target/product/fc6100"

readonly RAPTOR_TOOLCHAIN_PREFIX="${RAPTOR_DIR}/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-"
readonly RAPTOR_TOOLCHAIN_LIBGCC="$(${RAPTOR_TOOLCHAIN_PREFIX}gcc -print-libgcc-file-name)"

export TARGET_CROSS="${RAPTOR_TOOLCHAIN_PREFIX}"

export TARGET_GLOBAL_C_INCLUDES=" \
 ${RAPTOR_DIR}/bionic/libc/arch-arm/include \
 ${RAPTOR_DIR}/bionic/libc/include \
 ${RAPTOR_DIR}/bionic/libstdc++/include \
 ${RAPTOR_DIR}/bionic/libc/kernel/common \
 ${RAPTOR_DIR}/bionic/libc/kernel/arch-arm \
 ${RAPTOR_DIR}/bionic/libm/include \
 ${RAPTOR_DIR}/bionic/libm/include/arch/arm \
 ${RAPTOR_DIR}/bionic/libthread_db/include \
 ${RAPTOR_DIR}/system/core/include \
 ${RAPTOR_DIR}/system/core/include/arch/linux-arm \
 ${RAPTOR_DIR}/external/zlib \
 ${RAPTOR_DIR}/frameworks/base/include \
 ${ALCHEMY_DIR}/toolchains/bionic/include \
"

export TARGET_GLOBAL_CFLAGS=" \
 -fno-exceptions \
 -fpic \
 -ffunction-sections \
 -funwind-tables \
 -fno-short-enums \
 -fstack-protector \
 -Wa,--noexecstack \
 -include ${RAPTOR_DIR}/system/core/include/arch/linux-arm/AndroidConfig.h \
 -DANDROID \
 -fmessage-length=0 \
 -DOMAP_ENHANCEMENT \
 -DTARGET_OMAP3 \
 -g \
 -finline-functions \
 -fno-inline-functions-called-once \
 -fgcse-after-reload \
 -frerun-cse-after-loop \
 -frename-registers \
 -UDEBUG \
 -D_POSIX_SOURCE \
 -DANDROID_MAJOR=2 \
 -DANDROID_MINOR=3 \
 -O2 \
"

export TARGET_GLOBAL_CPPFLAGS=" \
 -fvisibility-inlines-hidden \
 -fno-rtti \
"

export TARGET_GLOBAL_LDFLAGS=" \
 -nostdlib \
 -Bdynamic \
 -Wl,-T,${RAPTOR_DIR}/build/core/armelf.x \
 -Wl,-dynamic-linker,/system/bin/linker \
 -Wl,--gc-sections \
 -Wl,-z,nocopyreloc \
 -L${RAPTOR_OUT}/obj/lib \
 -Wl,-rpath-link=${RAPTOR_OUT}/obj/lib \
"

export TARGET_GLOBAL_LDLIBS=" \
 -lc \
 -lstdc++ \
 -lm \
 ${RAPTOR_OUT}/obj/lib/crtbegin_dynamic.o \
 -Wl,-z,noexecstack \
 ${RAPTOR_TOOLCHAIN_LIBGCC} \
 ${RAPTOR_OUT}/obj/lib/crtend_android.o \
"

export TARGET_GLOBAL_LDFLAGS_SHARED=" \
 -nostdlib \
 -Wl,-T,${RAPTOR_DIR}/build/core/armelf.xsc \
 -Wl,--gc-sections \
 -Wl,-shared,-Bsymbolic \
"

export TARGET_GLOBAL_LDLIBS_SHARED=" \
 -L${RAPTOR_OUT}/obj/lib \
 -lc \
 -lstdc++ \
 -lm \
 ${RAPTOR_TOOLCHAIN_LIBGCC} \
"

export TARGET_PRODUCT="fc6100"
export TARGET_PRODUCT_VARIANT="hiphop"
export TARGET_OS="linux"
export TARGET_OS_FLAVOUR="android"
export TARGET_LIBC="bionic"
export TARGET_ARCH="arm"
export TARGET_CPU="omap3"
export TARGET_OUT="${TOP_DIR}/Alchemy-out/${TARGET_PRODUCT}-${TARGET_PRODUCT_VARIANT}"
export TARGET_OUT_BUILD="${TARGET_OUT}/build"
export TARGET_OUT_STAGING="${TARGET_OUT}/staging"
export TARGET_OUT_FINAL="${TARGET_OUT}/final"
export TARGET_CONFIG_DIR="${TOP_DIR}/Alchemy/test/config/${TARGET_PRODUCT}-${TARGET_PRODUCT_VARIANT}"
export TARGET_SCAN_PRUNE_DIRS="Alchemy-out ${RAPTOR_DIR}/hardware/parrot ${RAPTOR_DIR}/out"

export TARGET_STRIP="${RAPTOR_DIR}/out/host/linux-x86/bin/soslim --strip --shady --quiet"
export USE_COLORS=1

time ./Alchemy/scripts/alchemake.py -f ./Alchemy/main.mk $*

