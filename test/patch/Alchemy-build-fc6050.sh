#!/bin/bash

readonly TOP_DIR=`pwd`

export TARGET_PRODUCT="fc6050"
export TARGET_PRODUCT_VARIANT="hiphop"
export TARGET_OS="linux"
export TARGET_OS_FLAVOUR="parrot"
export TARGET_LIBC="eglibc"
export TARGET_ARCH="arm"
export TARGET_CPU="p6i"
export TARGET_OUT="${TOP_DIR}/Alchemy-out/${TARGET_PRODUCT}-${TARGET_PRODUCT_VARIANT}"
export TARGET_OUT_BUILD="${TARGET_OUT}/build"
export TARGET_OUT_STAGING="${TARGET_OUT}/staging"
export TARGET_OUT_FINAL="${TARGET_OUT}/final"
export TARGET_CONFIG_DIR="${TOP_DIR}/Alchemy-config/${TARGET_PRODUCT}-${TARGET_PRODUCT_VARIANT}"
export TARGET_SCAN_PRUNE_DIRS="Alchemy-out raptor"

export USE_COLORS=1

time make -f ./Alchemy/main.mk $*

