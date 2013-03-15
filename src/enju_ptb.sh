#!/usr/bin/env sh
#
# Parse input using Enju and convert it to PTB-format.
#
# Author:       Pontus Stenetorp    <pontus stenetorp se>
# Version:      2013-02-27

set -e

SCRIPT_DIR=`dirname "$0"`
TLS_DIR=${SCRIPT_DIR}/../tls
ENJU_DIR=${TLS_DIR}/ext/enju
STEPP_PATH=${ENJU_DIR}/bin/stepp
MEDLINE_MODEL_PATH=${ENJU_DIR}/share/stepp/models_medline
FLATPARSER_PATH=${TLS_DIR}/flatparser.py
TOKENISE_PATH=${TLS_DIR}/GTB-tokenize.pl

# Replace sentences that Enju failed to parse with a corresponding flat parse.
error_repl () {
    LINE_NUM=1
    while read LINE
    do
        LINE_START=`echo ${LINE} | cut -c -12`
        if [ "${LINE_START}" = '(TOP (error ' ]
        then
            echo "WARNING: Parse error for line:\t${LINE_NUM}" 1>&2
            # Note: A small oddity here is that Enju actually preserves the
            #   final punctuation mark when it has an error, but not upon
            #   success. We emulate the same behaviour and don't remove the
            #   final punctuation mark for the flat parses.
            LINE=`echo "${LINE}" | ${FLATPARSER_PATH} -t`
        fi
        echo "${LINE}"
        LINE_NUM=`expr ${LINE_NUM} + 1`
    done
}

# Note: We kill blank lines and leave no trace of them, this is consistent
#   with for example the Stanford Parser, but it breaks the converter.
# Note: We replace UNK (unknown) PoS-tags with NP, since NP is the majority
#   class and thus a feasible candidate.
sed '/^$/d' \
    | ${TOKENISE_PATH} \
    | ${ENJU_DIR}/enju -A -genia -xml \
        -t "${STEPP_PATH} -e -p -m ${MEDLINE_MODEL_PATH}" \
    | ${ENJU_DIR}/share/enju2ptb/convert -genia \
    | ${TLS_DIR}/postenju2ptb.prl \
    | sed -e 's|(UNK |(NP |g' \
    | error_repl
