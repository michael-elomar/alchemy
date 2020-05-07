#!/bin/bash

while read line; do
	key=$(echo ${line} | cut -f1 -d':')
	value=$(echo ${line} | cut -f2 -d':')

	case "${key}" in
	"UUID")
		UUID=${value}
		;;
	"Data blocks")
		DATA_BLOCKS=${value}
		;;
	"Data block size")
		DATA_BLOCK_SIZE=${value}
		;;
	"Hash block size")
		HASH_BLOCK_SIZE=${value}
		;;
	"Hash algorithm")
		HASH_ALG=${value}
		;;
	"Salt")
		SALT=${value}
		;;
	"Root hash")
		ROOT_HASH=${value}
		;;
	esac
done

echo setenv verity_sectors $((${DATA_BLOCKS} * ${DATA_BLOCK_SIZE} / 512))
echo setenv verity_data_blocks ${DATA_BLOCKS}
echo setenv verity_hash_start $((${DATA_BLOCKS} * ${DATA_BLOCK_SIZE} / ${HASH_BLOCK_SIZE} + 1))
echo setenv verity_data_block_sz ${DATA_BLOCK_SIZE}
echo setenv verity_hash_block_sz ${HASH_BLOCK_SIZE}
echo setenv verity_hash_alg ${HASH_ALG}
echo setenv verity_salt ${SALT}
echo setenv verity_root_hash ${ROOT_HASH}
echo setenv verity_extra 
