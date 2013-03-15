#!/bin/sh

# Create FreeBSD release-style checksums for a set of files.
#
# Example:
#
#   checksums.sh ./ *.tar.gz
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2012-05-26

USAGE="${0} OUTPUT_DIR FILE(S)..."

if [ $# -lt 2 ]
then
    echo ${USAGE} 1>&2
    exit 1
fi

OUTPUT_DIR=${1}
shift # Move the output directory out of the way for the other arguments

if [ ! -d "${OUTPUT_DIR}" ]; then
    echo 'ERROR: First argument not a directory, exiting' 1>&2
    exit 1
fi

INPUT_FILES=${@}

for CHECKSUM_BIN in md5sum sha512sum
do
    CHECKSUM_NAME=`echo ${CHECKSUM_BIN} | sed -e 's|sum$||g' \
        | tr '[a-z]' '[A-Z]'`
    eval "echo ${INPUT_FILES}" | sort | xargs -r ${CHECKSUM_BIN} \
        > ${OUTPUT_DIR}/CHECKSUM.${CHECKSUM_NAME}
done
