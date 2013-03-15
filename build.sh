#!/usr/bin/env sh

# Build a set of archives for supporting resources.
#
# Note: We very much assume well-behaved archives that extract into a single
#   directory that is a sub-set of their file names.
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2013-03-11

set -e

SCRIPT_DIR=`dirname "$0"`
ARCH_DIR=${SCRIPT_DIR}/dat
WRK_DIR=${SCRIPT_DIR}/wrk
TLS_DIR=${SCRIPT_DIR}/tls
SRC_DIR=${SCRIPT_DIR}/src
BLD_DIR=${SCRIPT_DIR}/bld
USAGE="USAGE: $0: version processes"

if [ $# -ne 2 ]
then
    echo "${USAGE}" 1>&2
    exit 1
fi

VERSION=$1
PROCESSES=$2

echo "${PROCESSES}" | grep -q '^[1-9][0-9]*$'
if [ $? -ne 0 ]
then
    echo "ERROR: $0: processes must be a positive integer" 1>&2
    exit 1
fi

FIXTERMNL_PATH=${TLS_DIR}/fixtermnl.sh
GENIASS_PATH=${SRC_DIR}/geniass_ss.sh
GTBTOK_PATH=${TLS_DIR}/GTB-tokenize.pl
SDEP_CONV_PATH=${SRC_DIR}/ptb_to_sdep.sh
CONNLX_CONV_PATH=${SRC_DIR}/ptb_to_connlx.bash

PARALLEL_XARGS="xargs -n 1 -P ${PROCESSES}"

# Find files in the work dir and strip the suffixes.
find_base_by_suffix () {
    SUFFIX=$1
    find "${WRK_DIR}" -name "*.${SUFFIX}" | sed -e "s|\.${SUFFIX}||g"
}

for ARCH_PATH in `find "${ARCH_DIR}" -name '*.tar.gz' -o -name '*.tgz'`
do
    # Establish a "base name", we will use this later for naming.
    ARCH_BASE=`echo "${ARCH_PATH}" \
        | sed -e 's|\.tar\.gz$||g' -e 's|\.tgz$||g' | xargs basename`

    # Clear out any junk directories in the work directory.
    find "${WRK_DIR}" -mindepth 1 -type d | xargs -r rm -r -f

    tar -x -z -f "${ARCH_PATH}" -C "${WRK_DIR}"

    # Let's do some pre-processing, some people don't understand that what is
    #   not visible in a GUI can actually be there, so let's clean up their
    #   damn temporary files.
    # This one is for some Mac junk that lies about its extension (it is
    #   binary, no matter what the suffix is).
    find "${WRK_DIR}" -name '._*' | xargs -r rm

    # We are working in a *NIX framework, so turn all text files into *NIX
    #   text files.
    find "${WRK_DIR}" -name '*.txt' | xargs dos2unix -k -q
    find "${WRK_DIR}" -name '*.txt' | "${FIXTERMNL_PATH}"

    # First stage, sentence splitting.
    find_base_by_suffix 'txt' | ${PARALLEL_XARGS} -I {} \
        sh -c "cat {}.txt | ${GENIASS_PATH} > {}.ss"

    # Pack up the sentence split data.
    SSPLIT_ARCH_NAME=${ARCH_BASE}_ssplit_${VERSION}.tar.gz
    # Note: Relative to the workdir root.
    tar -z -c -C "${WRK_DIR}" -f "${BLD_DIR}/${SSPLIT_ARCH_NAME}" \
        `cd "${WRK_DIR}" && find "${ARCH_BASE}" -name '*.ss'`

    # Second stage, tokenisation.
    find_base_by_suffix 'ss' | ${PARALLEL_XARGS} -I {} \
        sh -c "cat {}.ss | ${GTBTOK_PATH} > {}.tok"

    # Pack up the tokenised data.
    TOK_ARCH_NAME=${ARCH_BASE}_tok_${VERSION}.tar.gz
    # Note: Relative to the workdir root.
    tar -z -c -C "${WRK_DIR}" -f "${BLD_DIR}/${TOK_ARCH_NAME}" \
        `cd "${WRK_DIR}" && find "${ARCH_BASE}" -name '*.tok'`

    # Last stage, all of the parsers.
    for PARSER_NAME in mcccj stanford enju
    do
        # Just to be safe, clean out any remenants.
        find "${WRK_DIR}" -name '*.ptb' -o -name '*.sdep' -o -name '*.sdepcc' \
                -o -name '*.connlx' \
            | xargs -r rm

        # Core parser.
        find_base_by_suffix 'ss' | ${PARALLEL_XARGS} -I {} \
            sh -c "cat {}.ss | ${SRC_DIR}/${PARSER_NAME}_ptb.sh > {}.ptb"

        # Conversions.
        find_base_by_suffix 'ptb' | ${PARALLEL_XARGS} -I {} \
            sh -c "cat {}.ptb | ${SDEP_CONV_PATH} > {}.sdep"
        find_base_by_suffix 'ptb' | ${PARALLEL_XARGS} -I {} \
            sh -c "cat {}.ptb | ${SDEP_CONV_PATH} -c > {}.sdepcc"
        find_base_by_suffix 'ptb' | ${PARALLEL_XARGS} -I {} \
            sh -c "cat {}.ptb | ${CONNLX_CONV_PATH} > {}.connlx"

        # Pack up the parses.
        PARSE_ARCH_NAME=${ARCH_BASE}_${PARSER_NAME}_${VERSION}.tar.gz
        # Note: Relative to the workdir root.
        tar -z -c -C "${WRK_DIR}" -f "${BLD_DIR}/${PARSE_ARCH_NAME}" \
            `cd "${WRK_DIR}" && \
                find "${ARCH_BASE}" -name '*.ptb' -o -name '*.sdep' \
                    -o -name '*.sdepcc' -o -name '*.connlx'`
    done
done
