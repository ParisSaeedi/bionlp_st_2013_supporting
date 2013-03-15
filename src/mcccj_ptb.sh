#!/usr/bin/env sh
#
# Parse input using the Charniak-Johnson (BLLIP) Parser with the McClosky
#   self-trained biomedical model.
#
# Note: The version of BLLIP that we use always returns a parse (unless it
#   crashes, which I haven't been able to make it do), thus there is no
#   recovery of failed parses in this script.
#
# Author:       Pontus Stenetorp    <pontus stenetorp se>
# Version:      2013-02-27

set -e

SCRIPT_DIR=`dirname "$0"`
TLS_DIR=${SCRIPT_DIR}/../tls
EXT_DIR=${TLS_DIR}/ext
BLLIP_DIR=${EXT_DIR}/bllip-parser
MODEL_DIR=${EXT_DIR}/biomodel
PARSEIT_PATH=${BLLIP_DIR}/first-stage/PARSE/parseIt
BESTPARSES_PATH=${BLLIP_DIR}/second-stage/programs/features/best-parses
FEATURES_PATH=${MODEL_DIR}/reranker/features.gz
WEIGHTS_PATH=${MODEL_DIR}/reranker/weights.gz
TOKENISE_PATH=${TLS_DIR}/GTB-tokenize.pl
RESTORE_PATH=${TLS_DIR}/restore-doublequotes.py

# We read all inital input to tokenise it both using the "broken" McCCJ-style
#   due to a bug in the model and using the standard tokenisation. This
#   enables us to work around the bug as a post-processing step.
TMP_DATA=`mktemp`
TMP_TOK=`mktemp`
trap 'rm -f "${TMP_DATA}" "${TMP_TOK}"' EXIT INT TERM HUP
# Note: We remove blank lines since the parser halts if it encounters them.
sed '/^$/d' > ${TMP_DATA}
cat "${TMP_DATA}" | ${TOKENISE_PATH} > ${TMP_TOK}
# Note: Inserting sentence markers on the format:
#   "<s> ${SENTENCE} </s>" Do note the space preceeding the opening tag and
#   the space preceeding the closing tag. Without these you won't get any
#   output. Nor is any error or warning invoked, so much for XML.
cat "${TMP_DATA}" \
    | ${TOKENISE_PATH} -mccc \
    | sed -e 's|^|<s> |g' -e 's|$| </s>|g' \
    | ${PARSEIT_PATH} -K -l399 -N50 ${MODEL_DIR}/parser/ \
    | ${BESTPARSES_PATH} -l ${FEATURES_PATH} ${WEIGHTS_PATH} \
    | ${RESTORE_PATH} ${TMP_TOK}
rm -f "${TMP_DATA}" "${TMP_TOK}"
