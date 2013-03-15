#!/usr/bin/env bash

# Wrapper for pennconverter.jar that replaces failed conversions with the
#   corresponding conversion for a flat parse.
#
# Example storing failed conversions in a separate file:
#
#    cat ${PTB_FILE} | ./ptb_to_connlx.bash 1> ${OUTPUT_FILE} \
#        2> ${OUTPUT_FILE}.failed
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2013-02-28

set -e

SCRIPT_DIR=`dirname "$0"`
TLS_DIR=${SCRIPT_DIR}/../tls
PENNCONVERTER_JAR_PATH=${TLS_DIR}/pennconverter.jar
FLATPARSER_PATH=${TLS_DIR}/flatparser.py
PTBESC_PATH=${TLS_DIR}/ptbesc.py

LINE_NUM=1
while read LINE
do
    while true
    do
        # Tempfile for our output
        TMP_FILE=`mktemp`
        trap 'rm -f "${TMP_FILE}"' EXIT INT TERM HUP

        # Launch an instance of the converter tool with some necessary
        #   pre-processing.
        set +e
        echo "${LINE}" | sed -e 's|(ROOT |(TOP |g' \
            | java -jar ${PENNCONVERTER_JAR_PATH} -raw -splitSlash=false \
                2> /dev/null \
                >> ${TMP_FILE}
        CONVERTER_EXIT_CODE=$?
        set -e

        if [ ${CONVERTER_EXIT_CODE} -eq 0 ]
        then
            # The conversion succeeded, cat and unescape the output with an
            #   additional round since the conversion script doesn't escape
            #   token-internal escapes.
            # Note: This is our only Bash-ishm in this file.
            paste <(cut -f 1 ${TMP_FILE}) \
                <(cut -f 2 ${TMP_FILE} | ${PTBESC_PATH} -u) \
                <(cut -f 3- ${TMP_FILE})
            # Clean up the temporary file used for this round
            rm -f ${TMP_FILE}
            # Break out to process the next line
            break
        else
            # The converter died since it failed to convert, replace the parse
            #   with a flat parse and preserve the PoS-tags, then feed it back
            #   to the converter.
            echo -e "WARNING: Conversion error for line:\t${LINE_NUM}" 1>&2
            LINE=`echo "${LINE}" | ${FLATPARSER_PATH} -r`
        fi
        # Clean up the temporary file used for this round
        rm -f ${TMP_FILE}
    done
    LINE_NUM=`expr ${LINE_NUM} + 1`
done
