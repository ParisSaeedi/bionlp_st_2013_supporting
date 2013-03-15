#!/usr/bin/env sh

# Convert PennTreebank parses into basic or collapsed Stanford dependencies
#   using the Stanford Parser tools.
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2013-03-01

# Note: The converter is very robust, never the less, the kind of non-sense a
#   statistical parser can achieve once a few million sentences kick in is
#   truly amazing. For these cases we convert the parse into a flat one and
#   pass it back through the converter. This leads to launching additional
#   instances of Java that will slow things down. You will need to address
#   this if you want this script to be a part of a large-scale pipeline and
#   the converter won't give you much information on which sentence that
#   failed.

set -e

SCRIPT_DIR=`dirname "$0"`
TLS_DIR=${SCRIPT_DIR}/../tls
STANFORD_PARSER_DIR=${TLS_DIR}/ext/stanford-parser
FLATPARSER_PATH=${TLS_DIR}/flatparser.py

# Default to basic dependencies
TYPE_ARG=-basic

ARGS=`getopt c $*`

while true
do
    case "$1" in
        -c)
            TYPE_ARG=-CCprocessed
            shift;
            ;;
        *)
            break;
            ;;
    esac
done

LINE_NUM=1
while read LINE
do
    while true
    do
        set +e
        SDEP_DATA=`echo "${LINE}" \
            | java -cp "${STANFORD_PARSER_DIR}/*" \
                edu.stanford.nlp.trees.EnglishGrammaticalStructure \
                ${TYPE_ARG} -keepPunct -treeFile /dev/stdin`
        set -e
        if [ -n "${SDEP_DATA}" ]
        then
            # Converted succesfully.
            echo "${SDEP_DATA}\n"
            break
        else
            # Conversion failed, flatten the parse and try again.
            echo -e "WARNING: Conversion error for line:\t${LINE_NUM}" 1>&2
            LINE=`echo "${LINE}" | ${FLATPARSER_PATH} -r`
        fi
    done
    LINE_NUM=`expr ${LINE_NUM} + 1`
done
