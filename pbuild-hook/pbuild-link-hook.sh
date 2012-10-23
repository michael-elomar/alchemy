#!/bin/sh

# Check argument count, do NOT display anything on stdout
if [ $# -lt 5 ]; then
	exit 0
fi

# Get full path to this script
SCRIPT_PATH=`(cd $(dirname $0) && pwd)`

# Get parameters
NM=$1
CC=$2
MODULE_NAME=$3
MODULE_PATH=$4
OUT_DIR=$(dirname $5)
shift 5
OBJECTS=$*

OUT_SRC=${OUT_DIR}/pbuild_link_hook.cpp
OUT_OBJ=${OUT_DIR}/pbuild_link_hook.o

# Reset the output files
mkdir -p ${OUT_DIR}
rm -f ${OUT_SRC}
rm -f ${OUT_OBJ}
touch ${OUT_SRC}

###############################################################################
## Banner.
###############################################################################
echo "/*" >> ${OUT_SRC}
echo " * GENERATED FILE, DO NOT MODIFY" >> ${OUT_SRC}
echo " */" >> ${OUT_SRC}
echo "" >> ${OUT_SRC}

###############################################################################
## plog dynamic level.
###############################################################################

# List all symbols matching the pattern
PATTERN="pal_log_dyn_level_"
PATTERN_LEN=18

SYMBOLS=$( \
	${NM} -u ${OBJECTS} | \
	grep "U ${PATTERN}" | \
	awk '{ print $2}' | \
	sort | uniq --skip-chars=${PATTERN_LEN} \
)

if [ "${SYMBOLS}" != "" ]; then

	# Level definition shall be in extern "C" block
	echo "extern \"C\" {" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}

	# Shall be the same structure than in 'pbuild-stub.c'
	echo "struct pal_log_dyn_data {" >> ${OUT_SRC}
	echo "    int *level;" >> ${OUT_SRC}
	echo "    const char *ident;" >> ${OUT_SRC}
	echo "    struct pal_log_dyn_data *next;" >> ${OUT_SRC}
	echo "};" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}
	echo "void pal_log_dyn_add(struct pal_log_dyn_data *data);" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}

	# Define levels and data structure
	for x in ${SYMBOLS}; do
		echo "int ${x} = 3;" >> ${OUT_SRC}
		echo "static struct pal_log_dyn_data ${x}_data =" >> ${OUT_SRC}
		echo "    {&${x}, \"${x#pal_log_dyn_level_}\", 0};" >> ${OUT_SRC}
		echo "" >> ${OUT_SRC}
	done

	echo "}" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}

	# Use a global class object in anonymous namespace to do load time registration
	echo "namespace {" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}

	echo "class pal_log_dyn_init {" >> ${OUT_SRC}
	echo "public:" >> ${OUT_SRC}

	# Register levels in constructor
	echo "    pal_log_dyn_init() {" >> ${OUT_SRC}
	for x in ${SYMBOLS}; do
		echo "        pal_log_dyn_add(&${x}_data);" >> ${OUT_SRC}
	done
	echo "    }" >> ${OUT_SRC}

	echo "} pal_log_dyn_init_obj;" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}

	echo "}" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}

fi

###############################################################################
## Library describe
###############################################################################
LIB_DESC=$(cd ${MODULE_PATH} && ${SCRIPT_PATH}/describe.sh)

if [ "${LIB_DESC}" != "" ]; then
	# Definition shall be in extern "C" block
	echo "extern \"C\" {" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}

	# Shall be the same structure than in 'pbuild-stub.c'
	echo "struct pal_lib_desc_data {" >> ${OUT_SRC}
	echo "    const char *lib;" >> ${OUT_SRC}
	echo "    const char *desc;" >> ${OUT_SRC}
	echo "    struct pal_lib_desc_data *next;" >> ${OUT_SRC}
	echo "};" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}
	echo "void pal_lib_desc_add(struct pal_lib_desc_data *data);" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}

	# Data structure
	echo "static struct pal_lib_desc_data lib_desc_data =" >> ${OUT_SRC}
	echo "    {\"${MODULE_NAME}\", \"${LIB_DESC}\"};" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}

	echo "}" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}

	# Use a global class object in anonymous namespace to do load time registration
	echo "namespace {" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}

	echo "class pal_lib_desc_init {" >> ${OUT_SRC}
	echo "public:" >> ${OUT_SRC}

	# Register levels in constructor
	echo "    pal_lib_desc_init() {" >> ${OUT_SRC}
	echo "        pal_lib_desc_add(&lib_desc_data);" >> ${OUT_SRC}
	echo "    }" >> ${OUT_SRC}

	echo "} pal_lib_desc_init_obj;" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}

	echo "}" >> ${OUT_SRC}
	echo "" >> ${OUT_SRC}

fi

###############################################################################
## Final step.
###############################################################################

# Compile the file, generate the .o
${CC} -o ${OUT_OBJ} -c ${OUT_SRC}

# Print it so it will be added in the link
echo ${OUT_OBJ}

